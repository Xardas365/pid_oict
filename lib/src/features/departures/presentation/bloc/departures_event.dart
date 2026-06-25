import 'dart:async';

import '../../../../core/domain/pid_line_type.dart';
import '../../../stops/domain/stop_group.dart';

sealed class DeparturesEvent {
  const DeparturesEvent();
}

class DeparturesStarted extends DeparturesEvent {
  const DeparturesStarted(this.stop);

  final StopGroup stop;
}

class DeparturesRetried extends DeparturesEvent {
  const DeparturesRetried();
}

class DeparturesRefreshed extends DeparturesEvent {
  const DeparturesRefreshed({this.completion});

  final Completer<void>? completion;
}

class DeparturesTransportFilterSelected extends DeparturesEvent {
  const DeparturesTransportFilterSelected(this.mode);

  final PidTransportMode? mode;
}
