import '../repositories/saved_stops_repository.dart';
import '../saved_stop_groups.dart';

class ToggleFavoriteStopUseCase {
  const ToggleFavoriteStopUseCase(this._repository);

  final SavedStopsRepository _repository;

  Future<List<String>> call({
    required String groupId,
    required List<String> currentFavoriteGroupIds,
    required DateTime updatedAt,
  }) async {
    final updatedGroupIds = toggleFavoriteGroupId(
      currentFavoriteGroupIds,
      groupId,
    );

    try {
      await _repository.writeFavoriteGroupIds(
        groupIds: updatedGroupIds,
        updatedAt: updatedAt,
      );
    } on Object {
      // Favorite persistence must not block the stops UI.
    }

    return updatedGroupIds;
  }
}
