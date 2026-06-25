import '../../../../core/errors/app_failure.dart';
import '../../domain/search/stop_search_index.dart';
import '../../domain/search/stop_search_matcher.dart';
import '../../domain/search/stop_search_query.dart';
import '../../domain/stop.dart';
import '../../domain/stop_group.dart';
import 'stops_state.dart';

class StopsStateFactory {
  const StopsStateFactory();

  static const _searchMatcher = StopSearchMatcher();

  StopsState loading({
    required List<String> favoriteGroupIds,
    required List<String> recentGroupIds,
  }) {
    return StopsState(
      status: StopsStatus.loading,
      favoriteGroupIds: favoriteGroupIds,
      recentGroupIds: recentGroupIds,
    );
  }

  StopsState initialError({
    required AppFailure error,
    required List<String> favoriteGroupIds,
    required List<String> recentGroupIds,
  }) {
    return StopsState(
      status: StopsStatus.error,
      error: error,
      favoriteGroupIds: favoriteGroupIds,
      recentGroupIds: recentGroupIds,
    );
  }

  StopsState fromStops(
    List<Stop> stops, {
    required String searchQuery,
    required bool hasMore,
    required int nextOffset,
    required List<String> favoriteGroupIds,
    required List<String> recentGroupIds,
    StopSearchIndex? searchIndex,
    bool isLoadingMore = false,
    bool isSearching = false,
    bool useProvidedStopsDirectly = false,
    bool isFromCache = false,
    bool isCacheStale = false,
    AppFailure? cacheRefreshError,
    bool clearCacheRefreshError = false,
  }) {
    final allStops = List<Stop>.unmodifiable(stops);
    final effectiveSearchIndex =
        searchIndex ?? StopSearchIndex.fromGroups(groupStops(allStops));
    final allGroups = effectiveSearchIndex.groups;
    final filteredGroups = useProvidedStopsDirectly
        ? allGroups
        : _searchMatcher.matchGroups(
            effectiveSearchIndex,
            StopSearchQuery.parse(searchQuery),
          );
    final filteredStops = _representativeStops(filteredGroups);
    final status = filteredGroups.isEmpty
        ? StopsStatus.empty
        : StopsStatus.loaded;

    return StopsState(
      status: status,
      allStops: allStops,
      filteredStops: filteredStops,
      allGroups: allGroups,
      filteredGroups: filteredGroups,
      searchQuery: searchQuery,
      hasMore: hasMore,
      nextOffset: nextOffset,
      isLoadingMore: isLoadingMore,
      isSearching: isSearching,
      isFromCache: isFromCache,
      isCacheStale: isCacheStale,
      cacheRefreshError: clearCacheRefreshError ? null : cacheRefreshError,
      favoriteGroupIds: favoriteGroupIds,
      recentGroupIds: recentGroupIds,
      favoriteGroups: resolveGroups(allGroups, favoriteGroupIds),
      recentGroups: resolveGroups(allGroups, recentGroupIds),
    );
  }

  StopsState searchError({
    required AppFailure error,
    required List<Stop> allStops,
    required StopsState current,
    required String searchQuery,
    required List<String> favoriteGroupIds,
    required List<String> recentGroupIds,
  }) {
    final searchIndex = StopSearchIndex.fromGroups(groupStops(allStops));
    final allGroups = searchIndex.groups;

    return StopsState(
      status: StopsStatus.error,
      allStops: allStops,
      searchQuery: searchQuery,
      error: error,
      allGroups: allGroups,
      hasMore: current.hasMore,
      nextOffset: current.nextOffset,
      isFromCache: current.isFromCache,
      isCacheStale: current.isCacheStale,
      cacheRefreshError: current.cacheRefreshError,
      favoriteGroupIds: favoriteGroupIds,
      recentGroupIds: recentGroupIds,
      favoriteGroups: resolveGroups(allGroups, favoriteGroupIds),
      recentGroups: resolveGroups(allGroups, recentGroupIds),
    );
  }

  StopsState withSavedStops({
    required StopsState current,
    required List<String> favoriteGroupIds,
    required List<String> recentGroupIds,
  }) {
    return current.copyWith(
      favoriteGroupIds: favoriteGroupIds,
      recentGroupIds: recentGroupIds,
      favoriteGroups: resolveGroups(current.allGroups, favoriteGroupIds),
      recentGroups: resolveGroups(current.allGroups, recentGroupIds),
    );
  }

  List<StopGroup> resolveGroups(
    List<StopGroup> groups,
    List<String> groupIds,
  ) {
    final groupsById = {for (final group in groups) group.id: group};
    final resolvedGroups = <StopGroup>[];

    for (final groupId in groupIds) {
      final group = groupsById[groupId];
      if (group != null) {
        resolvedGroups.add(group);
      }
    }

    return List<StopGroup>.unmodifiable(resolvedGroups);
  }

  List<Stop> _representativeStops(List<StopGroup> groups) {
    return List<Stop>.unmodifiable(
      groups.map((group) => group.representativeStop),
    );
  }
}
