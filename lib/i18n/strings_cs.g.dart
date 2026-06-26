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
	late final Translations$transport$cs transport = Translations$transport$cs.internal(_root);
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

// Path: transport
class Translations$transport$cs {
	Translations$transport$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$transport$lineTypes$cs lineTypes = Translations$transport$lineTypes$cs.internal(_root);
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

	/// cs: 'Zobrazujeme uložené zastávky.'
	String get showingSavedStops => 'Zobrazujeme uložené zastávky.';

	/// cs: 'Zobrazujeme starší uložená data zastávek.'
	String get showingOlderSavedStops => 'Zobrazujeme starší uložená data zastávek.';

	/// cs: 'Zobrazujeme uložené zastávky. Aktualizace se nezdařila.'
	String get savedStopsRefreshFailed => 'Zobrazujeme uložené zastávky. Aktualizace se nezdařila.';

	/// cs: 'Oblíbené zastávky'
	String get favoriteStops => 'Oblíbené zastávky';

	/// cs: 'Poslední zastávky'
	String get recentStops => 'Poslední zastávky';

	/// cs: 'Přidat do oblíbených'
	String get addFavorite => 'Přidat do oblíbených';

	/// cs: 'Odebrat z oblíbených'
	String get removeFavorite => 'Odebrat z oblíbených';

	/// cs: 'Žádné oblíbené zastávky'
	String get noFavoriteStops => 'Žádné oblíbené zastávky';

	/// cs: 'Zpět nahoru'
	String get backToTop => 'Zpět nahoru';

	/// cs: 'Zastávka $name'
	String stopSemantic({required Object name}) => 'Zastávka ${name}';

	/// cs: 'ID $id'
	String stopId({required Object id}) => 'ID ${id}';

	/// cs: 'Nástupiště $platform • ID $id'
	String platformWithId({required Object platform, required Object id}) => 'Nástupiště ${platform} • ID ${id}';

	/// cs: 'Nástupiště $platforms • zóna $zone'
	String platformsWithZone({required Object platforms, required Object zone}) => 'Nástupiště ${platforms} • zóna ${zone}';

	/// cs: 'Nástupiště $platforms'
	String platforms({required Object platforms}) => 'Nástupiště ${platforms}';

	/// cs: '$count označníky • zóna $zone'
	String stopPointsWithZone({required Object count, required Object zone}) => '${count} označníky • zóna ${zone}';

	/// cs: '$count označníky'
	String stopPoints({required Object count}) => '${count} označníky';

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

	/// cs: 'Odjezdy zo zastávky'
	String get title => 'Odjezdy zo zastávky';

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

	/// cs: 'Pro vybraný typ dopravy nejsou dostupné žádné odjezdy.'
	String get emptyFilter => 'Pro vybraný typ dopravy nejsou dostupné žádné odjezdy.';

	/// cs: 'Aktualizuji odjezdy...'
	String get refreshing => 'Aktualizuji odjezdy...';

	/// cs: 'Načítání trvá déle než obvykle…'
	String get loadingLong => 'Načítání trvá déle než obvykle…';

	/// cs: 'Nepodařilo se aktualizovat odjezdy. Zobrazujeme poslední dostupná data.'
	String get staleWarning => 'Nepodařilo se aktualizovat odjezdy. Zobrazujeme poslední dostupná data.';

	/// cs: 'Zpět na zastávky'
	String get backToStops => 'Zpět na zastávky';

	/// cs: 'Vše'
	String get filterAll => 'Vše';

	/// cs: 'Metro'
	String get filterMetro => 'Metro';

	/// cs: 'Tram'
	String get filterTram => 'Tram';

	/// cs: 'Bus'
	String get filterBus => 'Bus';

	/// cs: 'Trolejbus'
	String get filterTrolleybus => 'Trolejbus';

	/// cs: 'Vlak'
	String get filterTrain => 'Vlak';

	/// cs: 'Přívoz'
	String get filterFerry => 'Přívoz';

	/// cs: 'Lanovka'
	String get filterFunicular => 'Lanovka';

	/// cs: 'Ostatní'
	String get filterOther => 'Ostatní';

	/// cs: 'Aktualizované před $seconds s'
	String lastUpdatedAgo({required Object seconds}) => 'Aktualizované před ${seconds} s';

	/// cs: 'Odjezd $time'
	String departureTime({required Object time}) => 'Odjezd ${time}';

	/// cs: 'Nástupiště $platform'
	String platform({required Object platform}) => 'Nástupiště ${platform}';

	/// cs: 'Sledovat vozidlo →'
	String get trackingHint => 'Sledovat vozidlo →';

