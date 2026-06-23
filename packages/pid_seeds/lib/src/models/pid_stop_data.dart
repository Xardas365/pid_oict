import 'package:flutter/foundation.dart';

import '../utils/pid_transport_type.dart';

@immutable
class PidStopData {
  const PidStopData({
    required this.id,
    required this.name,
    this.subtitle = '',
    this.distanceText,
    this.lineCountText,
    this.transportType = PidTransportType.unknown,
    this.isHighlighted = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? distanceText;
  final String? lineCountText;
  final PidTransportType transportType;
  final bool isHighlighted;

  PidStopData copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? distanceText,
    String? lineCountText,
    PidTransportType? transportType,
    bool? isHighlighted,
  }) {
    return PidStopData(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      distanceText: distanceText ?? this.distanceText,
      lineCountText: lineCountText ?? this.lineCountText,
      transportType: transportType ?? this.transportType,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}
