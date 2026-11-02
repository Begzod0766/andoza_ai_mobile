import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/design_selection_model.dart';
import '../../widgets/design/stage_progress_line.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/common/load_status.dart';
import '../../widgets/empty_state_pattern.dart';
import '../home/home_empty_screen.dart';
import '../room_setup/new_project_sheet.dart';

enum _ProjectFilter { all, ongoing, finished }

bool _isFinished(ProjectItem p) =>
    p.renovationStage == RenovationStage.santexnika;

/// E5: Loyihalarim — also A2's "Barchasi" destination (there is no
/// separate spec screen for that; this is the single, real
/// destination). Reuses the same [homeStateProvider] list and delta
/// progress bar as A2, so this never shows different data than home
/// does.
class E5ProjectsScreen extends ConsumerStatefulWidget {
  const E5ProjectsScreen({super.key});

  @override
  ConsumerState<E5ProjectsScreen> createState() => _E5ProjectsScreenState();
}

class _E5ProjectsScreenState extends ConsumerState<E5ProjectsScreen> {
  _ProjectFilter _filter = _ProjectFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectsProvider);
    final projects = projectsAsync.valueOrNull ?? const <ProjectItem>[];
    // While loading or after a failure the list is empty too — that must not
    // read as "you have no projects".
    final status = loadStatus(
      isEmpty: projects.isEmpty,
      loading: projectsAsync.isLoading,
      error: projectsAsync.error,
      onRetry: () => ref.invalidate(apartmentsProvider),
    );
    final visible = switch (_filter) {
      _ProjectFilter.all => projects,
      _ProjectFilter.ongoing => projects.where((p) => !_isFinished(p)).toList(),
      _ProjectFilter.finished => projects.where(_isFinished).toList(),
    };

    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundLight,
        elevation: 0,
        title: Text(l10n.profileMenuProjects, style: DesignTokens.heading3),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenPaddingHorizontal,
              vertical: DesignTokens.spacingSm,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.shopFilterAll,
                  selected: _filter == _ProjectFilter.all,
                  onTap: () => setState(() => _filter = _ProjectFilter.all),
                ),
                const SizedBox(width: DesignTokens.spacingSm),
                _FilterChip(
                  label: l10n.profileFilterOngoing,
                  selected: _filter == _ProjectFilter.ongoing,
                  onTap: () => setState(() => _filter = _ProjectFilter.ongoing),
                ),
                const SizedBox(width: DesignTokens.spacingSm),
                _FilterChip(
                  label: l10n.profileFilterFinished,
                  selected: _filter == _ProjectFilter.finished,
                  onTap: () =>
                      setState(() => _filter = _ProjectFilter.finished),
                ),
              ],
            ),
          ),
          Expanded(
            child: status ?? RefreshIndicator(
              onRefresh: () => ref.refresh(apartmentsProvider.future),
              child: visible.isEmpty
                ? LayoutBuilder(
                    builder: (context, box) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(minHeight: box.maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              DesignTokens.screenPaddingHorizontal,
                            ),
                            child: Center(
                              child: EmptyStatePattern(
                                icon: Icons.architecture_outlined,
                                title: l10n.profileProjectsEmptyTitle,
                                message: l10n.profileProjectsEmptyMessage,
                                actionLabel: l10n.profileProjectsEmptyAction,
                                onAction: () => showNewProjectSheet(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(
                      DesignTokens.screenPaddingHorizontal,
                    ),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: DesignTokens.spacingMd),
                    itemBuilder: (context, index) =>
                        _ProjectCard(project: visible[index]),
                  )),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: DesignTokens.white,
      selectedColor: DesignTokens.primaryBlue,
      labelStyle: DesignTokens.caption.copyWith(
        color: selected ? DesignTokens.white : DesignTokens.textDark,
      ),
    );
  }
}

/// "Chilonzor · 30.9.2026", or just the date when the project has no address
/// (it used to print "6 xona ·  · 30.9.2026").
String projectMetaDetails(String location, DateTime createdAt) {
  final date = '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  final place = location.trim();
  return place.isEmpty ? date : '$place · $date';
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stageStates = project.stageStates;
    final currentIndex = project.renovationStage.index;
    final finished = _isFinished(project);
    final excludedCount = stageStates
        .where((s) => s == StageDisplayState.excluded)
        .length;

    return Semantics(
      button: true,
      child: InkWell(
      // Same as Home's "Davom etish": this project's latest room in the
      // Studio. (It used to `go('/design/b2')` — another editor, no room id,
      // and the back stack wiped.)
      onTap: () {
        final roomId = project.studioRoomId;
        if (roomId != null) {
          context.push('/studio/$roomId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.homeNoRoomYet)),
          );
        }
      },
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        decoration: BoxDecoration(
          color: DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: DesignTokens.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: DesignTokens.borderGrayAlt,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: const Center(
                child: Icon(
                  Icons.view_in_ar_outlined,
                  size: DesignTokens.iconXl,
                  color: DesignTokens.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Row(
              children: [
                Expanded(
                  child: Text(project.name, style: DesignTokens.subtitle2),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (finished
                                ? DesignTokens.successGreen
                                : DesignTokens.primaryBlue)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Text(
                    finished
                        ? l10n.profileFilterFinished
                        : l10n.profileFilterOngoing,
                    style: DesignTokens.caption.copyWith(
                      color: finished
                          ? DesignTokens.successGreen
                          : DesignTokens.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              l10n.profileProjectMeta(
                project.roomCount,
                projectMetaDetails(project.location, project.createdAt),
              ),
              style: DesignTokens.caption.copyWith(
                color: DesignTokens.textGray,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            StageProgressLine(
              currentStep: currentIndex,
              totalSteps: kRenovationStages.length,
              stageStates: stageStates,
              stageLabel: excludedCount == 0
                  ? l10n.homeStageProgress(currentIndex + 1)
                  : l10n.homeStageProgressExcludedCount(
                      currentIndex + 1,
                      excludedCount,
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
