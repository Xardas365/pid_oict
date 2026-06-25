import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_state.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_state_factory.dart';

void main() {
  group('StopsStateFactory', () {
    const factory = StopsStateFactory();

    test('builds loaded state with grouped and filtered stops', () {
      final state = factory.fromStops(
        const [_floraPlatformB, _andel, _floraPlatformA],
        searchQuery: 'flo',
        hasMore: true,
        nextOffset: 500,
        favoriteGroupIds: const ['U118S1', 'missing', 'U123S1'],
        recentGroupIds: const ['U123S1'],
      );

      expect(state.status, StopsStatus.loaded);
      expect(state.allStops.map((stop) => stop.id), [
        'U118Z102P',
        'U123Z1',
        'U118Z101P',
      ]);
      expect(state.allGroups.map((group) => group.name), ['Andel', 'Flora']);
      expect(state.filteredGroups.map((group) => group.name), ['Flora']);
      expect(state.filteredStops.map((stop) => stop.id), ['U118Z101P']);
      expect(state.hasMore, isTrue);
      expect(state.nextOffset, 500);
      expect(state.favoriteGroups.map((group) => group.id), [
        'U118S1',
        'U123S1',
      ]);
      expect(state.recentGroups.map((group) => group.id), ['U123S1']);
    });

    test('can keep provided API search results unfiltered by query', () {
      final state = factory.fromStops(
        const [_floraPlatformA],
        searchQuery: 'and',
        hasMore: false,
        nextOffset: 100,
        favoriteGroupIds: const [],
        recentGroupIds: const [],
        useProvidedStopsDirectly: true,
      );

      expect(state.status, StopsStatus.loaded);
      expect(state.filteredGroups.single.name, 'Flora');
      expect(state.searchQuery, 'and');
    });

    test('updates saved group resolution without replacing loaded data', () {
      final state = factory.fromStops(
        const [_andel, _floraPlatformA],
        searchQuery: '',
        hasMore: false,
        nextOffset: 2,
        favoriteGroupIds: const [],
        recentGroupIds: const [],
      );

      final updatedState = factory.withSavedStops(
        current: state,
        favoriteGroupIds: const ['U118S1'],
        recentGroupIds: const ['U123S1'],
      );

      expect(updatedState.allGroups, state.allGroups);
      expect(updatedState.favoriteGroups.map((group) => group.name), [
        'Flora',
      ]);
      expect(updatedState.recentGroups.map((group) => group.name), ['Andel']);
    });
  });
}

const _andel = Stop(
  id: 'U123Z1',
  name: 'Andel',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U123S1',
  latitude: 50.07128,
  longitude: 14.40312,
);

const _floraPlatformA = Stop(
  id: 'U118Z101P',
  name: 'Flora',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  latitude: 50.07827,
  longitude: 14.4633,
);

const _floraPlatformB = Stop(
  id: 'U118Z102P',
  name: 'Flora',
  platformCode: 'B',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  latitude: 50.07831,
  longitude: 14.4631,
);
