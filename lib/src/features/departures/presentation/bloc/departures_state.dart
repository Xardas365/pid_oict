import '../../../../core/domain/pid_line_type.dart';
import '../../../stops/domain/stop_group.dart';
import '../../domain/departure.dart';
import '../departure_transport_filter.dart';

enum DeparturesStatus { loading, loaded, empty, error }

class DeparturesState {
  const DeparturesState({
    required this.status,
    this.stop,
    this.departures = const <Departure>[],
    this.error,
    this.refreshError,
    this.isRefreshing = false,
    this.selectedTransportMode,
    this.lastUpdated,
  });

  const DeparturesState.loading({StopGroup? stop})
    : this(status: DeparturesStatus.loading, stop: stop);

  final DeparturesStatus status;
  final StopGroup? stop;
  final List<Departure> departures;
  final Object? error;
  final Object? refreshError;
  final bool isRefreshing;
  final PidTransportMode? selectedTransportMode;
  final DateTime? lastUpdated;

  bool get hasDepartures => departures.isNotEmpty;
  List<PidTransportMode> get availableTransportModes {
    return deriveDepartureTransportModes(departures);
  }

  List<Departure> get visibleDepartures {
    return filterDeparturesByTransportMode(departures, selectedTransportMode);
  }

  PidLineType get representativeLineType {
    return representativeLineTypeForDepartures(departures);
  }

  DeparturesState copyWith({
    DeparturesStatus? status,
    StopGroup? stop,
    List<Departure>? departures,
    Object? error,
    Object? refreshError,
    bool? isRefreshing,
    PidTransportMode? selectedTransportMode,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearRefreshError = false,
    bool clearSelectedTransportMode = false,
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
      selectedTransportMode: clearSelectedTransportMode
          ? null
          : selectedTransportMode ?? this.selectedTransportMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
