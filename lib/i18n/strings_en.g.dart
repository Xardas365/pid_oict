///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$app$en app = _Translations$app$en._(_root);
	@override late final _Translations$navigation$en navigation = _Translations$navigation$en._(_root);
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$transport$en transport = _Translations$transport$en._(_root);
	@override late final _Translations$errors$en errors = _Translations$errors$en._(_root);
	@override late final _Translations$stops$en stops = _Translations$stops$en._(_root);
	@override late final _Translations$departures$en departures = _Translations$departures$en._(_root);
	@override late final _Translations$vehicleMap$en vehicleMap = _Translations$vehicleMap$en._(_root);
	@override late final _Translations$format$en format = _Translations$format$en._(_root);
}

// Path: app
class _Translations$app$en extends Translations$app$cs {
	_Translations$app$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'PID Departures';
}

// Path: navigation
class _Translations$navigation$en extends Translations$navigation$cs {
	_Translations$navigation$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get stops => 'Stops';
	@override String get departures => 'Departures';
	@override String get map => 'Map';
}

// Path: common
class _Translations$common$en extends Translations$common$cs {
	_Translations$common$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get retry => 'Try again';
}

// Path: transport
class _Translations$transport$en extends Translations$transport$cs {
	_Translations$transport$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$transport$lineTypes$en lineTypes = _Translations$transport$lineTypes$en._(_root);
}

// Path: errors
class _Translations$errors$en extends Translations$errors$cs {
	_Translations$errors$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get missingToken => 'Golemio API token is missing. Run the app with --dart-define=GOLEMIO_API_TOKEN=your_token.';
	@override String get unauthorized => 'The Golemio API token is invalid or unauthorized. Check the token.';
	@override String get network => 'Could not connect to the Golemio API. Check your internet connection.';
	@override String get timeout => 'The Golemio API did not respond in time. Please try again.';
	@override String get emptyResponse => 'The Golemio API returned an empty response.';
	@override String get invalidJson => 'The Golemio API returned a response that could not be read.';
	@override String get invalidData => 'The Golemio API returned incomplete or invalid data.';
	@override String get badRequest => 'The Golemio API request was rejected. Try the action again.';
	@override String get notFound => 'The requested data was not found in the Golemio API.';
	@override String get server => 'The Golemio API is temporarily unavailable. Please try again later.';
	@override String get unexpectedStatus => 'The Golemio API returned an unexpected response.';
	@override String stalePosition({required Object message}) => 'Showing the last known position. ${message}';
	@override String get refreshFailed => 'Refresh failed.';
}

// Path: stops
class _Translations$stops$en extends Translations$stops$cs {
	_Translations$stops$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'PID stops';
	@override String get searchHint => 'Search for a stop...';
	@override String get loading => 'Loading stops...';
	@override String get loadFailed => 'Could not load stops. Please try again.';
	@override String get invalidData => 'The Golemio API did not return any usable stops.';
	@override String get empty => 'No stops are available.';
	@override String get emptySearch => 'No stops match the search.';
	@override String get showingSavedStops => 'Showing saved stops.';
	@override String get showingOlderSavedStops => 'Showing older saved stop data.';
	@override String get savedStopsRefreshFailed => 'Showing saved stops. Refresh failed.';
	@override String get favoriteStops => 'Favorite stops';
	@override String get recentStops => 'Recent stops';
	@override String get addFavorite => 'Add to favorites';
	@override String get removeFavorite => 'Remove from favorites';
	@override String get noFavoriteStops => 'No favorite stops';
	@override String get backToTop => 'Back to top';
	@override String stopSemantic({required Object name}) => 'Stop ${name}';
	@override String stopId({required Object id}) => 'ID ${id}';
	@override String platformWithId({required Object platform, required Object id}) => 'Platform ${platform} • ID ${id}';
	@override String platformsWithZone({required Object platforms, required Object zone}) => 'Platforms ${platforms} • zone ${zone}';
	@override String platforms({required Object platforms}) => 'Platforms ${platforms}';
	@override String stopPointsWithZone({required Object count, required Object zone}) => '${count} stop points • zone ${zone}';
	@override String stopPoints({required Object count}) => '${count} stop points';
	@override String coordinatesWithId({required Object id, required Object latitude, required Object longitude}) => 'ID ${id} • ${latitude}, ${longitude}';
	@override String legacyPlatformWithId({required Object platform, required Object id}) => 'Platform ${platform} - ID ${id}';
}

