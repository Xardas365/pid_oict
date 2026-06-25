import 'dart:async';

import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

sealed class RepositoryResponse<T> {
  const RepositoryResponse();
}

class RepositorySuccess<T> extends RepositoryResponse<T> {
  const RepositorySuccess(this.value);

  final T value;
}

class RepositoryFailure<T> extends RepositoryResponse<T> {
  const RepositoryFailure(this.error);

  final Object error;
}

class RepositoryPending<T> extends RepositoryResponse<T> {
  const RepositoryPending(this.completer);

  final Completer<T> completer;
}

class QueueStopsRepository implements StopsRepository {
  QueueStopsRepository(this._responses);

  final List<RepositoryResponse<List<Stop>>> _responses;
  int callCount = 0;

  @override
  Future<List<Stop>> fetchStops() {
    return _next(_responses);
  }

  Future<T> _next<T>(List<RepositoryResponse<T>> responses) async {
    if (callCount >= responses.length) {
      throw StateError('No fake stops response at index $callCount.');
    }

    final response = responses[callCount];
    callCount++;

    return resolveRepositoryResponse(response);
  }
}

class QueueDeparturesRepository implements DeparturesRepository {
  QueueDeparturesRepository(this._responses);

  final List<RepositoryResponse<List<Departure>>> _responses;
  final receivedStops = <StopGroup>[];
  int callCount = 0;

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) {
    receivedStops.add(stop);
    return _next(_responses);
  }

  Future<T> _next<T>(List<RepositoryResponse<T>> responses) async {
    if (callCount >= responses.length) {
      throw StateError('No fake departures response at index $callCount.');
    }

    final response = responses[callCount];
    callCount++;

    return resolveRepositoryResponse(response);
  }
}

class QueueVehiclePositionRepository implements VehiclePositionRepository {
  QueueVehiclePositionRepository(this._responses);

  final List<RepositoryResponse<VehiclePosition>> _responses;
  final receivedVehicleIds = <String>[];
  int callCount = 0;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String vehicleId) {
    receivedVehicleIds.add(vehicleId);
    return _next(_responses);
  }

  Future<T> _next<T>(List<RepositoryResponse<T>> responses) async {
    if (callCount >= responses.length) {
      throw StateError(
        'No fake vehicle position response at index $callCount.',
      );
    }

    final response = responses[callCount];
    callCount++;

    return resolveRepositoryResponse(response);
  }
}

Future<T> resolveRepositoryResponse<T>(RepositoryResponse<T> response) async {
  return switch (response) {
    RepositorySuccess(:final value) => value,
    RepositoryFailure(:final error) => throwTestError(error),
    RepositoryPending(:final completer) => completer.future,
  };
}

Never throwTestError(Object error) {
  if (error is Exception) {
    throw error;
  }

  if (error is Error) {
    throw error;
  }

  throw StateError(error.toString());
}
