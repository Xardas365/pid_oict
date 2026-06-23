import 'package:flutter/foundation.dart';

import '../utils/pid_transport_type.dart';

@immutable
class PidDepartureData {
  const PidDepartureData({
    required this.id,
    required this.lineLabel,
    required this.destination,
    required this.remainingTimeText,
    this.platformText,
    this.gtfsTripId,
    this.delayText,
    this.transportType = PidTransportType.unknown,
  });

  final String id;
  final String lineLabel;
  final String destination;
  final String remainingTimeText;
  final String? platformText;
  final String? gtfsTripId;
  final String? delayText;
  final PidTransportType transportType;

  bool get isDelayed => delayText != null && delayText!.trim().isNotEmpty;

  PidDepartureData copyWith({
    String? id,
    String? lineLabel,
    String? destination,
    String? remainingTimeText,
    String? platformText,
    String? gtfsTripId,
    String? delayText,
    PidTransportType? transportType,
  }) {
    return PidDepartureData(
      id: id ?? this.id,
      lineLabel: lineLabel ?? this.lineLabel,
      destination: destination ?? this.destination,
      remainingTimeText: remainingTimeText ?? this.remainingTimeText,
      platformText: platformText ?? this.platformText,
      gtfsTripId: gtfsTripId ?? this.gtfsTripId,
      delayText: delayText ?? this.delayText,
      transportType: transportType ?? this.transportType,
    );
  }
}
