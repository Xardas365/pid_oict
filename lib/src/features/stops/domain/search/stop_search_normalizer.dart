class StopSearchNormalizer {
  const StopSearchNormalizer();

  String normalize(String value) {
    final normalizedWhitespace = value.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final buffer = StringBuffer();

    for (final codeUnit in normalizedWhitespace.codeUnits) {
      final character = String.fromCharCode(codeUnit);
      buffer.write(_searchCharacterReplacements[character] ?? character);
    }

    return _normalizeAbbreviations(buffer.toString());
  }

  String _normalizeAbbreviations(String value) {
    final normalized = value
        .replaceAll(RegExp('[.,]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return normalized
        .replaceAll(RegExp(r'\bhl\s*n\b'), 'hlavni nadrazi')
        .replaceAll(RegExp(r'\bhl\b'), 'hlavni')
        .replaceAll(RegExp(r'\bnadr\b'), 'nadrazi')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

const stopSearchNormalizer = StopSearchNormalizer();

String normalizeStopSearchText(String value) {
  return stopSearchNormalizer.normalize(value);
}

const _searchCharacterReplacements = <String, String>{
  'á': 'a',
  'č': 'c',
  'ď': 'd',
  'é': 'e',
  'ě': 'e',
  'í': 'i',
  'ň': 'n',
  'ó': 'o',
  'ř': 'r',
  'š': 's',
  'ť': 't',
  'ú': 'u',
  'ů': 'u',
  'ý': 'y',
  'ž': 'z',
};
