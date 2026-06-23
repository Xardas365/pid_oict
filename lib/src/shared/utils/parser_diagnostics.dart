import 'json_parsing.dart';

const defaultMaxParserSkipReasons = 5;

class ParserSkipReason {
  const ParserSkipReason({required this.index, required this.reason});

  final int index;
  final String reason;
}

class ParserDiagnostics {
  const ParserDiagnostics({
    required this.rawCount,
    required this.parsedCount,
    required this.skippedCount,
    this.skipReasons = const <ParserSkipReason>[],
  });

  final int rawCount;
  final int parsedCount;
  final int skippedCount;
  final List<ParserSkipReason> skipReasons;

  bool get hasSkippedRecords => skippedCount > 0;
}

class ParsedResult<T> {
  const ParsedResult({required this.items, required this.diagnostics});

  final List<T> items;
  final ParserDiagnostics diagnostics;
}

ParsedResult<T> parseJsonRecordsWithDiagnostics<T>({
  required Object? response,
  required T? Function(JsonMap json) parse,
  required String Function(JsonMap json) skipReason,
  int maxSkipReasons = defaultMaxParserSkipReasons,
}) {
  final records = readJsonRecords(response);
  final items = <T>[];
  final skipReasons = <ParserSkipReason>[];

  for (var index = 0; index < records.length; index++) {
    final record = records[index];
    final item = parse(record);

    if (item == null) {
      if (skipReasons.length < maxSkipReasons) {
        skipReasons.add(
          ParserSkipReason(index: index, reason: skipReason(record)),
        );
      }
      continue;
    }

    items.add(item);
  }

  if (records.isEmpty && response != null && maxSkipReasons > 0) {
    skipReasons.add(
      const ParserSkipReason(index: -1, reason: 'unsupported response shape'),
    );
  }

  final parsedItems = List<T>.unmodifiable(items);

  return ParsedResult<T>(
    items: parsedItems,
    diagnostics: ParserDiagnostics(
      rawCount: records.length,
      parsedCount: parsedItems.length,
      skippedCount: records.length - parsedItems.length,
      skipReasons: List<ParserSkipReason>.unmodifiable(skipReasons),
    ),
  );
}
