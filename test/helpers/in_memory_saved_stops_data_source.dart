import 'package:pid_oict/src/features/stops/data/datasources/saved_stops_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/saved_stops.dart';

class InMemorySavedStopsDataSource implements SavedStopsDataSource {
  FavoriteStops _favorites = FavoriteStops.empty();
  RecentStops _recent = RecentStops.empty();

  @override
  Future<FavoriteStops> readFavorites() async {
    return _favorites;
  }

  @override
  Future<void> writeFavorites(FavoriteStops favorites) async {
    _favorites = favorites;
  }

  @override
  Future<void> clearFavorites() async {
    _favorites = FavoriteStops.empty();
  }

  @override
  Future<RecentStops> readRecent() async {
    return _recent;
  }

  @override
  Future<void> writeRecent(RecentStops recent) async {
    _recent = recent;
  }

  @override
  Future<void> clearRecent() async {
    _recent = RecentStops.empty();
  }
}
