import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/utils/error_mapper.dart';

DioException _dio(DioExceptionType type, {int? statusCode, Object? error}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: statusCode),
  );
}

/// Captures both the raw [LogEvent]s and the fully rendered lines, so a test
/// can assert on the structured fields *and* on every character that would
/// actually reach the device log.
class _CapturingOutput extends LogOutput {
  final List<OutputEvent> events = [];
  final List<String> lines = [];

  @override
  void output(OutputEvent event) {
    events.add(event);
    lines.addAll(event.lines);
  }

  String get rendered => lines.join('\n');
}

void main() {
  group('mapErrorToMessage — DioException transport errors', () {
    test('connection timeout → timeout message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.connectionTimeout)),
        errorTimeout,
      );
    });

    test('send timeout → timeout message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.sendTimeout)),
        errorTimeout,
      );
    });

    test('receive timeout → timeout message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.receiveTimeout)),
        errorTimeout,
      );
    });

    test('connection error → no internet message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.connectionError)),
        errorNoInternet,
      );
    });

    test('bad certificate → server message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.badCertificate)),
        errorServer,
      );
    });

    test('cancel → generic message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.cancel)),
        errorGeneric,
      );
    });

    test('unknown wrapping a SocketException → no internet message', () {
      expect(
        mapErrorToMessage(
          _dio(DioExceptionType.unknown,
              error: const SocketException('no route')),
        ),
        errorNoInternet,
      );
    });

    test('unknown without a socket cause → generic message', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.unknown)),
        errorGeneric,
      );
    });
  });

  group('mapErrorToMessage — DioException bad responses', () {
    test('401 → session message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 401)),
        errorSession,
      );
    });

    test('403 → forbidden message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 403)),
        errorForbidden,
      );
    });

    test('404 → not found message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 404)),
        errorNotFound,
      );
    });

    test('500 → server message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 500)),
        errorServer,
      );
    });

    test('503 → server message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 503)),
        errorServer,
      );
    });

    test('400 client error → validation message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 400)),
        errorValidation,
      );
    });

    test('422 validation error → validation message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 422)),
        errorValidation,
      );
    });

    test('409 conflict → conflict message', () {
      expect(
        mapErrorToMessage(
            _dio(DioExceptionType.badResponse, statusCode: 409)),
        errorConflict,
      );
    });

    test('bad response with no status code → generic fallback', () {
      expect(
        mapErrorToMessage(_dio(DioExceptionType.badResponse)),
        errorGeneric,
      );
    });
  });

  group('mapErrorToMessage — ApiException wrapper', () {
    test('401 status → session message', () {
      expect(
        mapErrorToMessage(
            ApiException(message: 'Unauthorized', statusCode: 401)),
        errorSession,
      );
    });

    test('404 status → not found message', () {
      expect(
        mapErrorToMessage(ApiException(message: 'Not found', statusCode: 404)),
        errorNotFound,
      );
    });

    test('500 status → server message', () {
      expect(
        mapErrorToMessage(
            ApiException(message: 'Server error', statusCode: 500)),
        errorServer,
      );
    });

    test('no status but timeout message → timeout message', () {
      expect(
        mapErrorToMessage(ApiException(message: 'Connection timeout')),
        errorTimeout,
      );
    });

    test('no status but network message → no internet message', () {
      expect(
        mapErrorToMessage(ApiException(message: 'Network error: failed')),
        errorNoInternet,
      );
    });

    test('no status and unrecognised message → generic fallback', () {
      expect(
        mapErrorToMessage(ApiException(message: 'Something odd')),
        errorGeneric,
      );
    });
  });

  group('mapErrorToMessage — non-Dio errors', () {
    test('raw SocketException → no internet message', () {
      expect(
        mapErrorToMessage(const SocketException('down')),
        errorNoInternet,
      );
    });

    test('arbitrary exception → generic fallback', () {
      expect(mapErrorToMessage(Exception('boom')), errorGeneric);
    });

    test('null → generic fallback', () {
      expect(mapErrorToMessage(null), errorGeneric);
    });
  });

  group('mapErrorToMessage — diagnostics', () {
    late _CapturingOutput output;
    late Logger original;

    setUp(() {
      output = _CapturingOutput();
      original = errorMapperLogger;
      errorMapperLogger = Logger(
        filter: ProductionFilter(),
        printer: PrettyPrinter(colors: false, printEmojis: false),
        output: output,
      );
    });

    tearDown(() => errorMapperLogger = original);

    test('an unrecognised error reaches the logger with its type and message',
        () {
      // The regression that cost hours: a _TypeError from a null access_token
      // collapsed into errorGeneric with nothing written anywhere.
      final error = TypeError();
      expect(mapErrorToMessage(error), errorGeneric);

      expect(output.events, hasLength(1));
      expect(output.events.single.level, Level.error);
      expect(output.rendered, contains('${error.runtimeType}'));
      expect(output.rendered, contains(error.toString()));
    });

    test('an unrecognised exception message reaches the logger', () {
      expect(
        mapErrorToMessage(const FormatException('access_token was null')),
        errorGeneric,
      );

      expect(output.rendered, contains('FormatException'));
      expect(output.rendered, contains('access_token was null'));
    });

    test('a bare SocketException is not logged (offline is not a defect)', () {
      expect(mapErrorToMessage(const SocketException('down')), errorNoInternet);
      expect(output.events, isEmpty);
    });

    test('a DioException logs only enumerated safe fields — never credentials',
        () {
      // A real failed login: the password is in the request body, a bearer
      // token is in the headers, and the server echoed part of the payload
      // back in both the response body and the underlying error.
      const password = 'hunter2-PLAINTEXT-PASSWORD';
      const token = 'eyJhbGciOiJIUzI1NiJ9.SECRET-BEARER-TOKEN';
      const responseBody = 'CONFIDENTIAL-RESPONSE-BODY';
      final options = RequestOptions(
        path: '/auth/login',
        method: 'POST',
        data: {'username': 'rimefara', 'password': password},
        headers: {'Authorization': 'Bearer $token'},
      );
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        error: Exception('encode failed for {"password":"$password"}'),
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 401,
          data: {'detail': responseBody, 'echo': password},
        ),
      );

      expect(mapErrorToMessage(error), errorSession);

      final rendered = output.rendered;
      expect(rendered, isNot(contains(password)));
      expect(rendered, isNot(contains(token)));
      expect(rendered, isNot(contains('Authorization')));
      expect(rendered, isNot(contains(responseBody)));

      // Whitelist, not just blacklist: the logged message must be exactly the
      // enumerated-fields summary, so no future edit can widen it back into a
      // stringified exception that drags RequestOptions along.
      expect(
        output.events.single.origin.message,
        'DioException(badResponse) POST /auth/login → 401',
      );
      expect(output.events.single.origin.error, isNull);
    });

    test('an ApiException logs its status code but not its message/body', () {
      expect(
        mapErrorToMessage(
          ApiException(
            message: 'Unauthorized: CONFIDENTIAL-SERVER-DETAIL',
            statusCode: 401,
            response: {'detail': 'CONFIDENTIAL-RESPONSE-BODY'},
          ),
        ),
        errorSession,
      );

      expect(output.rendered, isNot(contains('CONFIDENTIAL')));
      expect(output.events.single.origin.message,
          'ApiException(statusCode: 401)');
    });
  });

  group('mapErrorWithServerDetail — the two shapes of a 422', () {
    test('a sentence from the server is shown as written', () {
      expect(
        mapErrorWithServerDetail(ApiException(
          message: 'Validation error',
          statusCode: 422,
          response: {'detail': "Noto'g'ri qiymat yuborildi."},
        )),
        "Noto'g'ri qiymat yuborildi.",
      );
    });

    test("pydantic's English field list keeps the generic text", () {
      expect(
        mapErrorWithServerDetail(ApiException(
          message: 'Validation error',
          statusCode: 422,
          response: {
            'detail': [
              {'loc': ['body', 'phone'], 'msg': 'Value error', 'type': 'value_error'},
            ],
          },
        )),
        errorValidation,
      );
    });

    test('a 415 says which file was refused', () {
      expect(
        mapErrorWithServerDetail(ApiException(
          message: 'Unsupported',
          statusCode: 415,
          response: {'detail': 'Fayl haqiqiy .glb emas'},
        )),
        'Fayl haqiqiy .glb emas',
      );
    });
  });
}
