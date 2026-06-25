import '../repositories/saved_stops_repository.dart';
import '../saved_stop_groups.dart';

class RecordRecentStopUseCase {
  const RecordRecentStopUseCase(this._repository);

  final SavedStopsRepository _repository;

  Future<List<String>> call({
    required String groupId,
    required List<String> currentRecentGroupIds,
    required DateTime updatedAt,
  }) async {
    final updatedGroupIds = recordRecentGroupId(
      currentRecentGroupIds,
      groupId,
    );

    try {
      await _repository.writeRecentGroupIds(
        groupIds: updatedGroupIds,
        updatedAt: updatedAt,
      );
    } on Object {
      // Recent-stop persistence must not block departure navigation.
    }

    return updatedGroupIds;
  }
}
