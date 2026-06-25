///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'pid_seed_strings.g.dart';

// Path: <root>
class TranslationsEn extends Translations
    with BaseTranslations<AppLocale, Translations> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  TranslationsEn(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver,
      TranslationMetadata<AppLocale, Translations>? meta})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = meta ??
            TranslationMetadata(
              locale: AppLocale.en,
              overrides: overrides ?? {},
              cardinalResolver: cardinalResolver,
              ordinalResolver: ordinalResolver,
            ),
        super(
            cardinalResolver: cardinalResolver,
            ordinalResolver: ordinalResolver) {
    super.$meta.setFlatMapFunction(
        $meta.getTranslation); // copy base translations to super.$meta
    $meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <en>.
  @override
  final TranslationMetadata<AppLocale, Translations> $meta;

  /// Access flat map
  @override
  dynamic operator [](String key) =>
      $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

  late final TranslationsEn _root = this; // ignore: unused_field

  @override
  TranslationsEn $copyWith(
          {TranslationMetadata<AppLocale, Translations>? meta}) =>
      TranslationsEn(meta: meta ?? this.$meta);

  // Translations
  @override
  late final _Translations$navigation$en navigation =
      _Translations$navigation$en._(_root);
  @override
  late final _Translations$transport$en transport =
      _Translations$transport$en._(_root);
  @override
  late final _Translations$search$en search = _Translations$search$en._(_root);
  @override
  late final _Translations$loading$en loading =
      _Translations$loading$en._(_root);
  @override
  late final _Translations$feedback$en feedback =
      _Translations$feedback$en._(_root);
  @override
  late final _Translations$stopCard$en stopCard =
      _Translations$stopCard$en._(_root);
  @override
  late final _Translations$departureTile$en departureTile =
      _Translations$departureTile$en._(_root);
  @override
  late final _Translations$mapMarker$en mapMarker =
      _Translations$mapMarker$en._(_root);
  @override
  late final _Translations$templates$en templates =
      _Translations$templates$en._(_root);
}

// Path: navigation
class _Translations$navigation$en extends Translations$navigation$cs {
  _Translations$navigation$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get stops => 'Stops';
  @override
  String get departures => 'Departures';
  @override
  String get map => 'Map';
}

// Path: transport
class _Translations$transport$en extends Translations$transport$cs {
  _Translations$transport$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get tram => 'Tram';
  @override
  String get bus => 'Bus';
  @override
  String get metro => 'Metro';
  @override
  String get train => 'Train';
  @override
  String get ferry => 'Ferry';
  @override
  String get unknown => 'Service';
}

// Path: search
class _Translations$search$en extends Translations$search$cs {
  _Translations$search$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get hint => 'Search for a stop...';
  @override
  String get clearTooltip => 'Clear search';
  @override
  String get filterTooltip => 'Filter';
  @override
  String get filterSemantic => 'Filter stops';
}

// Path: loading
class _Translations$loading$en extends Translations$loading$cs {
  _Translations$loading$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get generic => 'Loading...';
  @override
  String get stops => 'Loading stops...';
  @override
  String get departures => 'Loading departures...';
}

// Path: feedback
class _Translations$feedback$en extends Translations$feedback$cs {
  _Translations$feedback$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get stopsEmptyTitle => 'No stops';
  @override
  String get stopsEmptyMessage => 'Try changing the search or filter.';
  @override
  String get departuresEmptyTitle => 'No current departures';
  @override
  String get departuresEmptyMessage =>
      'Try refreshing data or selecting another direction.';
}

// Path: stopCard
class _Translations$stopCard$en extends Translations$stopCard$cs {
  _Translations$stopCard$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String semanticLabel({required Object name}) => 'Stop ${name}';
}

// Path: departureTile
class _Translations$departureTile$en extends Translations$departureTile$cs {
  _Translations$departureTile$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String semanticLabel({required Object line, required Object destination}) =>
      'Departure of line ${line} toward ${destination}';
  @override
  String get minutesUnit => 'min';
  @override
  String get showVehicleTooltip => 'Show vehicle on map';
  @override
  String get showVehicleSemantic => 'Show current vehicle position';
  @override
  String get vehicleUnavailable => 'Vehicle position is not available';
}

// Path: mapMarker
class _Translations$mapMarker$en extends Translations$mapMarker$cs {
  _Translations$mapMarker$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String semanticLabel({required Object line}) =>
      'Current position of line ${line}';
  @override
  String get live => 'live';
}

// Path: templates
class _Translations$templates$en extends Translations$templates$cs {
  _Translations$templates$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  late final _Translations$templates$stops$en stops =
      _Translations$templates$stops$en._(_root);
  @override
  late final _Translations$templates$departures$en departures =
      _Translations$templates$departures$en._(_root);
  @override
  late final _Translations$templates$vehicleMap$en vehicleMap =
      _Translations$templates$vehicleMap$en._(_root);
}

