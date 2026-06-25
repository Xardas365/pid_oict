const maxRecentStopGroupsCount = 10;

class SavedStopGroups {
  const SavedStopGroups({
    this.favoriteGroupIds = const <String>[],
    this.recentGroupIds = const <String>[],
  });

  const SavedStopGroups.empty() : this();

  final List<String> favoriteGroupIds;
  final List<String> recentGroupIds;
}

List<String> toggleFavoriteGroupId(
  List<String> currentGroupIds,
  String groupId,
) {
  final normalizedGroupId = _normalizeGroupId(groupId);
  if (normalizedGroupId == null) {
    return List<String>.unmodifiable(currentGroupIds);
  }

  if (currentGroupIds.contains(normalizedGroupId)) {
    return List<String>.unmodifiable(
      currentGroupIds.where((id) => id != normalizedGroupId),
    );
  }

  return List<String>.unmodifiable([...currentGroupIds, normalizedGroupId]);
}

List<String> recordRecentGroupId(
  List<String> currentGroupIds,
  String groupId, {
  int maxCount = maxRecentStopGroupsCount,
}) {
  final normalizedGroupId = _normalizeGroupId(groupId);
  if (normalizedGroupId == null || maxCount <= 0) {
    return List<String>.unmodifiable(currentGroupIds);
  }

  return List<String>.unmodifiable(
    <String>[
      normalizedGroupId,
      ...currentGroupIds.where((id) => id != normalizedGroupId),
    ].take(maxCount),
  );
}

String? _normalizeGroupId(String? groupId) {
  final normalizedGroupId = groupId?.trim();
  if (normalizedGroupId == null || normalizedGroupId.isEmpty) {
    return null;
  }

  return normalizedGroupId;
}
