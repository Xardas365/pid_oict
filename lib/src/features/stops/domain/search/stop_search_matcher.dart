import '../stop_group.dart';
import 'stop_search_document.dart';
import 'stop_search_index.dart';
import 'stop_search_query.dart';
import 'stop_search_result.dart';

class StopSearchMatcher {
  const StopSearchMatcher();

  List<StopSearchResult> search(
    StopSearchIndex index,
    StopSearchQuery query,
  ) {
    if (query.isBlank) {
      return List<StopSearchResult>.unmodifiable(
        index.documents.map((document) {
          return StopSearchResult(
            group: document.group,
            score: _blankQueryScore,
            matchedAlias: '',
          );
        }),
      );
    }

    final results = <StopSearchResult>[];
    for (final document in index.documents) {
      final result = _scoreDocument(document, query);
      if (result != null) {
        results.add(result);
      }
    }

    results.sort(_compareResults);
    return List<StopSearchResult>.unmodifiable(results);
  }

  List<StopGroup> matchGroups(StopSearchIndex index, StopSearchQuery query) {
    return List<StopGroup>.unmodifiable(
      search(index, query).map((result) => result.group),
    );
  }

  StopSearchResult? _scoreDocument(
    StopSearchDocument document,
    StopSearchQuery query,
  ) {
    var bestScore = _noMatchScore;
    var bestAlias = '';

    for (final alias in document.normalizedAliases) {
      final score = _scoreAlias(alias, query);
      if (score > bestScore) {
        bestScore = score;
        bestAlias = alias;
      }
    }

    if (bestScore == _noMatchScore) {
      return null;
    }

    return StopSearchResult(
      group: document.group,
      score: bestScore,
      matchedAlias: bestAlias,
    );
  }

  int _scoreAlias(String alias, StopSearchQuery query) {
    if (alias == query.normalizedInput) {
      return _exactMatchScore;
    }

    if (alias.startsWith(query.normalizedInput)) {
      return _startsWithScore;
    }

    if (query.tokens.length > 1 &&
        query.tokens.every((token) => alias.contains(token))) {
      return _allTokensScore;
    }

    if (alias.contains(query.normalizedInput)) {
      return _containsScore;
    }

    return _noMatchScore;
  }

  int _compareResults(StopSearchResult first, StopSearchResult second) {
    final scoreComparison = second.score.compareTo(first.score);
    if (scoreComparison != 0) {
      return scoreComparison;
    }

    final nameComparison = first.group.name.toLowerCase().compareTo(
      second.group.name.toLowerCase(),
    );
    if (nameComparison != 0) {
      return nameComparison;
    }

    return first.group.id.compareTo(second.group.id);
  }
}

const _exactMatchScore = 100;
const _startsWithScore = 80;
const _allTokensScore = 60;
const _containsScore = 40;
const _blankQueryScore = 0;
const _noMatchScore = -1;
