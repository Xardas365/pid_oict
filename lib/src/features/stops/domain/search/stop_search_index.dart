import 'package:meta/meta.dart';

import '../stop_group.dart';
import '../stop_visibility.dart';
import 'stop_search_alias_builder.dart';
import 'stop_search_document.dart';

@immutable
class StopSearchIndex {
  const StopSearchIndex({
    required this.groups,
    required this.documents,
    required this.isComplete,
    this.updatedAt,
  });

  factory StopSearchIndex.fromGroups(
    Iterable<StopGroup> groups, {
    bool isComplete = true,
    DateTime? updatedAt,
    StopSearchAliasBuilder aliasBuilder = const StopSearchAliasBuilder(),
  }) {
    final displayableGroups =
        groups.where(isDisplayablePassengerStopGroup).toList(growable: false)
          ..sort(compareStopGroupsByPublicName);
    final documents = displayableGroups
        .map((group) {
          return StopSearchDocument.fromGroup(
            group,
            aliasBuilder: aliasBuilder,
          );
        })
        .toList(growable: false);

    return StopSearchIndex(
      groups: List<StopGroup>.unmodifiable(displayableGroups),
      documents: List<StopSearchDocument>.unmodifiable(documents),
      isComplete: isComplete,
      updatedAt: updatedAt,
    );
  }

  final List<StopGroup> groups;
  final List<StopSearchDocument> documents;
  final bool isComplete;
  final DateTime? updatedAt;
}
