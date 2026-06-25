import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/search/stop_search_index.dart';
import 'package:pid_oict/src/features/stops/domain/search/stop_search_matcher.dart';
import 'package:pid_oict/src/features/stops/domain/search/stop_search_query.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

void main() {
  group('StopSearchMatcher', () {
    const matcher = StopSearchMatcher();

    test('returns all displayable groups for a blank query', () {
      final index = StopSearchIndex.fromGroups([
        _group('2', 'Staroměstská'),
        _group('1', 'Anděl'),
      ]);

      final results = matcher.matchGroups(index, StopSearchQuery.parse('   '));

      expect(results.map((group) => group.name), ['Anděl', 'Staroměstská']);
    });

    test('matches stop names without Czech diacritics', () {
      final index = StopSearchIndex.fromGroups([
        _group('1', 'Budějovická'),
        _group('2', 'Pankrác'),
        _group('3', 'Černý Most'),
      ]);

      expect(
        matcher
            .matchGroups(index, StopSearchQuery.parse('budejovicka'))
            .single
            .name,
        'Budějovická',
      );
      expect(
        matcher
            .matchGroups(index, StopSearchQuery.parse('pankrac'))
            .single
            .name,
        'Pankrác',
      );
      expect(
        matcher.matchGroups(index, StopSearchQuery.parse('cerny')).single.name,
        'Černý Most',
      );
    });

    test('scores exact, startsWith, token, and contains matches', () {
      final exact = matcher.search(
        StopSearchIndex.fromGroups([_group('1', 'Flora')]),
        StopSearchQuery.parse('flora'),
      );
      final startsWith = matcher.search(
        StopSearchIndex.fromGroups([_group('2', 'Flora sever')]),
        StopSearchQuery.parse('flora'),
      );
      final token = matcher.search(
        StopSearchIndex.fromGroups([_group('3', 'Nádraží hlavní Praha')]),
        StopSearchQuery.parse('hlavní nádraží'),
      );
      final contains = matcher.search(
        StopSearchIndex.fromGroups([_group('4', 'Praha Flora')]),
        StopSearchQuery.parse('flora'),
      );

      expect(
        exact.single.score,
        greaterThan(startsWith.single.score),
      );
      expect(
        startsWith.single.score,
        greaterThan(token.single.score),
      );
      expect(token.single.score, greaterThan(contains.single.score));
    });

    test('matches child stop groups through parent station aliases', () {
      final index = StopSearchIndex.fromGroups([
        _group(
          'U202S1',
          'Hlavní nádraží',
          searchAliases: const ['Praha hlavní nádraží'],
        ),
      ]);

      final prahaResults = matcher.matchGroups(
        index,
        StopSearchQuery.parse('praha hl'),
      );
      final abbreviationResults = matcher.matchGroups(
        index,
        StopSearchQuery.parse('hl. n.'),
      );

      expect(prahaResults.single.name, 'Hlavní nádraží');
      expect(abbreviationResults.single.name, 'Hlavní nádraží');
    });

    test('sorts equal scores by public name and group id', () {
      final index = StopSearchIndex.fromGroups([
        _group('name:flora-b', 'Praha Flora'),
        _group('name:flora-a', 'Praha Flora'),
        _group('name:andel', 'Praha Anděl'),
      ]);

      final results = matcher.matchGroups(
        index,
        StopSearchQuery.parse('praha'),
      );

      expect(results.map((group) => group.id), [
        'name:andel',
        'name:flora-a',
        'name:flora-b',
      ]);
    });

    test('keeps technical records hidden from search results', () {
      final index = StopSearchIndex.fromGroups([
        _group('1', 'Staroměstská'),
        _group('2', 'hr.VUSC Praha'),
        _group('3', 'Km 12,4'),
        _group('4', 'km 8,1'),
        _group('5', 'Odb Balabenka'),
        _group('6', 'Kmetiněves'),
        _group('7', 'Odborářů'),
        _group('8', 'vl. v km 12,4'),
        _group('9', 'Kolín výh.č.1'),
        _group('10', 'vjezd.náv Praha'),
        _group('11', 'odj.náv Praha'),
        _group('12', 'Praha náv. 1'),
      ]);

      final blankResults = matcher.matchGroups(
        index,
        StopSearchQuery.parse(''),
      );
      final searchResults = matcher.matchGroups(
        index,
        StopSearchQuery.parse('km'),
      );

      expect(blankResults.map((group) => group.name), [
        'Kmetiněves',
        'Odborářů',
        'Staroměstská',
      ]);
      expect(searchResults.map((group) => group.name), ['Kmetiněves']);
    });

    test('hides non-passenger GTFS location types when available', () {
      final index = StopSearchIndex.fromGroups([
        _group('1', 'Flora', locationType: 0),
        _group('2', 'Flora station', locationType: 1),
        _group('3', 'Flora entrance', locationType: 2),
        _group('4', 'Anděl'),
      ]);

      final results = matcher.matchGroups(index, StopSearchQuery.parse(''));

      expect(results.map((group) => group.name), ['Anděl', 'Flora']);
    });
  });
}

StopGroup _group(
  String id,
  String name, {
  int? locationType,
  List<String> searchAliases = const <String>[],
}) {
  return StopGroup(
    id: id,
    name: name,
    latitude: 50,
    longitude: 14,
    stops: [
      Stop(
        id: id,
        name: name,
        locationType: locationType,
        latitude: 50,
        longitude: 14,
        searchAliases: searchAliases,
      ),
    ],
    stopIds: [id],
    platformCodes: const [],
  );
}
