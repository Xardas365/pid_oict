import 'package:meta/meta.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/value_equality.dart';
import '../../domain/stop.dart';
import '../../domain/stop_group.dart';

enum StopsStatus { loading, loaded, empty, error }

@immutable
class StopsState {
  const StopsState({
    required this.status,
    this.allStops = const <Stop>[],
    this.filteredStops = const <Stop>[],
    this.allGroups = const <StopGroup>[],
    this.filteredGroups = const <StopGroup>[],
    this.searchQuery = '',
    this.error,
    this.hasMore = false,
    this.nextOffset = 0,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.isFromCache = false,
    this.isCacheStale = false,
    this.cacheRefreshError,
    this.favoriteGroupIds = const <String>[],
    this.recentGroupIds = const <String>[],
    this.favoriteGroups = const <StopGroup>[],
    this.recentGroups = const <StopGroup>[],
  });

  const StopsState.loading() : this(status: StopsStatus.loading);

  final StopsStatus status;
  final List<Stop> allStops;
  final List<Stop> filteredStops;
  final List<StopGroup> allGroups;
  final List<StopGroup> filteredGroups;
  final String searchQuery;
  final AppFailure? error;
  final bool hasMore;
  final int nextOffset;
  final bool isLoadingMore;
  final bool isSearching;
  final bool isFromCache;
  final bool isCacheStale;
  final AppFailure? cacheRefreshError;
  final List<String> favoriteGroupIds;
  final List<String> recentGroupIds;
  final List<StopGroup> favoriteGroups;
  final List<StopGroup> recentGroups;

  bool get isSearchActive => searchQuery.trim().isNotEmpty;
  bool get hasCacheWarning => isCacheStale || cacheRefreshError != null;

  bool isFavorite(StopGroup group) {
    return favoriteGroupIds.contains(group.id);
  }

  StopsState copyWith({
    StopsStatus? status,
    List<Stop>? allStops,
    List<Stop>? filteredStops,
    List<StopGroup>? allGroups,
    List<StopGroup>? filteredGroups,
    String? searchQuery,
    AppFailure? error,
    bool? hasMore,
    int? nextOffset,
    bool? isLoadingMore,
    bool? isSearching,
    bool? isFromCache,
    bool? isCacheStale,
    AppFailure? cacheRefreshError,
    List<String>? favoriteGroupIds,
    List<String>? recentGroupIds,
    List<StopGroup>? favoriteGroups,
    List<StopGroup>? recentGroups,
    bool clearError = false,
    bool clearCacheRefreshError = false,
  }) {
    return StopsState(
      status: status ?? this.status,
      allStops: allStops ?? this.allStops,
      filteredStops: filteredStops ?? this.filteredStops,
      allGroups: allGroups ?? this.allGroups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      isFromCache: isFromCache ?? this.isFromCache,
      isCacheStale: isCacheStale ?? this.isCacheStale,
      cacheRefreshError: clearCacheRefreshError
          ? null
          : cacheRefreshError ?? this.cacheRefreshError,
      favoriteGroupIds: favoriteGroupIds ?? this.favoriteGroupIds,
      recentGroupIds: recentGroupIds ?? this.recentGroupIds,
      favoriteGroups: favoriteGroups ?? this.favoriteGroups,
      recentGroups: recentGroups ?? this.recentGroups,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopsState &&
            status == other.status &&
            iterableEquals(allStops, other.allStops) &&
            iterableEquals(filteredStops, other.filteredStops) &&
            iterableEquals(allGroups, other.allGroups) &&
            iterableEquals(filteredGroups, other.filteredGroups) &&
            searchQuery == other.searchQuery &&
            error == other.error &&
            hasMore == other.hasMore &&
            nextOffset == other.nextOffset &&
            isLoadingMore == other.isLoadingMore &&
            isSearching == other.isSearching &&
            isFromCache == other.isFromCache &&
            isCacheStale == other.isCacheStale &&
            cacheRefreshError == other.cacheRefreshError &&
            iterableEquals(favoriteGroupIds, other.favoriteGroupIds) &&
            iterableEquals(recentGroupIds, other.recentGroupIds) &&
            iterableEquals(favoriteGroups, other.favoriteGroups) &&
            iterableEquals(recentGroups, other.recentGroups);
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      iterableHash(allStops),
      iterableHash(filteredStops),
      iterableHash(allGroups),
      iterableHash(filteredGroups),
      searchQuery,
      error,
      hasMore,
      nextOffset,
      isLoadingMore,
      isSearching,
      isFromCache,
      isCacheStale,
      cacheRefreshError,
      iterableHash(favoriteGroupIds),
      iterableHash(recentGroupIds),
      iterableHash(favoriteGroups),
      iterableHash(recentGroups),
    );
  }
}
