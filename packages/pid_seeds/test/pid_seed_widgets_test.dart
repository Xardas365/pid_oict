import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart';
import 'package:pid_seeds/pid_seeds.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleRawSync('cs');
  });

  testWidgets('PidSearchField hides clear button for empty query', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: const Scaffold(body: PidSearchField()),
      ),
    );

    expect(find.byTooltip('Vymazat hledání'), findsNothing);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('PidSearchField shows clear button for non-empty query', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Anděl');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: Scaffold(body: PidSearchField(controller: controller)),
      ),
    );

    expect(find.byTooltip('Vymazat hledání'), findsOneWidget);
  });

  testWidgets('PidSearchField clear button empties field and notifies change', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: Scaffold(
          body: PidSearchField(onChanged: changes.add),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Flora');
    await tester.pump();

    expect(find.byTooltip('Vymazat hledání'), findsOneWidget);

    await tester.tap(find.byTooltip('Vymazat hledání'));
    await tester.pump();

    expect(find.text('Flora'), findsNothing);
    expect(changes, containsAllInOrder(<String>['Flora', '']));
    expect(find.byTooltip('Vymazat hledání'), findsNothing);
  });

  testWidgets('PidSearchField keeps filter action when clear button is visible',
      (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Flor');
    addTearDown(controller.dispose);
    var filterTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: Scaffold(
          body: PidSearchField(
            controller: controller,
            onFilterPressed: () => filterTapCount++,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Vymazat hledání'), findsOneWidget);
    expect(find.byTooltip('Filtrovat'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrovat'));
    await tester.pumpAndSettle();

    expect(filterTapCount, 1);
    expect(controller.text, 'Flor');
  });

  testWidgets('PidStopCard trailing action does not trigger row tap', (
    tester,
  ) async {
    var rowTapCount = 0;
    var actionTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: Scaffold(
          body: PidStopCard(
            stop: const PidStopData(
              id: 'U123S1',
              name: 'Andel',
              subtitle: 'Nástupiště A • zóna P',
            ),
            onTap: () => rowTapCount++,
            trailingAction: PidStopCardAction(
              icon: Icons.star_border_rounded,
              tooltip: 'Přidat do oblíbených',
              onPressed: () => actionTapCount++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Přidat do oblíbených'));
    await tester.pumpAndSettle();

    expect(actionTapCount, 1);
    expect(rowTapCount, 0);
    expect(
      tester.getSize(find.byTooltip('Přidat do oblíbených')),
      const Size.square(48),
    );
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();

    expect(rowTapCount, 1);
  });

  testWidgets('PidStopCard renders favorite and non-favorite action states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: Scaffold(
          body: Column(
            children: [
              PidStopCard(
                stop: const PidStopData(
                  id: 'U123S1',
                  name: 'Andel',
                  subtitle: 'Nástupiště A • zóna P',
                  isHighlighted: true,
                ),
                trailingAction: PidStopCardAction(
                  icon: Icons.star_rounded,
                  tooltip: 'Odebrat z oblíbených',
                  onPressed: () {},
                  color: PidSeedColors.primary,
                ),
              ),
              PidStopCard(
                stop: const PidStopData(
                  id: 'U456S1',
                  name: 'Flora',
                  subtitle: 'Nástupiště B • zóna P',
                ),
                trailingAction: PidStopCardAction(
                  icon: Icons.star_border_rounded,
                  tooltip: 'Přidat do oblíbených',
                  onPressed: () {},
                  color: PidSeedColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final favoriteButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.star_rounded),
    );
    final nonFavoriteButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.star_border_rounded),
    );

    expect(favoriteButton.color, PidSeedColors.primary);
    expect(nonFavoriteButton.color, PidSeedColors.textMuted);
    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('Flora'), findsOneWidget);
  });

  testWidgets('PidStatusBanner renders title, message and tone icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: const Scaffold(
          body: PidStatusBanner(
            tone: PidStatusBannerTone.warning,
            title: 'Starší data',
            message: 'Zobrazujeme uložené zastávky.',
          ),
        ),
      ),
    );

    expect(find.text('Starší data'), findsOneWidget);
    expect(find.text('Zobrazujeme uložené zastávky.'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('PidFeedbackState supports compact message-only usage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: const Scaffold(
          body: PidFeedbackState(title: 'Žádné zastávky'),
        ),
      ),
    );

    expect(find.text('Žádné zastávky'), findsOneWidget);
  });

  testWidgets('PidSectionedStopList renders sections and back to top action', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var selectedStopId = '';
    var backToTopPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: Scaffold(
          body: PidSectionedStopList(
            controller: controller,
            showBackToTopButton: true,
            backToTopTooltip: 'Nahoru',
            onScrollToTop: () {
              backToTopPressed = true;
            },
            sections: [
              PidStopListSection(
                title: 'Oblíbené zastávky',
                items: [
                  PidStopListItem(
                    stop: const PidStopData(
                      id: 'U1',
                      name: 'Anděl',
                      subtitle: 'Nástupiště A • zóna P',
                    ),
                    onTap: () {
                      selectedStopId = 'U1';
                    },
                  ),
                ],
              ),
              const PidStopListSection(
                items: [
                  PidStopListItem(
                    stop: PidStopData(
                      id: 'U2',
                      name: 'Flora',
                      subtitle: 'Nástupiště B • zóna P',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Oblíbené zastávky'), findsOneWidget);
    expect(find.text('Anděl'), findsOneWidget);
    expect(find.text('Flora'), findsOneWidget);

    await tester.tap(find.text('Anděl'));
    await tester.pumpAndSettle();

    expect(selectedStopId, 'U1');

    await tester.tap(find.byTooltip('Nahoru'));
    await tester.pumpAndSettle();

    expect(backToTopPressed, isTrue);
  });

  testWidgets('PidStopsTemplate.screen renders supplied slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: const PidStopsTemplate.screen(
          title: 'Zastávky',
          search: Text('Search slot'),
          searchProgress: LinearProgressIndicator(),
          statusBanner: Text('Saved stops banner'),
          content: Text('Stops content'),
        ),
      ),
    );

    expect(find.text('Zastávky'), findsOneWidget);
    expect(find.text('Search slot'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Saved stops banner'), findsOneWidget);
    expect(find.text('Stops content'), findsOneWidget);
  });

  testWidgets('PidDeparturesTemplate.screen renders board slots and back', (
    tester,
  ) async {
    var backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: PidDeparturesTemplate.screen(
          title: 'Odjezdy zo zastávky',
          backTooltip: 'Zpět',
          onBack: () {
            backPressed = true;
          },
          stopHeader: const Text('Flora'),
          filterRow: const Text('Vše Tram'),
          lastUpdatedRow: const Text('Aktualizované před 4 s'),
          content: const Text('Departure content'),
        ),
      ),
    );

    expect(find.text('Odjezdy zo zastávky'), findsOneWidget);
    expect(find.text('Flora'), findsOneWidget);
    expect(find.text('Vše Tram'), findsOneWidget);
    expect(find.text('Aktualizované před 4 s'), findsOneWidget);
    expect(find.text('Departure content'), findsOneWidget);

    await tester.tap(find.byTooltip('Zpět'));

    expect(backPressed, isTrue);
  });

  testWidgets('PidVehicleMapTemplate.screen renders title and content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: const PidVehicleMapTemplate.screen(
          title: 'Mapa vozidla',
          content: Text('Map content'),
        ),
      ),
    );

    expect(find.text('Mapa vozidla'), findsOneWidget);
    expect(find.text('Map content'), findsOneWidget);
  });

  testWidgets('PidVehicleMapTemplate.screen supports explicit back action', (
    tester,
  ) async {
    var backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: PidSeedsTheme.light(),
        home: PidVehicleMapTemplate.screen(
          title: 'Mapa vozidla',
          backTooltip: 'Zpět na odjezdy',
          onBack: () {
            backPressed = true;
          },
          content: const Text('Map content'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Zpět na odjezdy'));

    expect(backPressed, isTrue);
  });
}
