import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/stops_screen.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart' as pid_seed_strings;
import 'package:pid_seeds/pid_seeds.dart';

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
}

Future<void> _pumpStopsScreen(
  WidgetTester tester,
  StopsRepository repository,
) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        theme: PidSeedsTheme.light(),
        home: BlocProvider(
          create: (_) => StopsCubit(GetStopsUseCase(repository))..loadStops(),
          child: const StopsScreen(),
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
