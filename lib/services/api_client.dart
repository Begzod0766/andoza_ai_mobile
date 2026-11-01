import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import 'sse_client.dart';

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.response});

  final String message;
  final int? statusCode;
  final dynamic response;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    this.onUnauthorized,
    this.onTokensRefreshed,
    this.onTokensCleared,
    this.language,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
  }) {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Tells the API this is a native client, not a browser. Without it the
        // server treats us as web and returns `access_token`/`refresh_token`
        // as null in the body — tokens go to HttpOnly cookies only, which a
        // Dart HTTP client has no jar for — and login fails on the null cast
        // in AuthResponse.fromJson. See `_is_native_client()` in the backend's
        // app/routers/auth.py.
        'X-Client-Type': 'mobile',
      },
    );
    _dio = Dio(baseOptions);

    // Bare client used to refresh the access token and to replay the original
    // request after a refresh. It has NO interceptors, so calling it never
    // re-enters the refresh flow (no 401 loop, no QueuedInterceptor deadlock).
    _refreshDio = Dio(baseOptions);

    // Order matters. The refresh interceptor goes first so that when it
    // successfully refreshes + replays a 401'd request it can `resolve` the
    // error before the auth interceptor's `onUnauthorized` would fire. Auth
    // second (attaches the bearer token before logging). Logging last.
    _dio.interceptors.add(_buildRefreshInterceptor());
    _dio.interceptors.add(_AuthInterceptor(() => _authToken, onUnauthorized));
    if (language != null) _dio.interceptors.add(_LanguageInterceptor(language!));
    // Logging never runs in release, and only when explicitly enabled in debug —
    // it logs methods/paths/status only, never request/response bodies.
    if (kDebugMode && AppConfig.debugLogging) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
  }

  late final Dio _dio;
  late final Dio _refreshDio;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Invoked whenever the backend answers 401, so the app can drop to the
  /// login screen from a single place instead of every call site.
  final void Function()? onUnauthorized;

  /// Invoked after a successful silent token refresh so the app can persist the
  /// rotated tokens (the backend rotates the refresh token on every refresh).
  final Future<void> Function(String accessToken, String? refreshToken)?
      onTokensRefreshed;

  /// Invoked when a refresh attempt fails, so the app can drop the now-dead
  /// persisted tokens.
  final Future<void> Function()? onTokensCleared;

  /// The app's language code (uz/ru/en), sent as `Accept-Language` on every
  /// request so the server answers (e.g. its error messages) in it.
  final String Function()? language;

  String? _authToken;
  String? _refreshToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
  }

  /// Seeds the refresh token (from login response or restored from storage) so
  /// the refresh interceptor can use it when the access token expires.
  void setRefreshToken(String token) {
    _refreshToken = token;
  }

  /// Auth endpoints must never trigger a refresh-and-retry: a 401 from these is
  /// terminal (bad credentials / already-invalid refresh token), and retrying
  /// would loop.
  static const _authPaths = <String>{
    '/auth/login',
    '/auth/refresh',
    '/auth/logout',
    '/auth/otp/request',
    '/auth/otp/verify',
    '/auth/register',
    '/auth/google',
  };

  static bool _isAuthPath(String path) =>
      _authPaths.any((p) => path == p || path.endsWith(p));

  /// Serialized (QueuedInterceptorsWrapper) so that N concurrent 401s trigger a
  /// single refresh: the first error runs the refresh, the rest wait behind it
  /// in the queue and — because the tokens are already fresh by the time they
  /// run — succeed on their own retry.
  QueuedInterceptorsWrapper _buildRefreshInterceptor() {
    return QueuedInterceptorsWrapper(
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        final requestOptions = err.requestOptions;
        final alreadyRetried = requestOptions.extra['__retried'] == true;

        if (err.response?.statusCode != 401 ||
            _isAuthPath(requestOptions.path) ||
            alreadyRetried) {
          handler.next(err);
          return;
        }

        final refreshToken = _refreshToken;
        if (refreshToken == null || refreshToken.isEmpty) {
          handler.next(err);
          return;
        }

        // Concurrency: because errors are queued, a sibling request may have
        // already refreshed the token by the time this one is processed. If the
        // bearer this request was sent with is no longer the current token, the
        // refresh already happened — just replay with the current token instead
        // of refreshing again (so N concurrent 401s => a single refresh).
        final currentBearer =
            _authToken != null ? 'Bearer $_authToken' : null;
        if (currentBearer != null &&
            requestOptions.headers['Authorization'] != currentBearer) {
          try {
            requestOptions.extra['__retried'] = true;
            requestOptions.headers['Authorization'] = currentBearer;
            final retried = await _refreshDio.fetch<dynamic>(requestOptions);
            handler.resolve(retried);
          } catch (_) {
            handler.next(err);
          }
          return;
        }

        try {
          // The backend only accepts the refresh token via the `refresh_token`
          // cookie header — not as a body field or bearer token.
          final refreshResponse = await _refreshDio.post<dynamic>(
            '/auth/refresh',
            options: Options(
              headers: {'Cookie': 'refresh_token=$refreshToken'},
            ),
          );
          final data = refreshResponse.data;
          final newAccess = data is Map<String, dynamic>
              ? data['access_token'] as String?
              : null;
          if (newAccess == null || newAccess.isEmpty) {
            await _handleRefreshFailure();
            handler.next(err);
            return;
          }
          final newRefresh = (data['refresh_token'] as String?) ?? refreshToken;

          _authToken = newAccess;
          _refreshToken = newRefresh;
          await onTokensRefreshed?.call(newAccess, newRefresh);

          // Replay the original request through the bare client with the fresh
          // bearer. `__retried` guards against a second refresh if it 401s
          // again; using `_refreshDio` also keeps it out of this interceptor.
          requestOptions.extra['__retried'] = true;
          requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retried = await _refreshDio.fetch<dynamic>(requestOptions);
          handler.resolve(retried);
        } catch (_) {
          await _handleRefreshFailure();
          handler.next(err);
        }
      },
    );
  }

  Future<void> _handleRefreshFailure() async {
    _authToken = null;
    _refreshToken = null;
    await onTokensCleared?.call();
  }

  /// The main Dio (with interceptors). Exposed only so tests can swap in a fake
  /// [HttpClientAdapter].
  @visibleForTesting
  Dio get httpDioForTest => _dio;

  /// The bare Dio used for refresh + replay. Exposed only so tests can swap in a
  /// fake [HttpClientAdapter].
  @visibleForTesting
  Dio get refreshDioForTest => _refreshDio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    required dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.put<dynamic>(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    required dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> delete(String path, {dynamic data}) async {
    try {
      await _dio.delete<dynamic>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Uploads a file as `multipart/form-data` under the field [fieldName].
  /// [bytes] + [filename] describe the file; dio sets the multipart content
  /// type (with boundary) automatically. Used for wallpaper image uploads.
  Future<T> uploadFile<T>(
    String path, {
    required List<int> bytes,
    required String filename,
    String fieldName = 'file',
    String? contentType,
    Map<String, String> fields = const {},
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        fieldName: MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: contentType == null
              ? null
              : DioMediaType.parse(contentType),
        ),
      });
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Like [uploadFile] but for several files in one `multipart/form-data`
  /// request; each entry is `(fieldName, bytes, filename, contentType)`.
  Future<T> uploadFiles<T>(
    String path, {
    required List<(String, List<int>, String, String)> files,
    Map<String, String> fields = const {},
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        for (final f in files)
          f.$1: MultipartFile.fromBytes(f.$2, filename: f.$3, contentType: DioMediaType.parse(f.$4)),
      });
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches a binary response (e.g. a generated PDF) as raw bytes. The auth
  /// token is attached via the interceptor like any other request.
  Future<List<int>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const <int>[];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Opens a Server-Sent Events stream (used by the AI builder). Yields one
  /// [SseEvent] per server event until the response completes or the
  /// subscription is cancelled. The auth token is attached via the interceptor
  /// just like any other request.
  Stream<SseEvent> stream(
    String path, {
    String method = 'POST',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async* {
    // Own a token when the caller didn't supply one, so we can abort the
    // underlying HTTP connection if the subscription is cancelled (otherwise dio
    // keeps the SSE socket open until the server finishes).
    final token = cancelToken ?? CancelToken();
    try {
      final response = await _dio.request<ResponseBody>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: token,
        options: Options(
          method: method,
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // SSE connections are long-lived; don't time out mid-stream.
          receiveTimeout: Duration.zero,
        ),
      );
      final body = response.data;
      if (body == null) return;
      yield* parseSseStream(body.stream.cast<List<int>>());
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      // Runs when the stream completes OR the subscription is cancelled — either
      // way, tear down the connection.
      if (!token.isCancelled) token.cancel();
    }
  }

  ApiException _handleDioError(DioException error) {
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout',
      DioExceptionType.sendTimeout => 'Send timeout',
      DioExceptionType.receiveTimeout => 'Receive timeout',
      DioExceptionType.badResponse => _handleBadResponse(error),
      DioExceptionType.badCertificate => 'Bad SSL certificate',
      _ => 'Network error: ${error.message}',
    };

    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
      response: error.response?.data,
    );
  }

  String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final errorMessage = _extractErrorMessage(error.response?.data);

    return switch (statusCode) {
      400 => 'Bad request: $errorMessage',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not found',
      409 => 'Conflict: $errorMessage',
      422 => 'Validation error: $errorMessage',
      500 => 'Server error',
      _ => 'HTTP $statusCode: $errorMessage',
    };
  }

  /// FastAPI returns errors as `{"detail": "..."}` or, for validation
  /// failures, `{"detail": [{"msg": "...", "loc": [...]}, ...]}`. Fall back to
  /// the older `message`/`error` keys for anything non-FastAPI.
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return detail.join(', ');
      }
      if (detail != null) return detail.toString();
    }
    return 'Unknown error';
  }
}

/// Attaches the bearer token to every outgoing request and routes 401s to a
/// single [onUnauthorized] callback.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenGetter, this._onUnauthorized);

  final String? Function() _tokenGetter;
  final void Function()? _onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Only fire for a genuine authenticated-session 401. Auth-path 401s (a
    // failed login / dead refresh) are terminal and must not force-navigate.
    if (err.response?.statusCode == 401 &&
        !ApiClient._isAuthPath(err.requestOptions.path)) {
      _onUnauthorized?.call();
    }
    handler.next(err);
  }
}

class _LanguageInterceptor extends Interceptor {
  _LanguageInterceptor(this._language);

  final String Function() _language;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _language();
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  static final _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
      'REQUEST: ${options.method} ${options.path}',
      error: options.queryParameters.isEmpty
          ? null
          : 'Query: ${options.queryParameters}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      'RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'ERROR: ${err.requestOptions.path}',
      error: err.message,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
