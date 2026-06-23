import 'package:flutter/foundation.dart';

import '../utils/pid_transport_type.dart';

@immutable
class PidVehiclePositionData {
  const PidVehiclePositionData({
    required this.vehicleId,
    required this.lineLabel,
    required this.destination,
    required this.lastUpdatedText,
    this.latitude,
    this.longitude,
    this.speedText,
    this.coordinatesText,
    this.transportType = PidTransportType.unknown,
  });

  final String vehicleId;
  final String lineLabel;
  final String destination;
  final String lastUpdatedText;
  final double? latitude;
  final double? longitude;
  final String? speedText;
  final String? coordinatesText;
  final PidTransportType transportType;

  PidVehiclePositionData copyWith({
    String? vehicleId,
    String? lineLabel,
    String? destination,
    String? lastUpdatedText,
    double? latitude,
    double? longitude,
    String? speedText,
    String? coordinatesText,
    PidTransportType? transportType,
  }) {
    return PidVehiclePositionData(
      vehicleId: vehicleId ?? this.vehicleId,
      lineLabel: lineLabel ?? this.lineLabel,
      destination: destination ?? this.destination,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedText: speedText ?? this.speedText,
      coordinatesText: coordinatesText ?? this.coordinatesText,
      transportType: transportType ?? this.transportType,
    );
  }
}
