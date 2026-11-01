import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/design_selection_model.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/estimate_provider.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/design/room_thumbnail.dart';
import '../../widgets/design/stage_progress_line.dart';
// home_empty_screen re-exports projects_provider.dart (projectsProvider) and
// project_item.dart (ProjectItem), which this screen also uses.
import 'home_empty_screen.dart';

/// How many project cards [_ProjectList] shows initially, and how many more
/// "Yana ko'rsatish" reveals per tap. Kept small since each card is a full
/// hero-style card (thumbnail + stats + progress) — showing all of a large
/// project list at once would be a wall of mostly-empty scrolling, and would
/// fire an estimate-preview request (see [_EstimateChip]) for every one of
/// them at once instead of only the ones actually on screen.
const int _kProjectPageSize = 3;

enum _ProjectFilter { all, ongoing, finished }

bool _isFinished(ProjectItem p) =>
    p.renovationStage == RenovationStage.santexnika;

/// Home Screen with Projects (A2)
/// Shows list of existing projects with options to view/edit
class HomeWithProjectsScreen extends ConsumerWidget {
  const HomeWithProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(projectsProvider).when(
      loading: () => const _HomeProjectsSkeleton(),
      error: (error, _) => SafeArea(
        child: ErrorView(
          error: error,
          title: l10n.homeProjectsLoadError,
          onRetry: () => ref.invalidate(apartmentsProvider),
        ),
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return const HomeEmptyBody();
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenPaddingHorizontal,
              vertical: DesignTokens.spacingLg,
            ),
            child: _ProjectList(projects: projects),
          ),
        );
      },
    );
  }
}

/// Loading placeholder for [HomeWithProjectsScreen]'s `projectsProvider`
/// fetch: the same filter-chip row plus a couple of [_ProjectCardSkeleton]
/// cards, laid out with the same padding as the loaded [_ProjectList] so
/// nothing reflows once the real cards arrive.
class _HomeProjectsSkeleton extends StatelessWidget {
  const _HomeProjectsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.screenPaddingHorizontal,
          vertical: DesignTokens.spacingLg,
        ),
        child: SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: DesignTokens.spacingSm),
                    const SkeletonBox.circle(size: 44),
                  ],
                ],
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              for (var i = 0; i < 2; i++) ...[
                const _ProjectCardSkeleton(),
                const SizedBox(height: DesignTokens.spacingMd),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder shaped like [_ProjectCard]: thumbnail, title, room-count line,
/// the 3-chip stat row, progress bar, legend and the "Davom etish" CTA — same
/// padding/radius as the real card.
class _ProjectCardSkeleton extends StatelessWidget {
  const _ProjectCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DesignTokens.borderGrayAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(
            width: double.infinity,
            height: 160,
            borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusLg)),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          const SkeletonBox(width: 140, height: 18),
          const SizedBox(height: DesignTokens.spacingXs),
          const SkeletonBox(width: 90, height: 12),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: DesignTokens.spacingSm),
                const Expanded(
                  child: SkeletonBox(width: double.infinity, height: 56),
                ),
              ],
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          const Row(
            children: [
              Expanded(child: SkeletonBox(width: double.infinity, height: 8)),
              SizedBox(width: DesignTokens.spacingSm),
              SkeletonBox.circle(size: DesignTokens.iconSm),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          const Row(
            children: [
              SkeletonBox.circle(size: 8),
              SizedBox(width: DesignTokens.spacingXs),
              SkeletonBox(width: 60, height: 10),
              SizedBox(width: DesignTokens.spacingMd),
              SkeletonBox.circle(size: 8),
              SizedBox(width: DesignTokens.spacingXs),
              SkeletonBox(width: 60, height: 10),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          const SkeletonBox(
            width: double.infinity,
            height: DesignTokens.buttonHeightLarge,
          ),
        ],
      ),
    );
  }
}

/// Every project gets the same full card (thumbnail, stats, progress,
/// "Davom etish"), stacked vertically in the page's own scroll — replaces
/// the old horizontal swipe carousel. Paginated with "Yana ko'rsatish"
/// ([_kProjectPageSize] at a time) rather than showing the whole list at
/// once: full cards are tall, and each visible one fires an estimate-preview
/// request (see [_EstimateChip]), so an unpaginated list of many projects
/// would be both a wall of scrolling and a burst of API calls.
class _ProjectList extends StatefulWidget {
  const _ProjectList({required this.projects});

  final List<ProjectItem> projects;

