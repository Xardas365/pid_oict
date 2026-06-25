import '../../../core/network/golemio_query_parameters.dart';
import '../domain/gtfs_stops_query.dart';

const gtfsStopsPath = '/v2/gtfs/stops';

String gtfsStopsPathWithQuery(GtfsStopsQuery query) {
  return gtfsStopsQueryParameters(query).appendToPath(gtfsStopsPath);
}

String gtfsStopsQueryString(GtfsStopsQuery query) {
  return gtfsStopsQueryParameters(query).encoded;
}

GolemioQueryParameters gtfsStopsQueryParameters(GtfsStopsQuery query) {
  final parameters = <GolemioQueryParameter>[];

  _addStringArray(parameters, 'names[]', query.names);
  _addStringArray(parameters, 'ids[]', query.ids);
  _addStringArray(parameters, 'aswIds[]', query.aswIds);
  _addIntArray(parameters, 'cisIds[]', query.cisIds);

  final limit = query.limit;
  if (limit != null) {
    parameters.add(GolemioQueryParameter('limit', limit.toString()));
  }

  final offset = query.offset;
  if (offset != null) {
    parameters.add(GolemioQueryParameter('offset', offset.toString()));
  }

  return GolemioQueryParameters.fromEntries(parameters);
}

void _addStringArray(
  List<GolemioQueryParameter> parameters,
  String key,
  List<String>? values,
) {
  if (values == null) {
    return;
  }

  for (final value in values) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      parameters.add(GolemioQueryParameter(key, trimmedValue));
    }
  }
}

void _addIntArray(
  List<GolemioQueryParameter> parameters,
  String key,
  List<int>? values,
) {
  if (values == null) {
    return;
  }

  for (final value in values) {
    parameters.add(GolemioQueryParameter(key, value.toString()));
  }
}