// Path: departures
class _Translations$departures$en extends Translations$departures$cs {
	_Translations$departures$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Departures from stop';
	@override String get emptyTabMessage => 'Select a stop from the list first.';
	@override String get loading => 'Loading departures...';
	@override String get loadFailed => 'Could not load departures. Please try again.';
	@override String get invalidData => 'The Golemio API did not return any usable departures.';
	@override String get empty => 'No departures are available for this stop.';
	@override String get emptyFilter => 'No departures are available for the selected transport type.';
	@override String get refreshing => 'Refreshing departures...';
	@override String get loadingLong => 'Loading is taking longer than usual…';
	@override String get staleWarning => 'Could not refresh departures. Showing the last available data.';
	@override String get backToStops => 'Back to stops';
	@override String get filterAll => 'All';
	@override String get filterMetro => 'Metro';
	@override String get filterTram => 'Tram';
	@override String get filterBus => 'Bus';
	@override String get filterTrolleybus => 'Trolleybus';
	@override String get filterTrain => 'Train';
	@override String get filterFerry => 'Ferry';
	@override String get filterFunicular => 'Funicular';
	@override String get filterOther => 'Other';
	@override String lastUpdatedAgo({required Object seconds}) => 'Updated ${seconds} s ago';
	@override String departureTime({required Object time}) => 'Departure ${time}';
	@override String platform({required Object platform}) => 'Platform ${platform}';
	@override String get trackingHint => 'Position →';
	@override String get toggleTimeDisplay => 'Toggle departure time display';
	@override String get showVehicleTooltip => 'Show vehicle position';
	@override String get wheelchairAccessible => 'Wheelchair-accessible departure';
	@override String get wheelchairAccessibleShort => 'Accessible';
	@override String get departingNow => 'now';
	@override String departingInMinutes({required Object minutes}) => 'in ${minutes} min';
	@override String departingInHours({required Object hours}) => 'in ${hours} h';
	@override String get onTime => 'On time';
	@override String get scheduledTimeOnly => 'timetable';
}

// Path: vehicleMap
class _Translations$vehicleMap$en extends Translations$vehicleMap$cs {
	_Translations$vehicleMap$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get emptyTabMessage => 'Select a departure with an available vehicle position.';
	@override String get title => 'Vehicle map';
	@override String get backToDepartures => 'Back to departures';
	@override String get loading => 'Loading vehicle position...';
	@override String get loadFailed => 'Could not load the vehicle position. Please try again.';
	@override String get invalidData => 'The current vehicle position is not available.';
	@override String vehicleMarkerSemantic({required Object line}) => 'Current position of line ${line}';
	@override String lastUpdated({required Object time}) => 'Last updated ${time}';
	@override String lastUpdatedAgo({required Object seconds}) => 'Last updated ${seconds} s ago';
	@override String nextStop({required Object stop}) => 'Next: ${stop}';
	@override String nextStopAt({required Object stop, required Object time}) => 'Next: ${stop} at ${time}';
	@override String get wheelchairAccessible => 'Accessible';
	@override String get airConditioned => 'Air-conditioned';
	@override String get usbChargers => 'USB charging';
	@override String operatorName({required Object name}) => 'Operator ${name}';
	@override String get recenterTooltip => 'Recenter vehicle';
	@override String get attribution => 'Map data (c) OpenStreetMap contributors';
}

// Path: format
class _Translations$format$en extends Translations$format$cs {
	_Translations$format$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noDelay => 'No delay';
	@override String delayMinutes({required Object minutes}) => 'Delay +${minutes} min';
	@override String get delayOnTimeShort => '0 min';
	@override String delayMinutesShort({required Object minutes}) => '+${minutes} min';
}