// Path: templates.stops
class _Translations$templates$stops$en extends Translations$templates$stops$cs {
  _Translations$templates$stops$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'PID stops';
  @override
  String get subtitle => 'Find a stop and continue to current departures';
  @override
  String get nearbyStops => 'Nearby stops';
  @override
  String get filterAction => 'Filter';
  @override
  String get loadFailed => 'Could not load stops';
  @override
  String get retry => 'Try again';
}

// Path: templates.departures
class _Translations$templates$departures$en
    extends Translations$templates$departures$cs {
  _Translations$templates$departures$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get backTooltip => 'Back to stops';
  @override
  String get backSemantic => 'Back to the stop list';
  @override
  String get pullToRefresh => 'Pull down to refresh departures';
  @override
  String get directionAndPlatform => 'Direction and platform';
  @override
  String get nearestDepartures => 'Nearest departures';
  @override
  String connectionCount({required Object count}) => 'Services: ${count}';
  @override
  String get loadFailed => 'Could not load departures';
  @override
  String get refresh => 'Refresh';
  @override
  String get mapHint => 'The map icon opens the current vehicle position';
}

// Path: templates.vehicleMap
class _Translations$templates$vehicleMap$en
    extends Translations$templates$vehicleMap$cs {
  _Translations$templates$vehicleMap$en._(TranslationsEn root)
      : this._root = root,
        super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get backTooltip => 'Back to departures';
  @override
  String get backSemantic => 'Back to departures';
  @override
  String get title => 'Vehicle position';
  @override
  String get centerTooltip => 'Center map';
  @override
  String get refreshTooltip => 'Refresh position';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'navigation.stops' => 'Stops',
      'navigation.departures' => 'Departures',
      'navigation.map' => 'Map',
      'transport.tram' => 'Tram',
      'transport.bus' => 'Bus',
      'transport.metro' => 'Metro',
      'transport.train' => 'Train',
      'transport.ferry' => 'Ferry',
      'transport.unknown' => 'Service',
      'search.hint' => 'Search for a stop...',
      'search.clearTooltip' => 'Clear search',
      'search.filterTooltip' => 'Filter',
      'search.filterSemantic' => 'Filter stops',
      'loading.generic' => 'Loading...',
      'loading.stops' => 'Loading stops...',
      'loading.departures' => 'Loading departures...',
      'feedback.stopsEmptyTitle' => 'No stops',
      'feedback.stopsEmptyMessage' => 'Try changing the search or filter.',
      'feedback.departuresEmptyTitle' => 'No current departures',
      'feedback.departuresEmptyMessage' =>
        'Try refreshing data or selecting another direction.',
      'stopCard.semanticLabel' => ({required Object name}) => 'Stop ${name}',
      'departureTile.semanticLabel' => (
              {required Object line, required Object destination}) =>
          'Departure of line ${line} toward ${destination}',
      'departureTile.minutesUnit' => 'min',
      'departureTile.showVehicleTooltip' => 'Show vehicle on map',
      'departureTile.showVehicleSemantic' => 'Show current vehicle position',
      'departureTile.vehicleUnavailable' => 'Vehicle position is not available',
      'mapMarker.semanticLabel' => ({required Object line}) =>
          'Current position of line ${line}',
      'mapMarker.live' => 'live',
      'templates.stops.title' => 'PID stops',
      'templates.stops.subtitle' =>
        'Find a stop and continue to current departures',
      'templates.stops.nearbyStops' => 'Nearby stops',
      'templates.stops.filterAction' => 'Filter',
      'templates.stops.loadFailed' => 'Could not load stops',
      'templates.stops.retry' => 'Try again',
      'templates.departures.backTooltip' => 'Back to stops',
      'templates.departures.backSemantic' => 'Back to the stop list',
      'templates.departures.pullToRefresh' => 'Pull down to refresh departures',
      'templates.departures.directionAndPlatform' => 'Direction and platform',
      'templates.departures.nearestDepartures' => 'Nearest departures',
      'templates.departures.connectionCount' => ({required Object count}) =>
          'Services: ${count}',
      'templates.departures.loadFailed' => 'Could not load departures',
      'templates.departures.refresh' => 'Refresh',
      'templates.departures.mapHint' =>
        'The map icon opens the current vehicle position',
      'templates.vehicleMap.backTooltip' => 'Back to departures',
      'templates.vehicleMap.backSemantic' => 'Back to departures',
      'templates.vehicleMap.title' => 'Vehicle position',
      'templates.vehicleMap.centerTooltip' => 'Center map',
      'templates.vehicleMap.refreshTooltip' => 'Refresh position',
      _ => null,
    };
  }
}
