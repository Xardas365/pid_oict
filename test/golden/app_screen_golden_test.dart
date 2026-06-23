import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/get_departures_for_stop_use_case.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_event.dart';
import 'package:pid_oict/src/features/departures/presentation/departures_screen.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/stops_screen.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_trip_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
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
            RepositorySuccess([repyDeparture(), motolDeparture()]),
          ]),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/departures_success.png'),
      );
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

  await tester.pumpWidget(localizedTestApp(home: home));
  await tester.pumpAndSettle();
}

Widget _stopsScreen(StopsRepository repository) {
  return BlocProvider(
    create: (_) => StopsCubit(GetStopsUseCase(repository))..loadStops(),
    child: const StopsScreen(),
  );
}

Widget _departuresScreen(
  DeparturesRepository repository, {
  void Function(DeparturesBloc bloc)? onBlocCreated,
}) {
  return BlocProvider(
    create: (_) {
      final bloc = DeparturesBloc(GetDeparturesForStopUseCase(repository))
        ..add(const DeparturesStarted(andelStop));
      onBlocCreated?.call(bloc);

      return bloc;
    },
    child: const DeparturesScreen(stop: andelStop),
  );
}

Widget _vehicleMapScreen(
  VehiclePositionRepository repository, {
  void Function(VehicleMapBloc bloc)? onBlocCreated,
}) {
  return BlocProvider(
    create: (_) {
      final bloc = VehicleMapBloc(
        GetVehiclePositionForTripUseCase(repository),
        pollingInterval: Duration.zero,
      )..add(const VehicleMapStarted('trip-10-repy'));
      onBlocCreated?.call(bloc);

      return bloc;
    },
    child: const VehicleMapScreen(
      gtfsTripId: 'trip-10-repy',
      showMapTiles: false,
    ),
  );
}
