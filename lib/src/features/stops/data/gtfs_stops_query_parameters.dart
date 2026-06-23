import '../domain/gtfs_stops_query.dart';

const gtfsStopsPath = '/v2/gtfs/stops';

String gtfsStopsPathWithQuery(GtfsStopsQuery query) {
  final queryString = gtfsStopsQueryString(query);
  if (queryString.isEmpty) {
    return gtfsStopsPath;
  }

  return '$gtfsStopsPath?$queryString';
}

String gtfsStopsQueryString(GtfsStopsQuery query) {
  return gtfsStopsQueryParameters(query)
      .map(
        (parameter) =>
            '${_encodeQueryKey(parameter.key)}='
            '${Uri.encodeQueryComponent(parameter.value)}',
      )
      .join('&');
}

List<MapEntry<String, String>> gtfsStopsQueryParameters(GtfsStopsQuery query) {
  final parameters = <MapEntry<String, String>>[];

  _addStringArray(parameters, 'names[]', query.names);
  _addStringArray(parameters, 'ids[]', query.ids);
  _addStringArray(parameters, 'aswIds[]', query.aswIds);
  _addIntArray(parameters, 'cisIds[]', query.cisIds);

  final limit = query.limit;
  if (limit != null) {
    parameters.add(MapEntry('limit', limit.toString()));
  }

  final offset = query.offset;
  if (offset != null) {
    parameters.add(MapEntry('offset', offset.toString()));
  }

  return parameters;
}

void _addStringArray(
  List<MapEntry<String, String>> parameters,
  String key,
  List<String>? values,
) {
  if (values == null) {
    return;
  }

  for (final value in values) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) {
      parameters.add(MapEntry(key, trimmedValue));
    }
  }
}

void _addIntArray(
  List<MapEntry<String, String>> parameters,
  String key,
  List<int>? values,
) {
  if (values == null) {
    return;
  }

  for (final value in values) {
    parameters.add(MapEntry(key, value.toString()));
  }
}

String _encodeQueryKey(String key) {
  return Uri.encodeQueryComponent(key).replaceAll('%5B%5D', '[]');
}
