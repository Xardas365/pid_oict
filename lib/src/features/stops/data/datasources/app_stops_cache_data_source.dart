import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/cached_stops.dart';
import 'file_stops_cache_data_source.dart';
import 'stops_cache_data_source.dart';

const stopsCacheDirectoryName = 'pid_oict';
const stopsCacheFileName = 'public_stops_cache.json';

typedef StopsCacheDirectoryResolver = Future<Directory> Function();
typedef StopsCacheFileResolver = Future<File> Function();

Future<File> resolveAppStopsCacheFile({
  StopsCacheDirectoryResolver directoryResolver =
      getApplicationSupportDirectory,
}) async {
  final supportDirectory = await directoryResolver();
  final separator = Platform.pathSeparator;

  return File(
    '${supportDirectory.path}$separator$stopsCacheDirectoryName$separator'
    '$stopsCacheFileName',
  );
}

class AppStopsCacheDataSource implements StopsCacheDataSource {
  const AppStopsCacheDataSource({this.fileResolver = resolveAppStopsCacheFile});

  final StopsCacheFileResolver fileResolver;

  @override
  Future<CachedStops?> read() async {
    final dataSource = await _fileDataSource();
    return dataSource.read();
  }

  @override
  Future<void> write(CachedStops cache) async {
    final dataSource = await _fileDataSource();
    await dataSource.write(cache);
  }

  @override
  Future<void> clear() async {
    final dataSource = await _fileDataSource();
    await dataSource.clear();
  }

  Future<FileStopsCacheDataSource> _fileDataSource() async {
    return FileStopsCacheDataSource(await fileResolver());
  }
}
