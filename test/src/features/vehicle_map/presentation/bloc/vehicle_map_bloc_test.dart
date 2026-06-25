import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_state.dart';

void main() {
  group('VehicleMapBloc', () {
    test('loads initial vehicle position successfully', () async {
      final repository = _QueueVehiclePositionRepository([
        _VehiclePositionSuccess(_position('vehicle-1')),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const VehicleMapStarted('service-1'));
      await _waitForStatus(bloc, VehicleMapStatus.loaded);

      expect(bloc.state.position?.vehicleId, 'vehicle-1');
      expect(repository.receivedVehicleIds, ['service-1']);
    });

    test('maps initial invalid data to no-position state', () async {
      final repository = _QueueVehiclePositionRepository([
        const _VehiclePositionFailure(
          AppException(type: AppExceptionType.invalidData, message: 'No data.'),
        ),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const VehicleMapStarted('service-1'));
      await _waitForStatus(bloc, VehicleMapStatus.noPosition);

      expect(bloc.state.position, isNull);
      expect(bloc.state.error, isA<AppException>());
    });

    test('maps initial network failure to error state', () async {
      const expectedError = AppException(
        type: AppExceptionType.network,
        message: 'Network failed.',
      );
      final repository = _QueueVehiclePositionRepository([
        const _VehiclePositionFailure(expectedError),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const VehicleMapStarted('service-1'));
      await _waitForStatus(bloc, VehicleMapStatus.error);

      expect(bloc.state.error, same(expectedError));
      expect(bloc.state.position, isNull);
    });

    test('retry reloads after first-load error', () async {
      final repository = _QueueVehiclePositionRepository([
        const _VehiclePositionFailure(
          AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
        ),
        _VehiclePositionSuccess(_position('vehicle-1')),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const VehicleMapStarted('service-1'));
      await _waitForStatus(bloc, VehicleMapStatus.error);

      bloc.add(const VehicleMapRetried());
      await _waitForStatus(bloc, VehicleMapStatus.loaded);

      expect(bloc.state.position?.vehicleId, 'vehicle-1');
      expect(repository.callCount, 2);
    });

    test('refresh success updates the position', () async {
      final repository = _QueueVehiclePositionRepository([
        _VehiclePositionSuccess(_position('vehicle-1')),
        _VehiclePositionSuccess(_position('vehicle-1', latitude: 50.08)),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const VehicleMapStarted('service-1'));
      await _waitForLatitude(bloc, 50.0755);

      bloc.add(const VehicleMapRefreshTicked());
      await _waitForLatitude(bloc, 50.08);

      expect(bloc.state.staleError, isNull);
      expect(repository.callCount, 2);
    });

    test('refresh error keeps previous position and marks stale', () async {
      const expectedError = AppException(
        type: AppExceptionType.timeout,
        message: 'Timeout.',
      );
      final repository = _QueueVehiclePositionRepository([
        _VehiclePositionSuccess(_position('vehicle-1')),
        const _VehiclePositionFailure(expectedError),
      ]);
      final bloc = _createBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const VehicleMapStarted('service-1'));
      await _waitForLatitude(bloc, 50.0755);

      bloc.add(const VehicleMapRefreshTicked());
      await bloc.stream.firstWhere((state) => state.staleError != null);

      expect(bloc.state.status, VehicleMapStatus.loaded);
      expect(bloc.state.position?.latitude, 50.0755);
      expect(bloc.state.staleError, same(expectedError));
      expect(bloc.state.isRefreshing, isFalse);
    });

    test(
      'refresh with existing position does not emit full-screen loading',
      () async {
        final refreshCompleter = Completer<VehiclePosition>();
        final repository = _QueueVehiclePositionRepository([
          _VehiclePositionSuccess(_position('vehicle-1')),
          _VehiclePositionPending(refreshCompleter),
        ]);
        final bloc = _createBloc(repository);
        addTearDown(bloc.close);

        bloc.add(const VehicleMapStarted('service-1'));
        await _waitForLatitude(bloc, 50.0755);

        final emitted = <VehicleMapState>[];
        final subscription = bloc.stream.listen(emitted.add);
        addTearDown(subscription.cancel);

        bloc.add(const VehicleMapRefreshTicked());
        await bloc.stream.firstWhere((state) => state.isRefreshing);

        expect(bloc.state.status, VehicleMapStatus.loaded);
        expect(bloc.state.position?.latitude, 50.0755);
        expect(
          emitted.any((state) => state.status == VehicleMapStatus.loading),
          isFalse,
        );

        refreshCompleter.complete(_position('vehicle-1', latitude: 50.08));
        await _waitForLatitude(bloc, 50.08);
      },
    );

    test('polling subscription is cancelled on close', () async {
      var isTickerCancelled = false;
      final tickerController = StreamController<void>(
        onCancel: () {
          isTickerCancelled = true;
        },
      );
      final repository = _QueueVehiclePositionRepository([
        _VehiclePositionSuccess(_position('vehicle-1')),
      ]);
      final bloc = VehicleMapBloc(
        GetVehiclePositionForVehicleUseCase(repository),
        pollingInterval: const Duration(seconds: 1),
        tickerFactory: (_) => tickerController.stream,
      )..add(const VehicleMapStarted('service-1'));
      await _waitForStatus(bloc, VehicleMapStatus.loaded);

      await bloc.close();

      expect(isTickerCancelled, isTrue);
      await tickerController.close();
    });

    test('ticker triggers refresh with same vehicleId', () async {
      final tickerController = StreamController<void>();
      final repository = _QueueVehiclePositionRepository([
        _VehiclePositionSuccess(_position('vehicle-1')),
        _VehiclePositionSuccess(_position('vehicle-1', latitude: 50.08)),
      ]);
      final bloc = VehicleMapBloc(
        GetVehiclePositionForVehicleUseCase(repository),
        pollingInterval: const Duration(seconds: 1),
        tickerFactory: (_) => tickerController.stream,
      )..add(const VehicleMapStarted('service-1'));
      addTearDown(bloc.close);
      addTearDown(tickerController.close);

      await _waitForLatitude(bloc, 50.0755);

      tickerController.add(null);
      await _waitForLatitude(bloc, 50.08);

      expect(repository.receivedVehicleIds, ['service-1', 'service-1']);
    });
  });
}

VehicleMapBloc _createBloc(_QueueVehiclePositionRepository repository) {
  return VehicleMapBloc(
    GetVehiclePositionForVehicleUseCase(repository),
    pollingInterval: Duration.zero,
  );
}

Future<void> _waitForStatus(
  VehicleMapBloc bloc,
  VehicleMapStatus status,
) async {
  if (bloc.state.status == status && !bloc.state.isRefreshing) {
    return;
  }

  await bloc.stream.firstWhere(
    (state) => state.status == status && !state.isRefreshing,
  );
}

Future<void> _waitForLatitude(VehicleMapBloc bloc, double latitude) async {
  if (bloc.state.position?.latitude == latitude && !bloc.state.isRefreshing) {
    return;
  }

  await bloc.stream.firstWhere(
    (state) => state.position?.latitude == latitude && !state.isRefreshing,
  );
}

VehiclePosition _position(String vehicleId, {double latitude = 50.0755}) {
  return VehiclePosition(
    vehicleId: vehicleId,
    latitude: latitude,
    longitude: 14.4378,
    lastUpdated: DateTime(2026, 6, 22, 10, 20),
  );
}

class _QueueVehiclePositionRepository implements VehiclePositionRepository {
  _QueueVehiclePositionRepository(this._responses);

  final List<_VehiclePositionResponse> _responses;
  final receivedVehicleIds = <String>[];
  int callCount = 0;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String vehicleId) async {
    receivedVehicleIds.add(vehicleId);
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _VehiclePositionSuccess(:final position) => position,
      _VehiclePositionFailure(:final error) => _throwTestError(error),
      _VehiclePositionPending(:final completer) => completer.future,
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

sealed class _VehiclePositionResponse {
  const _VehiclePositionResponse();
}

class _VehiclePositionSuccess extends _VehiclePositionResponse {
  const _VehiclePositionSuccess(this.position);

  final VehiclePosition position;
}

class _VehiclePositionFailure extends _VehiclePositionResponse {
  const _VehiclePositionFailure(this.error);

  final Object error;
}

class _VehiclePositionPending extends _VehiclePositionResponse {
  const _VehiclePositionPending(this.completer);

  final Completer<VehiclePosition> completer;
}
