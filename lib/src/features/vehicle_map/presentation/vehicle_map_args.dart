import 'package:meta/meta.dart';

import '../../../core/domain/pid_line_type.dart';
import '../../departures/domain/departure.dart';
import '../domain/vehicle_id.dart';

@immutable
class VehicleMapArgs {
  const VehicleMapArgs({
    required this.vehicleId,
    this.routeShortName,
    this.headsign,
    this.routeType,
    this.lineType,
  });

  final VehicleId vehicleId;
  final String? routeShortName;
  final String? headsign;
  final String? routeType;
  final PidLineType? lineType;

  static VehicleMapArgs? tryParseVehicleId(String? rawVehicleId) {
    final vehicleId = VehicleId.tryParse(rawVehicleId);
    if (vehicleId == null) {
      return null;
    }

    return VehicleMapArgs(vehicleId: vehicleId);
  }

  static VehicleMapArgs? fromDeparture(Departure departure) {
    final vehicleId = VehicleId.tryParse(departure.vehicleId);
    if (vehicleId == null) {
      return null;
    }

    return VehicleMapArgs(
      vehicleId: vehicleId,
      routeShortName: _trimOrNull(departure.routeShortName),
      headsign: _trimOrNull(departure.headsign),
      routeType: _trimOrNull(departure.routeType),
      lineType: departure.lineType,
    );
  }

  String? get title {
    final route = routeShortName;
    final destination = headsign;
    if (route == null || destination == null) {
      return null;
    }

    return '$route – $destination';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehicleMapArgs &&
            vehicleId == other.vehicleId &&
            routeShortName == other.routeShortName &&
            headsign == other.headsign &&
            routeType == other.routeType &&
            lineType == other.lineType;
  }

  @override
  int get hashCode {
    return Object.hash(
      vehicleId,
      routeShortName,
      headsign,
      routeType,
      lineType,
    );
  }
}

String? _trimOrNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
