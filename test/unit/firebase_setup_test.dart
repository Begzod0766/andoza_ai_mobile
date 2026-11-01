import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/services/firebase_setup.dart';

void main() {
  test('initFirebase returns false when initializeApp throws', () async {
    final ok = await initFirebase(
      initializeApp: () async => throw Exception('no config'),
    );
    expect(ok, isFalse);
  });

  test('telemetry is off outside release', () {
    expect(telemetryEnabled(release: false), isFalse);
    expect(telemetryEnabled(release: true), isTrue);
  });
}
