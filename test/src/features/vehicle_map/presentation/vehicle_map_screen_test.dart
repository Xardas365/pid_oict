import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_args.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_screen.dart';
import 'package:pid_oict/src/shared/widgets/live_relative_time_text.dart';

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
            _position(
              'vehicle-123',
              lastUpdated: DateTime(2026, 6, 22, 10, 20),
            ),
          ),
        ]),
      );

      await tester.pumpAndSettle();

      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.options.initialCameraFit, isNull);
      expect(map.options.initialCenter.latitude, closeTo(50.0755, 0.0001));
      expect(map.options.initialCenter.longitude, closeTo(14.4378, 0.0001));
      expect(map.options.initialZoom, 15);
      final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
      expect(markerLayer.markers.single.width, inInclusiveRange(44, 56));
      expect(markerLayer.markers.single.height, inInclusiveRange(44, 56));
      expect(markerLayer.markers.single.alignment, Alignment.topCenter);
      final polylineLayer = tester.widget<PolylineLayer>(
        find.byType(PolylineLayer),
      );
      expect(polylineLayer.polylines, hasLength(2));
      expect(polylineLayer.polylines.first.strokeWidth, 5);
      expect(polylineLayer.polylines.last.strokeWidth, 6.8);
      expect(
        polylineLayer.polylines.first.color,
        isNot(polylineLayer.polylines.last.color),
      );
      expect(
        polylineLayer.polylines.first.points.last.latitude,
        closeTo(50.0755, 0.0001),
      );
      expect(
        polylineLayer.polylines.first.points.last.longitude,
        closeTo(14.4378, 0.0001),
      );
      expect(
        polylineLayer.polylines.last.points.first.latitude,
        closeTo(50.0755, 0.0001),
      );
      expect(
        polylineLayer.polylines.last.points.first.longitude,
        closeTo(14.4378, 0.0001),
      );
      final circleLayer = tester.widget<CircleLayer>(find.byType(CircleLayer));
      expect(circleLayer.circles, hasLength(4));
      final traveledStop = circleLayer.circles.singleWhere(
        (circle) =>
            circle.key == const ValueKey('vehicle-route-stop-traveled-1'),
      );
      final currentStop = circleLayer.circles.singleWhere(
        (circle) =>
            circle.key == const ValueKey('vehicle-route-stop-current-2'),
      );
      final nextStop = circleLayer.circles.singleWhere(
        (circle) => circle.key == const ValueKey('vehicle-route-stop-next-3'),
      );
      final destinationStop = circleLayer.circles.singleWhere(
        (circle) =>
            circle.key == const ValueKey('vehicle-route-stop-destination-4'),
      );
      expect(currentStop.radius, greaterThan(nextStop.radius));
      expect(nextStop.radius, greaterThan(traveledStop.radius));
      expect(destinationStop.radius, greaterThan(nextStop.radius));
      expect(traveledStop.radius, lessThan(3));
      expect(find.text('10 – Sidliste Repy'), findsWidgets);
      expect(find.byTooltip('Zpět na odjezdy'), findsOneWidget);
      expect(find.byTooltip('Vycentrovat vozidlo'), findsOneWidget);
      expect(find.byKey(const ValueKey('vehicle-map-marker')), findsOneWidget);
      expect(find.textContaining('vehicle-123'), findsNothing);
      expect(find.text('Sidliste Repy'), findsOneWidget);
      expect(find.text('+1 min'), findsOneWidget);
      expect(find.text('Další: Narodni divadlo v 10:24'), findsOneWidget);
      expect(
        find.text(
          'Tramvaj · Dopravce DPP · Bezbariérové · Klimatizace · USB nabíjení',
        ),
        findsOneWidget,
      );
      expect(find.byType(LiveRelativeTimeText), findsOneWidget);
      expect(find.text('Poslední aktualizace 10:20:00'), findsOneWidget);
      expect(
        find.text('Mapová data (c) přispěvatelé OpenStreetMap'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('vehicle-map-info-panel')),
          matching: find.byKey(const ValueKey('vehicle-map-attribution')),
        ),
        findsNothing,
      );
      expect(map.children.last, isA<MarkerLayer>());

      await tester.tap(find.byTooltip('Vycentrovat vozidlo'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows live relative last update in the info panel', (
      tester,
    ) async {
      await _pumpVehicleMapScreen(
        tester,
        repository: _QueueVehiclePositionRepository([
          _VehiclePositionSuccess(
            _position('vehicle-123', lastUpdated: DateTime.now()),
          ),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LiveRelativeTimeText), findsOneWidget);
      expect(
        find.textContaining('Poslední aktualizace před'),
        findsOneWidget,
      );
    });

    testWidgets('starts long routes around the current vehicle', (
      tester,
    ) async {
      await _pumpVehicleMapScreen(
        tester,
        repository: _QueueVehiclePositionRepository([
          _VehiclePositionSuccess(_longTrainPosition()),
        ]),
      );

      await tester.pumpAndSettle();

      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.options.initialCameraFit, isNull);
      expect(map.options.initialCenter.latitude, closeTo(50.0755, 0.0001));
      expect(map.options.initialCenter.longitude, closeTo(14.4378, 0.0001));
      expect(map.options.initialZoom, 15);
      expect(find.byTooltip('Vycentrovat vozidlo'), findsOneWidget);
      expect(find.byKey(const ValueKey('vehicle-map-marker')), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is PolylineLayer),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('vehicle-map-static-background')),
        findsOneWidget,
      );
    });

    test('focus coordinates prefer the current vehicle neighborhood', () {
      final coordinates = vehicleMapFocusCoordinatesForTesting(
        _longTrainPosition(),
      );

      expect(
        coordinates.any(
          (coordinate) =>
              coordinate.latitude == 50.0755 && coordinate.longitude == 14.4378,
        ),
        isTrue,
      );
      expect(
        coordinates.any(
          (coordinate) =>
              coordinate.latitude == 50.0619 && coordinate.longitude == 14.4083,
        ),
        isTrue,
      );
      expect(
        coordinates.any(
          (coordinate) =>
              coordinate.latitude == 49.9637 && coordinate.longitude == 14.0713,
        ),
        isFalse,
      );
    });

    test('recenter target uses only the current vehicle position', () {
      final position = _longTrainPosition();
      final point = vehicleMapRecenterPointForTesting(position);
      final contextCoordinates = vehicleMapFocusCoordinatesForTesting(position);

      expect(point.latitude, closeTo(50.0755, 0.0001));
      expect(point.longitude, closeTo(14.4378, 0.0001));
      expect(contextCoordinates, hasLength(greaterThan(1)));
      expect(
        contextCoordinates.any(
          (coordinate) =>
              coordinate.latitude == 50.0619 && coordinate.longitude == 14.4083,
        ),
        isTrue,
      );
    });

    test('recenter zoom preserves reasonable zoom and clamps extremes', () {
      expect(vehicleMapRecenterZoomForTesting(10), 15);
      expect(vehicleMapRecenterZoomForTesting(16), 16);
      expect(vehicleMapRecenterZoomForTesting(20), 17.5);
    });

    testWidgets('falls back to a single route line without distance metadata', (
      tester,
    ) async {
      await _pumpVehicleMapScreen(
        tester,
        repository: _QueueVehiclePositionRepository([
          _VehiclePositionSuccess(_positionWithoutRouteDistances()),
        ]),
      );

      await tester.pumpAndSettle();

      final polylineLayer = tester.widget<PolylineLayer>(
        find.byType(PolylineLayer),
      );
      expect(polylineLayer.polylines, hasLength(1));
      expect(polylineLayer.polylines.single.points, hasLength(3));
      expect(polylineLayer.polylines.single.points.first.latitude, 50.0748);
      expect(polylineLayer.polylines.single.points.last.latitude, 50.0763);
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

      expect(find.text('10 – Sidliste Repy'), findsWidgets);
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

      expect(find.byKey(const ValueKey('vehicle-map-marker')), findsOneWidget);
      expect(find.text('10 – Sidliste Repy'), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      refreshCompleter.complete(_position('vehicle-456', latitude: 50.08));
      await tester.pumpAndSettle();

      expect(find.textContaining('vehicle-456'), findsNothing);
      expect(find.text('10 – Sidliste Repy'), findsWidgets);
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

      expect(find.text('10 – Sidliste Repy'), findsWidgets);
      expect(repository.callCount, 1);

      bloc.add(const VehicleMapRefreshTicked());
      await tester.pumpAndSettle();

      expect(repository.callCount, 2);
      expect(find.byKey(const ValueKey('vehicle-map-marker')), findsOneWidget);
      expect(find.text('10 – Sidliste Repy'), findsWidgets);
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
          final args = _vehicleMapArgs();
          final bloc = VehicleMapBloc(
            GetVehiclePositionForVehicleUseCase(repository),
            pollingInterval: Duration.zero,
          )..add(VehicleMapStarted(args.vehicleId));
          onBlocCreated?.call(bloc);

          return bloc;
        },
        child: VehicleMapScreen(
          args: _vehicleMapArgs(),
          showMapTiles: false,
        ),
      ),
    ),
  );
}

