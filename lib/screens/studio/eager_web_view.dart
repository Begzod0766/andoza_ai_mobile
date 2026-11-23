import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A [WebViewWidget] that takes every touch the moment the finger lands.
///
/// The app-wide `DismissKeyboardOnTap` puts a tap recognizer into the
/// gesture arena of every touch. A native view only gets its pointer events
/// once it wins that arena, so with a still finger nothing reached the page
/// until the finger lifted: pointerdown and pointerup arrived together (the
/// Studio's long-press «O'chirish» never fired) and a drag started only after
/// the 18 px touch slop. The eager recognizer wins at once. The page handles
/// its own taps and inputs, so the Flutter unfocus tap is not needed over it.
class EagerWebView extends StatelessWidget {
  const EagerWebView({super.key, required this.controller});

  final WebViewController controller;

  static final gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
    Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
  };

  @override
  Widget build(BuildContext context) =>
      WebViewWidget(controller: controller, gestureRecognizers: gestureRecognizers);
}
