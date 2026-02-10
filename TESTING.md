# Dark Crystals - Testování

## Přehled testů

Současné automatické testy pokrývají:
1. **Widget testy** pro veřejné UI komponenty
2. **Základní ověření herní logiky** (independendně od soukromých tříd)
3. **Asset existence ověření**

### Co testuje:

✅ **IntroScreen**
- Zobrazuje nadpis "Dark Crystals"
- Zobrazuje tlačítko "Play"
- Přechodí na HeroSelectScreen

✅ **HeroSelectScreen**
- Zobrazuje seznam 10 hrdinů
- Má 5 prázdných slotů (ikona add)
- Má tlačítko "Boj"
- Tlačítko Boj je zakázáno bez hrdinů
- Může přidat hrdinu do slotu
- Po přidání se snížil počet prázdných slotů

⚠️ **GameView** (částečně nefunkční v testech)
- GameView testy mají problémy s timeout a layout overflow

❌ **Problémy**:
- GameView se nedokončí načít v testovacím prostředí (timeout)
- RenderFlex overflow v UI způsobuje chyby v layoutu
- pumpAndSettle timeouts při čekání na přechod

### Omezení současného testování

Většina herní logika je definována v **private třídách** (s prefixem `_`), což znemožňuje přímý přístup pro unit testování.

**Pro kompletní unit testování by bylo potřeba:**

1. **Přenést herní entity do public**
   ```dart
   class HeroDef {
     final String name;
     final Color color;
     final String imageAsset;
     final double cooldownDuration;
     final double damage;
     final _AttackType attackType;
     final double beamDps;
   }

   class Enemy {
     Offset position;
     final double hp;
     final double seed;
     final bool attacking;
     final double flashRemaining;
     final double pendingDamage;
     final double damageTextCooldown;
     final double animTime;
   }

   class Projectile {
     final Offset position;
     final Offset velocity;
     final double radius;
     final double damage;
     final double aoeRadius;
     final bool isAerinStrong;
     final double seed;
   }

   class HeroState {
     final _HeroPhase phase;
     final double timeRemaining;
   }
   ```

2. **Přenést herní konstanty do public třídy**
   ```dart
   class GameConstants {
     static const double heroAreaWidth = 150;
     static const double mapWidth = 1600;
     static const double mapHeight = 640;
     static const int heroSlots = 5;
     static const double heroLaneHeight = 80;
     static const double wallHpMax = 300;
     static const double enemyHpMax = 20;
     static const double enemySize = 40;
     static const double enemySpeed = 16;
     static const double projectileSpeed = 160;
     static const double spellCastingDuration = 5;
     static const double spellSendingDuration = 2;
     static const double spellCooldownDuration = 10;
     static const double wallDps = 5;
     static const double hitFlashDuration = 0.12;
     static const double projectileRadius = 2;
     static const double explosionDuration = 0.35;
     static const double swordRadius = 140;
   }
   ```

3. **Přenést herní výpočty do public funkcí**
   ```dart
   class GameCalculations {
     static double calculateDamage(double hp, double damage) => hp - damage;

     static double calculateWallDamage(double dps, double time) => dps * time;

     static bool isProjectileHit(
       Offset projectilePosition,
       double projectileRadius,
       Offset enemyPosition,
       double enemySize,
     ) {
       final distance = (projectilePosition - enemyPosition).distance;
       final hit = distance <= (projectileRadius + enemySize / 2);
       return hit;
     }
   }
   ```

### Doporučené další kroky pro testování

1. **Refactoring pro unit testování**
   - Přenést klíčové herní třídy (HeroDef, Enemy, Projectile, HeroState) do public
   - Vytvořit samostatný soubor `lib/game_constants.dart` s herními konstantami
   - Vytvořit soubor `lib/game_entities.dart` s herními entitami
   - Vytvořit soubor `lib/game_calculations.dart` s výpočetovými funkcemi

2. **Lepší integration testy**
   - Vytvořit mock ticker pro simulaci herního času
   - Vytvořit testovací GameView s asynchronním načítáním obrázků
   - Ověřit herní stavy po určitém čase (HP zdi, počet nepřátelů atd.)

3. **Konfigurační testy**
   - Vytvořit test pro různé herní módy (Aerin: fast/strong, Veyra: rapid/explosive atd.)
   - Test přechodu mezi obrazovkami

4. **CI/CD integrace**
   - `flutter test` pro místní vývoj
   - `flutter test --coverage` pro pokrytí kódu
   - Automatizované testování při každém push do repozitáře

### Spuštění testů

```bash
flutter test
```

### Poznámky

- Testy by měly běžet rychle (< 10 sekund)
- Pokud test trvá dlouho, může to znamenat problém v kódu
- Pro komplexnější testování zvaž použití `mockito` nebo `fake_async`
- Integration testy vyžadují stabilní asynchronní operace (Future.wait(), completer atd.)

### Known Issues

⚠️ **GameView testy nefungují** - mají problémy s:
   - Timeout při načítání GameView
   - RenderFlex overflow v HeroSelectScreen

To je přirozené - GameView má složitou asynchronní inicializaci a na obrázky, což v testovacím prostředí může způsobovat timeouty.
