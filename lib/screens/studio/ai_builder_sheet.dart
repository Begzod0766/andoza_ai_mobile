import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../models/business_profile.dart';
import '../../providers/ai_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/estimate_api_provider.dart';
import '../../utils/error_mapper.dart';
import '../business/style_chips.dart';

/// The request sent for [prompt] with a chosen furniture [style] (an id from
/// [furnitureStyles]) put in front: "Hi-Tech uslubida. …". The style is named
/// as the backend names it (`ai_designer.STYLE_LABELS`), whatever the app
/// language, so the server can recognise it in the request (handoff §8, #36).
String styledPrompt(String prompt, String? style) {
  final name = style == null ? null : _stylePromptNames[style];
  return name == null ? prompt : '$name uslubida. $prompt';
}

const _stylePromptNames = {
  'neoklassika': 'Neoklassika',
  'klassik': 'Klassik',
  'zamonaviy': 'Zamonaviy',
  'hitech': 'Hi-Tech',
  'minimalist': 'Minimalist',
  'skandinav': 'Skandinav',
  'loft': 'Loft',
  'milliy': 'Milliy',
};

/// "AI dizayner" sheet: the user types a natural-language request, the backend
/// agent streams its reasoning + tool calls (SSE), and on completion proposes a
/// patch the user can Apply or Discard.
///
/// Requires a backend room id (the room must be persisted first — see the
/// room-persistence bridge). Real generation needs a valid LLM key configured
/// server-side; without it the stream emits an error, which this sheet shows.
class AiBuilderSheet extends ConsumerStatefulWidget {
  const AiBuilderSheet({required this.roomId, super.key});

  final String roomId;

  static Future<void> show(BuildContext context, String roomId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignTokens.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AiBuilderSheet(roomId: roomId),
    );
  }

  @override
  ConsumerState<AiBuilderSheet> createState() => _AiBuilderSheetState();
}

class _AiBuilderSheetState extends ConsumerState<AiBuilderSheet> {
  final _promptController = TextEditingController();
  final _log = <AiBuildEvent>[];
  StreamSubscription<AiBuildEvent>? _sub;
  bool _running = false;
  bool _applying = false;
  String? _style;
  AiDone? _result;
  String? _error;

  @override
  void dispose() {
    _sub?.cancel();
    _promptController.dispose();
    super.dispose();
  }

