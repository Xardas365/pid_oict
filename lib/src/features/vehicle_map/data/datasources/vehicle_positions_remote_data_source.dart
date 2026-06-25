import '../../../../core/network/golemio_api_client.dart';

const vehiclePositionsPath = '/v2/public/vehiclepositions';
const vehiclePositionScopesParameter = 'scopes';
const vehiclePositionInfoScope = 'info';

class VehiclePositionRequest {
  VehiclePositionRequest({required String vehicleId})
    : vehicleId = vehicleId.trim();

  final String vehicleId;

  String get path => '$vehiclePositionsPath/${Uri.encodeComponent(vehicleId)}';

  Map<String, String?> get queryParameters => const <String, String?>{
    vehiclePositionScopesParameter: vehiclePositionInfoScope,
  };
}

class VehiclePositionsRemoteDataSource {
  const VehiclePositionsRemoteDataSource(this._apiClient);

  final GolemioApiClient _apiClient;

  Future<Object?> fetchVehiclePosition(VehiclePositionRequest request) {
    return _apiClient.getJson(
      request.path,
      queryParameters: request.queryParameters,
    );
  }
}
