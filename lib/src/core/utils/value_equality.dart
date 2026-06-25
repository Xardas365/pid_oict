bool iterableEquals<T>(Iterable<T> first, Iterable<T> second) {
  if (identical(first, second)) {
    return true;
  }

  final firstIterator = first.iterator;
  final secondIterator = second.iterator;

  while (true) {
    final firstHasNext = firstIterator.moveNext();
    final secondHasNext = secondIterator.moveNext();

    if (firstHasNext != secondHasNext) {
      return false;
    }

    if (!firstHasNext) {
      return true;
    }

    if (firstIterator.current != secondIterator.current) {
      return false;
    }
  }
}

int iterableHash(Iterable<Object?> values) {
  return Object.hashAll(values);
}
