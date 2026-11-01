import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/error_mapper.dart';
import 'report_repository.dart';

/// "Shikoyat qilish": pick a reason, optionally explain, send. Shows a
/// thank-you (or the error) as a snackbar once the sheet closes.
Future<void> showReportSheet(
  BuildContext context, {
  required ReportTarget target,
  required String targetId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: DesignTokens.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DesignTokens.radiusSheet),
      ),
    ),
    builder: (_) => ReportSheet(target: target, targetId: targetId),
  );
}

class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({required this.target, required this.targetId, super.key});

  final ReportTarget target;
  final String targetId;

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  ReportReason? _reason;
  final _details = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, ReportReason r) => switch (r) {
    ReportReason.spam => l10n.reportReasonSpam,
    ReportReason.inappropriate => l10n.reportReasonInappropriate,
    ReportReason.fraud => l10n.reportReasonFraud,
    ReportReason.other => l10n.reportReasonOther,
  };

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(reportRepositoryProvider)
          .report(
            target: widget.target,
            targetId: widget.targetId,
            reason: reason,
            details: _details.text,
          );
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.screenPaddingHorizontal,
        DesignTokens.spacingMd,
        DesignTokens.screenPaddingHorizontal,
        DesignTokens.spacingLg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reportTitle, style: DesignTokens.heading3),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(
              l10n.reportHint,
              style: DesignTokens.body2.copyWith(color: DesignTokens.textGray),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (r) {
                if (!_busy) setState(() => _reason = r);
              },
              child: Column(
                children: [
                  for (final r in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: r,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_label(l10n, r)),
                    ),
                ],
              ),
            ),
            TextField(
              controller: _details,
              enabled: !_busy,
              maxLength: 1000,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(labelText: l10n.reportDetails),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            FilledButton(
              onPressed: _reason == null || _busy ? null : _send,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.reportSend),
            ),
          ],
        ),
      ),
    );
  }
}