  @override
  State<_ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<_ProjectList> {
  int _visibleCount = _kProjectPageSize;
  _ProjectFilter _filter = _ProjectFilter.all;

  void _setFilter(_ProjectFilter filter) {
    setState(() {
      _filter = filter;
      // Otherwise a filter switch after "Yana ko'rsatish" taps could carry
      // over a page size larger than the new (likely smaller) filtered set
      // implies, or just look like an odd jump — restart from one page.
      _visibleCount = _kProjectPageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = switch (_filter) {
      _ProjectFilter.all => widget.projects,
      _ProjectFilter.ongoing =>
        widget.projects.where((p) => !_isFinished(p)).toList(),
      _ProjectFilter.finished => widget.projects.where(_isFinished).toList(),
    };
    final visible = filtered.take(_visibleCount).toList();
    final hasMore = _visibleCount < filtered.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _FilterChip(
              icon: Icons.grid_view_rounded,
              semanticLabel: l10n.shopFilterAll,
              selected: _filter == _ProjectFilter.all,
              onTap: () => _setFilter(_ProjectFilter.all),
            ),
            const SizedBox(width: DesignTokens.spacingSm),
            _FilterChip(
              icon: Icons.autorenew,
              semanticLabel: l10n.profileFilterOngoing,
              selected: _filter == _ProjectFilter.ongoing,
              onTap: () => _setFilter(_ProjectFilter.ongoing),
            ),
            const SizedBox(width: DesignTokens.spacingSm),
            _FilterChip(
              icon: Icons.check_circle_outline,
              semanticLabel: l10n.profileFilterFinished,
              selected: _filter == _ProjectFilter.finished,
              onTap: () => _setFilter(_ProjectFilter.finished),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        for (final project in visible) ...[
          _ProjectCard(project: project, active: true),
          const SizedBox(height: DesignTokens.spacingMd),
        ],
        if (hasMore)
          Center(
            child: OutlinedButton(
              onPressed: () => setState(
                () => _visibleCount += _kProjectPageSize,
              ),
              child: Text(l10n.homeLoadMore),
            ),
          ),
      ],
    );
  }
}

/// Icon-only filter toggle. [semanticLabel] carries the filter's name (e.g.
/// "Finished") for screen readers, since the visible face is just an icon.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? DesignTokens.primaryBlue : DesignTokens.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? DesignTokens.primaryBlue
                  : DesignTokens.borderGray,
            ),
          ),
          child: Icon(
            icon,
            size: DesignTokens.iconSm,
            color: selected ? DesignTokens.white : DesignTokens.textGray,
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.project, required this.active});

  final ProjectItem project;

  /// Whether this card is the carousel's current page. Gates the estimate
  /// fetch (see [_EstimateChip]) so only the visible card triggers a network
  /// call, not every project up front.
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stageStates = project.stageStates;
    final currentIndex = project.renovationStage.index;
    final excludedNames = [
      for (final stage in kRenovationStages)
        if (stageStates[stage.index] == StageDisplayState.excluded)
          _stageLabel(stage, l10n),
    ];
    final stageLabel = excludedNames.isEmpty
        ? l10n.homeStageProgress(currentIndex + 1)
        : l10n.homeStageProgressExcluded(
            currentIndex + 1, excludedNames.join(' va '));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF2FF), Color(0xFFF5F7FF), Color(0xFFEFF3FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE7EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The stage sits on the picture, as on the web's project hero card.
          Stack(
            children: [
              RoomThumbnail(height: 160, imageUrl: project.thumbnailUrl),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 56,
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingMd,
                      0,
                      DesignTokens.spacingMd,
                      DesignTokens.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(DesignTokens.radiusLg),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    child: Text(
                      l10n.homeStageProgress(currentIndex + 1),
                      style: DesignTokens.caption.copyWith(
                        color: DesignTokens.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Text(project.name, style: DesignTokens.subtitle1),
          Text(
            l10n.homeRoomCount(project.roomCount),
            style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  value: project.floorArea != null
                      ? l10n.homeAreaValue(project.floorArea!.toStringAsFixed(1))
                      : l10n.homeStatDash,
                  label: l10n.homeStatAreaLabel,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: _StatChip(
                  value: project.furnitureCount?.toString() ?? l10n.homeStatDash,
                  label: l10n.homeStatModelsLabel,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: _EstimateChip(project: project, active: active),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          // Tapping the stage/progress area opens the stage picker sheet so
          // the user can set which renovation stage this project is at.
          InkWell(
            onTap: () => _showStagePicker(context, ref, project),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spacingXs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StageProgressLine(
                      currentStep: currentIndex,
                      totalSteps: kRenovationStages.length,
                      stageStates: stageStates,
                      stageLabel: stageLabel,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingSm),
                  const Icon(
                    Icons.edit_outlined,
                    size: DesignTokens.iconSm,
                    color: DesignTokens.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          Row(
            children: [
              const _LegendDot(color: DesignTokens.existingStateGray),
              const SizedBox(width: DesignTokens.spacingXs),
              Text(
                l10n.homeLegendExisting,
                style: DesignTokens.caption.copyWith(
                  color: DesignTokens.textGray,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              _LegendDot(color: DesignTokens.delta.inProgress),
              const SizedBox(width: DesignTokens.spacingXs),
              Text(
                l10n.homeLegendNeeded,
                style: DesignTokens.caption.copyWith(
                  color: DesignTokens.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // "Davom etish" continues the project in the 3D Studio: open the
              // studio for this apartment's most-recently-edited room. Falls
              // back to the native design flow if the project has no rooms yet.
              onPressed: () {
                final roomId = project.studioRoomId;
                if (roomId != null) {
                  context.push('/studio/$roomId');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.homeNoRoomYet),
                    ),
                  );
                }
              },
              child: Text(l10n.homeResume),
            ),
          ),
        ],
      ),
    );
  }

}

/// One stat pill in a project card's stat row (area / model count / estimate).
class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingXs,
        vertical: DesignTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: DesignTokens.subtitle2,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: DesignTokens.caption.copyWith(color: DesignTokens.textGray),
          ),
        ],
      ),
    );
  }
}

