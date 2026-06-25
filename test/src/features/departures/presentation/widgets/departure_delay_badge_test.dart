import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/features/departures/presentation/widgets/departure_delay_badge.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.cs);
  });

  group('departureDelayLevel', () {
    test('classifies low, medium, and high delay', () {
      expect(departureDelayLevel(0), DepartureDelayLevel.low);
      expect(
        departureDelayLevel(mediumDepartureDelayThresholdSeconds - 1),
        DepartureDelayLevel.low,
      );
      expect(
        departureDelayLevel(mediumDepartureDelayThresholdSeconds),
        DepartureDelayLevel.medium,
      );
      expect(
        departureDelayLevel(highDepartureDelayThresholdSeconds - 1),
        DepartureDelayLevel.medium,
      );
      expect(
        departureDelayLevel(highDepartureDelayThresholdSeconds),
        DepartureDelayLevel.high,
      );
    });
  });

  group('formatDepartureDelayShort', () {
    test('formats no delay and rounded-up minute delay', () {
      expect(formatDepartureDelayShort(-30), '0 min');
      expect(formatDepartureDelayShort(0), '0 min');
      expect(formatDepartureDelayShort(1), '+1 min');
      expect(formatDepartureDelayShort(60), '+1 min');
      expect(formatDepartureDelayShort(61), '+2 min');
      expect(
        formatDepartureDelayShort(highDepartureDelayThresholdSeconds),
        '+10 min',
      );
    });
  });
}
