import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/get_vehicle_position_for_trip_use_case.dart';
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

  final GetVehiclePositionForTripUseCase _getVehiclePosition;
  final Duration pollingInterval;
  final VehicleMapTickerFactory _tickerFactory;

  StreamSubscription<void>? _pollingSubscription;
  var _isRequestInFlight = false;

  Future<void> _onStarted(
    VehicleMapStarted event,
    Emitter<VehicleMapState> emit,
  ) async {
    await _restartPolling();
    await _loadPosition(event.gtfsTripId, emit, showInitialLoading: true);
  }

  Future<void> _onRetried(
    VehicleMapRetried event,
    Emitter<VehicleMapState> emit,
  ) {
    final gtfsTripId = state.gtfsTripId;
    if (gtfsTripId == null) {
      return Future<void>.value();
    }

    return _loadPosition(gtfsTripId, emit, showInitialLoading: true);
  }

  Future<void> _onRefreshTicked(
    VehicleMapRefreshTicked event,
    Emitter<VehicleMapState> emit,
  ) {
    final gtfsTripId = state.gtfsTripId;
    if (gtfsTripId == null) {
      return Future<void>.value();
    }

    return _loadPosition(gtfsTripId, emit, showInitialLoading: false);
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
    String gtfsTripId,
    Emitter<VehicleMapState> emit, {
    required bool showInitialLoading,
  }) async {
    if (_isRequestInFlight) {
      return;
    }

    _isRequestInFlight = true;
    final previousPosition = state.position;

    if (showInitialLoading && previousPosition == null) {
      emit(VehicleMapState.loading(gtfsTripId: gtfsTripId));
    } else if (previousPosition != null) {
      emit(
        state.copyWith(
          status: VehicleMapStatus.loaded,
          gtfsTripId: gtfsTripId,
          position: previousPosition,
          isRefreshing: true,
          clearError: true,
          clearStaleError: true,
        ),
      );
    }

    try {
      final position = await _getVehiclePosition(gtfsTripId);
      emit(
        VehicleMapState(
          status: VehicleMapStatus.loaded,
          gtfsTripId: gtfsTripId,
          position: position,
        ),
      );
    } catch (error) {
      if (previousPosition != null) {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.loaded,
            gtfsTripId: gtfsTripId,
            position: previousPosition,
            staleError: error,
          ),
        );
      } else if (_isNoPositionError(error)) {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.noPosition,
            gtfsTripId: gtfsTripId,
            error: error,
          ),
        );
      } else {
        emit(
          VehicleMapState(
            status: VehicleMapStatus.error,
            gtfsTripId: gtfsTripId,
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
