import 'dart:convert';

import '../../../../core/network/golemio_api_client.dart';

const departureBoardsPath = '/v2/public/departureboards';

// Golemio OpenAPI for /v2/public/departureboards expects stop groups encoded
// as repeated stopIds={"0":["U717Z5P"]} query values.
const departureBoardsStopFilterParameter = 'stopIds';

class DepartureBoardRequest {
  DepartureBoardRequest({required List<String> stopIds})
    : stopIds = List<String>.unmodifiable(
        stopIds.map((id) => id.trim()).where((id) => id.isNotEmpty),
      );

  final List<String> stopIds;

  String get path => departureBoardsPath;

  bool get notFoundEmptyListAsSuccess => true;

  Map<String, String?> get queryParameters => <String, String?>{
    departureBoardsStopFilterParameter: stopIdsValue,
  };

  String get stopIdsValue => jsonEncode({'0': stopIds});
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
