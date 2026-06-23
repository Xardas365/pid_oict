import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/get_departures_for_stop_use_case.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_event.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_state.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

void main() {
  group('DeparturesBloc', () {
    const stop = Stop(id: 'U1', name: 'Andel');

    test('loads departures successfully', () async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DeparturesStarted(stop));
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

      bloc.add(const DeparturesStarted(stop));
      await _waitForStatus(bloc, DeparturesStatus.error);

      expect(bloc.state.error, same(expectedError));
      expect(bloc.state.departures, isEmpty);
    });

    test('empty result becomes empty state', () async {
      final repository = _QueueDeparturesRepository([
        const _DeparturesSuccess([]),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DeparturesStarted(stop));
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

      bloc.add(const DeparturesStarted(stop));
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

      bloc.add(const DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');

      bloc.add(const DeparturesRefreshed());
      await _waitForDeparture(bloc, 'Vypich');

      expect(bloc.state.refreshError, isNull);
      expect(repository.callCount, 2);
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

      bloc.add(const DeparturesStarted(stop));
      await _waitForDeparture(bloc, 'Nadrazi Hostivar');

      bloc.add(const DeparturesRefreshed());
      await bloc.stream.firstWhere((state) => state.refreshError != null);

      expect(bloc.state.status, DeparturesStatus.loaded);
      expect(bloc.state.departures.single.headsign, 'Nadrazi Hostivar');
      expect(bloc.state.refreshError, same(expectedError));
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

        bloc.add(const DeparturesStarted(stop));
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
  });
}

DeparturesBloc _createBloc(_QueueDeparturesRepository repository) {
  return DeparturesBloc(GetDeparturesForStopUseCase(repository));
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

Departure _departure(String headsign) {
  return Departure(
    routeShortName: '22',
    headsign: headsign,
    departureTime: DateTime(2026, 6, 22, 10, 15),
    gtfsTripId: 'trip-22-123',
  );
}

class _QueueDeparturesRepository implements DeparturesRepository {
  _QueueDeparturesRepository(this._responses);

  final List<_DeparturesResponse> _responses;
  final receivedStops = <Stop>[];
  var callCount = 0;

  @override
  Future<List<Departure>> fetchDeparturesForStop(Stop stop) async {
    receivedStops.add(stop);
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _DeparturesSuccess(:final departures) => departures,
      _DeparturesFailure(:final error) => throw error,
      _DeparturesPending(:final completer) => completer.future,
    };
  }
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
