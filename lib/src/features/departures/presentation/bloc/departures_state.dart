import '../../../stops/domain/stop.dart';
import '../../domain/departure.dart';

enum DeparturesStatus { loading, loaded, empty, error }

class DeparturesState {
  const DeparturesState({
    required this.status,
    this.stop,
    this.departures = const <Departure>[],
    this.error,
    this.refreshError,
    this.isRefreshing = false,
  });

  const DeparturesState.loading({Stop? stop})
    : this(status: DeparturesStatus.loading, stop: stop);

  final DeparturesStatus status;
  final Stop? stop;
  final List<Departure> departures;
  final Object? error;
  final Object? refreshError;
  final bool isRefreshing;

  bool get hasDepartures => departures.isNotEmpty;

  DeparturesState copyWith({
    DeparturesStatus? status,
    Stop? stop,
    List<Departure>? departures,
    Object? error,
    Object? refreshError,
    bool? isRefreshing,
    bool clearError = false,
    bool clearRefreshError = false,
  }) {
    return DeparturesState(
      status: status ?? this.status,
      stop: stop ?? this.stop,
      departures: departures ?? this.departures,
      error: clearError ? null : error ?? this.error,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
