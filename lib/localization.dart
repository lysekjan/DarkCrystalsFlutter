import 'package:flutter/material.dart';

enum AppLanguage {
  cs, // Czech
  sk, // Slovak
  hu, // Hungarian
  en, // English
  de, // German
  fr, // French
  es, // Spanish
  pt, // Portuguese
}

extension AppLanguageExtension on AppLanguage {
  String get name {
    switch (this) {
      case AppLanguage.cs:
        return 'Čeština';
      case AppLanguage.sk:
        return 'Slovenčina';
      case AppLanguage.hu:
        return 'Magyar';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.de:
        return 'Deutsch';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.pt:
        return 'Português';
    }
  }

  String get flagEmoji {
    switch (this) {
      case AppLanguage.cs:
        return '🇨🇿';
      case AppLanguage.sk:
        return '🇸🇰';
      case AppLanguage.hu:
        return '🇭🇺';
      case AppLanguage.en:
        return '🇬🇧';
      case AppLanguage.de:
        return '🇩🇪';
      case AppLanguage.fr:
        return '🇫🇷';
      case AppLanguage.es:
        return '🇪🇸';
      case AppLanguage.pt:
        return '🇵🇹';
    }
  }
}

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  // Static method to get localizations from BuildContext
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // ========== MAIN MENU ==========
  String get appName => _texts[language]!['appName']!;
  String get playButton => _texts[language]!['playButton']!;
  String get heroesButton => _texts[language]!['heroesButton']!;
  String get languageButton => _texts[language]!['languageButton']!;

  // ========== GAME UI ==========
  String get wave => _texts[language]!['wave']!;
  String get enemies => _texts[language]!['enemies']!;
  String get killed => _texts[language]!['killed']!;
  String get coins => _texts[language]!['coins']!;
  String get time => _texts[language]!['time']!;
  String get autoMode => _texts[language]!['autoMode']!;
  String get speed => _texts[language]!['speed']!;

  // ========== HEROES ==========
  String get heroAerin => _texts[language]!['heroAerin']!;
  String get heroVeyra => _texts[language]!['heroVeyra']!;
  String get heroThalor => _texts[language]!['heroThalor']!;
  String get heroMyris => _texts[language]!['heroMyris']!;
  String get heroKaelen => _texts[language]!['heroKaelen']!;
  String get heroSolenne => _texts[language]!['heroSolenne']!;
  String get heroRavik => _texts[language]!['heroRavik']!;
  String get heroBrann => _texts[language]!['heroBrann']!;
  String get heroNyxra => _texts[language]!['heroNyxra']!;
  String get heroEldrin => _texts[language]!['heroEldrin']!;

  // ========== UPGRADES ==========
  String get upgradeStats => _texts[language]!['upgradeStats']!;
  String get level => _texts[language]!['level']!;
  String get damage => _texts[language]!['damage']!;
  String get cooldown => _texts[language]!['cooldown']!;
  String get attackSpeed => _texts[language]!['attackSpeed']!;
  String get range => _texts[language]!['range']!;
  String get cancel => _texts[language]!['cancel']!;
  String get reset => _texts[language]!['reset']!;
  String get resetConfirm => _texts[language]!['resetConfirm']!;
  String get notEnoughCoins => _texts[language]!['notEnoughCoins']!;
  String get unlockCost => _texts[language]!['unlockCost']!;
  String get upgradeCost => _texts[language]!['upgradeCost']!;

  // ========== MODES ==========
  String get modeNormal => _texts[language]!['modeNormal']!;
  String get modeFast => _texts[language]!['modeFast']!;
  String get modeStrong => _texts[language]!['modeStrong']!;
  String get modeRapid => _texts[language]!['modeRapid']!;
  String get modeExplosive => _texts[language]!['modeExplosive']!;
  String get modeLightning => _texts[language]!['modeLightning']!;
  String get modeSword => _texts[language]!['modeSword']!;
  String get modeProjectile => _texts[language]!['modeProjectile']!;
  String get modeEnergy => _texts[language]!['modeEnergy']!;
  String get modeIce => _texts[language]!['modeIce']!;
  String get modeFreeze => _texts[language]!['modeFreeze']!;
  String get modeVine => _texts[language]!['modeVine']!;
  String get modeSpore => _texts[language]!['modeSpore']!;
  String get modeSunburst => _texts[language]!['modeSunburst']!;
  String get modeRadiant => _texts[language]!['modeRadiant']!;
  String get modeVoidburst => _texts[language]!['modeVoidburst']!;
  String get modeSoul => _texts[language]!['modeSoul']!;
  String get modeQuake => _texts[language]!['modeQuake']!;
  String get modeBoulder => _texts[language]!['modeBoulder']!;
  String get modeLightningBolt => _texts[language]!['modeLightningBolt']!;
  String get modeVoidChain => _texts[language]!['modeVoidChain']!;
  String get modeCosmic => _texts[language]!['modeCosmic']!;
  String get modeNova => _texts[language]!['modeNova']!;

  // ========== GAME OVER ==========
  String get gameOver => _texts[language]!['gameOver']!;
  String get gameOverWallDestroyed => _texts[language]!['gameOverWallDestroyed']!;
  String get finalScore => _texts[language]!['finalScore']!;
  String get wavesCompleted => _texts[language]!['wavesCompleted']!;
  String get totalEnemiesKilled => _texts[language]!['totalEnemiesKilled']!;
  String get coinsEarned => _texts[language]!['coinsEarned']!;
  String get playAgain => _texts[language]!['playAgain']!;
  String get backToMenu => _texts[language]!['backToMenu']!;

  // Translations data
  static final Map<AppLanguage, Map<String, String>> _texts = {
    AppLanguage.cs: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Hrát',
      'heroesButton': 'Hrdinové',
      'languageButton': 'Jazyk',
      // Game UI
      'wave': 'Vlna',
      'enemies': 'Nepřátelé',
      'killed': 'Zabito',
      'coins': 'Mince',
      'time': 'Čas',
      'autoMode': 'Auto',
      'speed': 'Rychlost',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Vlastnosti',
      'level': 'ÚROVEŇ',
      'damage': 'Poškození',
      'cooldown': 'Doba nabíjení',
      'attackSpeed': 'Rychlost útoku',
      'range': 'Dosah',
      'cancel': 'Zrušit',
      'reset': 'Resetovat',
      'resetConfirm': 'Opravdu resetovat hrdinu?',
      'notEnoughCoins': 'Nedostatek mincí',
      'unlockCost': 'Odemknout za',
      'upgradeCost': 'Upgrade za',
      // Modes
      'modeNormal': 'Normální',
      'modeFast': 'Rychlý',
      'modeStrong': 'Silný',
      'modeRapid': 'Rychlá palba',
      'modeExplosive': 'Výbušný',
      'modeLightning': 'Blesk',
      'modeSword': 'Meč',
      'modeProjectile': 'Projektil',
      'modeEnergy': 'Energie',
      'modeIce': 'Led',
      'modeFreeze': 'Zamrznutí',
      'modeVine': 'Réva',
      'modeSpore': 'Spóry',
      'modeSunburst': 'Sluneční záblesk',
      'modeRadiant': 'Zářivý',
      'modeVoidburst': 'Prázdnota',
      'modeSoul': 'Duše',
      'modeQuake': 'Zemětřesení',
      'modeBoulder': 'Kámen',
      'modeLightningBolt': 'Blesk',
      'modeVoidChain': 'Řetěz prázdnoty',
      'modeCosmic': 'Kosmický',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Konec hry',
      'gameOverWallDestroyed': 'Zeď byla zničena!',
      'finalScore': 'Finální skóre',
      'wavesCompleted': 'Dokončené vlny',
      'totalEnemiesKilled': 'Celkem zabito nepřátel',
      'coinsEarned': 'Získané mince',
      'playAgain': 'Hrát znovu',
      'backToMenu': 'Zpět do menu',
    },
    AppLanguage.sk: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Hrať',
      'heroesButton': 'Hrdinovia',
      'languageButton': 'Jazyk',
      // Game UI
      'wave': 'Vlna',
      'enemies': 'Nepriatelia',
      'killed': 'Zabitých',
      'coins': 'Mince',
      'time': 'Čas',
      'autoMode': 'Auto',
      'speed': 'Rýchlosť',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Vlastnosti',
      'level': 'ÚROVEŇ',
      'damage': 'Poškodenie',
      'cooldown': 'Doba nabíjania',
      'attackSpeed': 'Rýchlosť útoku',
      'range': 'Dosah',
      'cancel': 'Zrušiť',
      'reset': 'Resetovať',
      'resetConfirm': 'Naozaj resetovať hrdinu?',
      'notEnoughCoins': 'Nedostatok mincí',
      'unlockCost': 'Odomknúť za',
      'upgradeCost': 'Upgrade za',
      // Modes
      'modeNormal': 'Normálny',
      'modeFast': 'Rýchly',
      'modeStrong': 'Silný',
      'modeRapid': 'Rýchla paľba',
      'modeExplosive': 'Výbušný',
      'modeLightning': 'Blesk',
      'modeSword': 'Meč',
      'modeProjectile': 'Projektil',
      'modeEnergy': 'Energia',
      'modeIce': 'Ľad',
      'modeFreeze': 'Zamrznutie',
      'modeVine': 'Réva',
      'modeSpore': 'Spóry',
      'modeSunburst': 'Slnečný záblesk',
      'modeRadiant': 'Ziariavý',
      'modeVoidburst': 'Prázdnota',
      'modeSoul': 'Duša',
      'modeQuake': 'Zemetrasenie',
      'modeBoulder': 'Kameň',
      'modeLightningBolt': 'Blesk',
      'modeVoidChain': 'Reťaz prázdnoty',
      'modeCosmic': 'Kozmický',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Koniec hry',
      'gameOverWallDestroyed': 'Stena bola zničená!',
      'finalScore': 'Finálne skóre',
      'wavesCompleted': 'Dokončené vlny',
      'totalEnemiesKilled': 'Celkom zabitých nepriateľov',
      'coinsEarned': 'Získané mince',
      'playAgain': 'Hrať znova',
      'backToMenu': 'Späť do menu',
    },
    AppLanguage.hu: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Játék',
      'heroesButton': 'Hősök',
      'languageButton': 'Nyelv',
      // Game UI
      'wave': 'Hullám',
      'enemies': 'Ellenségek',
      'killed': 'Megölt',
      'coins': 'Érmék',
      'time': 'Idő',
      'autoMode': 'Auto',
      'speed': 'Sebesség',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Tulajdonságok',
      'level': 'SZINT',
      'damage': 'Sebzés',
      'cooldown': 'Visszatöltési idő',
      'attackSpeed': 'Támadási sebesség',
      'range': 'Hatótáv',
      'cancel': 'Mégse',
      'reset': 'Visszaállítás',
      'resetConfirm': 'Biztosan visszaállítod a hőst?',
      'notEnoughCoins': 'Nincs elég érme',
      'unlockCost': 'Feloldásért',
      'upgradeCost': 'Fejlesztésért',
      // Modes
      'modeNormal': 'Normál',
      'modeFast': 'Gyors',
      'modeStrong': 'Erős',
      'modeRapid': 'Gyors tűz',
      'modeExplosive': 'Robbanó',
      'modeLightning': 'Villám',
      'modeSword': 'Kard',
      'modeProjectile': 'Lövedék',
      'modeEnergy': 'Energia',
      'modeIce': 'Jég',
      'modeFreeze': 'Fagyasztás',
      'modeVine': 'Inda',
      'modeSpore': 'Spóra',
      'modeSunburst': 'Napfény',
      'modeRadiant': 'Fény',
      'modeVoidburst': 'Üresség',
      'modeSoul': 'Lélek',
      'modeQuake': 'Földrengés',
      'modeBoulder': 'Kő',
      'modeLightningBolt': 'Villám',
      'modeVoidChain': 'Üresség lánc',
      'modeCosmic': 'Kozmikus',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Játék vége',
      'gameOverWallDestroyed': 'A fal megsemmisült!',
      'finalScore': 'Végső pontszám',
      'wavesCompleted': 'Befejezett hullámok',
      'totalEnemiesKilled': 'Összes megölt ellenség',
      'coinsEarned': 'Szerzett érmék',
      'playAgain': 'Újra',
      'backToMenu': 'Vissza a menübe',
    },
    AppLanguage.en: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Play',
      'heroesButton': 'Heroes',
      'languageButton': 'Language',
      // Game UI
      'wave': 'Wave',
      'enemies': 'Enemies',
      'killed': 'Killed',
      'coins': 'Coins',
      'time': 'Time',
      'autoMode': 'Auto',
      'speed': 'Speed',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Stats',
      'level': 'LEVEL',
      'damage': 'Damage',
      'cooldown': 'Cooldown',
      'attackSpeed': 'Attack Speed',
      'range': 'Range',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'resetConfirm': 'Are you sure you want to reset this hero?',
      'notEnoughCoins': 'Not enough coins',
      'unlockCost': 'Unlock for',
      'upgradeCost': 'Upgrade for',
      // Modes
      'modeNormal': 'Normal',
      'modeFast': 'Fast',
      'modeStrong': 'Strong',
      'modeRapid': 'Rapid Fire',
      'modeExplosive': 'Explosive',
      'modeLightning': 'Lightning',
      'modeSword': 'Sword',
      'modeProjectile': 'Projectile',
      'modeEnergy': 'Energy',
      'modeIce': 'Ice',
      'modeFreeze': 'Freeze',
      'modeVine': 'Vine',
      'modeSpore': 'Spore',
      'modeSunburst': 'Sunburst',
      'modeRadiant': 'Radiant',
      'modeVoidburst': 'Voidburst',
      'modeSoul': 'Soul',
      'modeQuake': 'Quake',
      'modeBoulder': 'Boulder',
      'modeLightningBolt': 'Lightning Bolt',
      'modeVoidChain': 'Void Chain',
      'modeCosmic': 'Cosmic',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Game Over',
      'gameOverWallDestroyed': 'The wall has been destroyed!',
      'finalScore': 'Final Score',
      'wavesCompleted': 'Waves Completed',
      'totalEnemiesKilled': 'Total Enemies Killed',
      'coinsEarned': 'Coins Earned',
      'playAgain': 'Play Again',
      'backToMenu': 'Back to Menu',
    },
    AppLanguage.de: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Spielen',
      'heroesButton': 'Helden',
      'languageButton': 'Sprache',
      // Game UI
      'wave': 'Welle',
      'enemies': 'Feinde',
      'killed': 'Getötet',
      'coins': 'Münzen',
      'time': 'Zeit',
      'autoMode': 'Auto',
      'speed': 'Geschwindigkeit',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Statistiken',
      'level': 'STUFE',
      'damage': 'Schaden',
      'cooldown': 'Abklingzeit',
      'attackSpeed': 'Angriffsgeschwindigkeit',
      'range': 'Reichweite',
      'cancel': 'Abbrechen',
      'reset': 'Zurücksetzen',
      'resetConfirm': 'Möchten Sie diesen Helden wirklich zurücksetzen?',
      'notEnoughCoins': 'Nicht genug Münzen',
      'unlockCost': 'Freischalten für',
      'upgradeCost': 'Verbessern für',
      // Modes
      'modeNormal': 'Normal',
      'modeFast': 'Schnell',
      'modeStrong': 'Stark',
      'modeRapid': 'Schnellfeuer',
      'modeExplosive': 'Explosiv',
      'modeLightning': 'Blitz',
      'modeSword': 'Schwert',
      'modeProjectile': 'Projektil',
      'modeEnergy': 'Energie',
      'modeIce': 'Eis',
      'modeFreeze': 'Einfrieren',
      'modeVine': 'Rebe',
      'modeSpore': 'Sporen',
      'modeSunburst': 'Sonnenstrahl',
      'modeRadiant': 'Strahlend',
      'modeVoidburst': 'Leerenstoß',
      'modeSoul': 'Seele',
      'modeQuake': 'Erdbeben',
      'modeBoulder': 'Fels',
      'modeLightningBolt': 'Blitz',
      'modeVoidChain': 'Leerenkette',
      'modeCosmic': 'Kosmisch',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Spiel vorbei',
      'gameOverWallDestroyed': 'Die Mauer wurde zerstört!',
      'finalScore': 'Endpunktzahl',
      'wavesCompleted': 'Abgeschlossene Wellen',
      'totalEnemiesKilled': 'Insgesamt getötete Feinde',
      'coinsEarned': 'Verdiente Münzen',
      'playAgain': 'Erneut spielen',
      'backToMenu': 'Zurück zum Menü',
    },
    AppLanguage.fr: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Jouer',
      'heroesButton': 'Héros',
      'languageButton': 'Langue',
      // Game UI
      'wave': 'Vague',
      'enemies': 'Ennemis',
      'killed': 'Tués',
      'coins': 'Pièces',
      'time': 'Temps',
      'autoMode': 'Auto',
      'speed': 'Vitesse',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Statistiques',
      'level': 'NIVEAU',
      'damage': 'Dégâts',
      'cooldown': 'Temps de recharge',
      'attackSpeed': 'Vitesse d\'attaque',
      'range': 'Portée',
      'cancel': 'Annuler',
      'reset': 'Réinitialiser',
      'resetConfirm': 'Êtes-vous sûr de vouloir réinitialiser ce héros?',
      'notEnoughCoins': 'Pas assez de pièces',
      'unlockCost': 'Débloquer pour',
      'upgradeCost': 'Améliorer pour',
      // Modes
      'modeNormal': 'Normal',
      'modeFast': 'Rapide',
      'modeStrong': 'Fort',
      'modeRapid': 'Tir rapide',
      'modeExplosive': 'Explosif',
      'modeLightning': 'Foudre',
      'modeSword': 'Épée',
      'modeProjectile': 'Projectile',
      'modeEnergy': 'Énergie',
      'modeIce': 'Glace',
      'modeFreeze': 'Gel',
      'modeVine': 'Liane',
      'modeSpore': 'Spore',
      'modeSunburst': 'Éclair solaire',
      'modeRadiant': 'Rayonnant',
      'modeVoidburst': 'Explosion vide',
      'modeSoul': 'Âme',
      'modeQuake': 'Tremblement',
      'modeBoulder': 'Rocher',
      'modeLightningBolt': 'Foudre',
      'modeVoidChain': 'Chaîne du vide',
      'modeCosmic': 'Cosmique',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Partie terminée',
      'gameOverWallDestroyed': 'Le mur a été détruit!',
      'finalScore': 'Score final',
      'wavesCompleted': 'Vagues complétées',
      'totalEnemiesKilled': 'Total ennemis tués',
      'coinsEarned': 'Pièces gagnées',
      'playAgain': 'Rejouer',
      'backToMenu': 'Retour au menu',
    },
    AppLanguage.es: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Jugar',
      'heroesButton': 'Héroes',
      'languageButton': 'Idioma',
      // Game UI
      'wave': 'Ola',
      'enemies': 'Enemigos',
      'killed': 'Eliminados',
      'coins': 'Monedas',
      'time': 'Tiempo',
      'autoMode': 'Auto',
      'speed': 'Velocidad',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Estadísticas',
      'level': 'NIVEL',
      'damage': 'Daño',
      'cooldown': 'Tiempo de reutilización',
      'attackSpeed': 'Velocidad de ataque',
      'range': 'Alcance',
      'cancel': 'Cancelar',
      'reset': 'Reiniciar',
      'resetConfirm': '¿Estás seguro de que quieres reiniciar este héroe?',
      'notEnoughCoins': 'No hay suficientes monedas',
      'unlockCost': 'Desbloquear por',
      'upgradeCost': 'Mejorar por',
      // Modes
      'modeNormal': 'Normal',
      'modeFast': 'Rápido',
      'modeStrong': 'Fuerte',
      'modeRapid': 'Fuego rápido',
      'modeExplosive': 'Explosivo',
      'modeLightning': 'Rayo',
      'modeSword': 'Espada',
      'modeProjectile': 'Proyectil',
      'modeEnergy': 'Energía',
      'modeIce': 'Hielo',
      'modeFreeze': 'Congelación',
      'modeVine': 'Liana',
      'modeSpore': 'Espora',
      'modeSunburst': 'Ráfaga solar',
      'modeRadiant': 'Radiante',
      'modeVoidburst': 'Explosión vacía',
      'modeSoul': 'Alma',
      'modeQuake': 'Terremoto',
      'modeBoulder': 'Roca',
      'modeLightningBolt': 'Rayo',
      'modeVoidChain': 'Cadena vacía',
      'modeCosmic': 'Cósmico',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Juego terminado',
      'gameOverWallDestroyed': '¡El muro ha sido destruido!',
      'finalScore': 'Puntuación final',
      'wavesCompleted': 'Olas completadas',
      'totalEnemiesKilled': 'Total enemigos eliminados',
      'coinsEarned': 'Monedas ganadas',
      'playAgain': 'Jugar de nuevo',
      'backToMenu': 'Volver al menú',
    },
    AppLanguage.pt: {
      // Main Menu
      'appName': 'Dark Crystals',
      'playButton': 'Jogar',
      'heroesButton': 'Heróis',
      'languageButton': 'Idioma',
      // Game UI
      'wave': 'Onda',
      'enemies': 'Inimigos',
      'killed': 'Mortos',
      'coins': 'Moedas',
      'time': 'Tempo',
      'autoMode': 'Auto',
      'speed': 'Velocidade',
      // Heroes
      'heroAerin': 'Aerin',
      'heroVeyra': 'Veyra',
      'heroThalor': 'Thalor',
      'heroMyris': 'Myris',
      'heroKaelen': 'Kaelen',
      'heroSolenne': 'Solenne',
      'heroRavik': 'Ravik',
      'heroBrann': 'Brann',
      'heroNyxra': 'Nyxra',
      'heroEldrin': 'Eldrin',
      // Upgrades
      'upgradeStats': 'Estatísticas',
      'level': 'NÍVEL',
      'damage': 'Dano',
      'cooldown': 'Tempo de recarga',
      'attackSpeed': 'Velocidade de ataque',
      'range': 'Alcance',
      'cancel': 'Cancelar',
      'reset': 'Reiniciar',
      'resetConfirm': 'Tem certeza de que deseja reiniciar este herói?',
      'notEnoughCoins': 'Moedas insuficientes',
      'unlockCost': 'Desbloquear por',
      'upgradeCost': 'Melhorar por',
      // Modes
      'modeNormal': 'Normal',
      'modeFast': 'Rápido',
      'modeStrong': 'Forte',
      'modeRapid': 'Fogo rápido',
      'modeExplosive': 'Explosivo',
      'modeLightning': 'Raio',
      'modeSword': 'Espada',
      'modeProjectile': 'Projétil',
      'modeEnergy': 'Energia',
      'modeIce': 'Gelo',
      'modeFreeze': 'Congelamento',
      'modeVine': 'Liana',
      'modeSpore': 'Esporos',
      'modeSunburst': 'Rajada solar',
      'modeRadiant': 'Radiante',
      'modeVoidburst': 'Explosão vazia',
      'modeSoul': 'Alma',
      'modeQuake': 'Terremoto',
      'modeBoulder': 'Rocha',
      'modeLightningBolt': 'Raio',
      'modeVoidChain': 'Cadeia vazia',
      'modeCosmic': 'Cósmico',
      'modeNova': 'Nova',
      // Game Over
      'gameOver': 'Fim de jogo',
      'gameOverWallDestroyed': 'A parede foi destruída!',
      'finalScore': 'Pontuação final',
      'wavesCompleted': 'Ondas completadas',
      'totalEnemiesKilled': 'Total de inimigos mortos',
      'coinsEarned': 'Moedas ganhas',
      'playAgain': 'Jogar novamente',
      'backToMenu': 'Voltar ao menu',
    },
  };
}

// Localization delegates
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.values.any((lang) => _languageToString(lang) == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLanguage language = _languageFromLocale(locale);
    return AppLocalizations(language);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  AppLanguage _languageFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'cs':
        return AppLanguage.cs;
      case 'sk':
        return AppLanguage.sk;
      case 'hu':
        return AppLanguage.hu;
      case 'de':
        return AppLanguage.de;
      case 'fr':
        return AppLanguage.fr;
      case 'es':
        return AppLanguage.es;
      case 'pt':
        return AppLanguage.pt;
      case 'en':
      default:
        return AppLanguage.en;
    }
  }

  String _languageToString(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.cs:
        return 'cs';
      case AppLanguage.sk:
        return 'sk';
      case AppLanguage.hu:
        return 'hu';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.de:
        return 'de';
      case AppLanguage.fr:
        return 'fr';
      case AppLanguage.es:
        return 'es';
      case AppLanguage.pt:
        return 'pt';
    }
  }
}
