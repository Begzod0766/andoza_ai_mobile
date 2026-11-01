import 'package:riverpod/riverpod.dart';

import '../models/api/api.dart';
import '../models/design_selection_model.dart';
import '../repositories/apartment_repository.dart';
import '../repositories/room_state_repository.dart';
import 'auth_provider.dart';

/// Apartments + rooms repository (backend-aligned).
final apartmentRepositoryProvider = Provider<ApartmentRepository>((ref) {
  return ApartmentRepository(ref.watch(apiClientProvider));
});

/// Room construction-state + delta repository.
final roomStateRepositoryProvider = Provider<RoomStateRepository>((ref) {
  return RoomStateRepository(ref.watch(apiClientProvider));
});

/// The current user's apartments (each with its rooms).
/// The room as the server has it now (`GET /rooms/{id}`): surfaces and the
/// Studio's design state change in the web Studio, so a copy taken when the
/// room was saved is stale.
final serverRoomProvider =
    FutureProvider.autoDispose.family<RoomOut, String>((ref, roomId) {
  return ref.watch(apartmentRepositoryProvider).getRoom(roomId);
});

/// What the smeta says about a floor whose type was picked in the Studio
/// without a product.
enum FloorNote {
  /// The server priced it from the median shop product: a stand-in, approximate.
  standIn,

  /// The server has no floor line for it: the floor is not in the smeta.
  leftOut,
}

/// The floor note for [room] given the server smeta's [lines], or null when
/// there is nothing to say (a floor product chosen, no floor type, or a bare
/// concrete floor). The web smeta's `floorNote` (`SmetaPage.tsx`), handoff §7.2.
FloorNote? floorNote(RoomOut room, List<EstimateLine>? lines) {
  final design = room.state?['designState'];
  if (design is! Map) return null;
  final type = design['floorType'];
  if (design['floorConfigured'] != true ||
      type is! String ||
      type.isEmpty ||
      type == 'concrete' ||
      room.surfaces?['floor'] != null) {
    return null;
  }
  const floorCategories = {'laminat', 'parket', 'plitka'};
  final priced = (lines ?? const <EstimateLine>[])
      .any((l) => floorCategories.contains(l.category));
  return priced ? FloorNote.standIn : FloorNote.leftOut;
}

final apartmentsProvider = FutureProvider.autoDispose<List<Apartment>>((ref) {
  return ref.watch(apartmentRepositoryProvider).listApartments();
});

/// Apartment mutations that persist to the backend and then refresh
/// [apartmentsProvider]. Keeps repository writes + the 0-based enum → 1-based
/// backend index mapping out of the widgets, which should only dispatch intent.
final apartmentActionsProvider = Provider<ApartmentActions>((ref) {
  return ApartmentActions(ref);
});

class ApartmentActions {
  ApartmentActions(this._ref);

  final Ref _ref;

  /// Persists [stage] as [apartmentId]'s renovation stage, then invalidates
  /// [apartmentsProvider] so Home/E4/E5 refetch. The backend stores a 1-based
  /// stage index (1..8), so the enum's 0-based index is offset by one.
  Future<void> setRenovationStage(
    String apartmentId,
    RenovationStage stage,
  ) async {
    await _ref
        .read(apartmentRepositoryProvider)
        .updateApartment(apartmentId, renovationStage: stage.index + 1);
    _ref.invalidate(apartmentsProvider);
  }
}

/// A single room's construction-progress state, by room id.
final roomStateProvider =
    FutureProvider.autoDispose.family<RoomState, String>((ref, roomId) {
  return ref.watch(roomStateRepositoryProvider).getState(roomId);
});

/// The authoritative delta (material/cost difference vs a finished room), by
/// room id. Drives the real "tejaldingiz" (you saved) figure.
final roomDeltaProvider =
    FutureProvider.autoDispose.family<DeltaResponse, String>((ref, roomId) {
  return ref.watch(roomStateRepositoryProvider).getDelta(roomId);
});
