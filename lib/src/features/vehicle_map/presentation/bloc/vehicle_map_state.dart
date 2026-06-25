import 'package:meta/meta.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/vehicle_id.dart';
import '../../domain/vehicle_position.dart';

enum VehicleMapStatus { loading, loaded, noPosition, error }

@immutable
class VehicleMapState {
  const VehicleMapState({
    required this.status,
    this.vehicleId,
    this.position,
    this.error,
    this.staleError,
    this.isRefreshing = false,
  });

  const VehicleMapState.loading({VehicleId? vehicleId})
    : this(status: VehicleMapStatus.loading, vehicleId: vehicleId);

  final VehicleMapStatus status;
  final VehicleId? vehicleId;
  final VehiclePosition? position;
  final AppFailure? error;
  final AppFailure? staleError;
  final bool isRefreshing;

  bool get hasPosition => position != null;

  VehicleMapState copyWith({
    VehicleMapStatus? status,
    VehicleId? vehicleId,
    VehiclePosition? position,
    AppFailure? error,
    AppFailure? staleError,
    bool? isRefreshing,
    bool clearError = false,
    bool clearStaleError = false,
  }) {
    return VehicleMapState(
      status: status ?? this.status,
      vehicleId: vehicleId ?? this.vehicleId,
      position: position ?? this.position,
      error: clearError ? null : error ?? this.error,
      staleError: clearStaleError ? null : staleError ?? this.staleError,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehicleMapState &&
            status == other.status &&
            vehicleId == other.vehicleId &&
            position == other.position &&
            error == other.error &&
            staleError == other.staleError &&
            isRefreshing == other.isRefreshing;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      vehicleId,
      position,
      error,
      staleError,
      isRefreshing,
    );
  }
}
