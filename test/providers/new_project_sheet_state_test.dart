import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/features/new_project/new_project_sheet_state.dart';
import 'package:tamir_uy_mobile_flutter/models/user_model.dart';
import 'package:tamir_uy_mobile_flutter/providers/auth_provider.dart';
import 'package:tamir_uy_mobile_flutter/repositories/auth_repository.dart';

class _NoRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeAuth extends AuthNotifier {
  _FakeAuth() : super(_NoRepo());
  void set(AuthState s) => state = s;
}

const _signedIn = AuthAuthenticated(
  user: User(id: 'u1'),
  token: 't',
);

void main() {
  late _FakeAuth auth;
  late ProviderContainer container;

  setUp(() {
    auth = _FakeAuth()..set(_signedIn);
    container = ProviderContainer(
      overrides: [authStateProvider.overrideWith((ref) => auth)],
    );
    container.read(newProjectSheetOpenProvider.notifier).state = true;
  });
  tearDown(() => container.dispose());

  test('signing out closes the new-project sheet', () {
    auth.set(const AuthInitial());
    expect(container.read(newProjectSheetOpenProvider), isFalse);
  });

  test('a token refresh keeps the sheet as it was', () {
    auth.set(
      const AuthAuthenticated(
        user: User(id: 'u1'),
        token: 't2',
      ),
    );
    expect(container.read(newProjectSheetOpenProvider), isTrue);
  });
}
