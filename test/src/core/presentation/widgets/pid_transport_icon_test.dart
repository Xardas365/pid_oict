import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/presentation/widgets/pid_transport_icon.dart';

void main() {
  testWidgets('renders SVG asset by default when an asset path exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PidTransportIcon(lineType: PidLineType.tram)),
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.tram_outlined), findsNothing);
  });

  testWidgets('renders fallback Material icon when preferAsset is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PidTransportIcon(
            lineType: PidLineType.tram,
            preferAsset: false,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.tram_outlined), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('renders fallback Material icon when no asset path exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PidTransportIcon(lineType: PidLineType.unknown)),
      ),
    );

    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('uses semantic label on fallback icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PidTransportIcon(
            lineType: PidLineType.cityBus,
            preferAsset: false,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(
      find.byIcon(Icons.directions_bus_outlined),
    );
    expect(icon.semanticLabel, PidLineType.cityBus.label);
  });
}
