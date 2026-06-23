///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsCs = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.cs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <cs>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$cs app = Translations$app$cs.internal(_root);
	late final Translations$navigation$cs navigation = Translations$navigation$cs.internal(_root);
	late final Translations$common$cs common = Translations$common$cs.internal(_root);
	late final Translations$errors$cs errors = Translations$errors$cs.internal(_root);
	late final Translations$stops$cs stops = Translations$stops$cs.internal(_root);
	late final Translations$departures$cs departures = Translations$departures$cs.internal(_root);
	late final Translations$vehicleMap$cs vehicleMap = Translations$vehicleMap$cs.internal(_root);
	late final Translations$format$cs format = Translations$format$cs.internal(_root);
}

// Path: app
class Translations$app$cs {
	Translations$app$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'PID Odjezdy'
	String get title => 'PID Odjezdy';
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

// Path: common
class Translations$common$cs {
	Translations$common$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Zkusit znovu'
	String get retry => 'Zkusit znovu';
}

// Path: errors
class Translations$errors$cs {
	Translations$errors$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Chybí Golemio API token. Spusťte aplikaci s --dart-define=GOLEMIO_API_TOKEN=vas_token.'
	String get missingToken => 'Chybí Golemio API token. Spusťte aplikaci s --dart-define=GOLEMIO_API_TOKEN=vas_token.';

	/// cs: 'Golemio API token je neplatný nebo nemá oprávnění. Zkontrolujte token.'
	String get unauthorized => 'Golemio API token je neplatný nebo nemá oprávnění. Zkontrolujte token.';

	/// cs: 'Nepodařilo se připojit ke Golemio API. Zkontrolujte připojení k internetu.'
	String get network => 'Nepodařilo se připojit ke Golemio API. Zkontrolujte připojení k internetu.';

	/// cs: 'Golemio API neodpovědělo včas. Zkuste to prosím znovu.'
	String get timeout => 'Golemio API neodpovědělo včas. Zkuste to prosím znovu.';

	/// cs: 'Golemio API vrátilo prázdnou odpověď.'
	String get emptyResponse => 'Golemio API vrátilo prázdnou odpověď.';

	/// cs: 'Golemio API vrátilo odpověď, kterou se nepodařilo přečíst.'
	String get invalidJson => 'Golemio API vrátilo odpověď, kterou se nepodařilo přečíst.';

	/// cs: 'Golemio API vrátilo nekompletní nebo neplatná data.'
	String get invalidData => 'Golemio API vrátilo nekompletní nebo neplatná data.';

	/// cs: 'Golemio API požadavek nebyl přijat. Zkuste akci zopakovat.'
	String get badRequest => 'Golemio API požadavek nebyl přijat. Zkuste akci zopakovat.';

	/// cs: 'Požadovaná data nebyla v Golemio API nalezena.'
	String get notFound => 'Požadovaná data nebyla v Golemio API nalezena.';

	/// cs: 'Golemio API je dočasně nedostupné. Zkuste to prosím později.'
	String get server => 'Golemio API je dočasně nedostupné. Zkuste to prosím později.';

	/// cs: 'Golemio API vrátilo neočekávanou odpověď.'
	String get unexpectedStatus => 'Golemio API vrátilo neočekávanou odpověď.';

	/// cs: 'Zobrazuji poslední známou polohu. $message'
	String stalePosition({required Object message}) => 'Zobrazuji poslední známou polohu. ${message}';

	/// cs: 'Aktualizace se nepodařila.'
	String get refreshFailed => 'Aktualizace se nepodařila.';
}

// Path: stops
class Translations$stops$cs {
	Translations$stops$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'PID zastávky'
	String get title => 'PID zastávky';

	/// cs: 'Vyhledat zastávku...'
	String get searchHint => 'Vyhledat zastávku...';

	/// cs: 'Načítání zastávek...'
	String get loading => 'Načítání zastávek...';

	/// cs: 'Zastávky se nepodařilo načíst. Zkuste to prosím znovu.'
	String get loadFailed => 'Zastávky se nepodařilo načíst. Zkuste to prosím znovu.';

	/// cs: 'Golemio API nevrátilo žádné použitelné zastávky.'
	String get invalidData => 'Golemio API nevrátilo žádné použitelné zastávky.';

