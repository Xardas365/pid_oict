import '../../../i18n/strings.g.dart';
import '../domain/pid_line_type.dart';

class PidLineTypeLabelMapper {
  const PidLineTypeLabelMapper(this._strings);

  final Translations _strings;

  String labelFor(PidLineType lineType) {
    final labels = _strings.transport.lineTypes;

    return switch (lineType) {
      PidLineType.metro => labels.metro,
      PidLineType.tram => labels.tram,
      PidLineType.tramSpecial => labels.tramSpecial,
      PidLineType.tramNight => labels.tramNight,
      PidLineType.cityBus => labels.cityBus,
      PidLineType.cityBusNight => labels.cityBusNight,
      PidLineType.regionalBus => labels.regionalBus,
      PidLineType.regionalBusNight => labels.regionalBusNight,
      PidLineType.trolleybus => labels.trolleybus,
      PidLineType.trainS => labels.trainS,
      PidLineType.trainR => labels.trainR,
      PidLineType.trainInterregional => labels.trainInterregional,
      PidLineType.trainTourist => labels.trainTourist,
      PidLineType.ferry => labels.ferry,
      PidLineType.funicular => labels.funicular,
      PidLineType.replacementMetro => labels.replacementMetro,
      PidLineType.replacementTram => labels.replacementTram,
      PidLineType.replacementBus => labels.replacementBus,
      PidLineType.replacementTrain => labels.replacementTrain,
      PidLineType.replacementUnknown => labels.replacementUnknown,
      PidLineType.schoolBus => labels.schoolBus,
      PidLineType.specialOther => labels.specialOther,
      PidLineType.unknown => labels.unknown,
    };
  }
}
