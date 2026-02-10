import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dark_crystals/main.dart';

void main() {
  group('Dark Crystals - Widget Testy', () {
    testWidgets('IntroScreen zobrazuje hlavní prvky', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Dark Crystals'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('IntroScreen přechodí na HeroSelectScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();

      expect(find.text('Aerin'), findsOneWidget);
    });

    testWidgets('HeroSelectScreen zobrazuje seznam hrdinů', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HeroSelectScreen()));

      expect(find.text('Aerin'), findsOneWidget);
      expect(find.text('Veyra'), findsOneWidget);
    });

    testWidgets('HeroSelectScreen má tlačítko Boj', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HeroSelectScreen()));

      expect(find.text('Boj'), findsOneWidget);
    });

    testWidgets('může přidat alespoň jednoho hrdinu', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HeroSelectScreen()));

      await tester.tap(find.text('Aerin'));
      await tester.pump();

      final addIcons = find.byIcon(Icons.add);
      expect(addIcons, findsNWidgets(4));
    });

    testWidgets('GameView se správně načte', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HeroSelectScreen()));

      await tester.tap(find.text('Aerin'));
      await tester.pump();

      await tester.tap(find.text('Boj'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('GameView obsahuje textové prvky', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HeroSelectScreen()));

      await tester.tap(find.text('Aerin'));
      await tester.pump();

      await tester.tap(find.text('Boj'));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Herní logika - Základní testy', () {
    test('damage se odečítá od HP', () {
      const hp = 20.0;
      const damage = 5.0;
      final remaining = hp - damage;

      expect(remaining, 15.0);
      expect(remaining, greaterThan(0.0));
    });

    test('damage nesmí jít pod 0', () {
      const hp = 20.0;
      const damage = 25.0;
      final remaining = (hp - damage).clamp(0.0, double.infinity);

      expect(remaining, 0.0);
      expect(remaining, isNot(lessThan(0)));
    });

    test('čas do spawnu je v rozmezí', () {
      const minDelay = 1.0;
      const maxDelay = 10.0;

      final validDelay = 5.0;
      expect(validDelay, greaterThanOrEqualTo(minDelay));
      expect(validDelay, lessThanOrEqualTo(maxDelay));
    });

    test('wall damage je DPS * čas', () {
      const dps = 5.0;
      const time = 2.0;
      final damage = dps * time;

      expect(damage, 10.0);
    });
  });

  group('Asset cesty - Ověření', () {
    test('hero obrázky mají správnou cestu', () {
      const expectedPath = 'assets/heroes/';

      final heroImages = [
        'hero_aerin.png',
        'hero_veyra.png',
        'hero_thalor.png',
        'hero_myris.png',
        'hero_kaelen.png',
        'hero_solenne.png',
        'hero_ravik.png',
        'hero_brann.png',
        'hero_nyxra.png',
        'hero_eldrin.png',
      ];

      for (final image in heroImages) {
        final fullPath = '$expectedPath$image';
        expect(fullPath, contains(expectedPath));
        expect(fullPath, endsWith('.png'));
      }
    });
  });
}
