import 'package:flutter/foundation.dart';

const _golemioDebugLogsEnabled = bool.fromEnvironment(
  'GOLEMIO_DEBUG_LOGS',
  defaultValue: false,
);

const isGolemioDebugLoggingEnabled = kDebugMode && _golemioDebugLogsEnabled;

void logGolemioDebug(String message) {
  if (isGolemioDebugLoggingEnabled) {
    for (final line in message.split('\n')) {
      debugPrint('[Golemio] $line');
    }
  }
}
