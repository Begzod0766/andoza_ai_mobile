import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamir_uy_mobile_flutter/services/sign_in_history.dart';

void main() {
  test('a fresh install has not signed in before', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await SignInHistory().hasSignedInBefore(), isFalse);
  });

  test('marking sticks', () async {
    SharedPreferences.setMockInitialValues({});
    await SignInHistory().markSignedIn();
    expect(await SignInHistory().hasSignedInBefore(), isTrue);
  });

  // 1.0.2 and older had no history flag. Someone who signed out there and
  // then updated must still get the login screen, not a silent guest: those
  // builds wrote these keys only inside the signed-in shell.
  for (final legacy in ['tour.home.v1.done', 'push_prompt_answered']) {
    test('an update from a build that used the app ($legacy) counts', () async {
      SharedPreferences.setMockInitialValues({legacy: true});
      expect(await SignInHistory().hasSignedInBefore(), isTrue);
    });
  }

  test('the legacy check runs once: a guest seeing the tour later is no '
      'sign-in', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await SignInHistory().hasSignedInBefore(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour.home.v1.done', true);
    expect(await SignInHistory().hasSignedInBefore(), isFalse);
  });
}
