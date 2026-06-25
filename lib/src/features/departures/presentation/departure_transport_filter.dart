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

const departureTransportFilterPolicy = DepartureTransportFilterPolicy();

class DepartureTransportFilterPolicy {
  const DepartureTransportFilterPolicy({
    this.filterDepartures = const FilterDeparturesByTransportModeUseCase(),
  });

  final FilterDeparturesByTransportModeUseCase filterDepartures;

  List<PidTransportMode> deriveAvailableModes(
    Iterable<Departure> departures,
  ) {
    final modes = departures
        .map((departure) => departure.lineType.mode)
        .toSet();

    return List<PidTransportMode>.unmodifiable(
      departureTransportModeOrder.where(modes.contains),
    );
  }

  PidTransportMode? resolveSelectedMode({
    required Iterable<Departure> departures,
    required PidTransportMode? selectedMode,
  }) {
    if (selectedMode == null) {
      return null;
    }

    final availableModes = deriveAvailableModes(departures);
    return availableModes.contains(selectedMode) ? selectedMode : null;
  }

  PidLineType representativeLineTypeFor(
    Iterable<Departure> departures,
  ) {
    final modes = deriveAvailableModes(departures);
    if (modes.isEmpty) {
      return PidLineType.unknown;
    }

    return representativeLineTypeForMode(modes.first);
  }
}

class FilterDeparturesByTransportModeUseCase {
  const FilterDeparturesByTransportModeUseCase();

  List<Departure> call({
    required Iterable<Departure> departures,
    required PidTransportMode? selectedMode,
  }) {
    if (selectedMode == null) {
      return List<Departure>.unmodifiable(departures);
    }

    return List<Departure>.unmodifiable(
      departures.where((departure) => departure.lineType.mode == selectedMode),
    );
  }
}

List<PidTransportMode> deriveDepartureTransportModes(
  Iterable<Departure> departures,
) {
  return departureTransportFilterPolicy.deriveAvailableModes(departures);
}

List<Departure> filterDeparturesByTransportMode(
  Iterable<Departure> departures,
  PidTransportMode? selectedMode,
) {
  return departureTransportFilterPolicy.filterDepartures(
    departures: departures,
    selectedMode: selectedMode,
  );
}

PidLineType representativeLineTypeForDepartures(
  Iterable<Departure> departures,
) {
  return departureTransportFilterPolicy.representativeLineTypeFor(departures);
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
