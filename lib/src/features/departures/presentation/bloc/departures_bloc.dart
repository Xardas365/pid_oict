import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../stops/domain/stop_group.dart';
import '../../domain/departure.dart';
import '../../domain/usecases/get_departures_for_stop_use_case.dart';
import 'departures_event.dart';
import 'departures_state.dart';

const departureBoardRefreshInterval = Duration(seconds: 30);

class DeparturesBloc extends Bloc<DeparturesEvent, DeparturesState> {
  DeparturesBloc(
    this._getDepartures, {
    this.refreshInterval = departureBoardRefreshInterval,
  }) : super(const DeparturesState.loading()) {
    on<DeparturesStarted>(_onStarted);
    on<DeparturesRetried>(_onRetried);
    on<DeparturesRefreshed>(_onRefreshed);
  }

  final GetDeparturesForStopUseCase _getDepartures;
  final Duration refreshInterval;
  Timer? _refreshTimer;
  var _refreshInProgress = false;

  Future<void> _onStarted(
    DeparturesStarted event,
    Emitter<DeparturesState> emit,
  ) {
    return _load(event.stop, emit, resetPeriodicRefresh: true);
  }

  Future<void> _onRetried(
    DeparturesRetried event,
    Emitter<DeparturesState> emit,
  ) {
    final stop = state.stop;
    if (stop == null) {
      return Future<void>.value();
    }

    return _load(stop, emit, resetPeriodicRefresh: true);
  }

  Future<void> _onRefreshed(
    DeparturesRefreshed event,
    Emitter<DeparturesState> emit,
  ) async {
    if (_refreshInProgress) {
      event.completion?.complete();
      return;
    }

    _refreshInProgress = true;
    try {
      final stop = state.stop;
      if (stop == null) {
        return;
      }

      final previousDepartures = state.departures;
      if (previousDepartures.isNotEmpty) {
        emit(
          state.copyWith(
            status: DeparturesStatus.loaded,
            departures: previousDepartures,
            isRefreshing: true,
            clearError: true,
            clearRefreshError: true,
          ),
        );
      }

      try {
        final departures = await _getDepartures(stop);
        emit(_stateFromDepartures(stop, departures));
      } catch (error) {
        if (previousDepartures.isNotEmpty) {
          emit(
            state.copyWith(
              status: DeparturesStatus.loaded,
              departures: previousDepartures,
              refreshError: error,
              isRefreshing: false,
              clearError: true,
            ),
          );
          return;
        }

        emit(
          DeparturesState(
            status: DeparturesStatus.error,
            stop: stop,
            error: error,
          ),
        );
        _stopPeriodicRefresh();
      }
    } finally {
      _refreshInProgress = false;
      event.completion?.complete();
    }
  }

  Future<void> _load(
    StopGroup stop,
    Emitter<DeparturesState> emit, {
    bool resetPeriodicRefresh = false,
  }) async {
    if (resetPeriodicRefresh) {
      _stopPeriodicRefresh();
    }

    emit(DeparturesState.loading(stop: stop));

    try {
      final departures = await _getDepartures(stop);
      emit(_stateFromDepartures(stop, departures));
      _startPeriodicRefresh();
    } catch (error) {
      emit(
        DeparturesState(
          status: DeparturesStatus.error,
          stop: stop,
          error: error,
        ),
      );
    }
  }

  DeparturesState _stateFromDepartures(
    StopGroup stop,
    List<Departure> departures,
  ) {
    final immutableDepartures = List<Departure>.unmodifiable(departures);

    return DeparturesState(
      status: immutableDepartures.isEmpty
          ? DeparturesStatus.empty
          : DeparturesStatus.loaded,
      stop: stop,
      departures: immutableDepartures,
    );
  }

  void _startPeriodicRefresh() {
    _stopPeriodicRefresh();
    if (refreshInterval <= Duration.zero || state.stop == null) {
      return;
    }

    _refreshTimer = Timer.periodic(refreshInterval, (_) {
      if (isClosed ||
          _refreshInProgress ||
          state.status == DeparturesStatus.loading ||
          state.stop == null) {
        return;
      }

      add(const DeparturesRefreshed());
    });
  }

  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<void> close() {
    _stopPeriodicRefresh();
    return super.close();
  }
}
