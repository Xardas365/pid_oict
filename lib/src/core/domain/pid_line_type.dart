enum PidTransportMode {
  metro,
  tram,
  bus,
  trolleybus,
  train,
  ferry,
  funicular,
  unknown,
}

enum PidServiceKind {
  regular,
  night,
  replacement,
  school,
  special,
  tourist,
  interregional,
  unknown,
}

enum PidLinePage {
  metro,
  tram,
  cityBus,
  regionalBus,
  trolleybus,
  train,
  ferry,
  nightTransport,
  replacement,
  school,
  other,
  funicular,
  unknown,
}

enum PidLineType {
  metro,
  tram,
  tramSpecial,
  tramNight,
  cityBus,
  cityBusNight,
  regionalBus,
  regionalBusNight,
  trolleybus,
  trainS,
  trainR,
  trainInterregional,
  trainTourist,
  ferry,
  funicular,
  replacementMetro,
  replacementTram,
  replacementBus,
  replacementTrain,
  replacementUnknown,
  schoolBus,
  specialOther,
  unknown,
}

extension PidLineTypeInfo on PidLineType {
  PidTransportMode get mode {
    return switch (this) {
      PidLineType.metro ||
      PidLineType.replacementMetro => PidTransportMode.metro,
      PidLineType.tram ||
      PidLineType.tramSpecial ||
      PidLineType.tramNight ||
      PidLineType.replacementTram => PidTransportMode.tram,
      PidLineType.cityBus ||
      PidLineType.cityBusNight ||
      PidLineType.regionalBus ||
      PidLineType.regionalBusNight ||
      PidLineType.replacementBus ||
      PidLineType.schoolBus => PidTransportMode.bus,
      PidLineType.trolleybus => PidTransportMode.trolleybus,
      PidLineType.trainS ||
      PidLineType.trainR ||
      PidLineType.trainInterregional ||
      PidLineType.trainTourist ||
      PidLineType.replacementTrain => PidTransportMode.train,
      PidLineType.ferry => PidTransportMode.ferry,
      PidLineType.funicular => PidTransportMode.funicular,
      PidLineType.replacementUnknown ||
      PidLineType.specialOther ||
      PidLineType.unknown => PidTransportMode.unknown,
    };
  }

  PidServiceKind get service {
    return switch (this) {
      PidLineType.tramNight ||
      PidLineType.cityBusNight ||
      PidLineType.regionalBusNight => PidServiceKind.night,
      PidLineType.replacementMetro ||
      PidLineType.replacementTram ||
      PidLineType.replacementBus ||
      PidLineType.replacementTrain ||
      PidLineType.replacementUnknown => PidServiceKind.replacement,
      PidLineType.schoolBus => PidServiceKind.school,
      PidLineType.tramSpecial ||
      PidLineType.specialOther => PidServiceKind.special,
      PidLineType.trainTourist => PidServiceKind.tourist,
      PidLineType.trainInterregional => PidServiceKind.interregional,
      PidLineType.unknown => PidServiceKind.unknown,
      _ => PidServiceKind.regular,
    };
  }

  bool get isNight => service == PidServiceKind.night;

  bool get isReplacement => service == PidServiceKind.replacement;
}
