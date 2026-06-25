import '../../../i18n/strings.g.dart';

String formatClockTime(DateTime dateTime) {
  final localTime = dateTime.toLocal();

  return '${_twoDigits(localTime.hour)}:${_twoDigits(localTime.minute)}';
}

String formatClockTimeWithSeconds(DateTime dateTime) {
  final localTime = dateTime.toLocal();

  return '${_twoDigits(localTime.hour)}:'
      '${_twoDigits(localTime.minute)}:'
      '${_twoDigits(localTime.second)}';
}

String? formatDelaySeconds(int? delaySeconds) {
  if (delaySeconds == null) {
    return null;
  }

  if (delaySeconds <= 0) {
    return t.format.noDelay;
  }

  final minutes = (delaySeconds + 59) ~/ 60;

  return t.format.delayMinutes(minutes: minutes);
}

String formatRealtimeDelayLabel(int? delaySeconds) {
  if (delaySeconds == null) {
    return t.departures.scheduledTimeOnly;
  }

  if (delaySeconds == 0) {
    return t.departures.onTime;
  }

  final sign = delaySeconds > 0 ? '+' : '-';
  final minutes = (delaySeconds.abs() + 59) ~/ 60;

  return '$sign$minutes min';
}

String formatRelativeDepartureCountdown(Duration untilDeparture) {
  final seconds = untilDeparture.inSeconds;
  if (seconds <= 0) {
    return t.departures.departingNow;
  }

  final minutes = (seconds + 59) ~/ 60;
  if (minutes < 60) {
    return t.departures.departingInMinutes(minutes: minutes);
  }

  final hours = minutes ~/ 60;
  return t.departures.departingInHours(hours: hours);
}

int elapsedSecondsSince(DateTime dateTime, {DateTime? now}) {
  final referenceTime = now ?? DateTime.now();
  final elapsedSeconds = referenceTime.difference(dateTime).inSeconds;

  return elapsedSeconds < 0 ? 0 : elapsedSeconds;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
