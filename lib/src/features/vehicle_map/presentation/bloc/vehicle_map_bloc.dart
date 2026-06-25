import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../../domain/vehicle_id.dart';
import 'vehicle_map_event.dart';
import 'vehicle_map_state.dart';

typedef VehicleMapTickerFactory = Stream<void> Function(Duration interval);

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
    await _loadPosition(event.vehicleId, emit, showInitialLoading: true);
  }

  Future<void> _onRetried(
    VehicleMapRetried event,
    Emitter<VehicleMapState> emit,
  ) {
    final vehicleId = state.vehicleId;
    if (vehicleId == null) {
      return Future<void>.value();
    }

    return _loadPosition(vehicleId, emit, showInitialLoading: true);
  }

  Future<void> _onRefreshTicked(
    VehicleMapRefreshTicked event,
    Emitter<VehicleMapState> emit,
  ) {
    final vehicleId = state.vehicleId;
    if (vehicleId == null) {
      return Future<void>.value();
    }

    return _loadPosition(vehicleId, emit, showInitialLoading: false);
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
      emit(VehicleMapState.loading(vehicleId: vehicleId));
    } else if (previousPosition != null) {
      emit(
        state.copyWith(
          status: VehicleMapStatus.loaded,
          vehicleId: vehicleId,
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
          vehicleId: vehicleId,
          position: position,
        ),
      );
    } on Object catch (error) {
      final failure = AppFailure.fromObject(error);
      if (previousPosition != null) {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.loaded,
            vehicleId: vehicleId,
            position: previousPosition,
            staleError: failure,
          ),
        );
      } else if (_isNoPositionFailure(failure)) {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.noPosition,
            vehicleId: vehicleId,
            error: failure,
          ),
        );
      } else {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.error,
            vehicleId: vehicleId,
            error: failure,
          ),
        );
      }
    } finally {
      _isRequestInFlight = false;
    }
  }

  bool _isNoPositionFailure(AppFailure failure) {
    return failure.category == AppFailureCategory.invalidData;
  }

  @override
  Future<void> close() async {
    await _pollingSubscription?.cancel();
    return super.close();
  }
}
