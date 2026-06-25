import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/core/errors/app_failure.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/load_departure_board_use_case.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_event.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_state.dart';
import 'package:pid_oict/src/features/departures/presentation/departure_time_display_mode.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

void main() {
  group('DeparturesBloc', () {
    final stop = StopGroup.single(const Stop(id: 'U1', name: 'Andel'));

    test('loads departures successfully', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      expect(bloc.state.departures.single.headsign, 'Nadrazi Hostivar');
      expect(repository.callCount, 1);
      expect(repository.receivedStops.single, stop);
    });

    test('stores error when initial load fails', () async {
      const expectedError = AppException(
        type: AppExceptionType.network,
        message: 'Network failed.',
      );
      final repository = _QueueDeparturesRepository([
        const _DeparturesFailure(expectedError),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.error);

      expect(bloc.state.error?.category, AppFailureCategory.network);
      expect(bloc.state.error?.debugMessage, expectedError.message);
      expect(bloc.state.departures, isEmpty);
    });

    test('empty result becomes empty state', () async {
      final repository = _QueueDeparturesRepository([
        const _DeparturesSuccess([]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.empty);

      expect(bloc.state.departures, isEmpty);
    });

    test('retry reloads after error', () async {
      final repository = _QueueDeparturesRepository([
        const _DeparturesFailure(
          AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
        ),
        _DeparturesSuccess([_departure('Vypich')]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.error);

      bloc.add(const DeparturesRetried());
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      expect(bloc.state.departures.single.headsign, 'Vypich');
      expect(repository.callCount, 2);
    });

    test('refresh success replaces departures', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesSuccess([_departure('Vypich')]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');

      bloc.add(const DeparturesRefreshed());
      await _waitForDeparture(bloc, 'Vypich');

      expect(bloc.state.refreshError, isNull);
      expect(repository.callCount, 2);
    });

    test('selects transport filter and exposes filtered departures', () async {
      final tramDeparture = _departure('Sidliste Repy', routeShortName: '10');
      final busDeparture = _departure(
        'Koleje Strahov',
        routeShortName: '176',
        routeType: 'bus',
      );
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([tramDeparture, busDeparture]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      bloc.add(const DeparturesTransportFilterSelected(PidTransportMode.bus));
      await bloc.stream.firstWhere(
        (state) => state.selectedTransportMode == PidTransportMode.bus,
      );

      expect(bloc.state.visibleDepartures, [busDeparture]);
    });

    test('refresh falls back to all when selected type disappears', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([
          _departure('Sidliste Repy', routeShortName: '10'),
          _departure('Koleje Strahov', routeShortName: '176', routeType: 'bus'),
        ]),
        _DeparturesSuccess([
          _departure('Nadrazi Hostivar', routeShortName: '10'),
        ]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      bloc.add(const DeparturesTransportFilterSelected(PidTransportMode.bus));
      await bloc.stream.firstWhere(
        (state) => state.selectedTransportMode == PidTransportMode.bus,
      );

      bloc.add(const DeparturesRefreshed());
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');

      expect(bloc.state.selectedTransportMode, isNull);
      expect(bloc.state.visibleDepartures.single.headsign, 'Nadrazi Hostivar');
    });

    test('stores last successful refresh timestamp', () async {
      final updatedAt = DateTime(2026, 6, 22, 10, 30, 15);
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
      ]);
      final bloc = _createBloc(repository, now: () => updatedAt);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      expect(bloc.state.lastUpdated, updatedAt);
    });

    test('toggles departure time display mode', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      expect(
        bloc.state.timeDisplayMode,
        DepartureTimeDisplayMode.relativeFirst,
      );

      bloc.add(const DeparturesTimeDisplayModeToggled());
      await bloc.stream.firstWhere(
        (state) => state.timeDisplayMode == DepartureTimeDisplayMode.clockFirst,
      );

      bloc.add(const DeparturesTimeDisplayModeToggled());
      await bloc.stream.firstWhere(
        (state) =>
            state.timeDisplayMode == DepartureTimeDisplayMode.relativeFirst,
      );
    });

    test('refresh preserves departure time display mode', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesSuccess([_departure('Vypich')]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.loaded);

      bloc.add(const DeparturesTimeDisplayModeToggled());
      await bloc.stream.firstWhere(
        (state) => state.timeDisplayMode == DepartureTimeDisplayMode.clockFirst,
      );

      bloc.add(const DeparturesRefreshed());
      await _waitForDeparture(bloc, 'Vypich');

      expect(bloc.state.timeDisplayMode, DepartureTimeDisplayMode.clockFirst);
    });

    test('refresh error keeps previous departures visible', () async {
      const expectedError = AppException(
        type: AppExceptionType.network,
        message: 'Network failed.',
      );
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        const _DeparturesFailure(expectedError),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');

      bloc.add(const DeparturesRefreshed());
      await bloc.stream.firstWhere((state) => state.refreshError != null);

      expect(bloc.state.status, DeparturesStatus.loaded);
      expect(bloc.state.departures.single.headsign, 'Nadrazi Hostivar');
      expect(bloc.state.refreshError?.category, AppFailureCategory.network);
      expect(bloc.state.refreshError?.debugMessage, expectedError.message);
      expect(bloc.state.isRefreshing, isFalse);
    });

    test(
      'refresh with previous data does not emit full-screen loading',
      () async {
        final refreshCompleter = Completer<List<Departure>>();
        final repository = _QueueDeparturesRepository([
          _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
          _DeparturesPending(refreshCompleter),
        ]);
        final bloc = _createBloc(repository);
        addTearDown(bloc.close);

        bloc.add(DeparturesStarted(stop));
        await _waitForDeparture(bloc, 'Nadrazi Hostivar');

        final emitted = <DeparturesState>[];
        final subscription = bloc.stream.listen(emitted.add);
        addTearDown(subscription.cancel);

        bloc.add(const DeparturesRefreshed());
        await bloc.stream.firstWhere((state) => state.isRefreshing);

        expect(bloc.state.status, DeparturesStatus.loaded);
        expect(bloc.state.departures.single.headsign, 'Nadrazi Hostivar');
        expect(
          emitted.any((state) => state.status == DeparturesStatus.loading),
          isFalse,
        );

        refreshCompleter.complete([_departure('Vypich')]);
        await _waitForDeparture(bloc, 'Vypich');
      },
    );

    test('ignores duplicate simultaneous refresh requests', () async {
      final refreshCompleter = Completer<List<Departure>>();
      final firstCompletion = Completer<void>();
      final secondCompletion = Completer<void>();
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesPending(refreshCompleter),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');

      bloc
        ..add(DeparturesRefreshed(completion: firstCompletion))
        ..add(DeparturesRefreshed(completion: secondCompletion));
      await bloc.stream.firstWhere((state) => state.isRefreshing);
      await Future<void>.delayed(Duration.zero);

      expect(repository.callCount, 2);
      expect(secondCompletion.isCompleted, isTrue);

      refreshCompleter.complete([_departure('Vypich')]);
      await firstCompletion.future;

      expect(bloc.state.departures.single.headsign, 'Vypich');
    });

    test('periodic refresh reloads while the bloc is open', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesSuccess([_departure('Vypich')]),
      ]);
      final bloc = _createBloc(
        repository,
        refreshInterval: const Duration(milliseconds: 10),
      );
      addTearDown(bloc.close);

      bloc.add(DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');
      await _waitForDeparture(bloc, 'Vypich');

      expect(repository.callCount, 2);
    });

    test('close cancels periodic refresh timer', () async {
      final periodicCompleter = Completer<List<Departure>>();
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesPending(periodicCompleter),
      ]);
      final bloc = _createBloc(
        repository,
        refreshInterval: const Duration(milliseconds: 10),
      )..add(DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');
      await _waitForCallCount(repository, 2);

      await bloc.close();
      periodicCompleter.complete([_departure('Vypich')]);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(repository.callCount, 2);
    });
  });
}

