import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/shared/utils/date_time_formatters.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.cs);
  });

  group('date time formatters', () {
    test('formats clock time with padded hours and minutes', () {
      expect(formatClockTime(DateTime(2026, 6, 22, 7, 5, 9)), '07:05');
    });

    test('formats clock time with seconds', () {
      expect(
        formatClockTimeWithSeconds(DateTime(2026, 6, 22, 7, 5, 9)),
        '07:05:09',
      );
    });

    test('formats delay text', () {
      expect(formatDelaySeconds(null), isNull);
      expect(formatDelaySeconds(0), 'Bez zpoždění');
      expect(formatDelaySeconds(-30), 'Bez zpoždění');
      expect(formatDelaySeconds(1), 'Zpoždění +1 min');
      expect(formatDelaySeconds(120), 'Zpoždění +2 min');
      expect(formatDelaySeconds(121), 'Zpoždění +3 min');
    });

    test('formats realtime delay label', () {
      expect(formatRealtimeDelayLabel(null), 'dle JŘ');
      expect(formatRealtimeDelayLabel(0), 'Načas');
      expect(formatRealtimeDelayLabel(1), '+1 min');
      expect(formatRealtimeDelayLabel(120), '+2 min');
      expect(formatRealtimeDelayLabel(-1), '-1 min');
      expect(formatRealtimeDelayLabel(-120), '-2 min');
    });

    test('formats relative departure countdown compactly', () {
      expect(formatRelativeDepartureCountdown(Duration.zero), 'teď');
      expect(
        formatRelativeDepartureCountdown(const Duration(seconds: -1)),
        'teď',
      );
      expect(
        formatRelativeDepartureCountdown(const Duration(minutes: 3)),
        'za 3 min',
      );
      expect(
        formatRelativeDepartureCountdown(const Duration(minutes: 59)),
        'za 59 min',
      );
      expect(
        formatRelativeDepartureCountdown(const Duration(minutes: 60)),
        'za 1 h',
      );
      expect(
        formatRelativeDepartureCountdown(const Duration(minutes: 126)),
        'za 2 h',
      );
    });

    test('formats relative elapsed labels as seconds then minutes', () {
      final timestamp = DateTime(2026, 6, 22, 10);

      String format(DateTime now) {
        return formatRelativeElapsedSince(
          timestamp,
          now: now,
          secondsLabel: (seconds) => '$seconds s',
          minutesLabel: (minutes) => '$minutes min',
        );
      }

      expect(format(DateTime(2026, 6, 22, 9, 59, 59)), '0 s');
      expect(format(DateTime(2026, 6, 22, 10)), '0 s');
      expect(format(DateTime(2026, 6, 22, 10, 0, 12)), '12 s');
      expect(format(DateTime(2026, 6, 22, 10, 1)), '1 min');
      expect(format(DateTime(2026, 6, 22, 10, 2, 30)), '2 min');
    });
  });
}
