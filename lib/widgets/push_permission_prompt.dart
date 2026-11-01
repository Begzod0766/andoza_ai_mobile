import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../services/firebase_setup.dart';
import '../services/push_permission.dart';

/// Set once the user answered the soft prompt ("Ha" or "Keyinroq").
const pushPromptAnsweredKey = 'push_prompt_answered';

Future<bool> shouldAskForPush(SharedPreferences prefs) async =>
    !(prefs.getBool(pushPromptAnsweredKey) ?? false);

/// Shows the soft "shall we notify you?" dialog once after [child] appears.
/// Does nothing without Firebase or when the permission is already granted.
class PushPermissionPrompt extends ConsumerStatefulWidget {
  const PushPermissionPrompt({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushPermissionPrompt> createState() =>
      _PushPermissionPromptState();
}

class _PushPermissionPromptState extends ConsumerState<PushPermissionPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAsk());
  }

  Future<void> _maybeAsk() async {
    if (!ref.read(firebaseReadyProvider)) return;
    final permission = ref.read(pushPermissionProvider);
    final prefs = await SharedPreferences.getInstance();
    if (!await shouldAskForPush(prefs)) return;
    if (await permission.isGranted()) return;
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final yes = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pushPromptTitle),
        content: Text(l10n.pushPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.pushPromptLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.pushPromptYes),
          ),
        ],
      ),
    );
    await prefs.setBool(pushPromptAnsweredKey, true);
    if (yes == true) await permission.request();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
