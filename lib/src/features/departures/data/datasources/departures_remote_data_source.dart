import 'dart:convert';

import '../../../../core/network/golemio_api_client.dart';
import '../../../../core/network/golemio_query_parameters.dart';

const departureBoardsPath = '/v2/public/departureboards';

// Golemio OpenAPI names the departure board filter `stopIds`.
// The live API also accepts array-style `stopIds[]`, but the app uses the plain
// `stopIds` key with grouped stop IDs encoded as a JSON object:
// stopIds={"0":["U717Z5P","U718Z5P"]}.
const departureBoardsStopFilterParameter = 'stopIds';
const departureBoardMaxGroups = 50;
const departureBoardMaxStopsPerGroup = 50;
const departureBoardMaxStopsTotal = 50;
const departureBoardDefaultLimit = 5;
const departureBoardMaxLimit = 30;
const departureBoardDefaultMinutesAfter = 60;
const departureBoardMaxMinutesAfter = 360;
const departureBoardDefaultMinutesBefore = 0;
const departureBoardMinMinutesBefore = -359;
const departureBoardMaxMinutesBefore = 30;

class DepartureBoardRequest {
  factory DepartureBoardRequest({
    required List<String> stopIds,
    int? limit,
    int? minutesAfter,
    int? minutesBefore,
  }) {
    return DepartureBoardRequest.grouped(
      stopIdGroups: [stopIds],
      limit: limit,
      minutesAfter: minutesAfter,
      minutesBefore: minutesBefore,
    );
  }

  factory DepartureBoardRequest.grouped({
    required List<List<String>> stopIdGroups,
    int? limit,
    int? minutesAfter,
    int? minutesBefore,
  }) {
    final validatedGroups = _validateStopIdGroups(stopIdGroups);

    return DepartureBoardRequest._(
      stopIdGroups: validatedGroups,
      limit: _validateOptionalRange(
        name: 'limit',
        value: limit,
        min: 1,
        max: departureBoardMaxLimit,
      ),
      minutesAfter: _validateOptionalRange(
        name: 'minutesAfter',
        value: minutesAfter,
        min: 0,
        max: departureBoardMaxMinutesAfter,
      ),
      minutesBefore: _validateOptionalRange(
        name: 'minutesBefore',
        value: minutesBefore,
        min: departureBoardMinMinutesBefore,
        max: departureBoardMaxMinutesBefore,
      ),
    );
  }

  DepartureBoardRequest._({
    required this.stopIdGroups,
    this.limit,
    this.minutesAfter,
    this.minutesBefore,
  }) : stopIds = List<String>.unmodifiable(stopIdGroups.expand((ids) => ids));

  final List<List<String>> stopIdGroups;

  final List<String> stopIds;
  final int? limit;
  final int? minutesAfter;
  final int? minutesBefore;

  int get effectiveLimit => limit ?? departureBoardDefaultLimit;

  int get effectiveMinutesAfter =>
      minutesAfter ?? departureBoardDefaultMinutesAfter;

  int get effectiveMinutesBefore =>
      minutesBefore ?? departureBoardDefaultMinutesBefore;

  String get path => departureBoardsPath;

  bool get notFoundEmptyListAsSuccess => true;

  GolemioQueryParameters get queryParameters {
    return GolemioQueryParameters([
      GolemioQueryParameter(departureBoardsStopFilterParameter, stopIdsValue),
      GolemioQueryParameter('limit', limit?.toString()),
      GolemioQueryParameter('minutesAfter', minutesAfter?.toString()),
      GolemioQueryParameter('minutesBefore', minutesBefore?.toString()),
    ]);
  }

  String get stopIdsValue => jsonEncode({
    for (var index = 0; index < stopIdGroups.length; index++)
      '$index': stopIdGroups[index],
  });
}

List<List<String>> _validateStopIdGroups(List<List<String>> groups) {
  if (groups.isEmpty) {
    throw ArgumentError.value(
      groups,
      'stopIdGroups',
      'At least one stop ID group is required.',
    );
  }

  if (groups.length > departureBoardMaxGroups) {
    throw RangeError.range(
      groups.length,
      1,
      departureBoardMaxGroups,
      'stopIdGroups.length',
    );
  }

  var totalStops = 0;
  final validatedGroups = <List<String>>[];
  for (var index = 0; index < groups.length; index++) {
    final group = groups[index];
    final stopIds = group
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (stopIds.isEmpty) {
      throw ArgumentError.value(
        group,
        'stopIdGroups[$index]',
        'Each stop ID group must contain at least one non-empty stop ID.',
      );
    }

    if (stopIds.length > departureBoardMaxStopsPerGroup) {
      throw RangeError.range(
        stopIds.length,
        1,
        departureBoardMaxStopsPerGroup,
        'stopIdGroups[$index].length',
      );
    }

    totalStops += stopIds.length;
    if (totalStops > departureBoardMaxStopsTotal) {
      throw RangeError.range(
        totalStops,
        1,
        departureBoardMaxStopsTotal,
        'combined stop ID count',
      );
    }

    validatedGroups.add(List<String>.unmodifiable(stopIds));
  }

  return List<List<String>>.unmodifiable(validatedGroups);
}

int? _validateOptionalRange({
  required String name,
  required int? value,
  required int min,
  required int max,
}) {
  if (value == null) {
    return null;
  }

  if (value < min || value > max) {
    throw RangeError.range(value, min, max, name);
  }

  return value;
}

class DeparturesRemoteDataSource {
  const DeparturesRemoteDataSource(this._apiClient);

  final GolemioApiClient _apiClient;

  Future<Object?> fetchDepartureBoard(DepartureBoardRequest request) {
    return _apiClient.getJson(
      request.path,
      queryParameters: request.queryParameters,
      notFoundEmptyListAsSuccess: request.notFoundEmptyListAsSuccess,
    );
  }
}

String departureBoardStopIdsValue(List<String> stopIds) {
  return DepartureBoardRequest(stopIds: stopIds).stopIdsValue;
}
