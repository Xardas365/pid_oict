import 'pid_line_type.dart';

PidLineType fromPidPage({
  required PidLinePage page,
  required String shortName,
}) {
  final normalized = _normalizeShortName(shortName);
  if (normalized.isEmpty) {
    return PidLineType.unknown;
  }

  final guessed = guessFromShortName(normalized);

  return switch (page) {
    PidLinePage.metro => PidLineType.metro,
    PidLinePage.tram => _fromTramPage(normalized, guessed),
    PidLinePage.cityBus => _fromBusPage(normalized, guessed),
    PidLinePage.regionalBus => _fromRegionalBusPage(normalized, guessed),
    PidLinePage.trolleybus => PidLineType.trolleybus,
    PidLinePage.train => _fromTrainPage(guessed),
    PidLinePage.ferry => PidLineType.ferry,
    PidLinePage.nightTransport => _fromNightPage(guessed),
    PidLinePage.replacement => _guessReplacement(normalized),
    PidLinePage.school => PidLineType.schoolBus,
    PidLinePage.funicular => PidLineType.funicular,
    PidLinePage.other => _fromOtherPage(guessed),
    PidLinePage.unknown => guessed,
  };
}

PidLineType guessFromShortName(String shortName) {
  final normalized = _normalizeShortName(shortName);
  if (normalized.isEmpty) {
    return PidLineType.unknown;
  }

  if (normalized.startsWith('X')) {
    return _guessReplacement(normalized);
  }

  if (_isMetroLine(normalized)) {
    return PidLineType.metro;
  }

  final trainType = _guessTrain(normalized);
  if (trainType != null) {
    return trainType;
  }

  final lineNumber = _parseStrictInt(normalized);
  if (lineNumber != null) {
    return _guessNumericLine(lineNumber);
  }

  return _looksSpecialLabel(normalized)
      ? PidLineType.specialOther
      : PidLineType.unknown;
}

/// Converts a broad Golemio departure route type into a PID source page where
/// that context is specific enough. `bus` still needs line-number fallback
/// because it can mean city, regional, school, or night service.
PidLinePage? pidLinePageFromGolemioRouteType(String? routeType) {
  final normalized = routeType?.trim().toLowerCase();

  return switch (normalized) {
    'metro' => PidLinePage.metro,
    'tram' => PidLinePage.tram,
    'train' => PidLinePage.train,
    'ferry' => PidLinePage.ferry,
    'funicular' => PidLinePage.funicular,
    'trolleybus' => PidLinePage.trolleybus,
    'ext_miscellaneous' => PidLinePage.other,
    _ => null,
  };
}

PidLineType _fromTramPage(String normalized, PidLineType guessed) {
  if (guessed.mode == PidTransportMode.tram) {
    return guessed;
  }

  return _parseStrictInt(normalized) == null
      ? PidLineType.specialOther
      : PidLineType.tram;
}

PidLineType _fromBusPage(String normalized, PidLineType guessed) {
  if (guessed.mode == PidTransportMode.bus ||
      guessed == PidLineType.trolleybus ||
      guessed == PidLineType.schoolBus) {
    return guessed;
  }

  return _parseStrictInt(normalized) == null
      ? PidLineType.specialOther
      : PidLineType.cityBus;
}

PidLineType _fromRegionalBusPage(String normalized, PidLineType guessed) {
  if (guessed == PidLineType.regionalBus ||
      guessed == PidLineType.regionalBusNight) {
    return guessed;
  }

  return _parseStrictInt(normalized) == null
      ? PidLineType.specialOther
      : PidLineType.regionalBus;
}

PidLineType _fromTrainPage(PidLineType guessed) {
  if (guessed.mode == PidTransportMode.train) {
    return guessed;
  }

  return PidLineType.trainInterregional;
}

PidLineType _fromNightPage(PidLineType guessed) {
  return guessed.isNight ? guessed : PidLineType.specialOther;
}

PidLineType _fromOtherPage(PidLineType guessed) {
  return guessed == PidLineType.unknown ? PidLineType.specialOther : guessed;
}

PidLineType _guessReplacement(String normalized) {
  if (normalized == 'X') {
    return PidLineType.replacementUnknown;
  }

  final replacedLine = normalized.substring(1);
  if (_isMetroLine(replacedLine)) {
    return PidLineType.replacementMetro;
  }

  if (_isReplacementTrain(replacedLine)) {
    return PidLineType.replacementTrain;
  }

  final replacedType = guessFromShortName(replacedLine);
  return switch (replacedType.mode) {
    PidTransportMode.tram => PidLineType.replacementTram,
    PidTransportMode.bus ||
    PidTransportMode.trolleybus => PidLineType.replacementBus,
    PidTransportMode.train => PidLineType.replacementTrain,
    _ => PidLineType.replacementUnknown,
  };
}

PidLineType _guessNumericLine(int lineNumber) {
  if (_isTrolleybusNumber(lineNumber)) {
    return PidLineType.trolleybus;
  }

  if (_isBetween(lineNumber, 1, 26)) {
    return PidLineType.tram;
  }

  if (_isSpecialTramNumber(lineNumber)) {
    return PidLineType.tramSpecial;
  }

  if (_isBetween(lineNumber, 91, 99)) {
    return PidLineType.tramNight;
  }

  if (_isBetween(lineNumber, 100, 250)) {
    return PidLineType.cityBus;
  }

  if (_isBetween(lineNumber, 251, 280)) {
    return PidLineType.schoolBus;
  }

  if (_isBetween(lineNumber, 300, 899)) {
    return PidLineType.regionalBus;
  }

  if (_isBetween(lineNumber, 901, 917)) {
    return PidLineType.cityBusNight;
  }

  if (_isBetween(lineNumber, 951, 999)) {
    return PidLineType.regionalBusNight;
  }

  return PidLineType.unknown;
}

PidLineType? _guessTrain(String normalized) {
  final match = RegExp(r'^([SRTPUVL])(\d+)$').firstMatch(normalized);
  if (match == null) {
    return null;
  }

  return switch (match.group(1)) {
    'S' => PidLineType.trainS,
    'R' => PidLineType.trainR,
    'T' => PidLineType.trainTourist,
    'P' || 'U' || 'V' || 'L' => PidLineType.trainInterregional,
    _ => null,
  };
}

bool _isReplacementTrain(String replacedLine) {
  return RegExp(r'^[SR]\d+$').hasMatch(replacedLine);
}

bool _isMetroLine(String normalized) {
  return normalized == 'A' || normalized == 'B' || normalized == 'C';
}

bool _isTrolleybusNumber(int lineNumber) {
  return const {51, 52, 53, 58, 59}.contains(lineNumber);
}

bool _isSpecialTramNumber(int lineNumber) {
  return const {31, 34, 37, 41, 42}.contains(lineNumber);
}

bool _isBetween(int value, int min, int max) {
  return value >= min && value <= max;
}

int? _parseStrictInt(String value) {
  return RegExp(r'^\d+$').hasMatch(value) ? int.parse(value) : null;
}

String _normalizeShortName(String shortName) {
  return shortName.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
}

bool _looksSpecialLabel(String normalized) {
  if (normalized.isEmpty) {
    return false;
  }

  return normalized.startsWith('*') ||
      normalized.contains('MHD') ||
      RegExp('[A-Z]').hasMatch(normalized);
}
