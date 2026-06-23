import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/get_departures_for_stop_use_case.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_event.dart';
import 'package:pid_oict/src/features/departures/presentation/departures_screen.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

import '../../../test_localized_app.dart';

void main() {
  group('DeparturesScreen', () {
    testWidgets('shows loading state while departures are loading', (
      WidgetTester tester,
    ) async {
      final completer = Completer<List<Departure>>();

      await _pumpDeparturesScreen(
        tester,
        repository: _FutureDeparturesRepository(completer.future),
      );

      expect(find.text('Načítání odjezdů...'), findsOneWidget);

      completer.complete(const []);
    });

    testWidgets('shows loaded departures and vehicle map action', (
      WidgetTester tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: '22',
              headsign: 'Nadrazi Hostivar',
              departureTime: DateTime(2026, 6, 22, 10, 15),
              delaySeconds: 120,
              platform: '3',
              gtfsTripId: 'trip-22-123',
            ),
            Departure(
              routeShortName: 'A',
              headsign: 'Nemocnice Motol',
              departureTime: DateTime(2026, 6, 22, 10, 18),
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Staromestska'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.text('Odjezd 10:15'), findsOneWidget);
      expect(find.text('Zpoždění +2 min'), findsOneWidget);
      expect(find.text('Nástupiště 3'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.byTooltip('Zobrazit polohu vozidla'), findsOneWidget);
    });

    testWidgets('opens vehicle map screen with gtfsTripId', (
      WidgetTester tester,
    ) async {
      String? selectedTripId;

      await _pumpDeparturesScreen(
        tester,
        onTripSelected: (gtfsTripId) {
          selectedTripId = gtfsTripId;
        },
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: '22',
              headsign: 'Nadrazi Hostivar',
              departureTime: DateTime(2026, 6, 22, 10, 15),
              gtfsTripId: 'trip-22-123',
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zobrazit polohu vozidla'));
      await tester.pumpAndSettle();

      expect(selectedTripId, 'trip-22-123');
    });

    testWidgets('hides vehicle map action when gtfsTripId is missing', (
      WidgetTester tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: 'A',
              headsign: 'Nemocnice Motol',
              departureTime: DateTime(2026, 6, 22, 10, 15),
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nemocnice Motol'), findsOneWidget);
      expect(find.byTooltip('Zobrazit polohu vozidla'), findsNothing);
    });

    testWidgets('shows error and retries loading departures', (
      WidgetTester tester,
    ) async {
      final repository = _QueueDeparturesRepository([
        const _DeparturesFailure(
          AppException(
            type: AppExceptionType.network,
            message: 'Network error.',
          ),
        ),
        _DeparturesSuccess([
          Departure(
            routeShortName: '22',
            headsign: 'Nadrazi Hostivar',
            departureTime: DateTime(2026, 6, 22, 10, 15),
          ),
        ]),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Nepodařilo se připojit ke Golemio API. '
          'Zkontrolujte připojení k internetu.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Zkusit znovu'));
      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(repository.callCount, 2);
    });

    testWidgets('shows empty state when there are no departures', (
      WidgetTester tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([const _DeparturesSuccess([])]),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Pro tuto zastávku nejsou dostupné žádné odjezdy.'),
        findsOneWidget,
      );
    });

    testWidgets('pull-to-refresh reloads departures', (
      WidgetTester tester,
    ) async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesSuccess([_departure('Vypich')]),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);

      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(repository.callCount, 1);

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsNothing);
      expect(find.text('Vypich'), findsOneWidget);
      expect(repository.callCount, 2);
    });

    testWidgets('refresh failure keeps previous departures visible', (
      WidgetTester tester,
    ) async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        const _DeparturesFailure(
          AppException(
            type: AppExceptionType.network,
            message: 'Network error.',
          ),
        ),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(
        find.text(
          'Nepodařilo se připojit ke Golemio API. '
          'Zkontrolujte připojení k internetu.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('refreshing keeps existing departures on screen', (
      WidgetTester tester,
    ) async {
      final refreshCompleter = Completer<List<Departure>>();
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesPending(refreshCompleter),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      refreshCompleter.complete([_departure('Vypich')]);
      await tester.pumpAndSettle();

      expect(find.text('Vypich'), findsOneWidget);
    });
  });
}

Future<void> _pumpDeparturesScreen(
  WidgetTester tester, {
  required DeparturesRepository repository,
  ValueChanged<String>? onTripSelected,
}) async {
  await tester.pumpWidget(
    localizedTestApp(
      home: BlocProvider(
        create: (_) => DeparturesBloc(GetDeparturesForStopUseCase(repository))
          ..add(
            const DeparturesStarted(Stop(id: 'U123Z1', name: 'Staromestska')),
          ),
        child: DeparturesScreen(
          stop: const Stop(id: 'U123Z1', name: 'Staromestska'),
          onTripSelected: onTripSelected,
        ),
      ),
    ),
  );
}

Departure _departure(String headsign) {
  return Departure(
    routeShortName: '22',
    headsign: headsign,
    departureTime: DateTime(2026, 6, 22, 10, 15),
    gtfsTripId: 'trip-22-123',
  );
}

class _FutureDeparturesRepository implements DeparturesRepository {
  const _FutureDeparturesRepository(this._future);

  final Future<List<Departure>> _future;

  @override
  Future<List<Departure>> fetchDeparturesForStop(Stop stop) {
    return _future;
  }
}

class _QueueDeparturesRepository implements DeparturesRepository {
  _QueueDeparturesRepository(this._responses);

  final List<_DeparturesResponse> _responses;
  var callCount = 0;

  @override
  Future<List<Departure>> fetchDeparturesForStop(Stop stop) async {
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _DeparturesSuccess(:final departures) => departures,
      _DeparturesFailure(:final error) => throw error,
      _DeparturesPending(:final completer) => completer.future,
    };
  }
}

sealed class _DeparturesResponse {
  const _DeparturesResponse();
}

class _DeparturesSuccess extends _DeparturesResponse {
  const _DeparturesSuccess(this.departures);

  final List<Departure> departures;
}

class _DeparturesFailure extends _DeparturesResponse {
  const _DeparturesFailure(this.error);

  final Object error;
}

class _DeparturesPending extends _DeparturesResponse {
  const _DeparturesPending(this.completer);

  final Completer<List<Departure>> completer;
}
