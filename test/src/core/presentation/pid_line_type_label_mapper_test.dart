import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/presentation/pid_line_type_label_mapper.dart';

void main() {
  group('PidLineTypeLabelMapper', () {
    test('maps line types to Czech labels', () {
      final mapper = PidLineTypeLabelMapper(AppLocale.cs.buildSync());

      expect(mapper.labelFor(PidLineType.metro), 'Metro');
      expect(mapper.labelFor(PidLineType.tram), 'Tramvaj');
      expect(mapper.labelFor(PidLineType.cityBus), 'Městský autobus');
      expect(mapper.labelFor(PidLineType.tramNight), 'Noční tramvaj');
      expect(
        mapper.labelFor(PidLineType.replacementBus),
        'Náhradní autobusová doprava',
      );
      expect(mapper.labelFor(PidLineType.unknown), 'Neznámý typ linky');
    });

    test('maps line types to English labels', () {
      final mapper = PidLineTypeLabelMapper(AppLocale.en.buildSync());

      expect(mapper.labelFor(PidLineType.metro), 'Metro');
      expect(mapper.labelFor(PidLineType.tram), 'Tram');
      expect(mapper.labelFor(PidLineType.cityBus), 'City bus');
      expect(mapper.labelFor(PidLineType.tramNight), 'Night tram');
      expect(
        mapper.labelFor(PidLineType.replacementBus),
        'Bus replacement service',
      );
      expect(mapper.labelFor(PidLineType.unknown), 'Unknown line type');
    });
  });
}
