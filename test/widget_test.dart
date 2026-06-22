import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/main.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

void main() {
  testWidgets('app opens the stops screen and filters loaded stops', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PidOictApp(
        loadStops: () async => const [
          Stop(id: '1', name: 'Staromestska'),
          Stop(id: '2', name: 'Andel'),
          Stop(id: '3', name: 'hr.VUSC Praha'),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PID zastavky'), findsOneWidget);
    expect(find.text('Staromestska'), findsOneWidget);
    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('hr.VUSC Praha'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'and');
    await tester.pump();

    expect(find.text('Staromestska'), findsNothing);
    expect(find.text('Andel'), findsOneWidget);
  });
}
