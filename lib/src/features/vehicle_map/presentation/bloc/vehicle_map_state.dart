import '../../domain/vehicle_position.dart';

enum VehicleMapStatus { loading, loaded, noPosition, error }

class VehicleMapState {
  const VehicleMapState({
    required this.status,
    this.gtfsTripId,
    this.position,
    this.error,
    this.staleError,
    this.isRefreshing = false,
  });

  const VehicleMapState.loading({String? gtfsTripId})
    : this(status: VehicleMapStatus.loading, gtfsTripId: gtfsTripId);

  final VehicleMapStatus status;
  final String? gtfsTripId;
  final VehiclePosition? position;
  final Object? error;
  final Object? staleError;
  final bool isRefreshing;

  bool get hasPosition => position != null;

  VehicleMapState copyWith({
    VehicleMapStatus? status,
    String? gtfsTripId,
    VehiclePosition? position,
    Object? error,
    Object? staleError,
    bool? isRefreshing,
    bool clearError = false,
    bool clearStaleError = false,
  }) {
    return VehicleMapState(
      status: status ?? this.status,
      gtfsTripId: gtfsTripId ?? this.gtfsTripId,
      position: position ?? this.position,
      error: clearError ? null : error ?? this.error,
      staleError: clearStaleError ? null : staleError ?? this.staleError,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
