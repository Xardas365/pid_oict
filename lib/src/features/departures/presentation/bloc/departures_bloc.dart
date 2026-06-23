import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../stops/domain/stop.dart';
import '../../domain/departure.dart';
import '../../domain/usecases/get_departures_for_stop_use_case.dart';
import 'departures_event.dart';
import 'departures_state.dart';

class DeparturesBloc extends Bloc<DeparturesEvent, DeparturesState> {
  DeparturesBloc(this._getDepartures) : super(const DeparturesState.loading()) {
    on<DeparturesStarted>(_onStarted);
    on<DeparturesRetried>(_onRetried);
    on<DeparturesRefreshed>(_onRefreshed);
  }

  final GetDeparturesForStopUseCase _getDepartures;

  Future<void> _onStarted(
    DeparturesStarted event,
    Emitter<DeparturesState> emit,
  ) {
    return _load(event.stop, emit);
  }

  Future<void> _onRetried(
    DeparturesRetried event,
    Emitter<DeparturesState> emit,
  ) {
    final stop = state.stop;
    if (stop == null) {
      return Future<void>.value();
    }

    return _load(stop, emit);
  }

  Future<void> _onRefreshed(
    DeparturesRefreshed event,
    Emitter<DeparturesState> emit,
  ) async {
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
      }
    } finally {
      event.completion?.complete();
    }
  }

  Future<void> _load(Stop stop, Emitter<DeparturesState> emit) async {
    emit(DeparturesState.loading(stop: stop));

    try {
      final departures = await _getDepartures(stop);
      emit(_stateFromDepartures(stop, departures));
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

  DeparturesState _stateFromDepartures(Stop stop, List<Departure> departures) {
    final immutableDepartures = List<Departure>.unmodifiable(departures);

    return DeparturesState(
      status: immutableDepartures.isEmpty
          ? DeparturesStatus.empty
          : DeparturesStatus.loaded,
      stop: stop,
      departures: immutableDepartures,
    );
  }
}
