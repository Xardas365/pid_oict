import '../../../../core/errors/app_failure.dart';
import '../../../stops/domain/stop_group.dart';
import 'departures_state.dart';

class DepartureBoardRefreshPolicy {
  const DepartureBoardRefreshPolicy();

  bool canStartRefresh({
    required DeparturesState state,
    required bool refreshInProgress,
  }) {
    return !refreshInProgress && state.stop != null;
  }

  bool shouldKeepDeparturesVisible(DeparturesState state) {
    return state.departures.isNotEmpty;
  }

  DeparturesState refreshingWithPreviousData(DeparturesState state) {
    return state.copyWith(
      status: DeparturesStatus.loaded,
      departures: state.departures,
      isRefreshing: true,
      clearError: true,
      clearRefreshError: true,
    );
  }

  DeparturesState refreshFailure({
    required DeparturesState previousState,
    required StopGroup stop,
    required Object error,
  }) {
    final failure = AppFailure.fromObject(error);
    if (shouldKeepDeparturesVisible(previousState)) {
      return previousState.copyWith(
        status: DeparturesStatus.loaded,
        departures: previousState.departures,
        refreshError: failure,
        isRefreshing: false,
        clearError: true,
      );
    }

    return DeparturesState(
      status: DeparturesStatus.error,
      stop: stop,
      error: failure,
    );
  }
}