	/// cs: 'Přepnout zobrazení času odjezdu'
	String get toggleTimeDisplay => 'Přepnout zobrazení času odjezdu';

	/// cs: 'Zobrazit polohu vozidla'
	String get showVehicleTooltip => 'Zobrazit polohu vozidla';

	/// cs: 'Noční spoj'
	String get nightRoute => 'Noční spoj';

	/// cs: 'Bezbariérový odjezd'
	String get wheelchairAccessible => 'Bezbariérový odjezd';

	/// cs: 'Bezbariérové'
	String get wheelchairAccessibleShort => 'Bezbariérové';

	/// cs: 'teď'
	String get departingNow => 'teď';

	/// cs: 'za $minutes min'
	String departingInMinutes({required Object minutes}) => 'za ${minutes} min';

	/// cs: 'za $hours h'
	String departingInHours({required Object hours}) => 'za ${hours} h';

	/// cs: 'Načas'
	String get onTime => 'Načas';

	/// cs: 'dle JŘ'
	String get scheduledTimeOnly => 'dle JŘ';
}

// Path: vehicleMap
class Translations$vehicleMap$cs {
	Translations$vehicleMap$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Vyberte odjezd s dostupnou polohou vozidla.'
	String get emptyTabMessage => 'Vyberte odjezd s dostupnou polohou vozidla.';

	/// cs: 'Mapa vozidla'
	String get title => 'Mapa vozidla';

	/// cs: 'Zpět na odjezdy'
	String get backToDepartures => 'Zpět na odjezdy';

	/// cs: 'Načítání polohy vozidla...'
	String get loading => 'Načítání polohy vozidla...';

	/// cs: 'Polohu vozidla se nepodařilo načíst. Zkuste to prosím znovu.'
	String get loadFailed => 'Polohu vozidla se nepodařilo načíst. Zkuste to prosím znovu.';

	/// cs: 'Aktuální poloha vozidla není dostupná.'
	String get invalidData => 'Aktuální poloha vozidla není dostupná.';

	/// cs: 'Aktuální poloha linky $line'
	String vehicleMarkerSemantic({required Object line}) => 'Aktuální poloha linky ${line}';

	/// cs: 'Poslední aktualizace $time'
	String lastUpdated({required Object time}) => 'Poslední aktualizace ${time}';

	/// cs: 'Poslední aktualizace před $seconds s'
	String lastUpdatedAgo({required Object seconds}) => 'Poslední aktualizace před ${seconds} s';

	/// cs: 'Další: $stop'
	String nextStop({required Object stop}) => 'Další: ${stop}';

	/// cs: 'Další: $stop v $time'
	String nextStopAt({required Object stop, required Object time}) => 'Další: ${stop} v ${time}';

	/// cs: 'Bezbariérové'
	String get wheelchairAccessible => 'Bezbariérové';

	/// cs: 'Klimatizace'
	String get airConditioned => 'Klimatizace';

	/// cs: 'USB nabíjení'
	String get usbChargers => 'USB nabíjení';

	/// cs: 'Dopravce $name'
	String operatorName({required Object name}) => 'Dopravce ${name}';

	/// cs: 'Vycentrovat vozidlo'
	String get recenterTooltip => 'Vycentrovat vozidlo';

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

	/// cs: '0 min'
	String get delayOnTimeShort => '0 min';

	/// cs: '+$minutes min'
	String delayMinutesShort({required Object minutes}) => '+${minutes} min';
}

// Path: transport.lineTypes
class Translations$transport$lineTypes$cs {
	Translations$transport$lineTypes$cs.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// cs: 'Metro'
	String get metro => 'Metro';

	/// cs: 'Tramvaj'
	String get tram => 'Tramvaj';

	/// cs: 'Zvláštní tramvaj'
	String get tramSpecial => 'Zvláštní tramvaj';

	/// cs: 'Noční tramvaj'
	String get tramNight => 'Noční tramvaj';

	/// cs: 'Městský autobus'
	String get cityBus => 'Městský autobus';

	/// cs: 'Noční městský autobus'
	String get cityBusNight => 'Noční městský autobus';

	/// cs: 'Regionální autobus'
	String get regionalBus => 'Regionální autobus';

	/// cs: 'Noční regionální autobus'
	String get regionalBusNight => 'Noční regionální autobus';

	/// cs: 'Trolejbus'
	String get trolleybus => 'Trolejbus';

	/// cs: 'Vlak S'
	String get trainS => 'Vlak S';

	/// cs: 'Vlak R'
	String get trainR => 'Vlak R';