VehicleMapArgs _vehicleMapArgs() {
  return VehicleMapArgs(
    vehicleId: VehicleId('service-3-1001'),
    routeShortName: '10',
    headsign: 'Sidliste Repy',
    routeType: 'tram',
    lineType: PidLineType.tram,
  );
}

VehiclePosition _position(
  String vehicleId, {
  double latitude = 50.0755,
  DateTime? lastUpdated,
}) {
  return VehiclePosition(
    vehicleId: vehicleId,
    latitude: latitude,
    longitude: 14.4378,
    routeShortName: '10',
    routeType: 'tram',
    headsign: 'Sidliste Repy',
    delaySeconds: 60,
    shapeDistTraveled: 1200,
    lastStopSequence: 2,
    routePoints: const [
      VehicleRoutePoint(
        latitude: 50.0748,
        longitude: 14.4358,
        shapeDistTraveled: 900,
      ),
      VehicleRoutePoint(
        latitude: 50.0755,
        longitude: 14.4378,
        shapeDistTraveled: 1200,
      ),
      VehicleRoutePoint(
        latitude: 50.0763,
        longitude: 14.4402,
        shapeDistTraveled: 1500,
      ),
      VehicleRoutePoint(
        latitude: 50.0771,
        longitude: 14.4424,
        shapeDistTraveled: 1800,
      ),
    ],
    stopTimes: [
      const VehicleRouteStop(
        name: 'Andel',
        latitude: 50.0748,
        longitude: 14.4358,
        stopSequence: 1,
        zoneId: 'P',
        shapeDistTraveled: 900,
      ),
      const VehicleRouteStop(
        name: 'Zborovska',
        latitude: 50.0755,
        longitude: 14.4378,
        stopSequence: 2,
        zoneId: 'P',
        shapeDistTraveled: 1200,
      ),
      VehicleRouteStop(
        name: 'Narodni divadlo',
        latitude: 50.0763,
        longitude: 14.4402,
        stopSequence: 3,
        zoneId: 'P',
        shapeDistTraveled: 1500,
        realtimeArrivalTime: DateTime(2026, 6, 22, 10, 24),
      ),
      const VehicleRouteStop(
        name: 'Sidliste Repy',
        latitude: 50.0771,
        longitude: 14.4424,
        stopSequence: 4,
        zoneId: 'P',
        shapeDistTraveled: 1800,
      ),
    ],
    vehicleDescriptor: const VehicleDescriptor(
      operator: 'DPP',
      isWheelchairAccessible: true,
      isAirConditioned: true,
      hasUsbChargers: true,
    ),
    lastUpdated: lastUpdated ?? DateTime(2026, 6, 22, 10, 20),
  );
}

