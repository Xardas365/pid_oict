import '../models/saved_stops.dart';

abstract interface class SavedStopsDataSource {
  Future<FavoriteStops> readFavorites();

  Future<void> writeFavorites(FavoriteStops favorites);

  Future<void> clearFavorites();

  Future<RecentStops> readRecent();

  Future<void> writeRecent(RecentStops recent);

  Future<void> clearRecent();
}
