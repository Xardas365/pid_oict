import 'dart:async';

import '../../../stops/domain/stop.dart';

sealed class DeparturesEvent {
  const DeparturesEvent();
}

class DeparturesStarted extends DeparturesEvent {
  const DeparturesStarted(this.stop);

  final Stop stop;
}

class DeparturesRetried extends DeparturesEvent {
  const DeparturesRetried();
}

class DeparturesRefreshed extends DeparturesEvent {
  const DeparturesRefreshed({this.completion});

  final Completer<void>? completion;
}
