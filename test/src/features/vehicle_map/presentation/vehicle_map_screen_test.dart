import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_args.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_screen.dart';

import '../../../test_localized_app.dart';

void main() {
  group('VehicleMapScreen', () {
    testWidgets('shows loading state while position is loading', (
      tester,
    ) async {
      final completer = Completer<VehiclePosition>();

      await _pumpVehicleMapScreen(
        tester,
        repository: _FutureVehiclePositionRepository(completer.future),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Načítání polohy vozidla...'), findsOneWidget);

      completer.complete(_position('vehicle-123'));
    });

    testWidgets('shows map marker and last update after position loads', (
      tester,
    ) async {
      await _pumpVehicleMapScreen(
        tester,
        repository: _QueueVehiclePositionRepository([
          _VehiclePositionSuccess(
            VehiclePosition(
              vehicleId: 'vehicle-123',
              latitude: 50.0755,
              longitude: 14.4378,
              lastUpdated: DateTime(2026, 6, 22, 10, 20),
            ),
          ),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Poloha vozidla'), findsOneWidget);
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(find.text('Poslední aktualizace 10:20:00'), findsOneWidget);
      expect(
        find.text('Mapová data (c) přispěvatelé OpenStreetMap'),
        findsOneWidget,
      );
    });

    testWidgets('shows no-position state for invalid data', (
      tester,
    ) async {
      await _pumpVehicleMapScreen(
        tester,
        repository: _QueueVehiclePositionRepository([
          const _VehiclePositionFailure(
            AppException(
              type: AppExceptionType.invalidData,
              message: 'No data.',
            ),
          ),
        ]),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Aktuální poloha vozidla není dostupná.'),
        findsOneWidget,
      );
    });

    testWidgets('shows initial error and retries loading', (
      tester,
    ) async {
      final repository = _QueueVehiclePositionRepository([
        const _VehiclePositionFailure(
          AppException(
            type: AppExceptionType.network,
            message: 'Network error.',
          ),
        ),
        _VehiclePositionSuccess(_position('vehicle-123')),
      ]);

      await _pumpVehicleMapScreen(tester, repository: repository);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Nepodařilo se připojit ke Golemio API. '
          'Zkontrolujte připojení k internetu.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Zkusit znovu'));
      await tester.pumpAndSettle();

      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(repository.callCount, 2);
    });

    testWidgets('shows refreshing indicator while preserving marker', (
      tester,
    ) async {
      final refreshCompleter = Completer<VehiclePosition>();
      late VehicleMapBloc bloc;
      await _pumpVehicleMapScreen(
        tester,
        repository: _QueueVehiclePositionRepository([
          _VehiclePositionSuccess(_position('vehicle-123')),
          _VehiclePositionPending(refreshCompleter),
        ]),
        onBlocCreated: (createdBloc) {
          bloc = createdBloc;
        },
      );
      await tester.pumpAndSettle();

      bloc.add(const VehicleMapRefreshTicked());
      await bloc.stream.firstWhere((state) => state.isRefreshing);
      await tester.pump();

      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      refreshCompleter.complete(_position('vehicle-456', latitude: 50.08));
      await tester.pumpAndSettle();

      expect(find.text('Vozidlo vehicle-456'), findsOneWidget);
    });

    testWidgets('keeps last known position when refresh fails', (
      tester,
    ) async {
      late VehicleMapBloc bloc;
      final repository = _QueueVehiclePositionRepository([
        _VehiclePositionSuccess(_position('vehicle-123')),
        const _VehiclePositionFailure(
          AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
        ),
      ]);

      await _pumpVehicleMapScreen(
        tester,
        repository: repository,
        onBlocCreated: (createdBloc) {
          bloc = createdBloc;
        },
      );

      await tester.pumpAndSettle();

      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(repository.callCount, 1);

      bloc.add(const VehicleMapRefreshTicked());
      await tester.pumpAndSettle();

      expect(repository.callCount, 2);
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(
        find.text(
          'Zobrazuji poslední známou polohu. '
          'Golemio API neodpovědělo včas. Zkuste to prosím znovu.',
        ),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpVehicleMapScreen(
  WidgetTester tester, {
  required VehiclePositionRepository repository,
  void Function(VehicleMapBloc bloc)? onBlocCreated,
}) async {
  await tester.pumpWidget(
    localizedTestApp(
      home: BlocProvider(
        create: (_) {
          final args = VehicleMapArgs(
            vehicleId: VehicleId('service-3-1001'),
          );
          final bloc = VehicleMapBloc(
            GetVehiclePositionForVehicleUseCase(repository),
            pollingInterval: Duration.zero,
          )..add(VehicleMapStarted(args.vehicleId));
          onBlocCreated?.call(bloc);

          return bloc;
        },
        child: VehicleMapScreen(
          args: VehicleMapArgs(vehicleId: VehicleId('service-3-1001')),
          showMapTiles: false,
        ),
      ),
    ),
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

class _FutureVehiclePositionRepository implements VehiclePositionRepository {
  const _FutureVehiclePositionRepository(this._future);

  final Future<VehiclePosition> _future;

  @override
  Future<VehiclePosition> fetchVehiclePosition(VehicleId vehicleId) {
    return _future;
  }
}

class _QueueVehiclePositionRepository implements VehiclePositionRepository {
  _QueueVehiclePositionRepository(this._responses);

  final List<_VehiclePositionResponse> _responses;
  int callCount = 0;

  @override
  Future<VehiclePosition> fetchVehiclePosition(VehicleId vehicleId) async {
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
