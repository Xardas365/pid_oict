import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/golemio_api_client.dart';
import '../features/departures/data/datasources/departures_remote_data_source.dart';
import '../features/departures/data/repositories/golemio_departures_repository.dart';
import '../features/departures/domain/repositories/departures_repository.dart';
import '../features/departures/domain/usecases/get_departures_for_stop_use_case.dart';
import '../features/stops/data/datasources/app_saved_stops_data_source.dart';
import '../features/stops/data/datasources/app_stops_cache_data_source.dart';
import '../features/stops/data/datasources/saved_stops_data_source.dart';
import '../features/stops/data/datasources/stops_cache_data_source.dart';
import '../features/stops/data/datasources/stops_remote_data_source.dart';
import '../features/stops/data/repositories/golemio_stops_repository.dart';
import '../features/stops/domain/repositories/stops_repository.dart';
import '../features/stops/domain/usecases/get_stops_use_case.dart';
import '../features/vehicle_map/data/datasources/vehicle_positions_remote_data_source.dart';
import '../features/vehicle_map/data/repositories/golemio_vehicle_position_repository.dart';
import '../features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import '../features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({required this.child, super.key, this.apiClient});

  final Widget child;
  final GolemioApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    final externalApiClient = apiClient;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GolemioApiClient>(
          create: (_) => externalApiClient ?? GolemioApiClient(),
          dispose: (client) {
            if (externalApiClient == null) {
              client.close();
            }
          },
        ),
        RepositoryProvider<StopsRemoteDataSource>(
          create: (context) =>
              StopsRemoteDataSource(context.read<GolemioApiClient>()),
        ),
        RepositoryProvider<DeparturesRemoteDataSource>(
          create: (context) =>
              DeparturesRemoteDataSource(context.read<GolemioApiClient>()),
        ),
        RepositoryProvider<VehiclePositionsRemoteDataSource>(
          create: (context) => VehiclePositionsRemoteDataSource(
            context.read<GolemioApiClient>(),
          ),
        ),
        RepositoryProvider<StopsRepository>(
          create: (context) =>
              GolemioStopsRepository(context.read<StopsRemoteDataSource>()),
        ),
        RepositoryProvider<DeparturesRepository>(
          create: (context) => GolemioDeparturesRepository(
            context.read<DeparturesRemoteDataSource>(),
          ),
        ),
        RepositoryProvider<VehiclePositionRepository>(
          create: (context) => GolemioVehiclePositionRepository(
            context.read<VehiclePositionsRemoteDataSource>(),
          ),
        ),
        RepositoryProvider<GetStopsUseCase>(
          create: (context) => GetStopsUseCase(context.read<StopsRepository>()),
        ),
        RepositoryProvider<StopsCacheDataSource>(
          create: (_) => const AppStopsCacheDataSource(),
        ),
        RepositoryProvider<SavedStopsDataSource>(
          create: (_) => const AppSavedStopsDataSource(),
        ),
        RepositoryProvider<GetDeparturesForStopUseCase>(
          create: (context) =>
              GetDeparturesForStopUseCase(context.read<DeparturesRepository>()),
        ),
        RepositoryProvider<GetVehiclePositionForVehicleUseCase>(
          create: (context) => GetVehiclePositionForVehicleUseCase(
            context.read<VehiclePositionRepository>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
