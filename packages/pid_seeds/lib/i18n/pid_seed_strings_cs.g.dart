///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'pid_seed_strings.g.dart';

// Path: <root>
typedef TranslationsCs = Translations; // ignore: unused_element

class Translations with BaseTranslations<AppLocale, Translations> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  Translations(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver,
      TranslationMetadata<AppLocale, Translations>? meta})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = meta ??
            TranslationMetadata(
              locale: AppLocale.cs,
              overrides: overrides ?? {},
              cardinalResolver: cardinalResolver,
              ordinalResolver: ordinalResolver,
            ) {
    $meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <cs>.
  @override
  final TranslationMetadata<AppLocale, Translations> $meta;

  /// Access flat map
  dynamic operator [](String key) => $meta.getTranslation(key);

  late final Translations _root = this; // ignore: unused_field

  Translations $copyWith(
          {TranslationMetadata<AppLocale, Translations>? meta}) =>
      Translations(meta: meta ?? this.$meta);

  // Translations
  late final Translations$navigation$cs navigation =
      Translations$navigation$cs.internal(_root);
  late final Translations$transport$cs transport =
      Translations$transport$cs.internal(_root);
  late final Translations$search$cs search =
      Translations$search$cs.internal(_root);
  late final Translations$loading$cs loading =
      Translations$loading$cs.internal(_root);
  late final Translations$feedback$cs feedback =
      Translations$feedback$cs.internal(_root);
  late final Translations$stopCard$cs stopCard =
      Translations$stopCard$cs.internal(_root);
  late final Translations$departureTile$cs departureTile =
      Translations$departureTile$cs.internal(_root);
  late final Translations$mapMarker$cs mapMarker =
      Translations$mapMarker$cs.internal(_root);
  late final Translations$templates$cs templates =
      Translations$templates$cs.internal(_root);
}

// Path: navigation
class Translations$navigation$cs {
  Translations$navigation$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Zastávky'
  String get stops => 'Zastávky';

  /// cs: 'Odjezdy'
  String get departures => 'Odjezdy';

  /// cs: 'Mapa'
  String get map => 'Mapa';
}

// Path: transport
class Translations$transport$cs {
  Translations$transport$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Tram'
  String get tram => 'Tram';

  /// cs: 'Bus'
  String get bus => 'Bus';

  /// cs: 'Metro'
  String get metro => 'Metro';

  /// cs: 'Vlak'
  String get train => 'Vlak';

  /// cs: 'Přívoz'
  String get ferry => 'Přívoz';

  /// cs: 'Spoj'
  String get unknown => 'Spoj';
}

// Path: search
class Translations$search$cs {
  Translations$search$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Vyhledat zastávku...'
  String get hint => 'Vyhledat zastávku...';

  /// cs: 'Filtrovat'
  String get filterTooltip => 'Filtrovat';

  /// cs: 'Filtrovat zastávky'
  String get filterSemantic => 'Filtrovat zastávky';
}

// Path: loading
class Translations$loading$cs {
  Translations$loading$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Načítání...'
  String get generic => 'Načítání...';

  /// cs: 'Načítání zastávek...'
  String get stops => 'Načítání zastávek...';

  /// cs: 'Načítání odjezdů...'
  String get departures => 'Načítání odjezdů...';
}

// Path: feedback
class Translations$feedback$cs {
  Translations$feedback$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Žádné zastávky'
  String get stopsEmptyTitle => 'Žádné zastávky';

  /// cs: 'Zkuste upravit vyhledávání nebo filtr.'
  String get stopsEmptyMessage => 'Zkuste upravit vyhledávání nebo filtr.';

  /// cs: 'Žádné aktuální odjezdy'
  String get departuresEmptyTitle => 'Žádné aktuální odjezdy';

  /// cs: 'Zkuste obnovit data nebo vybrat jiný směr.'
  String get departuresEmptyMessage =>
      'Zkuste obnovit data nebo vybrat jiný směr.';
}

