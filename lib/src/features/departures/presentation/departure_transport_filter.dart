import '../../../core/domain/pid_line_type.dart';
import '../domain/departure.dart';

const List<PidTransportMode> departureTransportModeOrder = [
  PidTransportMode.metro,
  PidTransportMode.tram,
  PidTransportMode.bus,
  PidTransportMode.trolleybus,
  PidTransportMode.train,
  PidTransportMode.ferry,
  PidTransportMode.funicular,
  PidTransportMode.unknown,
];

List<PidTransportMode> deriveDepartureTransportModes(
  Iterable<Departure> departures,
) {
  final modes = departures.map((departure) => departure.lineType.mode).toSet();

  return List<PidTransportMode>.unmodifiable(
    departureTransportModeOrder.where(modes.contains),
  );
}

List<Departure> filterDeparturesByTransportMode(
  Iterable<Departure> departures,
  PidTransportMode? selectedMode,
) {
  if (selectedMode == null) {
    return List<Departure>.unmodifiable(departures);
  }

  return List<Departure>.unmodifiable(
    departures.where((departure) => departure.lineType.mode == selectedMode),
  );
}

PidLineType representativeLineTypeForDepartures(
  Iterable<Departure> departures,
) {
  final modes = deriveDepartureTransportModes(departures);
  if (modes.isEmpty) {
    return PidLineType.unknown;
  }

  return representativeLineTypeForMode(modes.first);
}

PidLineType representativeLineTypeForMode(PidTransportMode mode) {
  return switch (mode) {
    PidTransportMode.metro => PidLineType.metro,
    PidTransportMode.tram => PidLineType.tram,
    PidTransportMode.bus => PidLineType.cityBus,
    PidTransportMode.trolleybus => PidLineType.trolleybus,
    PidTransportMode.train => PidLineType.trainS,
    PidTransportMode.ferry => PidLineType.ferry,
    PidTransportMode.funicular => PidLineType.funicular,
    PidTransportMode.unknown => PidLineType.unknown,
  };
}