DeparturesBloc _createBloc(
  _QueueDeparturesRepository repository, {
  Duration refreshInterval = Duration.zero,
  DateTime Function()? now,
}) {
  return DeparturesBloc(
    LoadDepartureBoardUseCase(repository),
    refreshInterval: refreshInterval,
    now: now,
  );
}

Future<void> _waitForStatus(
  DeparturesBloc bloc,
  DeparturesStatus status,
) async {
  if (bloc.state.status == status && !bloc.state.isRefreshing) {
    return;
  }

  await bloc.stream.firstWhere(
    (state) => state.status == status && !state.isRefreshing,
  );
}

Future<void> _waitForDeparture(DeparturesBloc bloc, String headsign) async {
  if (bloc.state.departures.any(
    (departure) => departure.headsign == headsign,
  )) {
    return;
  }

  await bloc.stream.firstWhere(
    (state) =>
        state.departures.any((departure) => departure.headsign == headsign),
  );
}

Future<void> _waitForCallCount(
  _QueueDeparturesRepository repository,
  int callCount,
) async {
  while (repository.callCount < callCount) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

Departure _departure(
  String headsign, {
  String routeShortName = '22',
  String? routeType,
}) {
  return Departure(
    routeShortName: routeShortName,
    routeType: routeType,
    headsign: headsign,
    departureTime: DateTime(2026, 6, 22, 10, 15),
    gtfsTripId: 'trip-22-123',
  );
}

class _QueueDeparturesRepository implements DeparturesRepository {
  _QueueDeparturesRepository(this._responses);

  final List<_DeparturesResponse> _responses;
  final receivedStops = <StopGroup>[];
  int callCount = 0;

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) async {
    receivedStops.add(stop);
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _DeparturesSuccess(:final departures) => departures,
      _DeparturesFailure(:final error) => _throwTestError(error),
      _DeparturesPending(:final completer) => completer.future,
    };
  }
}

Never _throwTestError(Object error) {
  if (error is Exception) {
    throw error;
  }

  if (error is Error) {
    throw error;
  }

  throw StateError(error.toString());
}

sealed class _DeparturesResponse {
  const _DeparturesResponse();
}

class _DeparturesSuccess extends _DeparturesResponse {
  const _DeparturesSuccess(this.departures);

  final List<Departure> departures;
}

class _DeparturesFailure extends _DeparturesResponse {
  const _DeparturesFailure(this.error);

  final Object error;
}

class _DeparturesPending extends _DeparturesResponse {
  const _DeparturesPending(this.completer);

  final Completer<List<Departure>> completer;
}
