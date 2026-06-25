import 'package:meta/meta.dart';

@immutable
class VehicleId {
  VehicleId(String rawValue) : value = _normalize(rawValue) {
    if (value.isEmpty) {
      throw ArgumentError.value(
        rawValue,
        'rawValue',
        'Vehicle ID is required.',
      );
    }
  }

  final String value;

  static VehicleId? tryParse(String? rawValue) {
    if (rawValue == null) {
      return null;
    }

    final normalized = _normalize(rawValue);
    if (normalized.isEmpty) {
      return null;
    }

    return VehicleId(normalized);
  }

  static String _normalize(String rawValue) {
    return rawValue.trim();
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is VehicleId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
