import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/core/presentation/pid_transport_visuals.dart';

void main() {
  group('PidTransportVisuals', () {
    test('maps major line types to final SVG assets', () {
      expect(PidLineType.metro.visual.assetPath, PidTransportAssetPaths.metro);
      expect(PidLineType.tram.visual.assetPath, PidTransportAssetPaths.tram);
      expect(
        PidLineType.tramSpecial.visual.assetPath,
        PidTransportAssetPaths.tram,
      );
      expect(PidLineType.cityBus.visual.assetPath, PidTransportAssetPaths.bus);
      expect(
        PidLineType.regionalBus.visual.assetPath,
        PidTransportAssetPaths.bus,
      );
      expect(
        PidLineType.schoolBus.visual.assetPath,
        PidTransportAssetPaths.bus,
      );
      expect(
        PidLineType.trolleybus.visual.assetPath,
        PidTransportAssetPaths.trolleybus,
      );
      expect(PidLineType.trainS.visual.assetPath, PidTransportAssetPaths.train);
      expect(PidLineType.trainR.visual.assetPath, PidTransportAssetPaths.train);
      expect(
        PidLineType.trainInterregional.visual.assetPath,
        PidTransportAssetPaths.train,
      );
      expect(
        PidLineType.trainTourist.visual.assetPath,
        PidTransportAssetPaths.train,
      );
      expect(PidLineType.ferry.visual.assetPath, PidTransportAssetPaths.ferry);
      expect(
        PidLineType.funicular.visual.assetPath,
        PidTransportAssetPaths.funicular,
      );
    });

    test('maps night line types to the dedicated night SVG', () {
      expect(
        PidLineType.tramNight.visual.assetPath,
        PidTransportAssetPaths.night,
      );
      expect(
        PidLineType.cityBusNight.visual.assetPath,
        PidTransportAssetPaths.night,
      );
      expect(
        PidLineType.regionalBusNight.visual.assetPath,
        PidTransportAssetPaths.night,
      );
    });

    test('replacement line types reuse affected transport assets', () {
      expect(
        PidLineType.replacementMetro.visual.assetPath,
        PidTransportAssetPaths.metro,
      );
      expect(
        PidLineType.replacementTram.visual.assetPath,
        PidTransportAssetPaths.tram,
      );
      expect(
        PidLineType.replacementBus.visual.assetPath,
        PidTransportAssetPaths.bus,
      );
      expect(
        PidLineType.replacementTrain.visual.assetPath,
        PidTransportAssetPaths.train,
      );
    });

    test('unknown and special types keep fallback-only visuals', () {
      expect(PidLineType.replacementUnknown.visual.assetPath, isNull);
      expect(PidLineType.specialOther.visual.assetPath, isNull);
      expect(PidLineType.unknown.visual.assetPath, isNull);
    });

    test('resolves Prague metro line colors by route short name', () {
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.metro,
          routeShortName: 'A',
        ),
        same(PidLineBadgeColorResolver.metroA),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.metro,
          routeShortName: 'b',
        ),
        same(PidLineBadgeColorResolver.metroB),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.metro,
          routeShortName: ' C ',
        ),
        same(PidLineBadgeColorResolver.metroC),
      );
    });

    test('resolves transport mode badge colors', () {
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.tram,
          routeShortName: '10',
        ),
        same(PidLineBadgeColorResolver.tram),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.cityBus,
          routeShortName: '176',
        ),
        same(PidLineBadgeColorResolver.bus),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.trainS,
          routeShortName: 'S7',
        ),
        same(PidLineBadgeColorResolver.train),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.ferry,
          routeShortName: 'P2',
        ),
        same(PidLineBadgeColorResolver.ferry),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.funicular,
          routeShortName: 'LD',
        ),
        same(PidLineBadgeColorResolver.other),
      );
    });

    test('night lines keep their base transport badge color', () {
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.tramNight,
          routeShortName: '91',
        ),
        same(PidLineBadgeColorResolver.tram),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.cityBusNight,
          routeShortName: '901',
        ),
        same(PidLineBadgeColorResolver.bus),
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.regionalBusNight,
          routeShortName: '951',
        ),
        same(PidLineBadgeColorResolver.bus),
      );
    });

    test('metro B uses dark foreground for readable contrast', () {
      expect(
        PidLineBadgeColorResolver.metroB.foregroundColor,
        const Color(0xFF1F2937),
      );
    });

    test('falls back for unknown line types and unknown metro labels', () {
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.metro,
          routeShortName: 'D',
        ),
        isNull,
      );
      expect(
        PidLineBadgeColorResolver.resolve(
          lineType: PidLineType.unknown,
          routeShortName: '?',
        ),
        isNull,
      );
    });
  });
}
