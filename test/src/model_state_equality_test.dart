import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_failure.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_state.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/stops/domain/stops_cache_snapshot.dart';
import 'package:pid_oict/src/features/stops/domain/stops_page.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_state.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_state.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_args.dart';

void main() {
  group('model and state equality', () {
    test('compares stop domain values by content', () {
      final first = _stop(id: 'U1', name: 'Andel');
      final second = _stop(id: 'U1', name: 'Andel');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(_stop(id: 'U2', name: 'Andel')));
    });

    test('compares grouped stops by nested stop lists', () {
      final first = StopGroup.single(_stop(id: 'U1', name: 'Andel'));
      final second = StopGroup.single(_stop(id: 'U1', name: 'Andel'));

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(StopGroup.single(_stop(id: 'U2', name: 'Flora'))));
    });

    test('compares departure values by content', () {
      final first = _departure(vehicleId: 'service-1');
      final second = _departure(vehicleId: 'service-1');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(_departure(vehicleId: 'service-2')));
    });

    test('compares vehicle values by normalized identifiers and content', () {
      expect(VehicleId(' service-1 '), VehicleId('service-1'));
      expect(
        VehicleMapArgs(vehicleId: VehicleId(' service-1 ')),
        VehicleMapArgs(vehicleId: VehicleId('service-1')),
      );

      final first = _vehiclePosition(vehicleId: 'service-1');
      final second = _vehiclePosition(vehicleId: 'service-1');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(_vehiclePosition(vehicleId: 'service-2')));
    });

    test('compares cache and page snapshots by list content', () {
      final stop = _stop(id: 'U1', name: 'Andel');
      final cachedAt = DateTime.utc(2026, 6, 25, 10);

      expect(
        StopsPage(
          stops: [stop],
          limit: 500,
          offset: 0,
          rawReturnedCount: 1,
          hasMore: false,
        ),
        StopsPage(
          stops: [_stop(id: 'U1', name: 'Andel')],
          limit: 500,
          offset: 0,
          rawReturnedCount: 1,
          hasMore: false,
        ),
      );
      expect(
        StopsCacheSnapshot(cachedAt: cachedAt, stops: [stop]),
        StopsCacheSnapshot(
          cachedAt: cachedAt,
          stops: [_stop(id: 'U1', name: 'Andel')],
        ),
      );
    });

    test('compares Bloc and Cubit states by content', () {
      final stop = _stop(id: 'U1', name: 'Andel');
      final stopGroup = StopGroup.single(stop);
      final departure = _departure(vehicleId: 'service-1');
      final failure = AppFailure.unknown(StateError('boom'));
      final lastUpdated = DateTime.utc(2026, 6, 25, 10);
      final position = _vehiclePosition(vehicleId: 'service-1');

      expect(
        StopsState(
          status: StopsStatus.loaded,
          allStops: [stop],
          filteredStops: [stop],
          allGroups: [stopGroup],
          filteredGroups: [stopGroup],
          favoriteGroupIds: [stopGroup.id],
        ),
        StopsState(
          status: StopsStatus.loaded,
          allStops: [_stop(id: 'U1', name: 'Andel')],
          filteredStops: [_stop(id: 'U1', name: 'Andel')],
          allGroups: [StopGroup.single(_stop(id: 'U1', name: 'Andel'))],
          filteredGroups: [StopGroup.single(_stop(id: 'U1', name: 'Andel'))],
          favoriteGroupIds: [stopGroup.id],
        ),
      );
      expect(
        DeparturesState(
          status: DeparturesStatus.loaded,
          stop: stopGroup,
          departures: [departure],
          refreshError: failure,
          lastUpdated: lastUpdated,
        ),
        DeparturesState(
          status: DeparturesStatus.loaded,
          stop: StopGroup.single(_stop(id: 'U1', name: 'Andel')),
          departures: [_departure(vehicleId: 'service-1')],
          refreshError: AppFailure.unknown(StateError('boom')),
          lastUpdated: lastUpdated,
        ),
      );
      expect(
        VehicleMapState(
          status: VehicleMapStatus.loaded,
          vehicleId: VehicleId('service-1'),
          position: position,
          staleError: failure,
        ),
        VehicleMapState(
          status: VehicleMapStatus.loaded,
          vehicleId: VehicleId(' service-1 '),
          position: _vehiclePosition(vehicleId: 'service-1'),
          staleError: AppFailure.unknown(StateError('boom')),
        ),
      );
    });
  });
}

Stop _stop({required String id, required String name}) {
  return Stop(
    id: id,
    name: name,
    platformCode: 'A',
    zoneId: 'P',
    locationType: 0,
    parentStationId: 'S1',
    wheelchairBoarding: 1,
    levelId: 'L1',
    latitude: 50.078,
    longitude: 14.463,
  );
}

Departure _departure({required String vehicleId}) {
  return Departure(
    routeShortName: '10',
    headsign: 'Sidliste Repy',
    departureTime: DateTime.utc(2026, 6, 25, 10),
    routeType: 'tram',
    delaySeconds: 60,
    platform: 'A',
    stopId: 'U1',
    gtfsTripId: 'trip-1',
    vehicleId: vehicleId,
    isWheelchairAccessible: true,
  );
}

VehiclePosition _vehiclePosition({required String vehicleId}) {
  return VehiclePosition(
    vehicleId: vehicleId,
    latitude: 50.078,
    longitude: 14.463,
    bearing: 45,
    lastUpdated: DateTime.utc(2026, 6, 25, 10),
  );
}