  void _start() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _running) return;
    setState(() {
      _running = true;
      _result = null;
      _error = null;
      _log.clear();
    });

    _sub = ref
        .read(aiRepositoryProvider)
        .build(widget.roomId, styledPrompt(prompt, _style))
        .listen(
      (event) {
        if (!mounted) return;
        setState(() {
          if (event is AiDone) {
            _result = event;
            _running = false;
          } else if (event is AiError) {
            _error = event.message;
            _running = false;
          } else if (event is! AiUnknown) {
            _log.add(event);
          }
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          // Never surface a raw exception/HTTP string to the user — map it to a
          // friendly localized message like every other error path.
          _error = mapErrorToMessage(e);
          _running = false;
        });
      },
      onDone: () {
        if (!mounted) return;
        if (_running) setState(() => _running = false);
      },
    );
  }

  /// Applies the parts of the patch that map to the room record: ceiling height
  /// and per-surface materials (the drivers of the smeta). Furniture/lights and
  /// wall-length changes are surfaced in the summary but persisted by their own
  /// flows / the 3D Studio, so they aren't written here.
  Future<void> _apply(AiPatch patch) async {
    setState(() => _applying = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(apartmentRepositoryProvider);
      final patchSurfaces = patch.surfaces;
      final hasRoomEdits = patch.ceilingH != null ||
          (patchSurfaces != null && patchSurfaces.isNotEmpty);
      if (hasRoomEdits) {
        // Merge the AI's surface picks into the room's existing surfaces (a bare
        // `surfaces:` on PATCH replaces the whole map, which would wipe walls
        // the user already painted). Only fetch/merge when surfaces change.
        Map<String, dynamic>? mergedSurfaces;
        if (patchSurfaces != null && patchSurfaces.isNotEmpty) {
          final current = await repo.getRoom(widget.roomId);
          mergedSurfaces = {...?current.surfaces, ...patchSurfaces};
        }
        await repo.updateRoom(
          widget.roomId,
          ceilingH: patch.ceilingH,
          surfaces: mergedSurfaces,
        );
        // Refresh the smeta/delta so the change is reflected.
        ref.invalidate(roomDeltaProvider(widget.roomId));
        ref.invalidate(estimatePreviewProvider(widget.roomId));
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.studioAiApplied)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.studioApplyFailed(mapErrorToMessage(e)))));
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.auto_awesome, color: DesignTokens.primaryBlue),
                const SizedBox(height: DesignTokens.spacingMd),
                TextField(
                  controller: _promptController,
                  minLines: 2,
                  maxLines: 4,
                  enabled: !_running,
                  decoration: InputDecoration(
                    hintText: l10n.studioAiHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                Text(l10n.studioAiStyleLabel, style: DesignTokens.caption),
                const SizedBox(height: DesignTokens.spacingXs),
                Wrap(
                  spacing: DesignTokens.spacingXs,
                  runSpacing: DesignTokens.spacingXs,
                  children: [
                    for (final id in furnitureStyles)
                      ChoiceChip(
                        label: Text(furnitureStyleLabel(l10n, id)),
                        selected: _style == id,
                        labelStyle: DesignTokens.body2.copyWith(
                          color: _style == id
                              ? DesignTokens.white
                              : DesignTokens.textDark,
                        ),
                        checkmarkColor: DesignTokens.white,
                        // Tapping the chosen style again clears it.
                        onSelected: _running
                            ? null
                            : (on) => setState(() => _style = on ? id : null),
                      ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                SizedBox(
                  height: DesignTokens.buttonHeightLarge,
                  child: FilledButton.icon(
                    onPressed: _running ? null : _start,
                    icon: _running
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_running ? l10n.studioGenerating : l10n.studioGenerate),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      for (final e in _log) _EventTile(event: e),
                      if (_error != null) _ErrorTile(message: _error!),
                      if (_result != null)
                        _ResultCard(
                          result: _result!,
                          applying: _applying,
                          onApply: _result!.patch == null
                              ? null
                              : () => _apply(_result!.patch!),
                          onDiscard: () => Navigator.of(context).pop(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final AiBuildEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, text) = switch (event) {
      AiThinking(:final text) => (Icons.psychology_outlined, text),
      AiToolCall(:final name) => (Icons.build_outlined, l10n.studioActionLabel(name)),
      AiToolResult(:final name, :final summary) => (
          Icons.check_circle_outline,
          summary ?? l10n.studioDoneLabel(name),
        ),
      _ => (Icons.info_outline, ''),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: DesignTokens.textMuted),
          const SizedBox(width: DesignTokens.spacingSm),
          Expanded(
            child: Text(text, style: DesignTokens.body2),
          ),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spacingSm),
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: DesignTokens.spacingSm),
          Expanded(
            child: Text(
              l10n.studioAiNoResponse(message),
              style: DesignTokens.caption.copyWith(color: Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.applying,
    required this.onApply,
    required this.onDiscard,
  });

  final AiDone result;
  final bool applying;
  final VoidCallback? onApply;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patch = result.patch;
    final changes = <String>[
      if (patch?.ceilingH != null)
        l10n.studioChangeCeiling(patch!.ceilingH!.toStringAsFixed(2)),
      if (patch?.surfaces != null && patch!.surfaces!.isNotEmpty)
        l10n.studioChangeSurfaces(patch.surfaces!.length),
      if (patch?.wallLengths != null && patch!.wallLengths!.isNotEmpty)
        l10n.studioChangeWalls(patch.wallLengths!.length),
      if (patch?.furniture != null && patch!.furniture!.isNotEmpty)
        l10n.studioChangeFurniture(patch.furniture!.length),
      if (patch?.lights != null && patch!.lights!.isNotEmpty)
        l10n.studioChangeLights(patch.lights!.length),
    ];
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spacingSm),
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.primaryBlue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(result.summary, style: DesignTokens.body1),
          if (changes.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingSm),
            for (final c in changes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $c', style: DesignTokens.caption),
              ),
          ],
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: applying ? null : onDiscard,
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: FilledButton(
                  onPressed: (onApply == null || applying) ? null : onApply,
                  child: applying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.studioApply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
