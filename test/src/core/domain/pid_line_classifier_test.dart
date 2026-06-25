import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_classifier.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';

void main() {
  group('guessFromShortName', () {
    test('classifies metro A/B/C', () {
      expect(guessFromShortName('A'), PidLineType.metro);
      expect(guessFromShortName('B'), PidLineType.metro);
      expect(guessFromShortName('C'), PidLineType.metro);
    });

    test('classifies tram day lines', () {
      expect(guessFromShortName('1'), PidLineType.tram);
      expect(guessFromShortName('26'), PidLineType.tram);
    });

    test('classifies tram special lines', () {
      for (final line in ['31', '34', '37', '41', '42']) {
        expect(guessFromShortName(line), PidLineType.tramSpecial);
      }
    });

    test('classifies tram night lines 91-99', () {
      expect(guessFromShortName('91'), PidLineType.tramNight);
      expect(guessFromShortName('99'), PidLineType.tramNight);
    });

    test('classifies city bus lines 100-250', () {
      expect(guessFromShortName('100'), PidLineType.cityBus);
      expect(guessFromShortName('250'), PidLineType.cityBus);
    });

    test('classifies city bus night lines 901-917', () {
      expect(guessFromShortName('901'), PidLineType.cityBusNight);
      expect(guessFromShortName('917'), PidLineType.cityBusNight);
    });

    test('classifies regional bus lines 300-899', () {
      expect(guessFromShortName('300'), PidLineType.regionalBus);
      expect(guessFromShortName('899'), PidLineType.regionalBus);
    });

    test('classifies regional bus night lines 951-999', () {
      expect(guessFromShortName('951'), PidLineType.regionalBusNight);
      expect(guessFromShortName('999'), PidLineType.regionalBusNight);
    });

    test('classifies trolleybus lines', () {
      for (final line in ['51', '52', '53', '58', '59']) {
        expect(guessFromShortName(line), PidLineType.trolleybus);
      }
    });

    test('classifies train prefixes', () {
      expect(guessFromShortName('S7'), PidLineType.trainS);
      expect(guessFromShortName('R17'), PidLineType.trainR);
      expect(guessFromShortName('T3'), PidLineType.trainTourist);
      expect(guessFromShortName('P2'), PidLineType.trainInterregional);
      expect(guessFromShortName('U12'), PidLineType.trainInterregional);
      expect(guessFromShortName('V5'), PidLineType.trainInterregional);
      expect(guessFromShortName('L4'), PidLineType.trainInterregional);
    });

    test('does not classify P-prefixed lines as ferry without context', () {
      expect(guessFromShortName('P2'), isNot(PidLineType.ferry));
    });

    test('classifies replacement metro lines', () {
      expect(guessFromShortName('XA'), PidLineType.replacementMetro);
      expect(guessFromShortName('XB'), PidLineType.replacementMetro);
      expect(guessFromShortName('XC'), PidLineType.replacementMetro);
    });

    test('classifies replacement train lines', () {
      expect(guessFromShortName('XS7'), PidLineType.replacementTrain);
      expect(guessFromShortName('XR17'), PidLineType.replacementTrain);
    });

    test('classifies replacement tram and bus lines', () {
      expect(guessFromShortName('X22'), PidLineType.replacementTram);
      expect(guessFromShortName('X119'), PidLineType.replacementBus);
      expect(guessFromShortName('X350'), PidLineType.replacementBus);
    });

    test('classifies school lines 251-280', () {
      expect(guessFromShortName('251'), PidLineType.schoolBus);
      expect(guessFromShortName('280'), PidLineType.schoolBus);
    });

    test('classifies unknown and special labels', () {
      expect(guessFromShortName('AE'), PidLineType.specialOther);
      expect(guessFromShortName('IKEA'), PidLineType.specialOther);
      expect(guessFromShortName('BB1'), PidLineType.specialOther);
      expect(guessFromShortName('*888'), PidLineType.specialOther);
      expect(guessFromShortName('MHD Kladno'), PidLineType.specialOther);
      expect(guessFromShortName(''), PidLineType.unknown);
    });
  });

  group('fromPidPage', () {
    test('uses ferry page context for P2', () {
      expect(
        fromPidPage(page: PidLinePage.ferry, shortName: 'P2'),
        PidLineType.ferry,
      );
    });

    test('uses train page context for P2', () {
      expect(
        fromPidPage(page: PidLinePage.train, shortName: 'P2'),
        PidLineType.trainInterregional,
      );
    });

    test('returns train interregional for unknown train page pattern', () {
      expect(
        fromPidPage(page: PidLinePage.train, shortName: 'Os'),
        PidLineType.trainInterregional,
      );
    });
  });

  group('PidLineType metadata', () {
    test('exposes mode service and flags', () {
      expect(PidLineType.tramNight.mode, PidTransportMode.tram);
      expect(PidLineType.tramNight.service, PidServiceKind.night);
      expect(PidLineType.tramNight.isNight, isTrue);
      expect(PidLineType.replacementBus.isReplacement, isTrue);
    });
  });
}
