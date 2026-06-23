import '../../../stops/domain/stop_group.dart';
import '../departure.dart';

abstract interface class DeparturesRepository {
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop);
}
