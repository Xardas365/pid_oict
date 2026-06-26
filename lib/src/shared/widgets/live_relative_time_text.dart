import 'dart:async';

import 'package:flutter/material.dart';

import '../../../i18n/strings.g.dart';
import '../utils/date_time_formatters.dart';

enum _LiveRelativeTimeMode { departuresLastUpdated, vehicleLastUpdated }

class LiveRelativeTimeText extends StatefulWidget {
  const LiveRelativeTimeText.departuresLastUpdated({
    required this.timestamp,
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.now,
  }) : _mode = _LiveRelativeTimeMode.departuresLastUpdated,
       _relativeUntil = null;

  const LiveRelativeTimeText.vehicleLastUpdated({
    required this.timestamp,
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    Duration? relativeUntil,
    this.now,
  }) : _mode = _LiveRelativeTimeMode.vehicleLastUpdated,
       _relativeUntil = relativeUntil ?? const Duration(hours: 1);

  final DateTime timestamp;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final DateTime Function()? now;
  final _LiveRelativeTimeMode _mode;
  final Duration? _relativeUntil;

  @override
  State<LiveRelativeTimeText> createState() => _LiveRelativeTimeTextState();
}

class _LiveRelativeTimeTextState extends State<LiveRelativeTimeText> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = _currentNow();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LiveRelativeTimeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.timestamp != widget.timestamp ||
        oldWidget._mode != widget._mode ||
        oldWidget._relativeUntil != widget._relativeUntil ||
        oldWidget.now != widget.now) {
      _now = _currentNow();
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _now = _currentNow();
      });
    });
  }

  DateTime _currentNow() => widget.now?.call() ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Text(
      _label(context),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
      style: widget.style,
    );
  }

  String _label(BuildContext context) {
    final relativeUntil = widget._relativeUntil;
    final elapsedSeconds = elapsedSecondsSince(widget.timestamp, now: _now);
    if (relativeUntil != null && elapsedSeconds >= relativeUntil.inSeconds) {
      return context.t.vehicleMap.lastUpdated(
        time: formatClockTimeWithSeconds(widget.timestamp),
      );
    }

    return switch (widget._mode) {
      _LiveRelativeTimeMode.departuresLastUpdated => formatRelativeElapsedSince(
        widget.timestamp,
        now: _now,
        secondsLabel: (seconds) {
          return context.t.departures.lastUpdatedAgo(seconds: seconds);
        },
        minutesLabel: (minutes) {
          return context.t.departures.lastUpdatedAgoMinutes(
            minutes: minutes,
          );
        },
      ),
      _LiveRelativeTimeMode.vehicleLastUpdated => formatRelativeElapsedSince(
        widget.timestamp,
        now: _now,
        secondsLabel: (seconds) {
          return context.t.vehicleMap.lastUpdatedAgo(seconds: seconds);
        },
        minutesLabel: (minutes) {
          return context.t.vehicleMap.lastUpdatedAgoMinutes(minutes: minutes);
        },
      ),
    };
  }
}
