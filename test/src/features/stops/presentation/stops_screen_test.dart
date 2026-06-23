import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/data/datasources/saved_stops_data_source.dart';
import 'package:pid_oict/src/features/stops/data/datasources/stops_cache_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/cached_stops.dart';
import 'package:pid_oict/src/features/stops/data/models/saved_stops.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/stops_screen.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart' as pid_seed_strings;
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../helpers/in_memory_saved_stops_data_source.dart';
import '../../../../helpers/in_memory_stops_cache_data_source.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.cs);
    pid_seed_strings.LocaleSettings.setLocaleRawSync('cs');
  });

  testWidgets('shows loading state while stops are loading', (tester) async {
    final completer = Completer<List<Stop>>();

    await _pumpStopsScreen(tester, _FutureStopsRepository(completer.future));

    expect(find.text('Načítání zastávek...'), findsOneWidget);

    completer.complete(const []);
  });

  testWidgets('shows error state with retry', (tester) async {
    final repository = _QueueStopsRepository([
      const _StopsFailure(
        AppException(
          type: AppExceptionType.network,
          message: 'Network failed.',
        ),
      ),
      const _StopsSuccess([Stop(id: '1', name: 'Andel')]),
    ]);

    await _pumpStopsScreen(tester, repository);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Nepodařilo se připojit ke Golemio API. Zkontrolujte připojení k internetu.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Zkusit znovu'));
    await tester.pumpAndSettle();

    expect(find.text('Andel'), findsOneWidget);
    expect(repository.callCount, 2);
  });

  testWidgets('shows empty state when no stops are available', (tester) async {
    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([const _StopsSuccess([])]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Žádné zastávky nejsou k dispozici.'), findsOneWidget);
  });

  testWidgets('shows loaded stops and filters them locally', (tester) async {
    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Staromestska'),
          Stop(id: '2', name: 'Andel'),
          Stop(id: '3', name: 'hr.VUSC Praha'),
        ]),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Staromestska'), findsOneWidget);
    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('hr.VUSC Praha'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'and');
    await tester.pump();

    expect(find.text('Staromestska'), findsNothing);
    expect(find.text('Andel'), findsOneWidget);
  });

  testWidgets('uses native scrollbar and scrolls back to top', (tester) async {
    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([_StopsSuccess(_manyPublicStops(30))]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byTooltip('Zpět nahoru'), findsNothing);
    expect(find.text('Stop 00'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byTooltip('Zpět nahoru'), findsOneWidget);

    await tester.tap(find.byTooltip('Zpět nahoru'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Zpět nahoru'), findsNothing);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.text('Stop 00'), findsOneWidget);
  });

  testWidgets('shows stale cache warning and keeps cached stops visible', (
    tester,
  ) async {
    final refreshCompleter = Completer<List<Stop>>();
    final cache = InMemoryStopsCacheDataSource();
    await cache.write(
      CachedStops(
        cachedAt: _now.subtract(stopsCacheTtl + const Duration(minutes: 1)),
        stops: const [_andelPublicStop],
      ),
    );

    await _pumpStopsScreen(
      tester,
      _FutureStopsRepository(refreshCompleter.future),
      cacheDataSource: cache,
      now: () => _now,
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Zobrazujeme starší uložená data zastávek.'),
      findsOneWidget,
    );
    expect(find.text('Andel'), findsOneWidget);

    refreshCompleter.complete(const []);
    await tester.pump();
  });

  testWidgets(
    'shows refresh failure warning while cached stops remain visible',
    (tester) async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now.subtract(const Duration(hours: 1)),
          stops: const [_andelPublicStop],
        ),
      );

      await _pumpStopsScreen(
        tester,
        _QueueStopsRepository([
          const _StopsFailure(
            AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
          ),
        ]),
        cacheDataSource: cache,
        now: () => _now,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Zobrazujeme uložené zastávky. Aktualizace se nezdařila.'),
        findsOneWidget,
      );
      expect(find.text('Andel'), findsOneWidget);
    },
  );

  testWidgets('does not show cache warning for fresh network data', (
    tester,
  ) async {
    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([_andelPublicStop]),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('Zobrazujeme uložené zastávky.'), findsNothing);
    expect(
      find.text('Zobrazujeme starší uložená data zastávek.'),
      findsNothing,
    );
    expect(
      find.text('Zobrazujeme uložené zastávky. Aktualizace se nezdařila.'),
      findsNothing,
    );
  });

  testWidgets('search works with cached groups', (tester) async {
    final refreshCompleter = Completer<List<Stop>>();
    final cache = InMemoryStopsCacheDataSource();
    await cache.write(
      CachedStops(
        cachedAt: _now,
        stops: const [_andelPublicStop, _staromestskaPublicStop],
      ),
    );

    await _pumpStopsScreen(
      tester,
      _FutureStopsRepository(refreshCompleter.future),
      cacheDataSource: cache,
      now: () => _now,
    );
    await tester.pump();
    await tester.pump();

    await tester.enterText(find.byType(EditableText), 'and');
    await tester.pump();

    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('Staromestska'), findsNothing);

    refreshCompleter.complete(const []);
    await tester.pump();
  });

  testWidgets('opening a stop records it as recent', (tester) async {
    final savedStops = InMemorySavedStopsDataSource();
    StopGroup? selectedStop;

    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([_andelPublicStop]),
      ]),
      savedStopsDataSource: savedStops,
      onStopSelected: (stop) {
        selectedStop = stop;
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();

    expect(selectedStop?.id, 'U123S1');
    expect((await savedStops.readRecent()).recentGroupIds, ['U123S1']);
  });

  testWidgets('favorite icon toggles state without opening departures', (
    tester,
  ) async {
    final savedStops = InMemorySavedStopsDataSource();
    StopGroup? selectedStop;

    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([_andelPublicStop]),
      ]),
      savedStopsDataSource: savedStops,
      onStopSelected: (stop) {
        selectedStop = stop;
      },
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Přidat do oblíbených'), findsOneWidget);

    await tester.tap(find.byTooltip('Přidat do oblíbených'));
    await tester.pumpAndSettle();

    expect(selectedStop, isNull);
    expect((await savedStops.readFavorites()).favoriteGroupIds, ['U123S1']);
    expect(find.text('Oblíbené zastávky'), findsOneWidget);
    expect(find.byTooltip('Odebrat z oblíbených'), findsOneWidget);

    await tester.tap(find.byTooltip('Odebrat z oblíbených'));
    await tester.pumpAndSettle();

    expect((await savedStops.readFavorites()).favoriteGroupIds, isEmpty);
    expect(find.text('Oblíbené zastávky'), findsNothing);
  });

  testWidgets('favorite row opens departures', (tester) async {
    final savedStops = InMemorySavedStopsDataSource();
    await savedStops.writeFavorites(
      FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U123S1']),
    );
    StopGroup? selectedStop;

    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([_andelPublicStop, _staromestskaPublicStop]),
      ]),
      savedStopsDataSource: savedStops,
      onStopSelected: (stop) {
        selectedStop = stop;
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Oblíbené zastávky'), findsOneWidget);

    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();

    expect(selectedStop?.id, 'U123S1');
    expect((await savedStops.readRecent()).recentGroupIds, ['U123S1']);
  });

  testWidgets('recent row opens departures', (tester) async {
    final savedStops = InMemorySavedStopsDataSource();
    await savedStops.writeRecent(
      RecentStops(updatedAt: _now, recentGroupIds: const ['U456S1']),
    );
    StopGroup? selectedStop;

    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([_andelPublicStop, _staromestskaPublicStop]),
      ]),
      savedStopsDataSource: savedStops,
      onStopSelected: (stop) {
        selectedStop = stop;
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Poslední zastávky'), findsOneWidget);

    await tester.tap(find.text('Staromestska'));
    await tester.pumpAndSettle();

    expect(selectedStop?.id, 'U456S1');
    expect((await savedStops.readRecent()).recentGroupIds, ['U456S1']);
  });

  testWidgets(
    'recent section is hidden when it would be the only list content',
    (tester) async {
      final savedStops = InMemorySavedStopsDataSource();
      await savedStops.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['U123S1']),
      );

      await _pumpStopsScreen(
        tester,
        _QueueStopsRepository([
          const _StopsSuccess([_andelPublicStop]),
        ]),
        savedStopsDataSource: savedStops,
      );
      await tester.pumpAndSettle();

      expect(find.text('Poslední zastávky'), findsNothing);
      expect(find.text('Andel'), findsOneWidget);
    },
  );

  testWidgets('favorite and recent sections are hidden during search', (
    tester,
  ) async {
    final savedStops = InMemorySavedStopsDataSource();
    await savedStops.writeFavorites(
      FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U123S1']),
    );
    await savedStops.writeRecent(
      RecentStops(updatedAt: _now, recentGroupIds: const ['U456S1']),
    );

    await _pumpStopsScreen(
      tester,
      _QueueStopsRepository([
        const _StopsSuccess([_andelPublicStop, _staromestskaPublicStop]),
      ]),
      savedStopsDataSource: savedStops,
    );
    await tester.pumpAndSettle();

    expect(find.text('Oblíbené zastávky'), findsOneWidget);
    expect(find.text('Poslední zastávky'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'and');
    await tester.pump();

    expect(find.text('Oblíbené zastávky'), findsNothing);
    expect(find.text('Poslední zastávky'), findsNothing);
    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('Staromestska'), findsNothing);
  });

  testWidgets('favorite section coexists with stale cache warning', (
    tester,
  ) async {
    final refreshCompleter = Completer<List<Stop>>();
    final cache = InMemoryStopsCacheDataSource();
    final savedStops = InMemorySavedStopsDataSource();
    await cache.write(
      CachedStops(
        cachedAt: _now.subtract(stopsCacheTtl + const Duration(minutes: 1)),
        stops: const [_andelPublicStop],
      ),
    );
    await savedStops.writeFavorites(
      FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U123S1']),
    );

    await _pumpStopsScreen(
      tester,
      _FutureStopsRepository(refreshCompleter.future),
      cacheDataSource: cache,
      savedStopsDataSource: savedStops,
      now: () => _now,
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Zobrazujeme starší uložená data zastávek.'),
      findsOneWidget,
    );
    expect(find.text('Oblíbené zastávky'), findsOneWidget);
    expect(find.text('Andel'), findsOneWidget);

    refreshCompleter.complete(const []);
    await tester.pump();
  });
}

