import '../../domain/stop.dart';
import '../../domain/stop_group.dart';

enum StopsStatus { loading, loaded, empty, error }

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
  });

  const StopsState.loading() : this(status: StopsStatus.loading);

  final StopsStatus status;
  final List<Stop> allStops;
  final List<Stop> filteredStops;
  final List<StopGroup> allGroups;
  final List<StopGroup> filteredGroups;
  final String searchQuery;
  final Object? error;
  final bool hasMore;
  final int nextOffset;
  final bool isLoadingMore;
  final bool isSearching;

  bool get isSearchActive => searchQuery.trim().isNotEmpty;

  StopsState copyWith({
    StopsStatus? status,
    List<Stop>? allStops,
    List<Stop>? filteredStops,
    List<StopGroup>? allGroups,
    List<StopGroup>? filteredGroups,
    String? searchQuery,
    Object? error,
    bool? hasMore,
    int? nextOffset,
    bool? isLoadingMore,
    bool? isSearching,
    bool clearError = false,
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
    );
  }
}
