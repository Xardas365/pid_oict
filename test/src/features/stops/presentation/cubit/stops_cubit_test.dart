import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_state.dart';

void main() {
  group('StopsCubit', () {
    test('loads stops successfully', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'hr.VUSC Praha'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.allStops, hasLength(2));
      expect(cubit.state.filteredStops.map((stop) => stop.name), ['Andel']);
      expect(repository.callCount, 1);
    });

    test('stores error when initial load fails', () async {
      const expectedError = AppException(
        type: AppExceptionType.network,
        message: 'Network failed.',
      );
      final repository = _FakeStopsRepository([
        const _StopsFailure(expectedError),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.error);
      expect(cubit.state.error, same(expectedError));
      expect(cubit.state.filteredStops, isEmpty);
    });

    test('retry reloads after error', () async {
      final repository = _FakeStopsRepository([
        const _StopsFailure(
          AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
        ),
        const _StopsSuccess([Stop(id: '1', name: 'Andel')]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      await cubit.retry();

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredStops.single.name, 'Andel');
      expect(repository.callCount, 2);
    });

    test('empty API result becomes empty state', () async {
      final repository = _FakeStopsRepository([const _StopsSuccess([])]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.empty);
      expect(cubit.state.allStops, isEmpty);
      expect(cubit.state.filteredStops, isEmpty);
    });

    test('search filters already loaded stops', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('and');

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.searchQuery, 'and');
      expect(cubit.state.filteredStops.map((stop) => stop.name), ['Andel']);
    });

    test('search with no matching result becomes empty search state', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('airport');

      expect(cubit.state.status, StopsStatus.empty);
      expect(cubit.state.searchQuery, 'airport');
      expect(cubit.state.filteredStops, isEmpty);
    });

    test('search query changes do not call repository again', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit
        ..searchChanged('and')
        ..searchChanged('star')
        ..clearSearch();

      expect(repository.callCount, 1);
      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredStops, hasLength(2));
    });
  });
}

StopsCubit _createCubit(_FakeStopsRepository repository) {
  return StopsCubit(GetStopsUseCase(repository));
}

class _FakeStopsRepository implements StopsRepository {
  _FakeStopsRepository(this._responses);

  final List<_StopsResponse> _responses;
  var callCount = 0;

  @override
  Future<List<Stop>> fetchStops() async {
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _StopsSuccess(:final stops) => stops,
      _StopsFailure(:final error) => throw error,
    };
  }
}

sealed class _StopsResponse {
  const _StopsResponse();
}

class _StopsSuccess extends _StopsResponse {
  const _StopsSuccess(this.stops);

  final List<Stop> stops;
}

class _StopsFailure extends _StopsResponse {
  const _StopsFailure(this.error);

  final Object error;
}
