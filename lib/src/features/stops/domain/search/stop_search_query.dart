import 'package:meta/meta.dart';

import 'stop_search_normalizer.dart';

@immutable
class StopSearchQuery {
  factory StopSearchQuery.parse(
    String rawInput, {
    StopSearchNormalizer normalizer = const StopSearchNormalizer(),
  }) {
    final normalizedInput = normalizer.normalize(rawInput);
    final tokens = normalizedInput.isEmpty
        ? const <String>[]
        : normalizedInput.split(' ');

    return StopSearchQuery._(
      rawInput: rawInput,
      normalizedInput: normalizedInput,
      tokens: List<String>.unmodifiable(tokens),
    );
  }

  const StopSearchQuery._({
    required this.rawInput,
    required this.normalizedInput,
    required this.tokens,
  });

  final String rawInput;
  final String normalizedInput;
  final List<String> tokens;

  bool get isBlank => normalizedInput.isEmpty;
}
