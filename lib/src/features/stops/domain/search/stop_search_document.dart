import 'package:meta/meta.dart';

import '../stop_group.dart';
import 'stop_search_alias_builder.dart';
import 'stop_search_normalizer.dart';

@immutable
class StopSearchDocument {
  const StopSearchDocument({
    required this.group,
    required this.aliases,
    required this.normalizedAliases,
  });

  factory StopSearchDocument.fromGroup(
    StopGroup group, {
    StopSearchAliasBuilder aliasBuilder = const StopSearchAliasBuilder(),
    StopSearchNormalizer normalizer = const StopSearchNormalizer(),
  }) {
    final aliases = aliasBuilder.buildAliases(group);
    final normalizedAliases = aliases
        .map(normalizer.normalize)
        .where((alias) => alias.isNotEmpty)
        .toList(growable: false);

    return StopSearchDocument(
      group: group,
      aliases: aliases,
      normalizedAliases: List<String>.unmodifiable(normalizedAliases),
    );
  }

  final StopGroup group;
  final List<String> aliases;
  final List<String> normalizedAliases;
}
