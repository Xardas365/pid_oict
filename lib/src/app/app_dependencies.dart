import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/golemio_api_client.dart';
import '../features/departures/data/datasources/departures_remote_data_source.dart';
import '../features/departures/data/repositories/golemio_departures_repository.dart';
import '../features/departures/domain/repositories/departures_repository.dart';
import '../features/departures/domain/usecases/load_departure_board_use_case.dart';
import '../features/stops/data/datasources/app_saved_stops_data_source.dart';
import '../features/stops/data/datasources/app_stops_cache_data_source.dart';
import '../features/stops/data/datasources/saved_stops_data_source.dart';
import '../features/stops/data/datasources/stops_cache_data_source.dart';
import '../features/stops/data/datasources/stops_remote_data_source.dart';
import '../features/stops/data/repositories/golemio_stops_repository.dart';
import '../features/stops/data/repositories/saved_stops_repository_impl.dart';
import '../features/stops/data/repositories/stops_cache_repository_impl.dart';
import '../features/stops/domain/repositories/saved_stops_repository.dart';
import '../features/stops/domain/repositories/stops_cache_repository.dart';
import '../features/stops/domain/repositories/stops_repository.dart';
import '../features/stops/domain/usecases/get_stops_use_case.dart';
import '../features/stops/domain/usecases/load_cached_stops_use_case.dart';
import '../features/stops/domain/usecases/load_complete_stop_index_use_case.dart';
import '../features/stops/domain/usecases/load_saved_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/load_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/record_recent_stop_use_case.dart';
import '../features/stops/domain/usecases/refresh_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/save_stops_cache_use_case.dart';
import '../features/stops/domain/usecases/search_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/toggle_favorite_stop_use_case.dart';
import '../features/vehicle_map/data/datasources/vehicle_positions_remote_data_source.dart';
import '../features/vehicle_map/data/repositories/golemio_vehicle_position_repository.dart';
import '../features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import '../features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({
    required this.child,
    super.key,
    this.apiClient,
    this.stopsRepository,
    this.departuresRepository,
    this.vehiclePositionRepository,
    this.stopsCacheDataSource,
    this.savedStopsDataSource,
  });

  final Widget child;
  final GolemioApiClient? apiClient;
  final StopsRepository? stopsRepository;
  final DeparturesRepository? departuresRepository;
  final VehiclePositionRepository? vehiclePositionRepository;
  final StopsCacheDataSource? stopsCacheDataSource;
  final SavedStopsDataSource? savedStopsDataSource;

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
              stopsRepository ??
              GolemioStopsRepository(context.read<StopsRemoteDataSource>()),
        ),
        RepositoryProvider<DeparturesRepository>(
          create: (context) =>
              departuresRepository ??
              GolemioDeparturesRepository(
                context.read<DeparturesRemoteDataSource>(),
              ),
        ),
        RepositoryProvider<VehiclePositionRepository>(
          create: (context) =>
              vehiclePositionRepository ??
              GolemioVehiclePositionRepository(
                context.read<VehiclePositionsRemoteDataSource>(),
              ),
        ),
        RepositoryProvider<GetStopsUseCase>(
          create: (context) => GetStopsUseCase(context.read<StopsRepository>()),
        ),
        RepositoryProvider<StopsCacheDataSource>(
          create: (_) =>
              stopsCacheDataSource ?? const AppStopsCacheDataSource(),
        ),
        RepositoryProvider<SavedStopsDataSource>(
          create: (_) =>
              savedStopsDataSource ?? const AppSavedStopsDataSource(),
        ),
        RepositoryProvider<StopsCacheRepository>(
          create: (context) => StopsCacheRepositoryImpl(
            context.read<StopsCacheDataSource>(),
          ),
        ),
        RepositoryProvider<SavedStopsRepository>(
          create: (context) => SavedStopsRepositoryImpl(
            context.read<SavedStopsDataSource>(),
          ),
        ),
        RepositoryProvider<LoadStopGroupsUseCase>(
          create: (context) =>
              LoadStopGroupsUseCase(context.read<GetStopsUseCase>()),
        ),
        RepositoryProvider<RefreshStopGroupsUseCase>(
          create: (context) =>
              RefreshStopGroupsUseCase(context.read<GetStopsUseCase>()),
        ),
        RepositoryProvider<LoadCompleteStopIndexUseCase>(
          create: (context) =>
              LoadCompleteStopIndexUseCase(context.read<GetStopsUseCase>()),
        ),
        RepositoryProvider<SearchStopGroupsUseCase>(
          create: (context) =>
              SearchStopGroupsUseCase(context.read<GetStopsUseCase>()),
        ),
        RepositoryProvider<LoadCachedStopsUseCase>(
          create: (context) =>
              LoadCachedStopsUseCase(context.read<StopsCacheRepository>()),
        ),
        RepositoryProvider<SaveStopsCacheUseCase>(
          create: (context) =>
              SaveStopsCacheUseCase(context.read<StopsCacheRepository>()),
        ),
        RepositoryProvider<LoadSavedStopGroupsUseCase>(
          create: (context) =>
              LoadSavedStopGroupsUseCase(context.read<SavedStopsRepository>()),
        ),
        RepositoryProvider<ToggleFavoriteStopUseCase>(
          create: (context) =>
              ToggleFavoriteStopUseCase(context.read<SavedStopsRepository>()),
        ),
        RepositoryProvider<RecordRecentStopUseCase>(
          create: (context) =>
              RecordRecentStopUseCase(context.read<SavedStopsRepository>()),
        ),
        RepositoryProvider<LoadDepartureBoardUseCase>(
          create: (context) =>
              LoadDepartureBoardUseCase(context.read<DeparturesRepository>()),
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