	/// cs: 'Žádné zastávky nejsou k dispozici.'
	String get empty => 'Žádné zastávky nejsou k dispozici.';

	/// cs: 'Žádné zastávky neodpovídají hledání.'
	String get emptySearch => 'Žádné zastávky neodpovídají hledání.';

	/// cs: 'Zastávka $name'
	String stopSemantic({required Object name}) => 'Zastávka ${name}';

	/// cs: 'ID $id'
	String stopId({required Object id}) => 'ID ${id}';

	/// cs: 'Nástupiště $platform • ID $id'
	String platformWithId({required Object platform, required Object id}) => 'Nástupiště ${platform} • ID ${id}';

	/// cs: 'ID $id • $latitude, $longitude'
	String coordinatesWithId({required Object id, required Object latitude, required Object longitude}) => 'ID ${id} • ${latitude}, ${longitude}';

	/// cs: 'Nástupiště $platform - ID $id'
	String legacyPlatformWithId({required Object platform, required Object id}) => 'Nástupiště ${platform} - ID ${id}';
}

// Path: departures
class Translations$departures$cs {
	Translations$departures$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Nejdříve vyberte zastávku ze seznamu.'
	String get emptyTabMessage => 'Nejdříve vyberte zastávku ze seznamu.';

	/// cs: 'Načítání odjezdů...'
	String get loading => 'Načítání odjezdů...';

	/// cs: 'Odjezdy se nepodařilo načíst. Zkuste to prosím znovu.'
	String get loadFailed => 'Odjezdy se nepodařilo načíst. Zkuste to prosím znovu.';

	/// cs: 'Golemio API nevrátilo žádné použitelné odjezdy.'
	String get invalidData => 'Golemio API nevrátilo žádné použitelné odjezdy.';

	/// cs: 'Pro tuto zastávku nejsou dostupné žádné odjezdy.'
	String get empty => 'Pro tuto zastávku nejsou dostupné žádné odjezdy.';

	/// cs: 'Odjezd $time'
	String departureTime({required Object time}) => 'Odjezd ${time}';

	/// cs: 'Nástupiště $platform'
	String platform({required Object platform}) => 'Nástupiště ${platform}';

	/// cs: 'Zobrazit polohu vozidla'
	String get showVehicleTooltip => 'Zobrazit polohu vozidla';
}

// Path: vehicleMap
class Translations$vehicleMap$cs {
	Translations$vehicleMap$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Vyberte odjezd s dostupnou polohou vozidla.'
	String get emptyTabMessage => 'Vyberte odjezd s dostupnou polohou vozidla.';

	/// cs: 'Poloha vozidla'
	String get title => 'Poloha vozidla';

	/// cs: 'Načítání polohy vozidla...'
	String get loading => 'Načítání polohy vozidla...';

	/// cs: 'Polohu vozidla se nepodařilo načíst. Zkuste to prosím znovu.'
	String get loadFailed => 'Polohu vozidla se nepodařilo načíst. Zkuste to prosím znovu.';

	/// cs: 'Aktuální poloha vozidla není dostupná.'
	String get invalidData => 'Aktuální poloha vozidla není dostupná.';

	/// cs: 'Vozidlo $vehicleId'
	String vehicleLabel({required Object vehicleId}) => 'Vozidlo ${vehicleId}';

	/// cs: 'Poslední aktualizace $time'
	String lastUpdated({required Object time}) => 'Poslední aktualizace ${time}';

	/// cs: 'Mapová data (c) přispěvatelé OpenStreetMap'
	String get attribution => 'Mapová data (c) přispěvatelé OpenStreetMap';
}

// Path: format
class Translations$format$cs {
	Translations$format$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Bez zpoždění'
	String get noDelay => 'Bez zpoždění';

