import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/pid_line_type.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/utils/refresh_ticker.dart';
import '../../../stops/domain/stop_group.dart';
import '../../domain/departure.dart';
import '../../domain/usecases/load_departure_board_use_case.dart';
import '../../domain/usecases/refresh_departure_board_use_case.dart';
import '../departure_transport_filter.dart';
import 'departure_board_refresh_policy.dart';
import 'departures_event.dart';
import 'departures_state.dart';

const departureBoardRefreshInterval = Duration(seconds: 30);

class DeparturesBloc extends Bloc<DeparturesEvent, DeparturesState> {
  DeparturesBloc(
    this._loadDepartureBoard, {
    required RefreshDepartureBoardUseCase refreshDepartureBoard,
    this.refreshInterval = departureBoardRefreshInterval,
    DepartureTransportFilterPolicy filterPolicy =
        departureTransportFilterPolicy,
    DepartureBoardRefreshPolicy refreshPolicy =
        const DepartureBoardRefreshPolicy(),
    RefreshTicker? refreshTicker,
    DateTime Function()? now,
  }) : super(const DeparturesState.loading()) {
    _refreshDepartureBoard = refreshDepartureBoard;
    _filterPolicy = filterPolicy;
    _refreshPolicy = refreshPolicy;
    _refreshTicker = refreshTicker ?? TimerRefreshTicker();
    _now = now ?? DateTime.now;
    on<DeparturesStarted>(_onStarted);
    on<DeparturesRetried>(_onRetried);
    on<DeparturesRefreshed>(_onRefreshed);
    on<DeparturesTransportFilterSelected>(_onTransportFilterSelected);
  }

  final LoadDepartureBoardUseCase _loadDepartureBoard;
  final Duration refreshInterval;
  late final RefreshDepartureBoardUseCase _refreshDepartureBoard;
  late final DepartureTransportFilterPolicy _filterPolicy;
  late final DepartureBoardRefreshPolicy _refreshPolicy;
  late final RefreshTicker _refreshTicker;
  late final DateTime Function() _now;
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
    if (!_refreshPolicy.canStartRefresh(
      state: state,
      refreshInProgress: _refreshInProgress,
    )) {
      event.completion?.complete();
      return;
    }

    _refreshInProgress = true;
    try {
      final stop = state.stop;
      if (stop == null) {
        return;
      }

      final previousState = state;
      if (_refreshPolicy.shouldKeepDeparturesVisible(previousState)) {
        emit(_refreshPolicy.refreshingWithPreviousData(previousState));
      }

      try {
        final departures = await _refreshDepartureBoard(stop);
        emit(
          _stateFromDepartures(
            stop,
            departures,
            selectedTransportMode: previousState.selectedTransportMode,
          ),
        );
      } on Object catch (error) {
        final nextState = _refreshPolicy.refreshFailure(
          previousState: previousState,
          stop: stop,
          error: error,
        );
        emit(nextState);
        if (!_refreshPolicy.shouldKeepDeparturesVisible(previousState)) {
          _stopPeriodicRefresh();
        }
      }
    } finally {
      _refreshInProgress = false;
      event.completion?.complete();
    }
  }

  void _onTransportFilterSelected(
    DeparturesTransportFilterSelected event,
    Emitter<DeparturesState> emit,
  ) {
    final mode = event.mode;
    final selectedMode = _filterPolicy.resolveSelectedMode(
      departures: state.departures,
      selectedMode: mode,
    );

    if (mode != null && selectedMode == null) {
      emit(state.copyWith(clearSelectedTransportMode: true));
      return;
    }

    emit(
      state.copyWith(
        selectedTransportMode: selectedMode,
        clearSelectedTransportMode: selectedMode == null,
      ),
    );
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
      final departures = await _loadDepartureBoard(stop);
      emit(_stateFromDepartures(stop, departures));
      _startPeriodicRefresh();
    } on Object catch (error) {
      emit(
        DeparturesState(
          status: DeparturesStatus.error,
          stop: stop,
          error: AppFailure.fromObject(error),
        ),
      );
    }
  }

  DeparturesState _stateFromDepartures(
    StopGroup stop,
    List<Departure> departures, {
    PidTransportMode? selectedTransportMode,
  }) {
    final immutableDepartures = List<Departure>.unmodifiable(departures);
    final validSelectedTransportMode = _filterPolicy.resolveSelectedMode(
      departures: immutableDepartures,
      selectedMode: selectedTransportMode,
    );

    return DeparturesState(
      status: immutableDepartures.isEmpty
          ? DeparturesStatus.empty
          : DeparturesStatus.loaded,
      stop: stop,
      departures: immutableDepartures,
      selectedTransportMode: validSelectedTransportMode,
      lastUpdated: _now(),
    );
  }

  void _startPeriodicRefresh() {
    _stopPeriodicRefresh();
    if (refreshInterval <= Duration.zero || state.stop == null) {
      return;
    }

    _refreshTicker.start(
      interval: refreshInterval,
      onTick: () {
        if (isClosed ||
            _refreshInProgress ||
            state.status == DeparturesStatus.loading ||
            state.stop == null) {
          return;
        }

        add(const DeparturesRefreshed());
      },
    );
  }

  void _stopPeriodicRefresh() {
    _refreshTicker.stop();
  }

  @override
  Future<void> close() {
    _stopPeriodicRefresh();
    return super.close();
  }
}
