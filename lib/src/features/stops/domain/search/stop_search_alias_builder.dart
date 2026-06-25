import '../stop_group.dart';
import 'stop_search_normalizer.dart';

class StopSearchAliasBuilder {
  const StopSearchAliasBuilder({
    this.normalizer = const StopSearchNormalizer(),
  });

  final StopSearchNormalizer normalizer;

  List<String> buildAliases(StopGroup group) {
    final aliases = <String>[];
    final normalizedAliases = <String>{};

    void addAlias(String? alias) {
      final trimmedAlias = alias?.trim();
      if (trimmedAlias == null || trimmedAlias.isEmpty) {
        return;
      }

      final normalizedAlias = normalizer.normalize(trimmedAlias);
      if (normalizedAlias.isEmpty || !normalizedAliases.add(normalizedAlias)) {
        return;
      }

      aliases.add(trimmedAlias);
    }

    addAlias(group.name);

    for (final stop in group.stops) {
      addAlias(stop.name);
    }

    for (final platformCode in group.platformCodes) {
      addAlias('${group.name} $platformCode');
      addAlias('${group.name} nastupiste $platformCode');
    }

    return List<String>.unmodifiable(aliases);
  }
}