// Path: stopCard
class Translations$stopCard$cs {
  Translations$stopCard$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Zastávka $name'
  String semanticLabel({required Object name}) => 'Zastávka ${name}';
}

// Path: departureTile
class Translations$departureTile$cs {
  Translations$departureTile$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Odjezd linky $line směr $destination'
  String semanticLabel({required Object line, required Object destination}) =>
      'Odjezd linky ${line} směr ${destination}';

  /// cs: 'min'
  String get minutesUnit => 'min';

  /// cs: 'Zobrazit vozidlo na mapě'
  String get showVehicleTooltip => 'Zobrazit vozidlo na mapě';

  /// cs: 'Zobrazit aktuální polohu vozidla'
  String get showVehicleSemantic => 'Zobrazit aktuální polohu vozidla';

  /// cs: 'Poloha vozidla není dostupná'
  String get vehicleUnavailable => 'Poloha vozidla není dostupná';
}

// Path: mapMarker
class Translations$mapMarker$cs {
  Translations$mapMarker$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Aktuální poloha vozidla linky $line'
  String semanticLabel({required Object line}) =>
      'Aktuální poloha vozidla linky ${line}';

  /// cs: 'živě'
  String get live => 'živě';
}

// Path: templates
class Translations$templates$cs {
  Translations$templates$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$templates$stops$cs stops =
      Translations$templates$stops$cs.internal(_root);
  late final Translations$templates$departures$cs departures =
      Translations$templates$departures$cs.internal(_root);
  late final Translations$templates$vehicleMap$cs vehicleMap =
      Translations$templates$vehicleMap$cs.internal(_root);
}

// Path: templates.stops
class Translations$templates$stops$cs {
  Translations$templates$stops$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Zastávky PID'
  String get title => 'Zastávky PID';

  /// cs: 'Najděte zastávku a pokračujte na aktuální odjezdy'
  String get subtitle => 'Najděte zastávku a pokračujte na aktuální odjezdy';

  /// cs: 'Nejbližší zastávky'
  String get nearbyStops => 'Nejbližší zastávky';

  /// cs: 'Filtrovat'
  String get filterAction => 'Filtrovat';

  /// cs: 'Nepodařilo se načíst zastávky'
  String get loadFailed => 'Nepodařilo se načíst zastávky';

  /// cs: 'Zkusit znovu'
  String get retry => 'Zkusit znovu';
}

// Path: templates.departures
class Translations$templates$departures$cs {
  Translations$templates$departures$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Zpět na zastávky'
  String get backTooltip => 'Zpět na zastávky';

  /// cs: 'Zpět na seznam zastávek'
  String get backSemantic => 'Zpět na seznam zastávek';

  /// cs: 'Potáhněte dolů pro obnovení odjezdů'
  String get pullToRefresh => 'Potáhněte dolů pro obnovení odjezdů';

  /// cs: 'Směr a nástupiště'
  String get directionAndPlatform => 'Směr a nástupiště';

  /// cs: 'Nejbližší odjezdy'
  String get nearestDepartures => 'Nejbližší odjezdy';

  /// cs: 'Spoje: $count'
  String connectionCount({required Object count}) => 'Spoje: ${count}';

  /// cs: 'Nepodařilo se načíst odjezdy'
  String get loadFailed => 'Nepodařilo se načíst odjezdy';

  /// cs: 'Obnovit'
  String get refresh => 'Obnovit';

  /// cs: 'Ikona mapy u spoje otevře aktuální polohu vozidla'
  String get mapHint => 'Ikona mapy u spoje otevře aktuální polohu vozidla';
}

// Path: templates.vehicleMap
class Translations$templates$vehicleMap$cs {
  Translations$templates$vehicleMap$cs.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// cs: 'Zpět na odjezdy'
  String get backTooltip => 'Zpět na odjezdy';

  /// cs: 'Zpět na odjezdy'
  String get backSemantic => 'Zpět na odjezdy';