// Path: transport.lineTypes
class _Translations$transport$lineTypes$en extends Translations$transport$lineTypes$cs {
	_Translations$transport$lineTypes$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get metro => 'Metro';
	@override String get tram => 'Tram';
	@override String get tramSpecial => 'Special tram';
	@override String get tramNight => 'Night tram';
	@override String get cityBus => 'City bus';
	@override String get cityBusNight => 'Night city bus';
	@override String get regionalBus => 'Regional bus';
	@override String get regionalBusNight => 'Night regional bus';
	@override String get trolleybus => 'Trolleybus';
	@override String get trainS => 'S train';
	@override String get trainR => 'R train';
	@override String get trainInterregional => 'Interregional train';
	@override String get trainTourist => 'Tourist train';
	@override String get ferry => 'Ferry';
	@override String get funicular => 'Funicular';
	@override String get replacementMetro => 'Metro replacement service';
	@override String get replacementTram => 'Tram replacement service';
	@override String get replacementBus => 'Bus replacement service';
	@override String get replacementTrain => 'Train replacement service';
	@override String get replacementUnknown => 'Replacement service';
	@override String get schoolBus => 'School bus';
	@override String get specialOther => 'Other / special line';
	@override String get unknown => 'Unknown line type';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'PID Departures',
			'navigation.stops' => 'Stops',
			'navigation.departures' => 'Departures',
			'navigation.map' => 'Map',
			'common.retry' => 'Try again',
			'transport.lineTypes.metro' => 'Metro',
			'transport.lineTypes.tram' => 'Tram',
			'transport.lineTypes.tramSpecial' => 'Special tram',
			'transport.lineTypes.tramNight' => 'Night tram',
			'transport.lineTypes.cityBus' => 'City bus',
			'transport.lineTypes.cityBusNight' => 'Night city bus',
			'transport.lineTypes.regionalBus' => 'Regional bus',
			'transport.lineTypes.regionalBusNight' => 'Night regional bus',
			'transport.lineTypes.trolleybus' => 'Trolleybus',
			'transport.lineTypes.trainS' => 'S train',
			'transport.lineTypes.trainR' => 'R train',
			'transport.lineTypes.trainInterregional' => 'Interregional train',
			'transport.lineTypes.trainTourist' => 'Tourist train',
			'transport.lineTypes.ferry' => 'Ferry',
			'transport.lineTypes.funicular' => 'Funicular',
			'transport.lineTypes.replacementMetro' => 'Metro replacement service',
			'transport.lineTypes.replacementTram' => 'Tram replacement service',
			'transport.lineTypes.replacementBus' => 'Bus replacement service',
			'transport.lineTypes.replacementTrain' => 'Train replacement service',
			'transport.lineTypes.replacementUnknown' => 'Replacement service',
			'transport.lineTypes.schoolBus' => 'School bus',
			'transport.lineTypes.specialOther' => 'Other / special line',
			'transport.lineTypes.unknown' => 'Unknown line type',
			'errors.missingToken' => 'Golemio API token is missing. Run the app with --dart-define=GOLEMIO_API_TOKEN=your_token.',
			'errors.unauthorized' => 'The Golemio API token is invalid or unauthorized. Check the token.',
			'errors.network' => 'Could not connect to the Golemio API. Check your internet connection.',
			'errors.timeout' => 'The Golemio API did not respond in time. Please try again.',
			'errors.emptyResponse' => 'The Golemio API returned an empty response.',
			'errors.invalidJson' => 'The Golemio API returned a response that could not be read.',
			'errors.invalidData' => 'The Golemio API returned incomplete or invalid data.',
			'errors.badRequest' => 'The Golemio API request was rejected. Try the action again.',
			'errors.notFound' => 'The requested data was not found in the Golemio API.',
			'errors.server' => 'The Golemio API is temporarily unavailable. Please try again later.',
			'errors.unexpectedStatus' => 'The Golemio API returned an unexpected response.',
			'errors.stalePosition' => ({required Object message}) => 'Showing the last known position. ${message}',
			'errors.refreshFailed' => 'Refresh failed.',
			'stops.title' => 'PID stops',
			'stops.searchHint' => 'Search for a stop...',
			'stops.loading' => 'Loading stops...',
			'stops.loadFailed' => 'Could not load stops. Please try again.',
			'stops.invalidData' => 'The Golemio API did not return any usable stops.',
			'stops.empty' => 'No stops are available.',
			'stops.emptySearch' => 'No stops match the search.',
			'stops.showingSavedStops' => 'Showing saved stops.',
			'stops.showingOlderSavedStops' => 'Showing older saved stop data.',
			'stops.savedStopsRefreshFailed' => 'Showing saved stops. Refresh failed.',
			'stops.favoriteStops' => 'Favorite stops',
			'stops.recentStops' => 'Recent stops',
			'stops.addFavorite' => 'Add to favorites',
			'stops.removeFavorite' => 'Remove from favorites',
			'stops.noFavoriteStops' => 'No favorite stops',
			'stops.backToTop' => 'Back to top',
			'stops.stopSemantic' => ({required Object name}) => 'Stop ${name}',
			'stops.stopId' => ({required Object id}) => 'ID ${id}',
			'stops.platformWithId' => ({required Object platform, required Object id}) => 'Platform ${platform} • ID ${id}',
			'stops.platformsWithZone' => ({required Object platforms, required Object zone}) => 'Platforms ${platforms} • zone ${zone}',
			'stops.platforms' => ({required Object platforms}) => 'Platforms ${platforms}',
			'stops.stopPointsWithZone' => ({required Object count, required Object zone}) => '${count} stop points • zone ${zone}',
			'stops.stopPoints' => ({required Object count}) => '${count} stop points',
			'stops.coordinatesWithId' => ({required Object id, required Object latitude, required Object longitude}) => 'ID ${id} • ${latitude}, ${longitude}',
			'stops.legacyPlatformWithId' => ({required Object platform, required Object id}) => 'Platform ${platform} - ID ${id}',
			'departures.title' => 'Departures from stop',
			'departures.emptyTabMessage' => 'Select a stop from the list first.',
			'departures.loading' => 'Loading departures...',
			'departures.loadFailed' => 'Could not load departures. Please try again.',
			'departures.invalidData' => 'The Golemio API did not return any usable departures.',
			'departures.empty' => 'No departures are available for this stop.',
			'departures.emptyFilter' => 'No departures are available for the selected transport type.',
			'departures.refreshing' => 'Refreshing departures...',
			'departures.loadingLong' => 'Loading is taking longer than usual…',
			'departures.staleWarning' => 'Could not refresh departures. Showing the last available data.',
			'departures.backToStops' => 'Back to stops',
			'departures.filterAll' => 'All',
			'departures.filterMetro' => 'Metro',
			'departures.filterTram' => 'Tram',
			'departures.filterBus' => 'Bus',
			'departures.filterTrolleybus' => 'Trolleybus',
			'departures.filterTrain' => 'Train',
			'departures.filterFerry' => 'Ferry',
			'departures.filterFunicular' => 'Funicular',
			'departures.filterOther' => 'Other',
			'departures.lastUpdatedAgo' => ({required Object seconds}) => 'Updated ${seconds} s ago',
			'departures.departureTime' => ({required Object time}) => 'Departure ${time}',
			'departures.platform' => ({required Object platform}) => 'Platform ${platform}',
			'departures.trackingHint' => 'Position →',
			'departures.toggleTimeDisplay' => 'Toggle departure time display',
			'departures.showVehicleTooltip' => 'Show vehicle position',
			'departures.wheelchairAccessible' => 'Wheelchair-accessible departure',
			'departures.wheelchairAccessibleShort' => 'Accessible',
			'departures.departingNow' => 'now',
			'departures.departingInMinutes' => ({required Object minutes}) => 'in ${minutes} min',
			'departures.departingInHours' => ({required Object hours}) => 'in ${hours} h',
			'departures.onTime' => 'On time',
			'departures.scheduledTimeOnly' => 'timetable',
			'vehicleMap.emptyTabMessage' => 'Select a departure with an available vehicle position.',
			'vehicleMap.title' => 'Vehicle map',
			'vehicleMap.backToDepartures' => 'Back to departures',
			'vehicleMap.loading' => 'Loading vehicle position...',
			'vehicleMap.loadFailed' => 'Could not load the vehicle position. Please try again.',
			'vehicleMap.invalidData' => 'The current vehicle position is not available.',
			'vehicleMap.vehicleMarkerSemantic' => ({required Object line}) => 'Current position of line ${line}',
			'vehicleMap.lastUpdated' => ({required Object time}) => 'Last updated ${time}',
			'vehicleMap.lastUpdatedAgo' => ({required Object seconds}) => 'Last updated ${seconds} s ago',
			'vehicleMap.nextStop' => ({required Object stop}) => 'Next: ${stop}',
			'vehicleMap.nextStopAt' => ({required Object stop, required Object time}) => 'Next: ${stop} at ${time}',
			'vehicleMap.wheelchairAccessible' => 'Accessible',
			'vehicleMap.airConditioned' => 'Air-conditioned',
			'vehicleMap.usbChargers' => 'USB charging',
			'vehicleMap.operatorName' => ({required Object name}) => 'Operator ${name}',
			'vehicleMap.recenterTooltip' => 'Recenter vehicle',
			'vehicleMap.attribution' => 'Map data (c) OpenStreetMap contributors',
			'format.noDelay' => 'No delay',
			'format.delayMinutes' => ({required Object minutes}) => 'Delay +${minutes} min',
			'format.delayOnTimeShort' => '0 min',
			'format.delayMinutesShort' => ({required Object minutes}) => '+${minutes} min',
			_ => null,
		};
	}
}
