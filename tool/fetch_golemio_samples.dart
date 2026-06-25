import 'dart:convert';
import 'dart:io';

import 'package:pid_oict/src/core/config/app_config.dart';
import 'package:pid_oict/src/features/departures/data/datasources/departures_remote_data_source.dart';
import 'package:pid_oict/src/features/stops/data/datasources/stops_remote_data_source.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';
import 'package:pid_oict/src/features/vehicle_map/data/datasources/vehicle_positions_remote_data_source.dart';

const _outputDirectory = '.debug/golemio_samples';
const _defaultRecordLimit = 20;

Future<void> main(List<String> args) async {
  final options = _SampleToolOptions.parse(args);
  final token = Platform.environment[golemioApiTokenEnvironmentKey]?.trim();

  if (token == null || token.isEmpty) {
    stderr.writeln(
      'Missing $golemioApiTokenEnvironmentKey. '
      'Set it in your shell environment before running this tool.',
    );
    exitCode = 64;
    return;
  }

  final outputDirectory = Directory(_outputDirectory);
  await outputDirectory.create(recursive: true);

  final writtenFiles = <String>[];
  final timestamp = _timestampForFileName(DateTime.now().toUtc());

  writtenFiles.add(
    await _fetchAndWriteSample(
      token: token,
      path: StopsRequest(
        GtfsStopsQuery(limit: options.recordLimit, offset: 0),
      ).path,
      outputPath: '$_outputDirectory/${timestamp}_stops.json',
      recordLimit: options.recordLimit,
    ),
  );

  final stopId = options.stopId;
  if (stopId != null && stopId.isNotEmpty) {
    final request = DepartureBoardRequest(stopIds: [stopId]);
    writtenFiles.add(
      await _fetchAndWriteSample(
        token: token,
        path: request.path,
        queryParameters: request.queryParameters,
        outputPath: '$_outputDirectory/${timestamp}_departures.json',
        recordLimit: options.recordLimit,
      ),
    );
  } else {
    stdout.writeln(
      'Skipping departures sample. Pass --stop-id=<stop_id> to fetch it.',
    );
  }

  final vehicleId = options.vehicleId;
  if (vehicleId != null && vehicleId.isNotEmpty) {
    final request = VehiclePositionRequest(vehicleId: vehicleId);
    writtenFiles.add(
      await _fetchAndWriteSample(
        token: token,
        path: request.path,
        queryParameters: request.queryParameters,
        outputPath: '$_outputDirectory/${timestamp}_vehicle_position.json',
        recordLimit: options.recordLimit,
      ),
    );
  } else {
    stdout.writeln(
      'Skipping vehicle position sample. '
      'Pass --vehicle-id=<vehicle_id> to fetch it.',
    );
  }

  stdout.writeln('Wrote ${writtenFiles.length} sample file(s):');
  for (final path in writtenFiles) {
    stdout.writeln('- $path');
  }
}

Future<String> _fetchAndWriteSample({
  required String token,
  required String path,
  required String outputPath,
  required int recordLimit,
  Map<String, String?> queryParameters = const {},
}) async {
  final uri = Uri.parse(
    '$golemioBaseUrl$path',
  ).replace(queryParameters: queryParameters.isEmpty ? null : queryParameters);
  final json = await _fetchJson(uri, token);
  final sample = _trimSample(json, recordLimit);
  final file = File(outputPath);

  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(sample),
    flush: true,
  );

  return outputPath;
}

Future<Object?> _fetchJson(Uri uri, String token) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    request.headers
      ..set(HttpHeaders.acceptHeader, 'application/json')
      ..set('x-access-token', token);

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Golemio API returned HTTP ${response.statusCode}.',
        uri: uri,
      );
    }

    return jsonDecode(body) as Object?;
  } finally {
    client.close(force: true);
  }
}

Object? _trimSample(Object? value, int limit) {
  if (value is List) {
    return value.take(limit).toList(growable: false);
  }

  if (value is Map<String, Object?>) {
    for (final key in const [
      'features',
      'data',
      'results',
      'departures',
      'vehicle_positions',
      'vehiclePositions',
      'vehiclepositions',
    ]) {
      final nested = value[key];
      if (nested is List) {
        return {...value, key: nested.take(limit).toList(growable: false)};
      }
    }
  }

  return value;
}

String _timestampForFileName(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');

  return '${value.year}'
      '${twoDigits(value.month)}'
      '${twoDigits(value.day)}T'
      '${twoDigits(value.hour)}'
      '${twoDigits(value.minute)}'
      '${twoDigits(value.second)}Z';
}

class _SampleToolOptions {
  const _SampleToolOptions({
    required this.recordLimit,
    this.stopId,
    this.vehicleId,
  });

  factory _SampleToolOptions.parse(List<String> args) {
    String? stopId;
    String? vehicleId;
    var recordLimit = _defaultRecordLimit;

    for (final arg in args) {
      final parsed = _parseOption(arg);
      switch (parsed.key) {
        case '--stop-id':
          stopId = parsed.value;
        case '--vehicle-id':
          vehicleId = parsed.value;
        case '--limit':
          recordLimit = int.tryParse(parsed.value) ?? _defaultRecordLimit;
        default:
          throw FormatException('Unsupported argument: ${parsed.key}');
      }
    }

    return _SampleToolOptions(
      stopId: stopId,
      vehicleId: vehicleId,
      recordLimit: _clampLimit(recordLimit),
    );
  }

  final int recordLimit;
  final String? stopId;
  final String? vehicleId;

  static MapEntry<String, String> _parseOption(String arg) {
    final separator = arg.indexOf('=');
    if (separator <= 0) {
      throw FormatException('Expected --name=value argument, got: $arg');
    }

    return MapEntry(arg.substring(0, separator), arg.substring(separator + 1));
  }
}

int _clampLimit(int value) {
  if (value < 1) {
    return 1;
  }

  if (value > 100) {
    return 100;
  }

  return value;
}
