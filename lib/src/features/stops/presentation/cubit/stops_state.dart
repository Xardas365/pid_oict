import '../../domain/stop.dart';

enum StopsStatus { loading, loaded, empty, error }

class StopsState {
  const StopsState({
    required this.status,
    this.allStops = const <Stop>[],
    this.filteredStops = const <Stop>[],
    this.searchQuery = '',
    this.error,
  });

  const StopsState.loading() : this(status: StopsStatus.loading);

  final StopsStatus status;
  final List<Stop> allStops;
  final List<Stop> filteredStops;
  final String searchQuery;
  final Object? error;

  bool get isSearchActive => searchQuery.trim().isNotEmpty;

  StopsState copyWith({
    StopsStatus? status,
    List<Stop>? allStops,
    List<Stop>? filteredStops,
    String? searchQuery,
    Object? error,
    bool clearError = false,
  }) {
    return StopsState(
      status: status ?? this.status,
      allStops: allStops ?? this.allStops,
      filteredStops: filteredStops ?? this.filteredStops,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : error ?? this.error,
    );
  }
}
