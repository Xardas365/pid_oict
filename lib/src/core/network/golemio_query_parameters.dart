class GolemioQueryParameters {
  const GolemioQueryParameters(this.entries);

  const GolemioQueryParameters.empty() : entries = const [];

  factory GolemioQueryParameters.fromEntries(
    Iterable<GolemioQueryParameter> entries,
  ) {
    return GolemioQueryParameters(
      List<GolemioQueryParameter>.unmodifiable(entries),
    );
  }

  factory GolemioQueryParameters.fromMap(Map<String, String?> parameters) {
    return GolemioQueryParameters.fromEntries(
      parameters.entries.map(
        (entry) => GolemioQueryParameter(entry.key, entry.value),
      ),
    );
  }

  final List<GolemioQueryParameter> entries;

  bool get isEmpty => entries.every((entry) => entry.value == null);

  bool get isNotEmpty => !isEmpty;

  String get encoded {
    return entries
        .where((entry) => entry.value != null)
        .map(
          (entry) =>
              '${_encodeQueryKey(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value!)}',
        )
        .join('&');
  }

  String appendToPath(String path) {
    final query = encoded;
    if (query.isEmpty) {
      return path;
    }

    return path.contains('?') ? '$path&$query' : '$path?$query';
  }

  Map<String, String> toSingleValueMap() {
    return <String, String>{
      for (final entry in entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }
}

class GolemioQueryParameter {
  const GolemioQueryParameter(this.key, this.value);

  final String key;
  final String? value;
}

String _encodeQueryKey(String key) {
  return Uri.encodeQueryComponent(key).replaceAll('%5B%5D', '[]');
}
