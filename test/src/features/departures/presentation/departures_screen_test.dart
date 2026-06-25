import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/load_departure_board_use_case.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/refresh_departure_board_use_case.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_event.dart';
import 'package:pid_oict/src/features/departures/presentation/departures_screen.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

import '../../../test_localized_app.dart';

final _testStopGroup = StopGroup.single(
  const Stop(id: 'U123Z1', name: 'Staromestska'),
);

void main() {
  group('DeparturesScreen', () {
    testWidgets('shows loading state while departures are loading', (
      tester,
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
      tester,
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
              vehicleId: 'service-3-1001',
              isWheelchairAccessible: true,
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

      expect(find.text('Odjezdy zo zastávky'), findsOneWidget);
      expect(find.text('Staromestska'), findsOneWidget);
      expect(find.text('Vše'), findsOneWidget);
      expect(find.text('Tram'), findsOneWidget);
      expect(find.text('Metro'), findsOneWidget);
      expect(find.textContaining('Aktualizované před'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.text('10:15'), findsOneWidget);
      expect(find.text('+2 min'), findsOneWidget);
      expect(find.text('Nástupiště 3'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.byIcon(Icons.accessible_forward), findsOneWidget);
    });

    testWidgets('non-accessible departure does not show wheelchair icon', (
      tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: '22',
              headsign: 'Nadrazi Hostivar',
              departureTime: DateTime(2026, 6, 22, 10, 15),
              isWheelchairAccessible: false,
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.byIcon(Icons.accessible_forward), findsNothing);
    });

    testWidgets('departure without platform hides platform row', (
      tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: '22',
              headsign: 'Nadrazi Hostivar',
              departureTime: DateTime(2026, 6, 22, 10, 15),
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.textContaining('Nástupiště'), findsNothing);
    });

    testWidgets('long destination name ellipsizes without overflow', (
      tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: '176',
              routeType: 'bus',
              headsign:
                  'Velmi dlouhá cílová stanice přes celé město a ještě dál',
              departureTime: DateTime(2026, 6, 22, 10, 15),
              delaySeconds: 720,
              platform: 'A',
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Velmi dlouhá cílová stanice přes celé město a ještě dál'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('back button returns to stops callback', (
      tester,
    ) async {
      var backPressed = false;

      await _pumpDeparturesScreen(
        tester,
        onBackToStops: () {
          backPressed = true;
        },
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        ]),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zpět na zastávky'));
      await tester.pumpAndSettle();

      expect(backPressed, isTrue);
    });

    testWidgets('transport filter changes visible departures', (
      tester,
    ) async {
      await _pumpDeparturesScreen(
        tester,
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            _departure('Sidliste Repy', routeShortName: '10'),
            _departure(
              'Koleje Strahov',
              routeShortName: '176',
              routeType: 'bus',
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sidliste Repy'), findsOneWidget);
      expect(find.text('Koleje Strahov'), findsOneWidget);
      expect(find.text('Tram'), findsOneWidget);
      expect(find.text('Bus'), findsOneWidget);

      await tester.tap(find.text('Bus'));
      await tester.pumpAndSettle();

      expect(find.text('Sidliste Repy'), findsNothing);
      expect(find.text('Koleje Strahov'), findsOneWidget);

      await tester.tap(find.text('Vše'));
      await tester.pumpAndSettle();

      expect(find.text('Sidliste Repy'), findsOneWidget);
      expect(find.text('Koleje Strahov'), findsOneWidget);
    });

    testWidgets('opens vehicle map screen with vehicleId', (
      tester,
    ) async {
      String? selectedVehicleId;

      await _pumpDeparturesScreen(
        tester,
        onVehicleSelected: (vehicleId) {
          selectedVehicleId = vehicleId;
        },
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: '22',
              headsign: 'Nadrazi Hostivar',
              departureTime: DateTime(2026, 6, 22, 10, 15),
              gtfsTripId: 'trip-22-123',
              vehicleId: 'service-3-1001',
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Nadrazi Hostivar'));
      await tester.pumpAndSettle();

      expect(selectedVehicleId, 'service-3-1001');
    });

    testWidgets('hides vehicle map action when vehicleId is missing', (
      tester,
    ) async {
      String? selectedVehicleId;

      await _pumpDeparturesScreen(
        tester,
        onVehicleSelected: (vehicleId) {
          selectedVehicleId = vehicleId;
        },
        repository: _QueueDeparturesRepository([
          _DeparturesSuccess([
            Departure(
              routeShortName: 'A',
              headsign: 'Nemocnice Motol',
              departureTime: DateTime(2026, 6, 22, 10, 15),
              gtfsTripId: 'trip-without-vehicle',
            ),
          ]),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nemocnice Motol'), findsOneWidget);
      await tester.tap(find.text('Nemocnice Motol'));
      await tester.pumpAndSettle();

      expect(selectedVehicleId, isNull);
    });

    testWidgets('shows error and retries loading departures', (
      tester,
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
      tester,
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
      tester,
    ) async {
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesSuccess([_departure('Vypich')]),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);

      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(repository.callCount, 1);

      await tester.drag(
        find.byKey(const ValueKey('departures-list')),
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsNothing);
      expect(find.text('Vypich'), findsOneWidget);
      expect(repository.callCount, 2);
    });

    testWidgets('refresh failure keeps previous departures visible', (
      tester,
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

      await tester.drag(
        find.byKey(const ValueKey('departures-list')),
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(
        find.text(
          'Nepodařilo se aktualizovat odjezdy. '
          'Zobrazujeme poslední dostupná data.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Nepodařilo se připojit ke Golemio API. '
          'Zkontrolujte připojení k internetu.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('refreshing keeps existing departures on screen', (
      tester,
    ) async {
      final refreshCompleter = Completer<List<Departure>>();
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesPending(refreshCompleter),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('departures-list')),
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      refreshCompleter.complete([_departure('Vypich')]);
      await tester.pumpAndSettle();

      expect(find.text('Vypich'), findsOneWidget);
    });

    testWidgets('background refresh spinner does not shift updated label', (
      tester,
    ) async {
      final refreshCompleter = Completer<List<Departure>>();
      final repository = _QueueDeparturesRepository([
        _DeparturesSuccess([_departure('Nadrazi Hostivar')]),
        _DeparturesPending(refreshCompleter),
      ]);

      await _pumpDeparturesScreen(tester, repository: repository);
      await tester.pumpAndSettle();

      final labelFinder = find.textContaining('Aktualizované před');
      final beforeRefreshLeft = tester.getTopLeft(labelFinder).dx;

      await tester.drag(
        find.byKey(const ValueKey('departures-list')),
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getTopLeft(labelFinder).dx, beforeRefreshLeft);

      refreshCompleter.complete([_departure('Vypich')]);
      await tester.pumpAndSettle();
    });
  });
}

Future<void> _pumpDeparturesScreen(
  WidgetTester tester, {
  required DeparturesRepository repository,
  ValueChanged<String>? onVehicleSelected,
  VoidCallback? onBackToStops,
}) async {
  await tester.pumpWidget(
    localizedTestApp(
      home: BlocProvider(
        create: (_) => DeparturesBloc(
          LoadDepartureBoardUseCase(repository),
          refreshDepartureBoard: RefreshDepartureBoardUseCase(repository),
          refreshInterval: Duration.zero,
        )..add(DeparturesStarted(_testStopGroup)),
        child: DeparturesScreen(
          stop: _testStopGroup,
          onVehicleSelected: onVehicleSelected,
          onBackToStops: onBackToStops,
        ),
      ),
    ),
  );
}

Departure _departure(
  String headsign, {
  String routeShortName = '22',
  String? routeType,
}) {
  return Departure(
    routeShortName: routeShortName,
    routeType: routeType,
    headsign: headsign,
    departureTime: DateTime(2026, 6, 22, 10, 15),
    gtfsTripId: 'trip-22-123',
    vehicleId: 'service-3-1001',
  );
}

class _FutureDeparturesRepository implements DeparturesRepository {
  const _FutureDeparturesRepository(this._future);

  final Future<List<Departure>> _future;

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) {
    return _future;
  }
}

class _QueueDeparturesRepository implements DeparturesRepository {
  _QueueDeparturesRepository(this._responses);

  final List<_DeparturesResponse> _responses;
  int callCount = 0;

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) async {
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _DeparturesSuccess(:final departures) => departures,
      _DeparturesFailure(:final error) => _throwTestError(error),
      _DeparturesPending(:final completer) => completer.future,
    };
  }
}

Never _throwTestError(Object error) {
  if (error is Exception) {
    throw error;
  }

  if (error is Error) {
    throw error;
  }

  throw StateError(error.toString());
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
