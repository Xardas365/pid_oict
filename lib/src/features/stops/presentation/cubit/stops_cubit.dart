import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/stop.dart';
import '../../domain/usecases/get_stops_use_case.dart';
import '../stop_filter.dart';
import 'stops_state.dart';

class StopsCubit extends Cubit<StopsState> {
  StopsCubit(this._getStops) : super(const StopsState.loading());

  final GetStopsUseCase _getStops;

  Future<void> loadStops() async {
    emit(const StopsState.loading());

    try {
      final stops = await _getStops();
      emit(_stateFromStops(stops, searchQuery: ''));
    } catch (error) {
      emit(StopsState(status: StopsStatus.error, error: error));
    }
  }

  Future<void> retry() {
    return loadStops();
  }

  void searchChanged(String query) {
    final current = state;
    if (current.status == StopsStatus.loading ||
        current.status == StopsStatus.error) {
      return;
    }

    emit(_stateFromStops(current.allStops, searchQuery: query));
  }

  void clearSearch() {
    searchChanged('');
  }

  StopsState _stateFromStops(List<Stop> stops, {required String searchQuery}) {
    final allStops = List<Stop>.unmodifiable(stops);
    final filteredStops = filterStopsByName(allStops, searchQuery);
    final status = filteredStops.isEmpty
        ? StopsStatus.empty
        : StopsStatus.loaded;

    return StopsState(
      status: status,
      allStops: allStops,
      filteredStops: filteredStops,
      searchQuery: searchQuery,
    );
  }
}
