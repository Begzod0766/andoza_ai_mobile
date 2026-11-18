import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/studio_webview_screen.dart';

// The debug log of where the Studio WebView goes (mobile QA 2026-11-18: a new
// kitchen once opened at the finished room). It shows the stage and the app
// flags, never a room id or a pin/furniture value.
void main() {
  test('ids and private values are left out, the stage and flags stay', () {
    expect(
      studioLogUrl(
        'https://andozaai.uz/studio/3f2b9c1e-1a2b-4c3d-8e9f-0a1b2c3d4e5f/ichkarida'
        '?phase=quvurlar&app=1&lang=ru&ai_pin=https%3A%2F%2Fpin.it%2Fx&place=42',
      ),
      '/studio/:id/ichkarida?phase=quvurlar&app=1&lang=ru&ai_pin=…&place=…',
    );
    expect(studioLogUrl('https://andozaai.uz/login'), '/login');
    expect(studioLogUrl('https://andozaai.uz/studio/12345678/smeta'), '/studio/:id/smeta');
    expect(studioLogUrl(null), '?');
  });
}
