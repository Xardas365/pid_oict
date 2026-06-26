import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/load_departure_board_use_case.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_event.dart';
import 'package:pid_oict/src/features/departures/presentation/departures_screen.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/stops_screen.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_args.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_screen.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/test_data.dart';
import '../src/test_localized_app.dart';

void main() {
  group('screen goldens', () {
    testWidgets('StopsScreen success', (tester) async {
      await _pumpGolden(
        tester,
        _stopsScreen(
          QueueStopsRepository([
            const RepositorySuccess([andelStop, staromestskaStop]),
          ]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/stops_success.png'),
      );
    });

    testWidgets('StopsScreen empty', (tester) async {
      await _pumpGolden(
        tester,
        _stopsScreen(QueueStopsRepository([const RepositorySuccess(<Stop>[])])),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/stops_empty.png'),
      );
    });

    testWidgets('StopsScreen error', (tester) async {
      await _pumpGolden(
        tester,
        _stopsScreen(
          QueueStopsRepository([
            const RepositoryFailure<List<Stop>>(
              AppException(
                type: AppExceptionType.network,
                message: 'Network error.',
              ),
            ),
          ]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/stops_error.png'),
      );
    });

    testWidgets('DeparturesScreen success', (tester) async {
      await _pumpGolden(
        tester,
        _departuresScreen(
          QueueDeparturesRepository([
            RepositorySuccess([
              repyDeparture(),
              _busDeparture(),
              motolDeparture(),
            ]),
          ]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_success.png'),
      );
    });

    testWidgets('DeparturesScreen filtered', (tester) async {
      await _pumpGolden(
        tester,
        _departuresScreen(
          QueueDeparturesRepository([
            RepositorySuccess([
              repyDeparture(),
              _busDeparture(),
              motolDeparture(),
            ]),
          ]),
        ),
      );

      await tester.tap(find.text('Bus'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_filtered.png'),
      );
    });

    testWidgets('DeparturesScreen empty', (tester) async {
      await _pumpGolden(
        tester,
        _departuresScreen(
          QueueDeparturesRepository([const RepositorySuccess(<Departure>[])]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_empty.png'),
      );
    });

    testWidgets('DeparturesScreen initial error', (tester) async {
      await _pumpGolden(
        tester,
        _departuresScreen(
          QueueDeparturesRepository([
            const RepositoryFailure<List<Departure>>(
              AppException(type: AppExceptionType.network, message: 'Network.'),
            ),
          ]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_error.png'),
      );
    });

    testWidgets('DeparturesScreen refresh loading', (tester) async {
      final refreshCompleter = Completer<List<Departure>>();
      late DeparturesBloc bloc;

      await _pumpGolden(
        tester,
        _departuresScreen(
          QueueDeparturesRepository([
            RepositorySuccess<List<Departure>>([repyDeparture()]),
            RepositoryPending<List<Departure>>(refreshCompleter),
          ]),
          onBlocCreated: (createdBloc) {
            bloc = createdBloc;
          },
        ),
      );

      bloc.add(const DeparturesRefreshed());
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_refresh_loading.png'),
      );

      refreshCompleter.complete([_busDeparture()]);
      await tester.pumpAndSettle();
    });

    testWidgets('DeparturesScreen refresh warning', (tester) async {
      late DeparturesBloc bloc;

      await _pumpGolden(
        tester,
        _departuresScreen(
          QueueDeparturesRepository([
            RepositorySuccess<List<Departure>>([repyDeparture()]),
            const RepositoryFailure<List<Departure>>(
              AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
            ),
          ]),
          onBlocCreated: (createdBloc) {
            bloc = createdBloc;
          },
        ),
      );

      bloc.add(const DeparturesRefreshed());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_refresh_warning.png'),
      );
    });

    testWidgets('VehicleMapScreen loaded', (tester) async {
      await _pumpGolden(
        tester,
        _vehicleMapScreen(
          QueueVehiclePositionRepository([
            RepositorySuccess(andelVehiclePosition()),
          ]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/vehicle_map_loaded.png'),
      );
    });

    testWidgets('VehicleMapScreen stale warning', (tester) async {
      late VehicleMapBloc bloc;

      await _pumpGolden(
        tester,
        _vehicleMapScreen(
          QueueVehiclePositionRepository([
            RepositorySuccess<VehiclePosition>(andelVehiclePosition()),
            const RepositoryFailure<VehiclePosition>(
              AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
            ),
          ]),
          onBlocCreated: (createdBloc) {
            bloc = createdBloc;
          },
        ),
      );

      bloc.add(const VehicleMapRefreshTicked());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/vehicle_map_stale_warning.png'),
      );
    });
  });
}

Future<void> _pumpGolden(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    localizedTestApp(home: home, platform: TargetPlatform.android),
  );
  await tester.pumpAndSettle();
}

Widget _stopsScreen(StopsRepository repository) {
  return BlocProvider(
    create: (_) {
      final cubit = StopsCubit(GetStopsUseCase(repository));
      unawaited(cubit.loadStops());
      return cubit;
    },
    child: const StopsScreen(),
  );
}

Widget _departuresScreen(
  DeparturesRepository repository, {
  void Function(DeparturesBloc bloc)? onBlocCreated,
}) {
  return BlocProvider(
    create: (_) {
      final bloc = DeparturesBloc(
        LoadDepartureBoardUseCase(repository),
        refreshInterval: Duration.zero,
      )..add(DeparturesStarted(andelStopGroup));
      onBlocCreated?.call(bloc);

      return bloc;
    },
    child: DeparturesScreen(stop: andelStopGroup),
  );
}

Widget _vehicleMapScreen(
  VehiclePositionRepository repository, {
  void Function(VehicleMapBloc bloc)? onBlocCreated,
}) {
  final args = VehicleMapArgs(
    vehicleId: VehicleId('service-3-1001'),
    routeShortName: '10',
    headsign: 'Sidliste Repy',
    routeType: 'tram',
    lineType: PidLineType.tram,
  );

  return BlocProvider(
    create: (_) {
      final bloc = VehicleMapBloc(
        GetVehiclePositionForVehicleUseCase(repository),
        pollingInterval: Duration.zero,
      )..add(VehicleMapStarted(args.vehicleId));
      onBlocCreated?.call(bloc);

      return bloc;
    },
    child: VehicleMapScreen(args: args, showMapTiles: false),
  );
}

Departure _busDeparture() {
  return Departure(
    routeShortName: '176',
    routeType: 'bus',
    headsign: 'Karlovo namesti',
    departureTime: DateTime(2026, 6, 22, 10, 22),
    delaySeconds: 660,
    platform: 'B',
    gtfsTripId: 'trip-176-karlovo',
    vehicleId: 'service-3-176',
    isWheelchairAccessible: false,
  );
}