/// The "Smeta" stat chip: fetches the room's live cost estimate, but only
/// while its card is the carousel's current page ([active]) — showing every
/// project's price up front would mean one estimate API call per project on
/// every Home load, with no bulk endpoint to batch them (see
/// estimate_api_provider.dart). Non-active cards, and projects with no room
/// yet, just show a dash.
class _EstimateChip extends ConsumerWidget {
  const _EstimateChip({required this.project, required this.active});

  final ProjectItem project;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final roomId = project.studioRoomId;
    if (!active || roomId == null) {
      return _StatChip(value: l10n.homeStatDash, label: l10n.homeStatEstimateLabel);
    }
    final estimate = ref.watch(roomEstimateTotalProvider(roomId));
    final value = estimate.when(
      data: (total) => l10n.homeEstimateMln((total / 1000000).toStringAsFixed(1)),
      loading: () => '…',
      error: (_, _) => l10n.homeStatDash,
    );
    return _StatChip(value: value, label: l10n.homeStatEstimateLabel);
  }
}

/// Human-readable name for a [RenovationStage], shared by the active-project
/// card and the stage-picker sheet.
String _stageLabel(RenovationStage stage, AppLocalizations l10n) =>
    switch (stage) {
  RenovationStage.suvoq => l10n.stageSuvoq,
  RenovationStage.shpaklovka => l10n.stageShpaklovka,
  RenovationStage.boyoqOboi => l10n.stageBoyoqOboi,
  RenovationStage.pol => l10n.stagePol,
  RenovationStage.mebel => l10n.stageMebel,
  RenovationStage.elektr => l10n.stageElektr,
  RenovationStage.yoruglik => l10n.stageYoruglik,
  RenovationStage.santexnika => l10n.stageSantexnika,
  RenovationStage.unknown => '',
};

/// Opens the "Bosqichni tanlang" bottom sheet for [project], letting the user
/// set its renovation stage. On select it PATCHes the apartment and
/// invalidates [apartmentsProvider] so Home/E4/E5 refetch.
Future<void> _showStagePicker(
  BuildContext context,
  WidgetRef ref,
  ProjectItem project,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x801E2439),
    builder: (_) => _StagePickerSheet(project: project),
  );
}

/// Bottom sheet listing all 8 renovation stages with the current one
/// highlighted. Selecting one persists it via the apartment repository.
class _StagePickerSheet extends ConsumerWidget {
  const _StagePickerSheet({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentStage = project.renovationStage;

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: DesignTokens.spacingLg),
              decoration: BoxDecoration(
                color: DesignTokens.borderGray,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
          ),
          Text(l10n.homeStagePickerTitle, style: DesignTokens.heading3),
          const SizedBox(height: DesignTokens.spacingLg),
          for (final stage in kRenovationStages) ...[
            _StageOption(
              index: stage.index + 1,
              label: _stageLabel(stage, l10n),
              selected: stage == currentStage,
              onTap: () => _selectStage(context, ref, stage),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
          ],
        ],
      ),
    );
  }

  Future<void> _selectStage(
    BuildContext context,
    WidgetRef ref,
    RenovationStage stage,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(apartmentActionsProvider)
          .setRenovationStage(project.id, stage);
      navigator.pop();
    } catch (_) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.homeStageSaveError)),
      );
    }
  }
}

class _StageOption extends StatelessWidget {
  const _StageOption({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1F6) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          border: Border.all(
            color: selected
                ? DesignTokens.primaryBlue
                : const Color(0xFFEDEFF3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? DesignTokens.primaryBlue
                    : DesignTokens.borderGrayAlt,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Text(
                '$index',
                style: DesignTokens.subtitle2.copyWith(
                  color: selected ? DesignTokens.white : DesignTokens.textGray,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingMd),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.homeStageOption(index, label),
                style: DesignTokens.subtitle2,
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: DesignTokens.primaryBlue,
                size: DesignTokens.iconSm,
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
