import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/secure_storage.dart';

abstract interface class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  /// Exchanges a Google ID token (from Google Sign-In, minted for our web
  /// client id) for an andoza session via `POST /auth/google`. Same response
  /// and persistence as [login].
  Future<AuthResponse> loginWithGoogle(String idToken);

  /// Exchanges an Apple identity token for an andoza session via
  /// `POST /auth/apple`. [name] is sent only when Apple shared it (first
  /// authorization); the server keeps it for a new account only.
  Future<AuthResponse> loginWithApple(String identityToken, {String? name});
  Future<void> requestOtp(String phone);
  Future<AuthResponse> verifyOtp(String phone, String code);
  Future<AuthResponse> register(String username, String password, String? name);
  Future<void> logout();

  /// Permanently deletes the signed-in account (`POST /auth/delete-account`).
  /// [password] is omitted from the body when null/empty (phone-code accounts
  /// have none). Throws [ApiException] on failure; does NOT clear the local
  /// session — the caller does that via [clearSession] after success.
  Future<void> deleteAccount({String? password});

  /// Local-only session teardown: drops the cached + persisted tokens and the
  /// in-memory ApiClient token, WITHOUT calling the server (used when the
  /// session is already dead, e.g. a 401 with no usable refresh token). Shares
  /// the exact clear path [logout] uses so no key is left orphaned.
  Future<void> clearSession();

  Future<User?> getCurrentUser();
  Future<void> restoreToken();
  String? get token;

  /// The last known user — set from a successful auth call, a `/auth/me`
  /// fetch, or (minimally, id-only) restored from storage on cold start. Lets
  /// the notifier keep an optimistic authenticated session on a transient
  /// backend failure instead of discarding a still-valid stored token.
  User? get cachedUser;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._storage, {this.language});

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  /// The app language, sent when an account may be created (register, Google,
  /// Apple) so a new account starts in it. The server ignores it for an
  /// existing account.
  final String Function()? language;
  String? _cachedToken;
  User? _cachedUser;

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'username': email, 'password': password},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponse.fromJson(response);
      await _persistSession(authResponse);
      return authResponse;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'id_token': idToken, 'language': ?language?.call()},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final authResponse = AuthResponse.fromJson(response);
      await _persistSession(authResponse);
      return authResponse;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<AuthResponse> loginWithApple(String identityToken, {String? name}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/apple',
        data: {'identity_token': identityToken, 'name': ?name, 'language': ?language?.call()},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final authResponse = AuthResponse.fromJson(response);
      await _persistSession(authResponse);
      return authResponse;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    }
  }

  /// Persist an authenticated session (access + refresh tokens) so silent
  /// refresh-on-401 works. Shared by login / Google / OTP verify / register.
  Future<void> _persistSession(AuthResponse authResponse) async {
    _cachedToken = authResponse.token;
    _cachedUser = authResponse.user;
    await _storage.saveToken(authResponse.token);
    await _storage.saveUserId(authResponse.user.id);
    _apiClient.setAuthToken(authResponse.token);
    final refreshToken = authResponse.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(refreshToken);
      _apiClient.setRefreshToken(refreshToken);
    }
  }

  @override
  Future<void> requestOtp(String phone) async {
    try {
      await _apiClient.post<void>(
        '/auth/otp/request',
        data: {'phone': phone},
        fromJson: (_) {},
      );
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String code) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {'phone': phone, 'code': code},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final authResponse = AuthResponse.fromJson(response);
      await _persistSession(authResponse);
      return authResponse;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<AuthResponse> register(String username, String password, String? name) async {
    try {
      final data = <String, dynamic>{'username': username, 'password': password};
      if (name != null && name.isNotEmpty) data['name'] = name;
      final appLanguage = language?.call();
      if (appLanguage != null) data['language'] = appLanguage;
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: data,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final authResponse = AuthResponse.fromJson(response);
      await _persistSession(authResponse);
      return authResponse;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post<void>('/auth/logout', data: {}, fromJson: (_) {});
    } on ApiException {
      // Ignore logout errors
    } finally {
      await clearSession();
    }
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    // ApiException propagates unwrapped so mapErrorWithServerDetail can show
    // the server's own (Uzbek) 403 detail.
    await _apiClient.post<void>(
      '/auth/delete-account',
      data: {'password': (password == null || password.isEmpty) ? null : password},
      fromJson: (_) {},
    );
  }

  @override
  Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUser = null;
    await _storage.clear();
    _apiClient.clearAuthToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_cachedToken == null) return null;

    try {
      final user = await _apiClient.get<User>(
        '/auth/me',
        fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
      );
      _cachedUser = user;
      return user;
    } on ApiException catch (e) {
      // A real 401 means the session is genuinely invalid → report it (null) so
      // the caller tears the session down. Any other failure (offline / timeout
      // / 5xx) is transient → rethrow so the caller can keep the stored session
      // optimistically instead of bouncing the user to /login.
      if (e.statusCode == 401) return null;
      rethrow;
    }
  }

  @override
  Future<void> restoreToken() async {
    final token = await _storage.getToken();
    if (token != null) {
      _cachedToken = token;
      _apiClient.setAuthToken(token);
      // Rebuild a minimal (id-only) user from the persisted user id so a
      // transient /auth/me failure at cold start can still present an
      // optimistic authenticated session rather than a forced logout. It's
      // overwritten with the full user as soon as /auth/me succeeds.
      final userId = await _storage.getUserId();
      if (userId != null) {
        _cachedUser = User(id: userId);
      }
    }
    // Also restore the refresh token so an expired access token can be
    // refreshed on the first 401 after an app restart.
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      _apiClient.setRefreshToken(refreshToken);
    }
  }

  bool get isAuthenticated => _cachedToken != null;

  @override
  String? get token => _cachedToken;

  @override
  User? get cachedUser => _cachedUser;
}

class AuthException implements Exception {
  AuthException(this.message, {this.statusCode});
  final String message;

  /// The originating HTTP status (from [ApiException]), preserved so callers can
  /// classify reliably (401 = bad credentials, 409 = username taken) instead of
  /// substring-matching the message.
  final int? statusCode;

  @override
  String toString() => message;
}
