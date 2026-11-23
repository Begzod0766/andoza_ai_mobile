import 'package:flutter/material.dart';

/// A tap on empty space closes the keyboard. iOS number and phone pads have
/// no return key, so without this a phone or ceiling field could not be
/// dismissed and kept the buttons under it hidden. Taps on controls still go
/// to the controls: they win the gesture arena.
///
/// Wraps the whole app (`MaterialApp.builder`). Its tap recognizer joins the
/// arena of every touch, so a native view under it (the Studio WebView) must
/// claim its touches eagerly — see `EagerWebView`.
class DismissKeyboardOnTap extends StatelessWidget {
  const DismissKeyboardOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      );
}
