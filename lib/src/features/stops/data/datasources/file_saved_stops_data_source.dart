import 'dart:convert';
import 'dart:io';

import '../models/saved_stops.dart';
import 'saved_stops_data_source.dart';

class FileSavedStopsDataSource implements SavedStopsDataSource {
  const FileSavedStopsDataSource({
    required this.favoritesFile,
    required this.recentFile,
  });

  final File favoritesFile;
  final File recentFile;

  @override
  Future<FavoriteStops> readFavorites() async {
    final favorites = await _read(favoritesFile, FavoriteStops.fromJson);
    return favorites ?? FavoriteStops.empty();
  }

  @override
  Future<void> writeFavorites(FavoriteStops favorites) {
    return _write(favoritesFile, favorites.toJson());
  }

  @override
  Future<void> clearFavorites() {
    return _deleteIfExists(favoritesFile);
  }

  @override
  Future<RecentStops> readRecent() async {
    final recent = await _read(recentFile, RecentStops.fromJson);
    return recent ?? RecentStops.empty();
  }

  @override
  Future<void> writeRecent(RecentStops recent) {
    return _write(recentFile, recent.toJson());
  }

  @override
  Future<void> clearRecent() {
    return _deleteIfExists(recentFile);
  }

  Future<T?> _read<T>(File file, T? Function(Object? value) fromJson) async {
    try {
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return null;
      }

      return fromJson(jsonDecode(content));
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> _write(File file, Object? json) async {
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(json)}\n');
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
