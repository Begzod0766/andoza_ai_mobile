import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/design_tokens.dart';
import '../../features/new_project/new_project_sheet_state.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/room_persistence_provider.dart';
import '../../widgets/new_project/new_project_animations.dart';

/// Opens the A3 "+" sheet — the one entry point for every caller. The sheet
/// lives in `AppShell`'s body above the menu (`NewProjectSheetLayer`) and the
/// menu's circle moves to "+". A caller outside the shell (a root-navigator
/// screen such as `/setup/summary` or `/onboarding/e8`) is taken to the shell
/// first, since the sheet only exists there.
void showNewProjectSheet(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  if (!AppShellScope.isInside(context)) GoRouter.of(context).go('/');
  container.read(newProjectSheetOpenProvider.notifier).state = true;
}

/// Closes the sheet before a card's flow is pushed over the shell.
void _closeSheet(BuildContext context) => ProviderScope.containerOf(
  context,
  listen: false,
).read(newProjectSheetOpenProvider.notifier).state = false;

/// A3: "+" sheet — the three entry paths into a new project's measurement
/// flow, full height above the bottom menu.
bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

class NewProjectSheet extends StatelessWidget {
  const NewProjectSheet({
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
    super.key,
  });

  /// Vertical drags on the header (handle + title) — the host uses them to
  /// swipe the sheet down.
  final GestureDragUpdateCallback? onHeaderDragUpdate;
  final GestureDragEndCallback? onHeaderDragEnd;

  /// The drag handle at the top of the sheet.
  static const handleKey = Key('newProjectSheetHandle');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.screenPaddingHorizontal,
        DesignTokens.spacingMd,
        DesignTokens.screenPaddingHorizontal,
        DesignTokens.spacingXl,
      ),
      decoration: const BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusSheet),
          topRight: Radius.circular(DesignTokens.radiusSheet),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: onHeaderDragUpdate,
            onVerticalDragEnd: onHeaderDragEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    key: handleKey,
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(
                      bottom: DesignTokens.spacingLg,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.borderGray,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusFull,
                      ),
                    ),
                  ),
                ),
                Text(l10n.newProjectTitle, style: DesignTokens.heading3),
                const SizedBox(height: DesignTokens.spacingXs),
                Text(
                  l10n.newProjectSubtitle,
                  style: DesignTokens.body2.copyWith(
                    color: DesignTokens.textGray,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingLg),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _AnimatedCard(
                    animation: const WizardBoxAnimation(),
                    tint: DesignTokens.primaryBlue,
                    title: l10n.newProjectWizardTitle,
                    caption: l10n.newProjectWizardCaption,
                    onTap: () {
                      ProviderScope.containerOf(context)
                          .read(roomPersistenceProvider.notifier)
                          .startNewProject();
                      _closeSheet(context);
                      context.push('/wizard');
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _AnimatedCard(
                    animation: const LidarScanAnimation(),
                    tint: DesignTokens.primaryBlue,
                    // Android measures with the camera (ARCore); iPhones scan
                    // with LiDAR.
                    title: _isAndroid
                        ? l10n.newProjectArScanTitle
                        : l10n.newProjectLidarTitle,
                    caption: _isAndroid
                        ? l10n.newProjectArScanCaption
                        : l10n.newProjectLidarCaption,
                    onTap: () {
                      ProviderScope.containerOf(context)
                          .read(roomPersistenceProvider.notifier)
                          .continueCurrentProject();
                      _closeSheet(context);
                      context.push('/scanning/roomplan');
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _AnimatedCard(
                    animation: const DrawRoomAnimation(),
                    tint: DesignTokens.successGreen,
                    title: l10n.newProjectDrawTitle,
                    caption: l10n.newProjectDrawCaption,
                    onTap: () {
                      ProviderScope.containerOf(context)
                          .read(roomPersistenceProvider.notifier)
                          .startNewProject();
                      _closeSheet(context);
                      context.push('/setup/draw');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One entry path: the looping illustration on top, then the title and a
/// short caption. Read as one button ("title, caption"); the illustration is
/// decoration and carries no semantics.
class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({
    required this.animation,
    required this.tint,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final Widget animation;
  final Color tint;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(DesignTokens.radiusXl);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: DesignTokens.white,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: DesignTokens.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      height: 118,
                      margin: const EdgeInsets.all(DesignTokens.spacingSm),
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLg,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLg,
                        ),
                        child: animation,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingMd,
                      DesignTokens.spacingXs,
                      DesignTokens.spacingMd,
                      DesignTokens.spacingMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: DesignTokens.subtitle2),
                              const SizedBox(height: 2),
                              Text(
                                caption,
                                style: DesignTokens.caption.copyWith(
                                  color: DesignTokens.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: DesignTokens.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
