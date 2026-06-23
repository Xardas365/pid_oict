class GtfsStopsQuery {
  const GtfsStopsQuery({
    this.limit,
    this.offset,
    this.names,
    this.ids,
    this.aswIds,
    this.cisIds,
  });

  final int? limit;
  final int? offset;
  final List<String>? names;
  final List<String>? ids;
  final List<String>? aswIds;
  final List<int>? cisIds;

  bool get hasSearchTerms =>
      _hasValues(names) ||
      _hasValues(ids) ||
      _hasValues(aswIds) ||
      (cisIds != null && cisIds!.isNotEmpty);

  static bool _hasValues(List<String>? values) {
    return values != null && values.any((value) => value.trim().isNotEmpty);
  }
}