	/// cs: 'Zpoždění +$minutes min'
	String delayMinutes({required Object minutes}) => 'Zpoždění +${minutes} min';
}

/// The flat map containing all translations for locale <cs>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'PID Odjezdy',
			'navigation.stops' => 'Zastávky',
			'navigation.departures' => 'Odjezdy',
			'navigation.map' => 'Mapa',
			'common.retry' => 'Zkusit znovu',
			'errors.missingToken' => 'Chybí Golemio API token. Spusťte aplikaci s --dart-define=GOLEMIO_API_TOKEN=vas_token.',
			'errors.unauthorized' => 'Golemio API token je neplatný nebo nemá oprávnění. Zkontrolujte token.',
			'errors.network' => 'Nepodařilo se připojit ke Golemio API. Zkontrolujte připojení k internetu.',
			'errors.timeout' => 'Golemio API neodpovědělo včas. Zkuste to prosím znovu.',
			'errors.emptyResponse' => 'Golemio API vrátilo prázdnou odpověď.',
			'errors.invalidJson' => 'Golemio API vrátilo odpověď, kterou se nepodařilo přečíst.',
			'errors.invalidData' => 'Golemio API vrátilo nekompletní nebo neplatná data.',
			'errors.badRequest' => 'Golemio API požadavek nebyl přijat. Zkuste akci zopakovat.',
			'errors.notFound' => 'Požadovaná data nebyla v Golemio API nalezena.',
			'errors.server' => 'Golemio API je dočasně nedostupné. Zkuste to prosím později.',
			'errors.unexpectedStatus' => 'Golemio API vrátilo neočekávanou odpověď.',
			'errors.stalePosition' => ({required Object message}) => 'Zobrazuji poslední známou polohu. ${message}',
			'errors.refreshFailed' => 'Aktualizace se nepodařila.',
			'stops.title' => 'PID zastávky',
			'stops.searchHint' => 'Vyhledat zastávku...',
			'stops.loading' => 'Načítání zastávek...',
			'stops.loadFailed' => 'Zastávky se nepodařilo načíst. Zkuste to prosím znovu.',
			'stops.invalidData' => 'Golemio API nevrátilo žádné použitelné zastávky.',
			'stops.empty' => 'Žádné zastávky nejsou k dispozici.',
			'stops.emptySearch' => 'Žádné zastávky neodpovídají hledání.',
			'stops.stopSemantic' => ({required Object name}) => 'Zastávka ${name}',
			'stops.stopId' => ({required Object id}) => 'ID ${id}',
			'stops.platformWithId' => ({required Object platform, required Object id}) => 'Nástupiště ${platform} • ID ${id}',
			'stops.coordinatesWithId' => ({required Object id, required Object latitude, required Object longitude}) => 'ID ${id} • ${latitude}, ${longitude}',
			'stops.legacyPlatformWithId' => ({required Object platform, required Object id}) => 'Nástupiště ${platform} - ID ${id}',
			'departures.emptyTabMessage' => 'Nejdříve vyberte zastávku ze seznamu.',
			'departures.loading' => 'Načítání odjezdů...',
			'departures.loadFailed' => 'Odjezdy se nepodařilo načíst. Zkuste to prosím znovu.',
			'departures.invalidData' => 'Golemio API nevrátilo žádné použitelné odjezdy.',
			'departures.empty' => 'Pro tuto zastávku nejsou dostupné žádné odjezdy.',
			'departures.departureTime' => ({required Object time}) => 'Odjezd ${time}',
			'departures.platform' => ({required Object platform}) => 'Nástupiště ${platform}',
			'departures.showVehicleTooltip' => 'Zobrazit polohu vozidla',
			'vehicleMap.emptyTabMessage' => 'Vyberte odjezd s dostupnou polohou vozidla.',
			'vehicleMap.title' => 'Poloha vozidla',
			'vehicleMap.loading' => 'Načítání polohy vozidla...',
			'vehicleMap.loadFailed' => 'Polohu vozidla se nepodařilo načíst. Zkuste to prosím znovu.',
			'vehicleMap.invalidData' => 'Aktuální poloha vozidla není dostupná.',
			'vehicleMap.vehicleLabel' => ({required Object vehicleId}) => 'Vozidlo ${vehicleId}',
			'vehicleMap.lastUpdated' => ({required Object time}) => 'Poslední aktualizace ${time}',
			'vehicleMap.attribution' => 'Mapová data (c) přispěvatelé OpenStreetMap',
			'format.noDelay' => 'Bez zpoždění',
			'format.delayMinutes' => ({required Object minutes}) => 'Zpoždění +${minutes} min',
			_ => null,
		};
	}
}
