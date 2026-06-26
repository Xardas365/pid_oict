import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/shared/widgets/live_relative_time_text.dart';

import '../../test_localized_app.dart';

void main() {
  group('LiveRelativeTimeText', () {
    testWidgets('renders initial elapsed seconds', (tester) async {
      final timestamp = DateTime(2026, 6, 22, 10);
      final now = timestamp;

      await tester.pumpWidget(
        localizedTestApp(
          home: LiveRelativeTimeText.departuresLastUpdated(
            timestamp: timestamp,
            now: () => now,
          ),
        ),
      );

      expect(find.text('Aktualizováno před 0 s'), findsOneWidget);
    });

    testWidgets('updates every second and switches to minutes', (
      tester,
    ) async {
      final timestamp = DateTime(2026, 6, 22, 10);
      var now = timestamp;

      await tester.pumpWidget(
        localizedTestApp(
          home: LiveRelativeTimeText.departuresLastUpdated(
            timestamp: timestamp,
            now: () => now,
          ),
        ),
      );

      now = timestamp.add(const Duration(seconds: 12));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Aktualizováno před 12 s'), findsOneWidget);

      now = timestamp.add(const Duration(minutes: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Aktualizováno před 1 min'), findsOneWidget);
    });

    testWidgets('resets when timestamp changes', (tester) async {
      final firstTimestamp = DateTime(2026, 6, 22, 10);
      final secondTimestamp = DateTime(2026, 6, 22, 10, 0, 30);
      var now = firstTimestamp.add(const Duration(seconds: 12));

      await tester.pumpWidget(
        localizedTestApp(
          home: LiveRelativeTimeText.departuresLastUpdated(
            timestamp: firstTimestamp,
            now: () => now,
          ),
        ),
      );

      expect(find.text('Aktualizováno před 12 s'), findsOneWidget);

      now = secondTimestamp;
      await tester.pumpWidget(
        localizedTestApp(
          home: LiveRelativeTimeText.departuresLastUpdated(
            timestamp: secondTimestamp,
            now: () => now,
          ),
        ),
      );

      expect(find.text('Aktualizováno před 0 s'), findsOneWidget);
    });

    testWidgets('disposes timer without exceptions', (tester) async {
      final timestamp = DateTime(2026, 6, 22, 10);

      await tester.pumpWidget(
        localizedTestApp(
          home: LiveRelativeTimeText.departuresLastUpdated(
            timestamp: timestamp,
            now: () => timestamp,
          ),
        ),
      );
      await tester.pumpWidget(localizedTestApp(home: const SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });
  });
}
