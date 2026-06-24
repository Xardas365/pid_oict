import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/presentation/widgets/pid_transport_icon.dart';

void main() {
  testWidgets('renders fallback Material icon by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PidTransportIcon(lineType: PidLineType.tram)),
      ),
    );

    expect(find.byIcon(Icons.tram_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('uses semantic label on fallback icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PidTransportIcon(lineType: PidLineType.cityBus)),
      ),
    );

    final icon = tester.widget<Icon>(
      find.byIcon(Icons.directions_bus_outlined),
    );
    expect(icon.semanticLabel, PidLineType.cityBus.label);
  });
}
