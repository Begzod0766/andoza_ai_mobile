import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_mapper.dart';

/// Asks for confirmation, deletes the account on the server and — on success —
/// tears the session down (same clear path as logout) so the router lands on
/// /login, with a "deleted" snackbar. Errors keep the dialog open.
///
/// For a [guest] it is "delete guest data": the same endpoint, a warning that
/// the rooms go, and no password (a guest has none).
Future<void> confirmAndDeleteAccount(
  BuildContext context,
  WidgetRef ref, {
  bool guest = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final notifier = ref.read(authStateProvider.notifier);
  final deleted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DeleteAccountDialog(guest: guest),
  );
  if (deleted != true) return;
  messenger.showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
  await notifier.completeAccountDeletion();
}

/// Pops `true` once the server accepted the deletion.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key, this.guest = false});

  final bool guest;

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .deleteAccount(password: widget.guest ? null : _password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = mapErrorWithServerDetail(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guest = widget.guest;
    return AlertDialog(
      title: Text(guest ? l10n.profileGuestDelete : l10n.deleteAccountTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guest ? l10n.guestDeleteConfirm : l10n.deleteAccountBody),
            if (!guest) ...[
              const SizedBox(height: DesignTokens.spacingMd),
              TextField(
                controller: _password,
                obscureText: true,
                enabled: !_sending,
                decoration: InputDecoration(
                  labelText: l10n.deleteAccountPasswordLabel,
                  helperText: l10n.deleteAccountPasswordHint,
                  helperMaxLines: 2,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: DesignTokens.spacingSm),
              Text(_error!, style: const TextStyle(color: DesignTokens.errorText)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _sending ? null : _submit,
          style: TextButton.styleFrom(foregroundColor: DesignTokens.errorRed),
          child: Text(guest ? l10n.actionDelete : l10n.profileMenuDeleteAccount),
        ),
      ],
    );
  }
}
