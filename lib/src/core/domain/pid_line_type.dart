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

  String get label {
    return switch (this) {
      PidLineType.metro => 'Metro',
      PidLineType.tram => 'Tramvaj',
      PidLineType.tramSpecial => 'Zvláštní tramvaj',
      PidLineType.tramNight => 'Noční tramvaj',
      PidLineType.cityBus => 'Městský autobus',
      PidLineType.cityBusNight => 'Noční městský autobus',
      PidLineType.regionalBus => 'Regionální autobus',
      PidLineType.regionalBusNight => 'Noční regionální autobus',
      PidLineType.trolleybus => 'Trolejbus',
      PidLineType.trainS => 'Vlak S',
      PidLineType.trainR => 'Vlak R',
      PidLineType.trainInterregional => 'Mezikrajský vlak',
      PidLineType.trainTourist => 'Turistický vlak',
      PidLineType.ferry => 'Přívoz',
      PidLineType.funicular => 'Lanová dráha',
      PidLineType.replacementMetro => 'Náhradní doprava za metro',
      PidLineType.replacementTram => 'Náhradní tramvajová doprava',
      PidLineType.replacementBus => 'Náhradní autobusová doprava',
      PidLineType.replacementTrain => 'Náhradní vlaková doprava',
      PidLineType.replacementUnknown => 'Náhradní doprava',
      PidLineType.schoolBus => 'Školní linka',
      PidLineType.specialOther => 'Ostatní / zvláštní linka',
      PidLineType.unknown => 'Neznámý typ linky',
    };
  }

  bool get isNight => service == PidServiceKind.night;

  bool get isReplacement => service == PidServiceKind.replacement;
}
