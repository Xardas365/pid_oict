import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/saved_stops.dart';
import 'app_stops_cache_data_source.dart';
import 'file_saved_stops_data_source.dart';
import 'saved_stops_data_source.dart';

const favoriteStopsFileName = 'favorite_stops.json';
const recentStopsFileName = 'recent_stops.json';

class SavedStopsFiles {
  const SavedStopsFiles({
    required this.favoritesFile,
    required this.recentFile,
  });

  final File favoritesFile;
  final File recentFile;
}

typedef SavedStopsFilesResolver = Future<SavedStopsFiles> Function();

Future<SavedStopsFiles> resolveAppSavedStopsFiles({
  StopsCacheDirectoryResolver directoryResolver =
      getApplicationSupportDirectory,
}) async {
  final supportDirectory = await directoryResolver();
  final separator = Platform.pathSeparator;
  final directoryPath =
      '${supportDirectory.path}$separator$stopsCacheDirectoryName';

  return SavedStopsFiles(
    favoritesFile: File('$directoryPath$separator$favoriteStopsFileName'),
    recentFile: File('$directoryPath$separator$recentStopsFileName'),
  );
}

class AppSavedStopsDataSource implements SavedStopsDataSource {
  const AppSavedStopsDataSource({
    this.filesResolver = resolveAppSavedStopsFiles,
  });

  final SavedStopsFilesResolver filesResolver;

  @override
  Future<FavoriteStops> readFavorites() async {
    final dataSource = await _fileDataSource();
    return dataSource.readFavorites();
  }

  @override
  Future<void> writeFavorites(FavoriteStops favorites) async {
    final dataSource = await _fileDataSource();
    await dataSource.writeFavorites(favorites);
  }

  @override
  Future<void> clearFavorites() async {
    final dataSource = await _fileDataSource();
    await dataSource.clearFavorites();
  }

  @override
  Future<RecentStops> readRecent() async {
    final dataSource = await _fileDataSource();
    return dataSource.readRecent();
  }

  @override
  Future<void> writeRecent(RecentStops recent) async {
    final dataSource = await _fileDataSource();
    await dataSource.writeRecent(recent);
  }

  @override
  Future<void> clearRecent() async {
    final dataSource = await _fileDataSource();
    await dataSource.clearRecent();
  }

  Future<FileSavedStopsDataSource> _fileDataSource() async {
    final files = await filesResolver();
    return FileSavedStopsDataSource(
      favoritesFile: files.favoritesFile,
      recentFile: files.recentFile,
    );
  }
}
