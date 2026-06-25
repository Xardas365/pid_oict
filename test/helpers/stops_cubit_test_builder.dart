import 'package:pid_oict/src/features/stops/data/datasources/saved_stops_data_source.dart';
import 'package:pid_oict/src/features/stops/data/datasources/stops_cache_data_source.dart';
import 'package:pid_oict/src/features/stops/data/repositories/saved_stops_repository_impl.dart';
import 'package:pid_oict/src/features/stops/data/repositories/stops_cache_repository_impl.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/saved_stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_cache_repository.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_cached_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_complete_stop_index_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_saved_stop_groups_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/record_recent_stop_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/save_stops_cache_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/toggle_favorite_stop_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';

StopsCubit testStopsCubit(
  GetStopsUseCase getStops, {
  int pageSize = gtfsStopsPageSize,
  int remoteSupplementLimit = gtfsStopsRemoteSupplementLimit,
  Duration searchDebounceDuration = gtfsStopsSearchDebounceDuration,
  StopsCacheDataSource? cacheDataSource,
  SavedStopsDataSource? savedStopsDataSource,
  LoadCompleteStopIndexUseCase? loadCompleteStopIndex,
  DateTime Function()? now,
}) {
  final cacheRepository = cacheDataSource == null
      ? null
      : StopsCacheRepositoryImpl(cacheDataSource);
  final savedStopsRepository = savedStopsDataSource == null
      ? null
      : SavedStopsRepositoryImpl(savedStopsDataSource);

  return StopsCubit(
    getStops,
    pageSize: pageSize,
    remoteSupplementLimit: remoteSupplementLimit,
    searchDebounceDuration: searchDebounceDuration,
    loadCompleteStopIndex: loadCompleteStopIndex,
    loadCachedStops: _loadCachedStops(cacheRepository),
    saveStopsCache: _saveStopsCache(cacheRepository),
    loadSavedStopGroups: _loadSavedStopGroups(savedStopsRepository),
    toggleFavoriteStop: _toggleFavoriteStop(savedStopsRepository),
    recordRecentStopUseCase: _recordRecentStop(savedStopsRepository),
    now: now,
  );
}

LoadCachedStopsUseCase? _loadCachedStops(StopsCacheRepository? repository) {
  if (repository == null) {
    return null;
  }

  return LoadCachedStopsUseCase(repository);
}

SaveStopsCacheUseCase? _saveStopsCache(StopsCacheRepository? repository) {
  if (repository == null) {
    return null;
  }

  return SaveStopsCacheUseCase(repository);
}

LoadSavedStopGroupsUseCase? _loadSavedStopGroups(
  SavedStopsRepository? repository,
) {
  if (repository == null) {
    return null;
  }

  return LoadSavedStopGroupsUseCase(repository);
}

ToggleFavoriteStopUseCase? _toggleFavoriteStop(
  SavedStopsRepository? repository,
) {
  if (repository == null) {
    return null;
  }

  return ToggleFavoriteStopUseCase(repository);
}

RecordRecentStopUseCase? _recordRecentStop(SavedStopsRepository? repository) {
  if (repository == null) {
    return null;
  }

  return RecordRecentStopUseCase(repository);
}
