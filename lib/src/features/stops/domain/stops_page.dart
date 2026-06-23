import 'stop.dart';

class StopsPage {
  const StopsPage({
    required this.stops,
    required this.limit,
    required this.offset,
    required this.rawReturnedCount,
    required this.hasMore,
  });

  final List<Stop> stops;
  final int limit;
  final int offset;
  final int rawReturnedCount;
  final bool hasMore;
}
