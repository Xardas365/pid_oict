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
  });
}
