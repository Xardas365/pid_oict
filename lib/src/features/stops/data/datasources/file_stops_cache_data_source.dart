import 'dart:convert';
import 'dart:io';

import '../models/cached_stops.dart';
import 'stops_cache_data_source.dart';

class FileStopsCacheDataSource implements StopsCacheDataSource {
  const FileStopsCacheDataSource(this.file);

  final File file;

  @override
  Future<CachedStops?> read() async {
    try {
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return null;
      }

      return CachedStops.fromJson(jsonDecode(content));
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(CachedStops cache) async {
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(cache.toJson())}\n');
  }

  @override
  Future<void> clear() async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
