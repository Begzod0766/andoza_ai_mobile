import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamir_uy_mobile_flutter/screens/studio/eager_web_view.dart';
import 'package:tamir_uy_mobile_flutter/widgets/common/dismiss_keyboard_on_tap.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Records the pointer events Flutter hands to the native view — the same
/// path an Android/iOS WebView gets its touches through.
class _RecordingViewController extends PlatformViewController {
  final events = <PointerEvent>[];
  @override
  int get viewId => 1;
  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async => events.add(event);
  @override
  Future<void> clearFocus() async {}
  @override
  Future<void> dispose() async {}
}

final _view = _RecordingViewController();

class _FakeController extends PlatformWebViewController {
  _FakeController(super.params) : super.implementation();
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Builds a real platform-view surface with whatever gesture recognizers the
/// app passes, so the gesture arena behaves as on a device.
class _FakeWidget extends PlatformWebViewWidget {
  _FakeWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => PlatformViewSurface(
        controller: _view,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        gestureRecognizers: params.gestureRecognizers,
      );
}

class _FakePlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) =>
      _FakeController(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) =>
      _FakeWidget(params);
}

void main() {
  setUp(() {
    WebViewPlatform.instance = _FakePlatform();
    _view.events.clear();
  });

  Widget app(Widget home) => MaterialApp(
        builder: (context, child) => DismissKeyboardOnTap(child: child!),
        home: home,
      );

  testWidgets(
      'under the app-wide keyboard dismiss, a held finger reaches the WebView '
      'before it lifts (long press can fire)', (tester) async {
    final controller = WebViewController();
    await tester.pumpWidget(app(Scaffold(body: EagerWebView(controller: controller))));

    final gesture = await tester.startGesture(tester.getCenter(find.byType(EagerWebView)));
    await tester.pump(const Duration(seconds: 1));
    expect(_view.events.whereType<PointerDownEvent>(), hasLength(1),
        reason: 'the page needs pointerdown while the finger is still down');

    // A small move goes through at once, not after the 18 px touch slop.
    await gesture.moveBy(const Offset(4, 0));
    await tester.pump();
    expect(_view.events.whereType<PointerMoveEvent>(), isNotEmpty);

    await gesture.up();
    await tester.pump();
    expect(_view.events.whereType<PointerUpEvent>(), hasLength(1));
  });

  testWidgets('a tap on empty space still closes the keyboard', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(app(Scaffold(
      body: Column(children: [
        TextField(focusNode: focus, keyboardType: TextInputType.phone),
        const Expanded(child: SizedBox.expand()),
      ]),
    )));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focus.hasFocus, isTrue);

    await tester.tapAt(const Offset(200, 500));
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });
}
