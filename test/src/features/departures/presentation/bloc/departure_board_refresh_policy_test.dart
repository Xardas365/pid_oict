import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/core/errors/app_failure.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departure_board_refresh_policy.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_state.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

void main() {
  group('DepartureBoardRefreshPolicy', () {
    const policy = DepartureBoardRefreshPolicy();
    final stop = StopGroup.single(const Stop(id: 'U1', name: 'Andel'));
    final departure = Departure(
      routeShortName: '9',
      headsign: 'Spojovaci',
      departureTime: DateTime.utc(2026, 1, 1, 12),
    );
    const error = AppException(
      type: AppExceptionType.network,
      message: 'Network failed.',
    );

    test('keeps previous departures visible during refresh', () {
      final state = DeparturesState(
        status: DeparturesStatus.loaded,
        stop: stop,
        departures: [departure],
        refreshError: AppFailure.fromException(error),
      );

      final refreshingState = policy.refreshingWithPreviousData(state);

      expect(refreshingState.status, DeparturesStatus.loaded);
      expect(refreshingState.departures, [departure]);
      expect(refreshingState.isRefreshing, isTrue);
      expect(refreshingState.refreshError, isNull);
    });

    test('maps refresh failure with previous data to stale loaded state', () {
      final state = DeparturesState(
        status: DeparturesStatus.loaded,
        stop: stop,
        departures: [departure],
      );

      final failureState = policy.refreshFailure(
        previousState: state,
        stop: stop,
        error: error,
      );

      expect(failureState.status, DeparturesStatus.loaded);
      expect(failureState.departures, [departure]);
      expect(failureState.refreshError?.category, AppFailureCategory.network);
      expect(failureState.refreshError?.debugMessage, error.message);
      expect(failureState.isRefreshing, isFalse);
    });

    test('maps refresh failure without previous data to error state', () {
      final state = DeparturesState(status: DeparturesStatus.empty, stop: stop);

      final failureState = policy.refreshFailure(
        previousState: state,
        stop: stop,
        error: error,
      );

      expect(failureState.status, DeparturesStatus.error);
      expect(failureState.departures, isEmpty);
      expect(failureState.error?.category, AppFailureCategory.network);
      expect(failureState.error?.debugMessage, error.message);
    });
  });
}