VehiclePosition _positionWithoutRouteDistances() {
  return VehiclePosition(
    vehicleId: 'vehicle-123',
    latitude: 50.0755,
    longitude: 14.4378,
    routeShortName: '10',
    routeType: 'tram',
    headsign: 'Sidliste Repy',
    routePoints: const [
      VehicleRoutePoint(latitude: 50.0748, longitude: 14.4358),
      VehicleRoutePoint(latitude: 50.0755, longitude: 14.4378),
      VehicleRoutePoint(latitude: 50.0763, longitude: 14.4402),
    ],
    lastUpdated: DateTime(2026, 6, 22, 10, 20),
  );
}

VehiclePosition _longTrainPosition() {
  return VehiclePosition(
    vehicleId: 'train-service-1',
    latitude: 50.0755,
    longitude: 14.4378,
    routeShortName: 'S7',
    routeType: 'train',
    headsign: 'Beroun',
    delaySeconds: 60,
    shapeDistTraveled: 90000,
    lastStopSequence: 12,
    routePoints: const [
      VehicleRoutePoint(
        latitude: 50.0833,
        longitude: 14.4667,
        shapeDistTraveled: 85000,
      ),
      VehicleRoutePoint(
        latitude: 50.0796,
        longitude: 14.4511,
        shapeDistTraveled: 88000,
      ),
      VehicleRoutePoint(
        latitude: 50.0755,
        longitude: 14.4378,
        shapeDistTraveled: 90000,
      ),
      VehicleRoutePoint(
        latitude: 50.0719,
        longitude: 14.4212,
        shapeDistTraveled: 91200,
      ),
      VehicleRoutePoint(
        latitude: 50.0537,
        longitude: 14.2906,
        shapeDistTraveled: 105000,
      ),
      VehicleRoutePoint(
        latitude: 49.9637,
        longitude: 14.0713,
        shapeDistTraveled: 128000,
      ),
    ],
    stopTimes: const [
      VehicleRouteStop(
        name: 'Praha hlavni nadrazi',
        latitude: 50.0833,
        longitude: 14.4667,
        stopSequence: 10,
        shapeDistTraveled: 85000,
      ),
      VehicleRouteStop(
        name: 'Praha-Smichov',
        latitude: 50.0619,
        longitude: 14.4083,
        stopSequence: 13,
        shapeDistTraveled: 93000,
      ),
      VehicleRouteStop(
        name: 'Beroun',
        latitude: 49.9637,
        longitude: 14.0713,
        stopSequence: 18,
        shapeDistTraveled: 128000,
      ),
    ],
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
