import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_webview_screen.dart';
import 'package:tamir_uy_mobile_flutter/services/push_router.dart';
import 'package:tamir_uy_mobile_flutter/services/share_intent.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeAuth extends AuthNotifier {
  _FakeAuth() : super(_NoRepo());
  void set(AuthState s) => state = s;
}

const _signedIn = AuthAuthenticated(user: User(id: 'u1'), token: 't');
const _share = 'Check out this Pin! https://pin.it/AbCd12';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('findPinUrl (same rules as the web app)', () {
    test("takes the link out of the Pinterest app's share text", () {
      expect(findPinUrl(_share), 'https://pin.it/AbCd12');
      expect(
        findPinUrl('https://mx.pinterest.com/pin/516647388484185204/'),
        'https://mx.pinterest.com/pin/516647388484185204/',
      );
      expect(
        findPinUrl('see https://example.com and https://www.pinterest.co.uk/pin/1/'),
        'https://www.pinterest.co.uk/pin/1/',
      );
    });

    test('is null without a Pinterest https link', () {
      expect(findPinUrl('no link here'), isNull);
      expect(findPinUrl('http://pin.it/AbCd12'), isNull);
      expect(findPinUrl('https://notpinterest.com/pin/1/'), isNull);
    });

    test('is a first filter only: the server checks the host strictly', () {
      // Like the web app's regex, a host such as pinterest.evil.com passes
      // here; the backend's host list refuses it with a 422.
      expect(findPinUrl('https://pinterest.evil.com/pin/1/'), isNotNull);
    });
  });

  test('the studio path carries the pin for the web AI designer', () {
    expect(studioRoomPath('r1'), '/studio/r1');
    expect(studioRoomPath('r1', focus: true), '/studio/r1?focus=1');
    final path = studioRoomPath('r1', aiPin: 'https://pin.it/AbCd12');
    expect(Uri.parse(path).queryParameters['ai_pin'], 'https://pin.it/AbCd12');
    expect(sharePinRoute(_share), startsWith('/share/pin?text='));
    expect(Uri.parse(sharePinRoute(_share)).queryParameters['text'], _share);
  });

  group('ShareIntentHandler', () {
    test('signed in: the share screen opens at once', () {
      final auth = _FakeAuth()..set(_signedIn);
      final c = ProviderContainer(
        overrides: [authStateProvider.overrideWith((ref) => auth)],
      );
      addTearDown(c.dispose);
      final opened = <String>[];
      ShareIntentHandler(c.read, navigate: opened.add).open(_share);
      expect(opened, [sharePinRoute(_share)]);
      expect(c.read(pendingPushRouteProvider), isNull);
    });

    test('signed out: it waits for sign-in in the pending route', () {
      final auth = _FakeAuth();
      final c = ProviderContainer(
        overrides: [authStateProvider.overrideWith((ref) => auth)],
      );
      addTearDown(c.dispose);
      final opened = <String>[];
      ShareIntentHandler(c.read, navigate: opened.add).open(_share);
      expect(opened, isEmpty);
      expect(c.read(pendingPushRouteProvider), sharePinRoute(_share));
    });

    test('takes the share the app was started with', () async {
      const channel = MethodChannel('test/share');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        return call.method == 'take' ? _share : null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      final auth = _FakeAuth()..set(_signedIn);
      final c = ProviderContainer(
        overrides: [authStateProvider.overrideWith((ref) => auth)],
      );
      addTearDown(c.dispose);
      final opened = <String>[];
      await ShareIntentHandler(c.read, navigate: opened.add).attach(channel);
      expect(opened, [sharePinRoute(_share)]);
    });
  });
}
