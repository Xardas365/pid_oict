import '../../../../core/network/golemio_api_client.dart';
import '../../../../core/network/golemio_query_parameters.dart';
import '../../domain/gtfs_stops_query.dart';
import '../gtfs_stops_query_parameters.dart';

class StopsRequest {
  const StopsRequest(this.query);

  final GtfsStopsQuery query;

  String get path => gtfsStopsPath;

  GolemioQueryParameters get queryParameters => gtfsStopsQueryParameters(query);
}

class StopsRemoteDataSource {
  const StopsRemoteDataSource(this._apiClient);

  final GolemioApiClient _apiClient;

  Future<Object?> fetchStops(StopsRequest request) {
    return _apiClient.getJson(
      request.path,
      queryParameters: request.queryParameters,
    );
  }
}
