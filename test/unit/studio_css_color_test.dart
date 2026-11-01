import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_webview_screen.dart';

void main() {
  test('parseCssRgb reads rgb and rgba, quoted or not', () {
    expect(parseCssRgb('rgb(237, 227, 250)'), const Color(0xFFEDE3FA));
    expect(parseCssRgb('"rgba(15, 27, 42, 0.9)"'), const Color(0xFF0F1B2A));
  });

  test('parseCssRgb gives null for anything else', () {
    expect(parseCssRgb(''), isNull);
    expect(parseCssRgb('null'), isNull);
    expect(parseCssRgb('#ffffff'), isNull);
  });
}
