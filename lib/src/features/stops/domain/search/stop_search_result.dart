import 'package:meta/meta.dart';

import '../stop_group.dart';

@immutable
class StopSearchResult {
  const StopSearchResult({
    required this.group,
    required this.score,
    required this.matchedAlias,
  });

  final StopGroup group;
  final int score;
  final String matchedAlias;
}
