import '../../../stops/domain/stop.dart';
import '../departure.dart';

abstract interface class DeparturesRepository {
  Future<List<Departure>> fetchDeparturesForStop(Stop stop);
}
