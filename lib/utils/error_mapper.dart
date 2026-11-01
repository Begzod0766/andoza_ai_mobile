import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../services/api_client.dart';

/// Centralized, single-source-of-truth error → user-message mapping.
///
/// Turns any thrown error — especially a [DioException] (timeout, no
/// connection, 4xx/5xx) or the app's own [ApiException] wrapper — into a short,
/// user-friendly **Uzbek** message safe to show in an [ErrorView], a snackbar
/// or an inline banner. It never leaks a raw exception/stack string to the UI.
///
/// Covered cases: no internet / connection, timeout, 400/422 (validation),
/// 401 (session expired), 403 (forbidden), 404 (not found), 409 (conflict),
/// 5xx / server, and a generic fallback for everything else.
String mapErrorToMessage(Object? error) {
  if (error is DioException) {
    // One compact line per transport/HTTP failure. Only fields that are safe
    // by construction — never the object itself: DioException.toString()
    // embeds RequestOptions, i.e. the login body (plaintext password) and the
    // Authorization header. No stack trace: a Dio failure's stack points at
    // Dio's own construction site, so it would be noise on every 4xx.
    errorMapperLogger.w(_describeDio(error));
    return _mapDio(error);
  }
  if (error is ApiException) {
    // Status code only: ApiException.message (and toString()) can embed the
    // server's response body via ApiClient._extractErrorMessage, and
    // .response holds the raw body outright.
    errorMapperLogger.w(
      'ApiException(statusCode: ${error.statusCode ?? '-'})',
    );
    return _mapApiException(error);
  }
  // A bare SocketException means "offline", which the returned message already
  // says and the user already knows. Logging every one would be pure noise.
  if (error is SocketException) return errorNoInternet;
  // The fallback is the loud one. A login outage once cost hours of
  // print()-patching and rebuilds because a `_TypeError` ("type 'Null' is not
  // a subtype of type 'String' in type cast", from a server that had started
  // returning a null access_token) died here and reached the user as nothing
  // but errorGeneric. A parse failure, a platform-channel failure and a null
  // dereference must not be indistinguishable in the logs too — this is why
  // the mapper is no longer a pure function.
  errorMapperLogger.e(
    'Unmapped error: ${error.runtimeType}',
    error: error?.toString(),
    stackTrace: error is Error ? error.stackTrace : null,
  );
  return errorGeneric;
}

/// Logger used for the diagnostics above.
///
/// Deliberately built with a [ProductionFilter] rather than the package
/// default ([DevelopmentFilter], which drops everything outside [kDebugMode]),
/// unlike `ApiClient`'s `_LoggingInterceptor` — that one is debug-gated
/// because it logs *every* request. This one only fires on failures and only
/// ever emits sanitised fields, and the incident it exists for happened on a
/// release build on a physical device, where a debug-only log is worth
/// nothing.
///
/// Replaceable so tests can capture what was written.
@visibleForTesting
Logger errorMapperLogger = Logger(filter: ProductionFilter());

/// Safe one-line summary of a [DioException] — explicitly enumerated fields,
/// never `toString()`. Carries no request body, no headers, no response body.
String _describeDio(DioException error) {
  final statusCode = error.response?.statusCode;
  return 'DioException(${error.type.name}) '
      '${error.requestOptions.method} ${error.requestOptions.path}'
      '${statusCode == null ? '' : ' → $statusCode'}';
}

/// "No internet / connection" — the device can't reach the network at all.
const String errorNoInternet = 'Internet aloqasi yo\'q. Ulanishni tekshiring.';

/// The request reached the network but the server didn't answer in time.
const String errorTimeout = 'Server javob bermadi. Qayta urinib ko\'ring.';

/// 400 / 422 — the request payload failed client-side / server-side validation.
const String errorValidation =
    'Kiritilgan ma\'lumotlar noto\'g\'ri. Tekshirib, qaytadan kiriting.';

/// 401 — the session is no longer valid; the user must re-authenticate.
const String errorSession = 'Sessiya tugadi. Iltimos, qaytadan kiring.';

/// 403 — authenticated, but not allowed to perform this action.
const String errorForbidden = 'Bu amalni bajarishga ruxsatingiz yo\'q.';

/// 404 — the requested resource doesn't exist.
const String errorNotFound = 'Ma\'lumot topilmadi.';

/// 409 — the request conflicts with the current server state.
const String errorConflict =
    'Ma\'lumotlarda ziddiyat yuz berdi. Iltimos, qaytadan urinib ko\'ring.';

/// 5xx / bad certificate — the server itself failed.
const String errorServer =
    'Serverda xatolik yuz berdi. Birozdan so\'ng urinib ko\'ring.';

/// Fallback for anything not otherwise recognised.
const String errorGeneric = 'Xatolik yuz berdi. Qayta urinib ko\'ring.';

String _mapDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return errorTimeout;
    case DioExceptionType.connectionError:
      return errorNoInternet;
    case DioExceptionType.badCertificate:
      return errorServer;
    case DioExceptionType.badResponse:
      return _mapStatus(error.response?.statusCode);
    case DioExceptionType.cancel:
      return errorGeneric;
    case DioExceptionType.unknown:
      if (error.error is SocketException) return errorNoInternet;
      return errorGeneric;
  }
}

/// [ApiException] (thrown by [ApiClient]) keeps the HTTP status code for
/// bad responses but flattens the [DioExceptionType] into a message string for
/// transport/timeout failures — so map by status code when present, otherwise
/// fall back to matching the known message markers the client produces.
String _mapApiException(ApiException error) {
  final statusCode = error.statusCode;
  if (statusCode != null) return _mapStatus(statusCode);
  final message = error.message.toLowerCase();
  if (message.contains('timeout')) return errorTimeout;
  if (message.contains('network') || message.contains('connection')) {
    return errorNoInternet;
  }
  if (message.contains('server')) return errorServer;
  return errorGeneric;
}

String _mapStatus(int? statusCode) {
  if (statusCode == null) return errorGeneric;
  if (statusCode == 400 || statusCode == 422) return errorValidation;
  if (statusCode == 401) return errorSession;
  if (statusCode == 403) return errorForbidden;
  if (statusCode == 404) return errorNotFound;
  if (statusCode == 409) return errorConflict;
  if (statusCode >= 500) return errorServer;
  return errorGeneric;
}

/// Like [mapErrorToMessage], but when the server explained a 400/403/409 itself
/// (FastAPI `{"detail": "..."}`, in Uzbek) that sentence is shown instead of
/// the generic status text — "which line was refused" beats "invalid data".
///
/// A 422 comes in two shapes: a plain sentence (a value the database refused,
/// "Noto'g'ri qiymat yuborildi.") is shown like the others; pydantic's list of
/// `{loc, msg, type}` is English and per-field, so it keeps the generic text.
String mapErrorWithServerDetail(Object? error) {
  if (error is ApiException &&
      (error.statusCode == 400 ||
          error.statusCode == 403 ||
          error.statusCode == 409 ||
          error.statusCode == 413 ||
          error.statusCode == 415 ||
          error.statusCode == 422 ||
          error.statusCode == 429)) {
    final body = error.response;
    final detail = body is Map ? body['detail'] : null;
    if (detail is String && detail.trim().isNotEmpty) return detail.trim();
  }
  return mapErrorToMessage(error);
}