  /// cs: 'Poloha vozidla'
  String get title => 'Poloha vozidla';

  /// cs: 'Vycentrovat mapu'
  String get centerTooltip => 'Vycentrovat mapu';

  /// cs: 'Obnovit polohu'
  String get refreshTooltip => 'Obnovit polohu';
}

/// The flat map containing all translations for locale <cs>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'navigation.stops' => 'Zastávky',
      'navigation.departures' => 'Odjezdy',
      'navigation.map' => 'Mapa',
      'transport.tram' => 'Tram',
      'transport.bus' => 'Bus',
      'transport.metro' => 'Metro',
      'transport.train' => 'Vlak',
      'transport.ferry' => 'Přívoz',
      'transport.unknown' => 'Spoj',
      'search.hint' => 'Vyhledat zastávku...',
      'search.filterTooltip' => 'Filtrovat',
      'search.filterSemantic' => 'Filtrovat zastávky',
      'loading.generic' => 'Načítání...',
      'loading.stops' => 'Načítání zastávek...',
      'loading.departures' => 'Načítání odjezdů...',
      'feedback.stopsEmptyTitle' => 'Žádné zastávky',
      'feedback.stopsEmptyMessage' => 'Zkuste upravit vyhledávání nebo filtr.',
      'feedback.departuresEmptyTitle' => 'Žádné aktuální odjezdy',
      'feedback.departuresEmptyMessage' =>
        'Zkuste obnovit data nebo vybrat jiný směr.',
      'stopCard.semanticLabel' => ({required Object name}) =>
          'Zastávka ${name}',
      'departureTile.semanticLabel' => (
              {required Object line, required Object destination}) =>
          'Odjezd linky ${line} směr ${destination}',
      'departureTile.minutesUnit' => 'min',
      'departureTile.showVehicleTooltip' => 'Zobrazit vozidlo na mapě',
      'departureTile.showVehicleSemantic' => 'Zobrazit aktuální polohu vozidla',
      'departureTile.vehicleUnavailable' => 'Poloha vozidla není dostupná',
      'mapMarker.semanticLabel' => ({required Object line}) =>
          'Aktuální poloha vozidla linky ${line}',
      'mapMarker.live' => 'živě',
      'templates.stops.title' => 'Zastávky PID',
      'templates.stops.subtitle' =>
        'Najděte zastávku a pokračujte na aktuální odjezdy',
      'templates.stops.nearbyStops' => 'Nejbližší zastávky',
      'templates.stops.filterAction' => 'Filtrovat',
      'templates.stops.loadFailed' => 'Nepodařilo se načíst zastávky',
      'templates.stops.retry' => 'Zkusit znovu',
      'templates.departures.backTooltip' => 'Zpět na zastávky',
      'templates.departures.backSemantic' => 'Zpět na seznam zastávek',
      'templates.departures.pullToRefresh' =>
        'Potáhněte dolů pro obnovení odjezdů',
      'templates.departures.directionAndPlatform' => 'Směr a nástupiště',
      'templates.departures.nearestDepartures' => 'Nejbližší odjezdy',
      'templates.departures.connectionCount' => ({required Object count}) =>
          'Spoje: ${count}',
      'templates.departures.loadFailed' => 'Nepodařilo se načíst odjezdy',
      'templates.departures.refresh' => 'Obnovit',
      'templates.departures.mapHint' =>
        'Ikona mapy u spoje otevře aktuální polohu vozidla',
      'templates.vehicleMap.backTooltip' => 'Zpět na odjezdy',
      'templates.vehicleMap.backSemantic' => 'Zpět na odjezdy',
      'templates.vehicleMap.title' => 'Poloha vozidla',
      'templates.vehicleMap.centerTooltip' => 'Vycentrovat mapu',
      'templates.vehicleMap.refreshTooltip' => 'Obnovit polohu',
      _ => null,
    };
  }
}
