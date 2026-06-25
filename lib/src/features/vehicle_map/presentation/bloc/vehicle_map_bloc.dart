import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../../domain/vehicle_id.dart';
import 'vehicle_map_event.dart';
import 'vehicle_map_state.dart';

typedef VehicleMapTickerFactory = Stream<void> Function(Duration interval);

const _missingVehicleIdException = AppException(
  type: AppExceptionType.invalidData,
  message: 'Vehicle ID is required to load vehicle position.',
);

Stream<void> _defaultTicker(Duration interval) {
  return Stream<void>.periodic(interval);
}

class VehicleMapBloc extends Bloc<VehicleMapEvent, VehicleMapState> {
  VehicleMapBloc(
    this._getVehiclePosition, {
    this.pollingInterval = const Duration(seconds: 15),
    this._tickerFactory = _defaultTicker,
  }) : super(const VehicleMapState.loading()) {
    on<VehicleMapStarted>(_onStarted);
    on<VehicleMapRetried>(_onRetried);
    on<VehicleMapRefreshTicked>(_onRefreshTicked);
  }

  final GetVehiclePositionForVehicleUseCase _getVehiclePosition;
  final Duration pollingInterval;
  final VehicleMapTickerFactory _tickerFactory;

  StreamSubscription<void>? _pollingSubscription;
  var _isRequestInFlight = false;

  Future<void> _onStarted(
    VehicleMapStarted event,
    Emitter<VehicleMapState> emit,
  ) async {
    await _restartPolling();
    final vehicleId = VehicleId.tryParse(event.vehicleId);
    if (vehicleId == null) {
      emit(
        const VehicleMapState(
          status: VehicleMapStatus.noPosition,
          error: _missingVehicleIdException,
        ),
      );
      return;
    }

    await _loadPosition(vehicleId, emit, showInitialLoading: true);
  }

  Future<void> _onRetried(
    VehicleMapRetried event,
    Emitter<VehicleMapState> emit,
  ) {
    final vehicleId = state.vehicleId;
    final parsedVehicleId = VehicleId.tryParse(vehicleId);
    if (parsedVehicleId == null) {
      return Future<void>.value();
    }

    return _loadPosition(parsedVehicleId, emit, showInitialLoading: true);
  }

  Future<void> _onRefreshTicked(
    VehicleMapRefreshTicked event,
    Emitter<VehicleMapState> emit,
  ) {
    final vehicleId = state.vehicleId;
    final parsedVehicleId = VehicleId.tryParse(vehicleId);
    if (parsedVehicleId == null) {
      return Future<void>.value();
    }

    return _loadPosition(parsedVehicleId, emit, showInitialLoading: false);
  }

  Future<void> _restartPolling() async {
    await _pollingSubscription?.cancel();
    _pollingSubscription = null;

    if (pollingInterval <= Duration.zero) {
      return;
    }

    _pollingSubscription = _tickerFactory(pollingInterval).listen((_) {
      add(const VehicleMapRefreshTicked());
    });
  }

  Future<void> _loadPosition(
    VehicleId vehicleId,
    Emitter<VehicleMapState> emit, {
    required bool showInitialLoading,
  }) async {
    if (_isRequestInFlight) {
      return;
    }

    _isRequestInFlight = true;
    final previousPosition = state.position;

    if (showInitialLoading && previousPosition == null) {
      emit(VehicleMapState.loading(vehicleId: vehicleId.value));
    } else if (previousPosition != null) {
      emit(
        state.copyWith(
          status: VehicleMapStatus.loaded,
          vehicleId: vehicleId.value,
          position: previousPosition,
          isRefreshing: true,
          clearError: true,
          clearStaleError: true,
        ),
      );
    }

    try {
      final position = await _getVehiclePosition(vehicleId);
      emit(
        VehicleMapState(
          status: VehicleMapStatus.loaded,
          vehicleId: vehicleId.value,
          position: position,
        ),
      );
    } on Object catch (error) {
      if (previousPosition != null) {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.loaded,
            vehicleId: vehicleId.value,
            position: previousPosition,
            staleError: error,
          ),
        );
      } else if (_isNoPositionError(error)) {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.noPosition,
            vehicleId: vehicleId.value,
            error: error,
          ),
        );
      } else {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.error,
            vehicleId: vehicleId.value,
            error: error,
          ),
        );
      }
    } finally {
      _isRequestInFlight = false;
    }
  }

  bool _isNoPositionError(Object error) {
    return error is AppException && error.type == AppExceptionType.invalidData;
  }

  @override
  Future<void> close() async {
    await _pollingSubscription?.cancel();
    return super.close();
  }
}
