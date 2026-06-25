import '../../../../core/network/golemio_api_client.dart';
import '../../../../core/network/golemio_query_parameters.dart';
import '../../domain/vehicle_id.dart';

const vehiclePositionsPath = '/v2/public/vehiclepositions';
const vehiclePositionScopesParameter = 'scopes';
const vehiclePositionInfoScope = 'info';
const vehiclePositionStopTimesScope = 'stop_times';
const vehiclePositionShapesScope = 'shapes';
const vehiclePositionVehicleDescriptorScope = 'vehicle_descriptor';

class VehiclePositionRequest {
  const VehiclePositionRequest({required this.vehicleId});

  final VehicleId vehicleId;

  String get path {
    return '$vehiclePositionsPath/${Uri.encodeComponent(vehicleId.value)}';
  }

  GolemioQueryParameters get queryParameters => const GolemioQueryParameters([
    GolemioQueryParameter(
      vehiclePositionScopesParameter,
      vehiclePositionInfoScope,
    ),
    GolemioQueryParameter(
      vehiclePositionScopesParameter,
      vehiclePositionStopTimesScope,
    ),
    GolemioQueryParameter(
      vehiclePositionScopesParameter,
      vehiclePositionShapesScope,
    ),
    GolemioQueryParameter(
      vehiclePositionScopesParameter,
      vehiclePositionVehicleDescriptorScope,
    ),
  ]);
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
