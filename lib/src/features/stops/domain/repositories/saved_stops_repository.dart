import '../saved_stop_groups.dart';

abstract interface class SavedStopsRepository {
  Future<SavedStopGroups> read();

  Future<void> writeFavoriteGroupIds({
    required List<String> groupIds,
    required DateTime updatedAt,
  });

  Future<void> writeRecentGroupIds({
    required List<String> groupIds,
    required DateTime updatedAt,
  });
}