Future<void> _pumpStopsScreen(
  WidgetTester tester,
  StopsRepository repository, {
  StopsCacheDataSource? cacheDataSource,
  SavedStopsDataSource? savedStopsDataSource,
  DateTime Function()? now,
  ValueChanged<StopGroup>? onStopSelected,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        theme: PidSeedsTheme.light(),
        home: BlocProvider(
          create: (_) => StopsCubit(
            GetStopsUseCase(repository),
            cacheDataSource: cacheDataSource,
            savedStopsDataSource: savedStopsDataSource,
            now: now,
          )..loadStops(),
          child: StopsScreen(onStopSelected: onStopSelected),
        ),
      ),
    ),
  );
}

class _FutureStopsRepository implements StopsRepository {
  const _FutureStopsRepository(this._future);

  final Future<List<Stop>> _future;

  @override
  Future<List<Stop>> fetchStops() {
    return _future;
  }
}

final _now = DateTime.utc(2026, 6, 23, 12);

const _andelPublicStop = Stop(
  id: 'U123Z1',
  name: 'Andel',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U123S1',
  latitude: 50.07128,
  longitude: 14.40312,
);

const _staromestskaPublicStop = Stop(
  id: 'U456Z2',
  name: 'Staromestska',
  platformCode: 'B',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U456S1',
  latitude: 50.08708,
  longitude: 14.42078,
);

List<Stop> _manyPublicStops(int count) {
  return List<Stop>.generate(
    count,
    (index) => Stop(
      id: 'U${index.toString().padLeft(3, '0')}Z1',
      name: 'Stop ${index.toString().padLeft(2, '0')}',
      platformCode: 'A',
      zoneId: 'P',
      locationType: 0,
      parentStationId: 'U${index.toString().padLeft(3, '0')}S1',
      latitude: 50 + index / 1000,
      longitude: 14 + index / 1000,
    ),
    growable: false,
  );
}

class _QueueStopsRepository implements StopsRepository {
  _QueueStopsRepository(this._responses);

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
