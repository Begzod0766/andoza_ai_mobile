import 'package:tamir_uy_mobile_flutter/screens/studio/studio_webview_screen.dart';
import 'package:flutter_test/flutter_test.dart';

// Mobile QA 2026-11-18 (andoza_ai#318 on the phone): the app's own wizard
// opened a new bathroom at the finished room; the web wizard opens it at
// Quvurlar, the pipes laid before the plaster.
void main() {
  test('a new bathroom or kitchen opens at Quvurlar, other rooms at Suvoq', () {
    expect(newRoomStudioPhase('hammom'), 'quvurlar');
    expect(newRoomStudioPhase('oshxona'), 'quvurlar');
    expect(newRoomStudioPhase('yotoqxona'), 'suvoq');
    expect(newRoomStudioPhase('bolalar'), 'suvoq');
    expect(newRoomStudioPhase(null), 'suvoq');
  });

  test('the studio path carries the stage to open', () {
    expect(
      studioRoomPath('r1', phase: 'quvurlar'),
      '/studio/r1?phase=quvurlar',
    );
    expect(studioRoomPath('r1'), '/studio/r1');
  });
}
