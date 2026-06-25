import '../../../../shared/utils/json_parsing.dart';
import '../../domain/saved_stop_groups.dart';

const savedStopsSchemaVersion = 1;
const int maxRecentStopsCount = maxRecentStopGroupsCount;

class FavoriteStops {
  const FavoriteStops({
    required this.updatedAt,
    this.schemaVersion = savedStopsSchemaVersion,
    this.favoriteGroupIds = const <String>[],
  });

  FavoriteStops.empty({DateTime? updatedAt})
    : this(updatedAt: updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0));

  final int schemaVersion;
  final DateTime updatedAt;
  final List<String> favoriteGroupIds;

  FavoriteStops add(String groupId, {required DateTime updatedAt}) {
    final normalizedGroupId = _normalizeGroupId(groupId);
    if (normalizedGroupId == null ||
        favoriteGroupIds.contains(normalizedGroupId)) {
      return this;
    }

    return FavoriteStops(
      updatedAt: updatedAt,
      favoriteGroupIds: List<String>.unmodifiable([
        ...favoriteGroupIds,
        normalizedGroupId,
      ]),
    );
  }

  FavoriteStops remove(String groupId, {required DateTime updatedAt}) {
    final normalizedGroupId = _normalizeGroupId(groupId);
    if (normalizedGroupId == null) {
      return this;
    }

    final updatedGroupIds = favoriteGroupIds
        .where((id) => id != normalizedGroupId)
        .toList(growable: false);
    if (updatedGroupIds.length == favoriteGroupIds.length) {
      return this;
    }

    return FavoriteStops(
      updatedAt: updatedAt,
      favoriteGroupIds: List<String>.unmodifiable(updatedGroupIds),
    );
  }

  JsonMap toJson() {
    return {
      'schemaVersion': schemaVersion,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'favoriteGroupIds': favoriteGroupIds,
    };
  }

  static FavoriteStops? fromJson(Object? value) {
    final json = asJsonMap(value);
    if (json == null || !_hasSupportedSchema(json)) {
      return null;
    }

    final updatedAt = readDateTime(json, const [
      ['updatedAt'],
    ]);
    final favoriteGroupIds = _readGroupIds(json, const [
      ['favoriteGroupIds'],
    ]);
    if (updatedAt == null || favoriteGroupIds == null) {
      return null;
    }

    return FavoriteStops(
      updatedAt: updatedAt,
      favoriteGroupIds: favoriteGroupIds,
    );
  }
}

class RecentStops {
  const RecentStops({
    required this.updatedAt,
    this.schemaVersion = savedStopsSchemaVersion,
    this.recentGroupIds = const <String>[],
  });

  RecentStops.empty({DateTime? updatedAt})
    : this(updatedAt: updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0));

  final int schemaVersion;
  final DateTime updatedAt;
  final List<String> recentGroupIds;

  RecentStops add(
    String groupId, {
    required DateTime updatedAt,
    int maxCount = maxRecentStopsCount,
  }) {
    final normalizedGroupId = _normalizeGroupId(groupId);
    if (normalizedGroupId == null || maxCount <= 0) {
      return this;
    }

    final updatedGroupIds = <String>[
      normalizedGroupId,
      ...recentGroupIds.where((id) => id != normalizedGroupId),
    ].take(maxCount).toList(growable: false);

    return RecentStops(
      updatedAt: updatedAt,
      recentGroupIds: List<String>.unmodifiable(updatedGroupIds),
    );
  }

  JsonMap toJson() {
    return {
      'schemaVersion': schemaVersion,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'recentGroupIds': recentGroupIds.take(maxRecentStopsCount).toList(),
    };
  }

  static RecentStops? fromJson(Object? value) {
    final json = asJsonMap(value);
    if (json == null || !_hasSupportedSchema(json)) {
      return null;
    }

    final updatedAt = readDateTime(json, const [
      ['updatedAt'],
    ]);
    final recentGroupIds = _readGroupIds(json, const [
      ['recentGroupIds'],
    ]);
    if (updatedAt == null || recentGroupIds == null) {
      return null;
    }

    return RecentStops(
      updatedAt: updatedAt,
      recentGroupIds: List<String>.unmodifiable(
        recentGroupIds.take(maxRecentStopsCount),
      ),
    );
  }
}

bool _hasSupportedSchema(JsonMap json) {
  final schemaVersion = readInt(json, const [
    ['schemaVersion'],
  ]);

  return schemaVersion == savedStopsSchemaVersion;
}

List<String>? _readGroupIds(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);
  if (value is! List) {
    return null;
  }

  final groupIds = <String>[];
  final seenGroupIds = <String>{};

  for (final groupIdValue in value) {
    final groupId = _normalizeGroupId(groupIdValue?.toString());
    if (groupId == null || seenGroupIds.contains(groupId)) {
      continue;
    }

    groupIds.add(groupId);
    seenGroupIds.add(groupId);
  }

  return List<String>.unmodifiable(groupIds);
}

String? _normalizeGroupId(String? groupId) {
  final normalizedGroupId = groupId?.trim();
  if (normalizedGroupId == null || normalizedGroupId.isEmpty) {
    return null;
  }

  return normalizedGroupId;
}
