import '../domain/departure.dart';

enum DepartureTimeDisplayMode { relativeFirst, clockFirst }

const adaptiveClockFirstThreshold = Duration(minutes: 90);

DepartureTimeDisplayMode defaultDepartureTimeDisplayMode(
  List<Departure> departures, {
  required DateTime now,
  Duration clockFirstThreshold = adaptiveClockFirstThreshold,
}) {
  if (departures.isEmpty) {
    return DepartureTimeDisplayMode.relativeFirst;
  }

  final nearestDepartureTime = departures
      .map((departure) => departure.departureTime)
      .reduce((earliest, departureTime) {
        if (departureTime.isBefore(earliest)) {
          return departureTime;
        }

        return earliest;
      });
  final untilNearestDeparture = nearestDepartureTime.difference(now);

  return untilNearestDeparture > clockFirstThreshold
      ? DepartureTimeDisplayMode.clockFirst
      : DepartureTimeDisplayMode.relativeFirst;
}
