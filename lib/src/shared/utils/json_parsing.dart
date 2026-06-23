typedef JsonMap = Map<String, Object?>;

class ParsedCoordinates {
  const ParsedCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

JsonMap? asJsonMap(Object? value) {
  if (value is JsonMap) {
    return value;
  }

  if (value is Map) {
    final result = <String, Object?>{};

    for (final entry in value.entries) {
      final key = entry.key;
      if (key is String) {
        result[key] = entry.value;
      }
    }

    return result;
  }

  return null;
}

List<JsonMap> readJsonRecords(Object? value) {
  if (value is List) {
    return _readJsonRecordsFromList(value);
  }

  final json = asJsonMap(value);
  if (json == null) {
    return <JsonMap>[];
  }

  for (final path in const [
    ['features'],
    ['data'],
    ['results'],
    ['departures'],
    ['vehicle_positions'],
    ['vehiclePositions'],
    ['vehiclepositions'],
  ]) {
    final nestedValue = readJsonValue(json, [path]);

    if (nestedValue is List) {
      return _readJsonRecordsFromList(nestedValue);
    }

    final nestedJson = asJsonMap(nestedValue);
    if (nestedJson != null) {
      return [nestedJson];
    }
  }

  return [json];
}

List<JsonMap> _readJsonRecordsFromList(List<Object?> values) {
  final records = <JsonMap>[];

  for (final value in values) {
    final json = asJsonMap(value);
    if (json != null) {
      records.add(json);
      continue;
    }

    if (value is List) {
      records.addAll(_readJsonRecordsFromList(value));
    }
  }

  return records;
}

Object? readJsonValue(JsonMap json, List<List<String>> paths) {
  for (final path in paths) {
    Object? current = json;

    for (final segment in path) {
      final currentMap = asJsonMap(current);
      if (currentMap == null || !currentMap.containsKey(segment)) {
        current = null;
        break;
      }

      current = currentMap[segment];
    }

    if (current != null) {
      return current;
    }
  }

  return null;
}

String? readString(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);
  if (value == null) {
    return null;
  }

  final parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
}

double? readDouble(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.trim());
  }

  return null;
}

int? readInt(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.round();
  }

  if (value is String) {
    return int.tryParse(value.trim());
  }

  return null;
}

bool? readBool(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);

  if (value is bool) {
    return value;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
  }

  return null;
}

DateTime? readDateTime(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);

  if (value is DateTime) {
    return value;
  }

  if (value is num) {
    return _dateTimeFromEpoch(value);
  }

  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsedDate = DateTime.tryParse(trimmed);
    if (parsedDate != null) {
      return parsedDate;
    }

    final parsedNumber = num.tryParse(trimmed);
    if (parsedNumber != null) {
      return _dateTimeFromEpoch(parsedNumber);
    }
  }

  return null;
}

ParsedCoordinates? readGeoJsonPoint(JsonMap json) {
  final coordinates = readJsonValue(json, [
    ['geometry', 'coordinates'],
    ['properties', 'geometry', 'coordinates'],
  ]);

  if (coordinates is List && coordinates.length >= 2) {
    final longitude = _doubleFromValue(coordinates[0]);
    final latitude = _doubleFromValue(coordinates[1]);

    if (_isValidCoordinate(latitude: latitude, longitude: longitude)) {
      return ParsedCoordinates(latitude: latitude!, longitude: longitude!);
    }
  }

  final latitude = readDouble(json, [
    ['latitude'],
    ['lat'],
    ['properties', 'latitude'],
    ['properties', 'lat'],
    ['position', 'latitude'],
    ['position', 'lat'],
    ['properties', 'position', 'latitude'],
    ['properties', 'position', 'lat'],
  ]);
  final longitude = readDouble(json, [
    ['longitude'],
    ['lon'],
    ['lng'],
    ['properties', 'longitude'],
    ['properties', 'lon'],
    ['properties', 'lng'],
    ['position', 'longitude'],
    ['position', 'lon'],
    ['position', 'lng'],
    ['properties', 'position', 'longitude'],
    ['properties', 'position', 'lon'],
    ['properties', 'position', 'lng'],
  ]);

  if (_isValidCoordinate(latitude: latitude, longitude: longitude)) {
    return ParsedCoordinates(latitude: latitude!, longitude: longitude!);
  }

  return null;
}

DateTime _dateTimeFromEpoch(num value) {
  final rounded = value.round();

  if (rounded.abs() >= 100000000000) {
    return DateTime.fromMillisecondsSinceEpoch(rounded, isUtc: true);
  }

  return DateTime.fromMillisecondsSinceEpoch(rounded * 1000, isUtc: true);
}

double? _doubleFromValue(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.trim());
  }

  return null;
}

bool _isValidCoordinate({
  required double? latitude,
  required double? longitude,
}) {
  if (latitude == null || longitude == null) {
    return false;
  }

  return latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}