	/// cs: 'Mezikrajský vlak'
	String get trainInterregional => 'Mezikrajský vlak';

	/// cs: 'Turistický vlak'
	String get trainTourist => 'Turistický vlak';

	/// cs: 'Přívoz'
	String get ferry => 'Přívoz';

	/// cs: 'Lanová dráha'
	String get funicular => 'Lanová dráha';

	/// cs: 'Náhradní doprava za metro'
	String get replacementMetro => 'Náhradní doprava za metro';

	/// cs: 'Náhradní tramvajová doprava'
	String get replacementTram => 'Náhradní tramvajová doprava';

	/// cs: 'Náhradní autobusová doprava'
	String get replacementBus => 'Náhradní autobusová doprava';

	/// cs: 'Náhradní vlaková doprava'
	String get replacementTrain => 'Náhradní vlaková doprava';

	/// cs: 'Náhradní doprava'
	String get replacementUnknown => 'Náhradní doprava';

	/// cs: 'Školní linka'
	String get schoolBus => 'Školní linka';

	/// cs: 'Ostatní / zvláštní linka'
	String get specialOther => 'Ostatní / zvláštní linka';

	/// cs: 'Neznámý typ linky'
	String get unknown => 'Neznámý typ linky';
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
			'transport.lineTypes.metro' => 'Metro',
			'transport.lineTypes.tram' => 'Tramvaj',
			'transport.lineTypes.tramSpecial' => 'Zvláštní tramvaj',
			'transport.lineTypes.tramNight' => 'Noční tramvaj',
			'transport.lineTypes.cityBus' => 'Městský autobus',
			'transport.lineTypes.cityBusNight' => 'Noční městský autobus',
			'transport.lineTypes.regionalBus' => 'Regionální autobus',
			'transport.lineTypes.regionalBusNight' => 'Noční regionální autobus',
			'transport.lineTypes.trolleybus' => 'Trolejbus',
			'transport.lineTypes.trainS' => 'Vlak S',
			'transport.lineTypes.trainR' => 'Vlak R',
			'transport.lineTypes.trainInterregional' => 'Mezikrajský vlak',
			'transport.lineTypes.trainTourist' => 'Turistický vlak',
			'transport.lineTypes.ferry' => 'Přívoz',
			'transport.lineTypes.funicular' => 'Lanová dráha',
			'transport.lineTypes.replacementMetro' => 'Náhradní doprava za metro',
			'transport.lineTypes.replacementTram' => 'Náhradní tramvajová doprava',
			'transport.lineTypes.replacementBus' => 'Náhradní autobusová doprava',
			'transport.lineTypes.replacementTrain' => 'Náhradní vlaková doprava',
			'transport.lineTypes.replacementUnknown' => 'Náhradní doprava',
			'transport.lineTypes.schoolBus' => 'Školní linka',
			'transport.lineTypes.specialOther' => 'Ostatní / zvláštní linka',
			'transport.lineTypes.unknown' => 'Neznámý typ linky',
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
			'stops.showingSavedStops' => 'Zobrazujeme uložené zastávky.',
			'stops.showingOlderSavedStops' => 'Zobrazujeme starší uložená data zastávek.',
			'stops.savedStopsRefreshFailed' => 'Zobrazujeme uložené zastávky. Aktualizace se nezdařila.',
			'stops.favoriteStops' => 'Oblíbené zastávky',
			'stops.recentStops' => 'Poslední zastávky',
			'stops.addFavorite' => 'Přidat do oblíbených',
			'stops.removeFavorite' => 'Odebrat z oblíbených',
			'stops.noFavoriteStops' => 'Žádné oblíbené zastávky',
			'stops.backToTop' => 'Zpět nahoru',
			'stops.stopSemantic' => ({required Object name}) => 'Zastávka ${name}',
			'stops.stopId' => ({required Object id}) => 'ID ${id}',
			'stops.platformWithId' => ({required Object platform, required Object id}) => 'Nástupiště ${platform} • ID ${id}',
			'stops.platformsWithZone' => ({required Object platforms, required Object zone}) => 'Nástupiště ${platforms} • zóna ${zone}',
			'stops.platforms' => ({required Object platforms}) => 'Nástupiště ${platforms}',
			'stops.stopPointsWithZone' => ({required Object count, required Object zone}) => '${count} označníky • zóna ${zone}',
			'stops.stopPoints' => ({required Object count}) => '${count} označníky',
			'stops.coordinatesWithId' => ({required Object id, required Object latitude, required Object longitude}) => 'ID ${id} • ${latitude}, ${longitude}',
			'stops.legacyPlatformWithId' => ({required Object platform, required Object id}) => 'Nástupiště ${platform} - ID ${id}',
			'departures.title' => 'Odjezdy zo zastávky',
			'departures.emptyTabMessage' => 'Nejdříve vyberte zastávku ze seznamu.',
			'departures.loading' => 'Načítání odjezdů...',
			'departures.loadFailed' => 'Odjezdy se nepodařilo načíst. Zkuste to prosím znovu.',
			'departures.invalidData' => 'Golemio API nevrátilo žádné použitelné odjezdy.',
			'departures.empty' => 'Pro tuto zastávku nejsou dostupné žádné odjezdy.',
			'departures.emptyFilter' => 'Pro vybraný typ dopravy nejsou dostupné žádné odjezdy.',
			'departures.refreshing' => 'Aktualizuji odjezdy...',
			'departures.loadingLong' => 'Načítání trvá déle než obvykle…',
			'departures.staleWarning' => 'Nepodařilo se aktualizovat odjezdy. Zobrazujeme poslední dostupná data.',
			'departures.backToStops' => 'Zpět na zastávky',
			'departures.filterAll' => 'Vše',
			'departures.filterMetro' => 'Metro',
			'departures.filterTram' => 'Tram',
			'departures.filterBus' => 'Bus',
			'departures.filterTrolleybus' => 'Trolejbus',
			'departures.filterTrain' => 'Vlak',
			'departures.filterFerry' => 'Přívoz',
			'departures.filterFunicular' => 'Lanovka',
			'departures.filterOther' => 'Ostatní',
			'departures.lastUpdatedAgo' => ({required Object seconds}) => 'Aktualizované před ${seconds} s',
			'departures.departureTime' => ({required Object time}) => 'Odjezd ${time}',
			'departures.platform' => ({required Object platform}) => 'Nástupiště ${platform}',
			'departures.trackingHint' => 'Sledovat vozidlo →',
			'departures.toggleTimeDisplay' => 'Přepnout zobrazení času odjezdu',
			'departures.showVehicleTooltip' => 'Zobrazit polohu vozidla',
			'departures.nightRoute' => 'Noční spoj',
			'departures.wheelchairAccessible' => 'Bezbariérový odjezd',
			'departures.wheelchairAccessibleShort' => 'Bezbariérové',
			'departures.departingNow' => 'teď',
			'departures.departingInMinutes' => ({required Object minutes}) => 'za ${minutes} min',
			'departures.departingInHours' => ({required Object hours}) => 'za ${hours} h',
			'departures.onTime' => 'Načas',
			'departures.scheduledTimeOnly' => 'dle JŘ',
			'vehicleMap.emptyTabMessage' => 'Vyberte odjezd s dostupnou polohou vozidla.',
			'vehicleMap.title' => 'Mapa vozidla',
			'vehicleMap.backToDepartures' => 'Zpět na odjezdy',
			'vehicleMap.loading' => 'Načítání polohy vozidla...',
			'vehicleMap.loadFailed' => 'Polohu vozidla se nepodařilo načíst. Zkuste to prosím znovu.',
			'vehicleMap.invalidData' => 'Aktuální poloha vozidla není dostupná.',
			'vehicleMap.vehicleMarkerSemantic' => ({required Object line}) => 'Aktuální poloha linky ${line}',
			'vehicleMap.lastUpdated' => ({required Object time}) => 'Poslední aktualizace ${time}',
			'vehicleMap.lastUpdatedAgo' => ({required Object seconds}) => 'Poslední aktualizace před ${seconds} s',
			'vehicleMap.nextStop' => ({required Object stop}) => 'Další: ${stop}',
			'vehicleMap.nextStopAt' => ({required Object stop, required Object time}) => 'Další: ${stop} v ${time}',
			'vehicleMap.wheelchairAccessible' => 'Bezbariérové',
			'vehicleMap.airConditioned' => 'Klimatizace',
			'vehicleMap.usbChargers' => 'USB nabíjení',
			'vehicleMap.operatorName' => ({required Object name}) => 'Dopravce ${name}',
			'vehicleMap.recenterTooltip' => 'Vycentrovat vozidlo',
			'vehicleMap.attribution' => 'Mapová data (c) přispěvatelé OpenStreetMap',
			'format.noDelay' => 'Bez zpoždění',
			'format.delayMinutes' => ({required Object minutes}) => 'Zpoždění +${minutes} min',
			'format.delayOnTimeShort' => '0 min',
			'format.delayMinutesShort' => ({required Object minutes}) => '+${minutes} min',
			_ => null,
		};
	}
}
