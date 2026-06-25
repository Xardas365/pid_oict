import '../../../../core/errors/app_failure.dart';
import '../../domain/vehicle_position.dart';

enum VehicleMapStatus { loading, loaded, noPosition, error }

class VehicleMapState {
  const VehicleMapState({
    required this.status,
    this.vehicleId,
    this.position,
    this.error,
    this.staleError,
    this.isRefreshing = false,
  });

  const VehicleMapState.loading({String? vehicleId})
    : this(status: VehicleMapStatus.loading, vehicleId: vehicleId);

  final VehicleMapStatus status;
  final String? vehicleId;
  final VehiclePosition? position;
  final AppFailure? error;
  final AppFailure? staleError;
  final bool isRefreshing;

  bool get hasPosition => position != null;

  VehicleMapState copyWith({
    VehicleMapStatus? status,
    String? vehicleId,
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
}
