import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart';
import 'package:pid_seeds/pid_seeds.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleRawSync('cs');
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

    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();

    expect(rowTapCount, 1);
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
}
