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
  });
}
