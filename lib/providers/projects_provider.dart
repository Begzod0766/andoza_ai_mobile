import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/apartment.dart';
import '../models/design_selection_model.dart';
import '../models/project_item.dart';
import 'apartment_provider.dart';

/// Riverpod provider for home screen state
final homeStateProvider = StateNotifierProvider<HomeStateNotifier, HomeState>(
  (ref) => HomeStateNotifier(),
);

/// The merged project list the UI renders: the user's real backend
/// apartments ([apartmentsProvider]) mapped to [ProjectItem]s, plus any
/// locally-added ([homeStateProvider]) projects not yet present on the
/// server. Dedup is by `id` with the server winning, so an optimistic add
/// disappears cleanly once the refetch returns it.
///
/// Loading/error state is passed straight through from [apartmentsProvider]
/// (via [AsyncValue.whenData]); invalidate [apartmentsProvider] to retry.
final projectsProvider = Provider<AsyncValue<List<ProjectItem>>>((ref) {
  final localProjects = ref.watch(homeStateProvider).projects;
  return ref.watch(apartmentsProvider).whenData((apartments) {
    final serverProjects = apartments.map(_apartmentToProject).toList();
    final serverIds = serverProjects.map((p) => p.id).toSet();
    final localOnly =
        localProjects.where((p) => !serverIds.contains(p.id)).toList();
    return [...serverProjects, ...localOnly];
  });
});

/// Maps a backend [Apartment] to the UI's [ProjectItem]. The backend's
/// `renovation_stage` is a 1-based int (1..8); it maps to the
/// [RenovationStage] enum value at the matching 0-based position, so the
/// card's "Bosqich N/8" mirrors the server exactly. [roomCondition] stays
/// null ("not yet assessed") — the server has no room-condition concept yet.
ProjectItem _apartmentToProject(Apartment a) {
  // Pick the most-recently-edited room to resume in the 3D Studio.
  final rooms = [...a.rooms]
    ..sort((r1, r2) => r2.updatedAt.compareTo(r1.updatedAt));
  return ProjectItem(
    id: a.id,
    name: a.name,
    location: a.address ?? '',
    roomCount: a.rooms.length,
    createdAt: a.createdAt,
    renovationStage: kRenovationStages[(a.renovationStage - 1).clamp(
      0,
      kRenovationStages.length - 1,
    )],
    studioRoomId: rooms.isNotEmpty ? rooms.first.id : null,
    thumbnailUrl: rooms.isNotEmpty ? rooms.first.thumbnailUrl : null,
    floorArea: rooms.isNotEmpty ? rooms.first.floorArea : null,
    // A saved room with no layout yet has 0 models — known, not unknown.
    furnitureCount:
        rooms.isNotEmpty ? (rooms.first.furnitureLayout?.length ?? 0) : null,
  );
}

class HomeStateNotifier extends StateNotifier<HomeState> {
  HomeStateNotifier() : super(HomeState(projects: []));

  void addProject(ProjectItem project) {
    state = state.copyWith(projects: [...state.projects, project]);
  }

  void removeProject(String id) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != id).toList(),
    );
  }
}
