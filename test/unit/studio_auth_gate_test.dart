import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_auth_gate.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_session.dart';
import 'package:tamir_uy_mobile_flutter/services/secure_storage.dart';

const _guestUser = User(id: 'g1', isGuest: true);

void main() {
  test('the channel name matches the web', () {
    expect(studioAuthGateChannel, 'AndozaAuthGate');
  });

  test('parses the feature', () {
    expect(authGateFeatureFromMessage('{"feature":"render"}'), 'render');
    expect(authGateFeatureFromMessage('open'), isNull);
    expect(authGateFeatureFromMessage('{"x":1}'), isNull);
    expect(authGateFeatureFromMessage('{"feature":3}'), isNull);
    expect(authGateFeatureFromMessage('[1]'), isNull);
  });

  test('seed carries is_guest', () {
    expect(studioAuthSeedJs(_guestUser), contains(r'\"is_guest\":true'));
    expect(studioAuthSeedJs(const User(id: 'u')),
        contains(r'\"is_guest\":false'));
  });

  group('onStudioAuthGate', () {
    late List<String> calls;
    late AuthState auth;

    Future<void> run(WidgetTester tester, String message,
        {required bool signedUp}) async {
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
        return TextButton(
          onPressed: () => onStudioAuthGate(
            context,
            message,
            readAuth: () => auth,
            storage: SecureStorageService(),
            runJavaScript: (js) async => calls.add('js:$js'),
            reopen: () async => calls.add('reopen'),
            showSheet: (context, {required feature}) async {
              calls.add('sheet:$feature');
              if (signedUp) {
                auth = const AuthAuthenticated(
                    user: User(id: 'u9'), token: 'new');
              }
              return signedUp;
            },
            seedCookies: (a, _) async => calls.add('cookies:${a.token}'),
          ),
          child: const Text('go'),
        );
      })));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
    }

    setUp(() {
      calls = [];
      auth = const AuthAuthenticated(user: _guestUser, token: 'guest');
    });

    testWidgets('success re-seeds and reopens the page', (tester) async {
      await run(tester, '{"feature":"ai_design"}', signedUp: true);
      // The seed carries a timestamp, so match its user rather than the text.
      expect(calls, [
        'sheet:ai_design',
        'cookies:new',
        allOf(
          startsWith("js:localStorage.setItem('uy-tamir-auth'"),
          contains(r'\"id\":\"u9\"'),
          contains(r'\"is_guest\":false'),
        ),
        'reopen',
      ]);
    });

    testWidgets('no re-seed after Later', (tester) async {
      await run(tester, '{"feature":"render"}', signedUp: false);
      expect(calls, ['sheet:render']);
    });

    testWidgets('a signed-up user gets no sheet', (tester) async {
      auth = const AuthAuthenticated(user: User(id: 'u9'), token: 'new');
      await run(tester, '{"feature":"render"}', signedUp: false);
      expect(calls, isEmpty);
    });

    testWidgets('a second message while the sheet is open is ignored',
        (tester) async {
      final sheet = Completer<bool>();
      var sheets = 0;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
        Future<void> post() => onStudioAuthGate(
              context,
              '{"feature":"render"}',
              readAuth: () => auth,
              storage: SecureStorageService(),
              runJavaScript: (_) async {},
              reopen: () async {},
              showSheet: (context, {required feature}) {
                sheets++;
                return sheet.future;
              },
              seedCookies: (_, _) async {},
            );
        return TextButton(
          onPressed: () {
            post();
            post();
          },
          child: const Text('go'),
        );
      })));
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(sheets, 1);
      sheet.complete(false);
      await tester.pumpAndSettle();
    });

    testWidgets('a malformed message shows nothing', (tester) async {
      await run(tester, 'hello', signedUp: true);
      expect(calls, isEmpty);
    });
  });
}
