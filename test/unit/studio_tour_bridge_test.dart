import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_tour_bridge.dart';

void main() {
  test('channel name matches the web page (window.AndozaStudioTour)', () {
    expect(studioTourChannel, 'AndozaStudioTour');
  });

  test('open and closed messages map to the tour state', () {
    expect(studioTourOpenFromMessage('open'), isTrue);
    expect(studioTourOpenFromMessage('closed'), isFalse);
  });

  test('anything else is ignored', () {
    expect(studioTourOpenFromMessage(''), isNull);
    expect(studioTourOpenFromMessage('OPEN '), isNull);
    expect(studioTourOpenFromMessage('{"open":true}'), isNull);
  });

  test('skip script dispatches the event the page listens to', () {
    expect(studioTourSkipJs, contains("new Event('andoza:tour-skip')"));
    expect(studioTourSkipJs, contains('window.dispatchEvent'));
  });
}
