import '../repositories/saved_stops_repository.dart';
import '../saved_stop_groups.dart';

class LoadSavedStopGroupsUseCase {
  const LoadSavedStopGroupsUseCase(this._repository);

  final SavedStopsRepository _repository;

  Future<SavedStopGroups> call() async {
    try {
      return await _repository.read();
    } on Object {
      return const SavedStopGroups.empty();
    }
  }
}
