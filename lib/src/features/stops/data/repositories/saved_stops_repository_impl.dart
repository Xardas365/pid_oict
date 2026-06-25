import '../../domain/repositories/saved_stops_repository.dart';
import '../../domain/saved_stop_groups.dart';
import '../datasources/saved_stops_data_source.dart';
import '../models/saved_stops.dart';

class SavedStopsRepositoryImpl implements SavedStopsRepository {
  const SavedStopsRepositoryImpl(this._dataSource);

  final SavedStopsDataSource _dataSource;

  @override
  Future<SavedStopGroups> read() async {
    final favorites = await _readFavoriteGroupIds();
    final recent = await _readRecentGroupIds();

    return SavedStopGroups(favoriteGroupIds: favorites, recentGroupIds: recent);
  }

  @override
  Future<void> writeFavoriteGroupIds({
    required List<String> groupIds,
    required DateTime updatedAt,
  }) {
    return _dataSource.writeFavorites(
      FavoriteStops(updatedAt: updatedAt, favoriteGroupIds: groupIds),
    );
  }

  @override
  Future<void> writeRecentGroupIds({
    required List<String> groupIds,
    required DateTime updatedAt,
  }) {
    return _dataSource.writeRecent(
      RecentStops(updatedAt: updatedAt, recentGroupIds: groupIds),
    );
  }

  Future<List<String>> _readFavoriteGroupIds() async {
    try {
      return (await _dataSource.readFavorites()).favoriteGroupIds;
    } on Object {
      return const <String>[];
    }
  }

  Future<List<String>> _readRecentGroupIds() async {
    try {
      return (await _dataSource.readRecent()).recentGroupIds;
    } on Object {
      return const <String>[];
    }
  }
}
