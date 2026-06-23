import '../stop.dart';

abstract interface class StopsRepository {
  Future<List<Stop>> fetchStops();
}
