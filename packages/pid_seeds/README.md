# PID Seeds

`pid_seeds` je Flutter design-system package pripravený z mockupov pre zadanie OICT/PID. Obsahuje znovupoužiteľné widgety pre tri požadované používateľské toky:

1. vyhľadanie a výber zastávky,
2. zobrazenie odjazdov zo zastávky,
3. zobrazenie aktuálnej polohy vozidla na mape.

Package neobsahuje API klienta ani mapový plugin. Je to zámer: komponenty majú byť čisto prezentačné a dátovo napojené cez parametre a callbacky. V produkčnej aplikácii môžeš použiť ľubovoľný state management, HTTP klient aj mapový plugin.

## Inštalácia cez lokálnu dependency

V hlavnej Flutter aplikácii pridaj do `pubspec.yaml`:

```yaml
dependencies:
  pid_seeds:
    path: ../pid_seeds
```

Potom spusti:

```bash
flutter pub get
```

## Rýchle použitie

```dart
import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: PidSeedsTheme.light(),
      home: PidStopsTemplate(
        stops: const [
          PidStopData(
            id: 'U699Z301P',
            name: 'Hradčanská',
            subtitle: 'tram, metro A, bus',
            distanceText: '320 m',
            lineCountText: '3 linky',
            transportType: PidTransportType.tram,
            isHighlighted: true,
          ),
        ],
        selectedFilter: 'all',
        filters: PidFilterChipData.pidTransportDefaults,
        onStopSelected: (stop) {
          // otvor detail odjazdov pre stop.id
        },
      ),
    );
  }
}
```

## Atomic design štruktúra

```text
lib/
  pid_seeds.dart
  src/
    tokens/       # farby, typografia, spacing, radii, shadow, motion
    theme/        # ThemeData pre celú appku
    models/       # jednoduché UI data classes
    utils/        # transport typy a mapovanie farieb/ikon
    atomic/
      atoms/      # najmenšie prvky: badge, search field, text, marker, icon button
      molecules/  # kombinácie atómov: stop card, departure tile, bottom nav
      organisms/  # väčšie sekcie: header, list, map preview, map panel
      templates/  # celé obrazovky pripravené na napojenie dát
```

## Pripravené obrazovky

### `PidStopsTemplate`

Použitie pre obrazovku so zoznamom zastávok. Podporuje:

- vyhľadávacie pole,
- filtre typov dopravy,
- loading/error/empty stavy,
- refresh cez `RefreshIndicator`,
- callback `onStopSelected`.

### `PidDeparturesTemplate`

Použitie pre odjazdy zo zvolenej zastávky. Podporuje:

- back button,
- stav aktualizácie,
- filtre smerov alebo nástupíšť,
- zoznam odjazdov,
- callback `onShowVehicle`, ktorý otvorí mapu pre konkrétne `vehicleId`.

### `PidVehicleMapTemplate`

Použitie pre mapu vozidla. Podporuje:

- vlastný `mapContent`, ak používaš napríklad Google Maps alebo MapLibre,
- fallback `PidMapPreview` bez externých závislostí,
- overlay marker vozidla,
- refresh a locate callbacky,
- spodný informačný panel o vozidle.

## Ako napojiť Golemio dáta

Package očakáva dáta v jednoduchých UI modeloch:

```dart
PidStopData(...)
PidDepartureData(...)
PidVehiclePositionData(...)
```

Mapovanie z API odporúčam držať v hlavnej aplikácii, napríklad:

```text
Golemio API DTO -> mapper -> PidStopData / PidDepartureData / PidVehiclePositionData -> pid_seeds widgety
```

Tak zostane design system nezávislý od konkrétneho backendu, testovateľný a znovupoužiteľný.

## Paleta

Paleta vychádza z mockupov:

- primary blue `#2563EB` pre navigáciu, primárne akcie a vybraný stav,
- teal `#14B8A6` pre živý/aktuálny stav,
- amber `#F59E0B` pre oneskorenie alebo upozornenie,
- slate neutrals pre texty a pozadie,
- light surfaces `#F6F8FB`, `#FFFFFF`, `#EAF2FF` pre pokojné dopravné UI.

## Vývoj

```bash
cd pid_seeds
flutter pub get
flutter analyze
flutter test
cd example
flutter run
```

## Poznámky k znovupoužiteľnosti

- Widgety nepoužívajú API volania, globálny stav ani router.
- Každý väčší komponent prijíma dáta cez immutable modely a akcie cez callbacky.
- Mapový plugin nie je súčasťou balíka; reálna mapa sa injektuje cez `mapContent`.
- Všetky farby, spacing a typografia sú uložené v tokenoch.
- Šablóny sú pripravené tak, aby sa dali použiť priamo alebo postupne nahrádzať vlastnými page widgetmi.
