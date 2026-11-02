import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/l10n/app_localizations.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/profile/delete_account_dialog.dart';
import 'package:tamir_uy_mobile_flutter/services/api_client.dart';
import 'package:tamir_uy_mobile_flutter/services/secure_storage.dart';
import 'package:tamir_uy_mobile_flutter/utils/error_mapper.dart';

import '../support/localized_pump.dart';

class _Adapter implements HttpClientAdapter {
  RequestOptions? last;
  int status = 204;
  Object? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeRepo implements AuthRepository {
  _FakeRepo({this.error});
  final Object? error;
  final calls = <String?>[];
  int cleared = 0;

  @override
  Future<void> deleteAccount({String? password}) async {
    calls.add(password);
    if (error != null) throw error!;
  }

  @override
  Future<void> clearSession() async => cleared++;

  @override
  dynamic noSuchMethod(Invocation i) => null;
}

void main() {
  group('AuthRepositoryImpl.deleteAccount', () {
    late _Adapter adapter;
    late AuthRepositoryImpl repo;

    setUp(() {
      adapter = _Adapter();
      final client = ApiClient(baseUrl: 'http://test.local/api/v1');
      client.httpDioForTest.httpClientAdapter = adapter;
      repo = AuthRepositoryImpl(client, SecureStorageService());
    });

    test('posts the password to /auth/delete-account', () async {
      await repo.deleteAccount(password: 'secret');
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, endsWith('/auth/delete-account'));
      expect(adapter.last!.data, {'password': 'secret'});
    });

    test('sends a null password when empty or absent', () async {
      await repo.deleteAccount(password: '');
      expect(adapter.last!.data, {'password': null});
      await repo.deleteAccount();
      expect(adapter.last!.data, {'password': null});
    });

    test('403 surfaces the server detail', () async {
      adapter
        ..status = 403
        ..body = {'detail': "Parol noto'g'ri"};
      try {
        await repo.deleteAccount(password: 'x');
        fail('should throw');
      } catch (e) {
        expect(mapErrorWithServerDetail(e), "Parol noto'g'ri");
      }
    });
  });

  group('delete account dialog', () {
    Future<_FakeRepo> open(
      WidgetTester tester,
      _FakeRepo repo, {
      List<bool?>? result,
    }) async {
      result ??= <bool?>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: wrapLocalized(
            Builder(
              builder: (c) => TextButton(
                onPressed: () async => result!.add(
                  await showDialog<bool>(
                    context: c,
                    builder: (_) => const DeleteAccountDialog(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
            withProviderScope: false,
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('cancel does nothing', (tester) async {
      final repo = _FakeRepo();
      final result = <bool?>[];
      await open(tester, repo, result: result);
      await tester.tap(find.text('Bekor qilish'));
      await tester.pumpAndSettle();
      expect(repo.calls, isEmpty);
      expect(result, [false]);
      expect(find.byType(DeleteAccountDialog), findsNothing);
    });

    testWidgets('confirm calls deleteAccount and closes with true', (
      tester,
    ) async {
      final repo = _FakeRepo();
      final result = <bool?>[];
      await open(tester, repo, result: result);
      await tester.enterText(find.byType(TextField), 'pw');
      await tester.tap(find.widgetWithText(TextButton, "Hisobni o'chirish"));
      await tester.pumpAndSettle();
      expect(repo.calls, ['pw']);
      expect(result, [true]);
    });

    testWidgets('error stays open and shows the detail', (tester) async {
      final repo = _FakeRepo(
        error: ApiException(
          message: 'x',
          statusCode: 403,
          response: {'detail': "Parol noto'g'ri"},
        ),
      );
      await open(tester, repo);
      await tester.tap(find.widgetWithText(TextButton, "Hisobni o'chirish"));
      await tester.pumpAndSettle();
      expect(find.byType(DeleteAccountDialog), findsOneWidget);
      expect(find.text("Parol noto'g'ri"), findsOneWidget);
    });
  });

  test(
    'completeAccountDeletion clears the session and unauthenticates',
    () async {
      final repo = _FakeRepo();
      final n = AuthNotifier(repo);
      n.state = const AuthAuthenticated(
        user: User(id: 'u'),
        token: 't',
      );
      await n.completeAccountDeletion();
      expect(repo.cleared, 1);
      expect(n.state, isA<AuthInitial>());
    },
  );

  test('the password hint tells Google and Apple users to leave it empty too', () {
    for (final code in ['uz', 'ru', 'en']) {
      final hint = lookupAppLocalizations(Locale(code)).deleteAccountPasswordHint;
      expect(hint, contains('Google'), reason: code);
      expect(hint, contains('Apple'), reason: code);
    }
  });
}
