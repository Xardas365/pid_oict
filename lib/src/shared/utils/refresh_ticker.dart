import 'dart:async';

typedef RefreshTickCallback = void Function();

abstract interface class RefreshTicker {
  void start({
    required Duration interval,
    required RefreshTickCallback onTick,
  });

  void stop();
}

class TimerRefreshTicker implements RefreshTicker {
  Timer? _timer;

  @override
  void start({
    required Duration interval,
    required RefreshTickCallback onTick,
  }) {
    stop();
    if (interval <= Duration.zero) {
      return;
    }

    _timer = Timer.periodic(interval, (_) => onTick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
