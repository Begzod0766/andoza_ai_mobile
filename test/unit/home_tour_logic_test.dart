import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_steps.dart';
import 'package:tamir_uy_mobile_flutter/features/tour/home_tour_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('not done by default, done after mark', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(isHomeTourDone(prefs), isFalse);
    await markHomeTourDone(prefs);
    expect(isHomeTourDone(prefs), isTrue);
    expect(prefs.getBool(homeTourDoneKey), isTrue);
  });

  test('interrupted tour (no mark) stays not done on re-read', () async {
    final prefs = await SharedPreferences.getInstance();
    final again = await SharedPreferences.getInstance();
    expect(isHomeTourDone(again), isFalse);
    expect(isHomeTourDone(prefs), isFalse);
  });

  test('steps with projects', () {
    expect(homeTourSteps(hasProjects: true), [
      HomeTourTarget.newProject,
      HomeTourTarget.resume,
      HomeTourTarget.estimate,
      HomeTourTarget.shop,
      HomeTourTarget.masters,
      HomeTourTarget.help,
    ]);
  });

  test('steps without projects', () {
    expect(homeTourSteps(hasProjects: false), [
      HomeTourTarget.newProject,
      HomeTourTarget.shop,
      HomeTourTarget.masters,
      HomeTourTarget.help,
    ]);
  });
}
