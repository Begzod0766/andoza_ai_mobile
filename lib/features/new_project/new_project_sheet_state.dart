import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the new-project ("+") sheet is open. The one source of truth for
/// the sheet in `AppShell`'s body and for the menu's circle sitting on "+".
/// Open it with `showNewProjectSheet(context)`; close it by setting false.
final newProjectSheetOpenProvider = StateProvider<bool>((ref) => false);

/// Marks the subtree of `AppShell` (menu and tab screens), so a caller can
/// tell whether the shell — and with it the sheet — is on screen around it.
/// Root-navigator screens (`/setup/summary`, `/onboarding/e8`, …) are not
/// inside it.
class AppShellScope extends InheritedWidget {
  const AppShellScope({required super.child, super.key});

  static bool isInside(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppShellScope>() != null;

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => false;
}
