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

String _twoDigits(int value) => value.toString().padLeft(2, '0');
