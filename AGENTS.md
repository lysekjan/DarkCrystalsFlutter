# AGENTS.md

## Working Rules For This Project

- Communicate with the user in Czech.
- At the start of each new iteration, read `project_info.txt`. If the file is renamed, read the current `project_info` file instead.
- For every task in this project, think the work through carefully, make a clear plan of what needs to be done, and ask the user about any unclear requirements or details before implementation.
- After every code or asset change in this project, update this `AGENTS.md` file so the project context stays current.
- Keep `project_info.txt` aligned with gameplay and code changes when relevant gameplay behavior changes.
- Do not run long Flutter/Dart verification commands in this project. In particular, do not run `dart`, `flutter analyze`, `flutter run`, `flutter build`, or similar commands. If verification is needed, tell the user exactly which command to run manually.
- Keep gameplay notes here aligned with the real implementation in `lib/main.dart`.
- When hero abilities or hero names change, update `INFO.txt`.
- In this project, when the user says "sprite hrdiny", treat it as the in-game moving unit on the map, not the portrait used on cards or in menus.

## Project Summary

- Project: `Dark Crystals`
- Type: Flutter arcade / lane-defense game with a custom game loop and `CustomPainter` rendering.
- Main flow: intro screen -> hero selection -> chapter selection -> level selection -> game scene.
- Core gameplay logic is concentrated mainly in `lib/main.dart`.

## Current Gameplay Model

- 2026-10-22: Nepratele detekuji nejblizsiho ziveho hrdinu/sberace v kruhu 500 (vsechny smery), kontrola po 0.2-0.4 herni sekundy. Cil drzi do smrti nebo vzdalenosti nad 650; pak znovu hledaji nebo pokracuji ke stabilnimu bodu palisady. Palisada pri kontaktu zustava prioritou. Cil navigace za prekazkami se obnovuje po 0.4-0.6 s s fazi podle nepritele; volna prima cesta reaguje ihned. Nahrazuje starsi vyber cilu pouze vlevo bez omezeni dosahu. FPS zatim nemereno.

- 2026-10-22: Nepruchozi pudorysy podle obrazku: kazda budova (pevna i postavena vez, bleskova vez, portal, zlaty dul) i jezirko many blokuje presne spodni polovinu sveho vykresleneho obdelniku (`_blockingHalf`: plna sirka, od stredu obrazku dolu, bez odstupu); horni polovina je pruchozi, takze jednotky mohou jit "za" budovou. Stromy blokuji spodni polovinu jen v prostrednich 50 % sirky (kmen, koreny, kameny), koruna a okraje jsou pruchozi. Stromy a jezirka se nove kresli primo v `_GamePainter` (`groundSprites` z `_economySceneSprites()`, serazene podle spodni hrany) pod neprateli, sberaci i hrdiny; puvodni widgety stromu a jezirek odstraneny. Nad vsemi jednotkami je vrstva `_OcclusionPainter`: pro kazdou budovu/strom/jezirko (`_occluderSprites()`, tridy `_SceneSprite`) znovu nakresli jeji obrazek s opacity 0.7 orezany na obdelniky jednotek, jejichz pozice (stred) je nad stredem obrazku (`baseline`) a ktere obrazek prekryvaji; jednotky pred budovou se z orezu odecitaji. Jednotka za budovou je tak videt jen asi z 30 %. Sberaci tezi drevo, zlato a manu z predni strany zdroje (`_miningSpotFor`: 6 px pod spodni hranou obrazku), kamen beze zmeny.

- 2026-10-22: Dosah vsech utoku hrdinu zvetsen o 300 % (4x): standard 1066.67, Thalor mec 560, Myris freeze 800, Kaelen vine 400, Solenne sunburst/radiant 160/360, Brann earthquake 320, Eldrin nova 400. Zasahy, efekty kolem hrdinu, AI a kruhy dosahu sdileji nove hodnoty. Dosah leceni a polomer vybuchu projektilu se nemeni.

- 2026-10-22: Rumble kapitola 1 / level 1 preskakuje vyber hrdinu a vynucuje jedineho Aerin. Nema pocatecni sberace, nakup sberacu, jejich HUD kartu ani portal (vcetne kolize). Plan nepratel zustava puvodni: 30 vln, pocty 1, 3, 5... po 30 sekundach. Druhy level zustava sberacskym tutorialem.

- 2026-10-22: Tutorial je pouze Rumble, kapitola 1 / level 2: bez hrdinu, jeden pocatecni sberac u portalu, 10 vln po 4 nepratelich se zacatky po 30 hernich sekundach (prvni ihned). Nakup i ostatni mechaniky zustavaji. Rumble vybira nejdrive kapitolu a level; tutorial preskoci vyber hrdinu, ostatni levely jej oteviraji pred hrou. Prvni level ma puvodni herni pravidla.

- 2026-10-22: Optimalizace navigace a rozestupu: `_navigation` kontroluje jen stav/type stavebnich mist a znovu nevytvari seznam vsech stromu pro kazdou jednotku. `BuildingNavigation` indexuje prekazky do bunek 256 a pres Expando uklada trasy jednotlivych jednotek (i nedostupny nezmeneny cil). Zmena cile, blokovana dalsi usecka nebo nova geometrie vyvola nove hledani. Rozestupy testuji obsazenost jednotkami pred budovami. Bez zmen rychlosti, dosahu a limitu poctu jednotek; vykon na zarizeni zatim nemeren.

- 2026-10-22: Vsechny tri varianty stromu zvetseny o 300 % (4x): 416x440, 416x472 a 440x436. Sdileny rozestup zvetsen z 80 na 320; klikaci plochy a nepruchozi kmeny se odvozuji od novych rozmeru. Generovani zohlednuje i stromy vyssi nez mapa Gathering; na mensi mape se muze vejit mene stromu. Animace a tezba se nemeni.

- 2026-10-22: Budovy na bojove mape opet zvetseny 2x: portal 640x640 (stred zachovan), zlaty dul 600x544, strazne veze 352x544, bleskove veze 160x160. Pudy, hitboxy a ukazatele odvozuji rozmery ze stejnych konstant; rezervace stavebnich mist zvetsena. Menu a spawn u portalu zustavaji uvnitr mapy. Na nizke mape Gathering mohou vysoke modely presahovat hranice mapy; generovani dulu pocita i s vyskou modelu vetsi nez mapa. Stromy, jezirka many a jednotky se nemeni.

- 2026-10-21: Spolecne rozestupy vsech zivych jednotek vcetne smisenych dvojic (hrdina/sberac/nepritel). Prostorova mrizka v `lib/unit_spacing.dart` hleda nejblizsi volne misto s mezerou 6; polomery hrdina 96, sberac 104, nepritel 54. Korekce respektuji pudorysy budov a neprochazeji skrz ne. Nahradilo puvodni mekke rozestupy pouze nepratel; mrtvoly se neblokuji. Melee kontakt nepritel-hrdina je 160, nepritel-sberac 168, aby boj fungoval i s vetsimi modely. Rozestupy se kontroluji po pohybu v Gathering i Rumble a ostatnich bojich, pri startu a nakupu sberace.

- 2026-10-21: Portal, zlaty dul, pevna vez i objednane/postavene veze maji nepruchozi obdelnikovy pudorys u spodni casti modelu (80 % sirky, 45 % vysky, stred +20 % vysky, odstup 14). Spolecna navigace v `lib/building_navigation.dart` vede hrdiny, nepratele i sberace kolem rohu; cile uvnitr budov presouva k okraji. Tezba a stavba zacinaji az po prichodu, rozestupovani nepratel nesmi tlacit skrz budovu. Pri vzniku prekazky se jednotky uvnitr vysunou ven. Portal a dul jsou nove kresleny v GamePainter pred neprateli, sberaci a hrdiny; portal si ponechava neviditelnou klikaci vrstvu a menu.

- 2026-10-21: Herni modely zvetseny 2x oproti dosavadni velikosti: hrdinove render 192, sberaci 208, nepratele vcetne fallbacku a smrti 2x, strazne veze 176x272, bleskove 80x80, portal 320x320 se zachovanym stredem, dul 300x272. HP a kontextova menu zohlednuji vetsi modely. Herni velikosti jednotek pro boj, rychlosti a dosahy se nemeni; rozmery map ani portrety v HUD se nemeni.

- 2026-10-20: Gathering i Rumble maji pevny portal napravo od palisady (box x=240, y=120, 160x160). Pouziva `assets/buildings/portal_sheet.png`, 24 snimku v mrizce 6x4 (569x555), smycka 12 fps. Klik otevre menu s ikonou Spirit a nakupem sberace za 20 zlata; bez penez je volba neaktivni. Puvodni nakupni tlacitka v horni liste odstranena. Vsichni sberaci vznikaji vedle portalu pri startu, nakupu i restartu. Nahodne suroviny se vyhybaji portalu. Odevzdavani surovin nadale probiha u palisady.

- 2026-10-20: Rumble ma mapu 6400x3200 (oba rozmery +300 %, 4x). Kamera zachovava puvodni meritko podle 1600x800 a mapu lze prochazet posunem. Velikosti, rychlosti a dosahy jednotek/vezi zustavaji stejne. Nepratele vznikaji na novem pravem okraji, nahodne suroviny a relativni stavebni mista pouzivaji celou mapu. Startovni hrdinove, sberaci a odevzdavaci bod zustavaji v puvodni oblasti u baze, aby byli pri startu viditelni. Ostatni rezimy zustavaji 1600x400.

- 2026-10-19: Vykresleni sberacu zvetseno o 300 % (26 -> 104, 4x); HP, naklad a ramecek vyberu se umistuji podle vetsiho render boxu. Herni dosahy a hitbox zustavaji 26. Pri pohybu doleva se Spirit zrcadli, vcetne cesty za nepratelem, ke stavbe, surovine i dorucovani; pri zastaveni se vraci vychozi orientace.

- 2026-10-19: Sberaci v Gathering i Rumble pouzivaji `assets/workers/Spirit.png` (16 snimku v jednom radku). Idle a pohyb prehravaji 0-7, tezba a utok/stavba na miste 8-15, rychlosti 8 snimku/s herniho casu. Zustava HP pruh, znacka nakladu a bily vyberovy ramecek; zeleny ctverec slouzi jen jako fallback pri nenacteni assetu.

- Levelovani hrdinu je omezeno na aktualni Rumble beh: 1 XP za nepratele pripada pouze hrdinovi s poslednim zasahem; prahy jsou `10, 15, 23, 34, 51...` s prenosem XP. Level zvysuje HP i vsechny utoky o 20 % slozene (vuci zakladu) a hrdinu vyleci; level je videt na karte. Restart vraci level i XP na 1/0.

- 2026-10-12: Cena noveho sberace v Gathering i Rumble je 20 zlata (`gatheringWorkerCost`); spolecnou hodnotu pouziva tlacitko, kontrola zustatku i odecteni minci.

- Bleskova vez je druha dostupna stavba v Rumble (druhy slot, 300 zlata). Ma fialovy ctverec 40x40 a pouziva stejny `_LightningEffect` jako hrdinove: okamzity zasah jednoho nejblizsiho ziveho nepritele, bez retezeni. Zakladni poskozeni je 20 (2x strazna vez), stejny dosah a interval 5 s. Stavba i upgrade trvaji 60 hernich sekund prace sberace; upgrade stoji 100, poskozeni roste 20/60/180/... a behem upgradu nestreli. Bourani vraci 50 % skutecne investice (zaklad 150). Typ se resetuje s mistem. V prazdnem stavebnim menu jsou nyni dva dostupne a dva zamcene sloty.

- Uroven veze a pruh upgradu jsou pod dosahem ctyrslotoveho menu, aby zustaly citelne i pri otevrene nabidce. Poskozeni 10 / 5 s plati pro zakladni uroven 1; vyssi urovne maji trojnasobek poskozeni predchozi urovne.

- Menu hotove veze pouziva stejne ctyri sloty jako stavba: nahore upgrade, vpravo bourani s presnou refundaci, zbytek zamceny. Pod vezi je zobrazena uroven. Pri upgradu zustava dostupne bourani, dalsi upgrade je blokovany; klik s vybranym sberacem obnovi neobsazenou praci.

- 2026-10-09: Postavene veze v Rumble maji uroven od 1. Upgrade stoji vzdy 100 zlata a vyzaduje 60 hernich sekund prace sberace; po dokonceni prida jednu uroven a ztrojnasobi poskozeni (10/30/90/...). Behem celeho cekani a prace na upgradu vez nestrili. Plati stejny vyber volneho sberace a rucni obnoveni prerusene prace jako pri stavbe. Zbourani vraci polovinu vsech zaplacenych investic vcetne pripadneho probihajiciho upgradu do HUD i save slotu, uvolni stavitele a obnovi prazdne stavebni misto. Restart nuluje i urovne a investice. Tyka se pouze hracem postavenych vezi, ne puvodni veze u palisady.

- Stavebni menu se zavira i pri vyberu hrdinu pres karty nebo tlacitko volneho sberace; novy tezebni, pohybovy nebo utocny prikaz uvolni sberace ze stavby a zachova rozestaveny postup.

- Stavebni nabidka ma ctyri sloty kolem mista; prvni zobrazuje vez a cenu 200, ostatni jsou zamcene. Pri nedostatku minci zustava otevrena a zobrazi upozorneni. Sberac se pri stavbe zastavi vedle pudorysu veze; neseny naklad si zachovava. Automaticky se vybira nejblizsi necinny sberac pouze pri koupi, pozdejsi obsazeni prazdneho staveniste je rucni.

- 2026-10-06: Rumble ma dve pevna oranzova stavebni mista 28x28 mimo suroviny. Klik otevre ctyri sloty (strazna vez za 200 minci, tri zamcene). Po zaplaceni se jednorazove priradi volny sberac; bez nej stavba ceka na rucni prikaz vybranemu sberaci klikem na staveniste. Jeden sberac stavi 60 hernich sekund po prichodu, s ohledem na rychlost hry. Novy prikaz nebo smrt stavitele praci prerusi, postup zustava a dalsi sberac muze pokracovat bez dalsi platby. Hotova vez sdili obrazek, rozmery, dosah a strelbu puvodni veze (10 damage / 5 s). Stavby a jejich postup plati jen pro aktualni hru, restart obnovi prazdna mista; zaplacene mince se nevraceji.

- Rezim `Gathering` se otevre kliknutim na budovu `assets/buildings/atrium.png` ve vesnici; zobrazuje stejnou herni mapu s travou, palisadou a obrannou vezi, ale bez hrdinu, nepratel a spoustenych vln. Obsahuje jedno trvale nahodne umistene zlatiste (zluty box `20x20`), 5-10 hnedych stromu, 5-10 sedych kamenu, jeden trvaly fialovy fragment nahore hned vedle baze a dalsich 5-10 nahodnych fragmentu (boxy `20x20`) a syte zelene pracovniky u zdi (v Gathering 1, v Rumble na startu 2). Sberac je rucne ovladany: kliknutim se vybere (bily okraj), tahem obdelniku lze vybrat vice sberacu najednou a klik na zlato, strom nebo kamen jim zada opakovany tezebni prikaz (3 sekundy tezby, navrat k odevzdani a znovu ke stejnemu zdroji); klik na fragment jim zada tezbu 10 jednotek a v Rumble doruceni nejblizsimu zivemu hrdinovi, ktery ziska 10 bodu magicke energie. Klik na bezne misto jim zada pouze presun a klik vlevo od palisady jim zada navrat do baze. Po tezbe nese naklad se zlutou, hnedou, sedou nebo fialovou teckou; novy prikaz vzdy prerusi dosavadni cinnost a zrusi opakovani. V horni liste lze opakovane koupit dalsiho pracovnika za `20` minci.
- Rezim `Rumble` se otevre kliknutim na budovu `assets/buildings/shamanTent.png`; po vyberu hrdinu, kapitoly a levelu kombinuje obranu vesnice s Gathering ekonomikou: bezi vlastni pevny plan `30` vln, v nemz prvni vlna ma `1` nepritele a kazda dalsi o `2` vice; zacatky vln deli `30` sekund. Zaroven jsou pritomni palisada, hrdinove, sberaci, suroviny a nakup sberacu. Rumble pouziva spolecny obdelnikovy multiselect hrdinu i sberacu.
- Map size is `1600 x 400`; Rumble uses `6400 x 3200` with the original camera scale based on `1600 x 800`. The larger map is explored by panning. Terrain and palisade images stretch over the current map dimensions.
- The wall is still anchored near the left side at `x = 100`.
- Heroes can no longer move or spawn to the left of the wall; move orders are clamped so they stop just to the right of it.
- There are 5 hero slots.
- Enemies spawn on the right side in 5 lanes but can now move freely through the map.
- The enemy roster now also includes `ZombieShooter`, a ranged enemy that fires a `1` damage projectile at heroes from medium range (`180`) once per second, but still switches to the usual melee wall attack when it reaches the wall line.
- The wall has `300 HP`.
- Enemy base HP is `20`, scaled by wave.
- Selected chapter currently only gates access; selected level also multiplies enemy HP by `1.2^(level-1)`.
- Level spawn composition is now driven by per-level `LevelDef` JSON data (`waves` with timed spawn `events`).
- If a level does not yet have JSON data or a local editor override, the game falls back to a deterministic generated legacy template so existing levels remain playable.
- Completing all waves in a level now counts as defending the village: gameplay shows a victory dialog and the active save slot marks that chapter/level pair as completed.
- Enemy move speed is `16`.
- Most enemies deal `5 DPS` in melee to both wall and heroes; `ZombieShooter` is the current exception and deals `1` damage per ranged projectile to heroes while still using melee against the wall.
- Enemy touch targeting uses a tolerant tap radius.
- Game speed can be switched between `1x`, `2x`, `4x`, and `8x`.
- Default game speed is `2x`.

## Hero Cycle

- Heroes use two phases only: `sending -> cooldown`.
- The game now effectively runs in automatic attack mode all the time.
- Heroes are selectable directly on the map.
- Clicking a hero selects it.
- Dragging on empty map space now draws a square selection box and can multi-select all heroes inside it.
- Clicking a map position while a hero is selected gives that hero a move order.
- Clicking a map position while multiple heroes are selected sends the whole group there in a small spaced formation so they do not overlap, and the multi-selection is cleared immediately after issuing the order.
- Clicking a targetable enemy while one or more heroes are selected now issues a focused attack order: each selected hero moves until that specific enemy is inside that hero's own current attack range.
- While a focused attack order is active, the ordered heroes keep prioritizing only that chosen enemy until it dies.
- If the focused enemy dies during the approach, those heroes stop immediately and then continue again under their normal behavior mode.
- Focused attack orders clear the current selection immediately after the enemy click.
- During movement, the hero cannot attack.
- During movement, cooldown continues to progress normally.
- If cooldown finishes during movement, the attack is queued and starts only after the hero reaches the destination.
- If no valid enemy target exists, heroes do not spend an attack cycle.
- After cooldown reaches zero without a target, the hero waits in a ready state and starts `sending` immediately once a valid target appears.
- A hero can begin auto-attack only if at least one enemy is inside that hero's current attack range.

## Hero Mechanics

- 2026-10-20: Aerinuv attack sheet se prednacita s idle a FutureBuildery maji oddelene klice, aby se idle textura neinterpretovala jako sirsi attack snimky pri prepnuti. Utocna animace 13 snimku pri 12 fps pouziva realny cas (~1.08 s) nezavisle na rychlosti hry; bojove casovani se nemeni. Rozmery overeny: idle 316x307, attack 420x307, spolecne ukotveni podle idle.

- 2026-10-20: Aerinuv treti utok `strong` (ohniva koule) zpusobuje plne poskozeni vsem cilitelnym nepratelum v polomeru 52 od zasazeneho nepritele. Pouziva existujici AoE a ohnivy vybuch, vcetne bonusu poskozeni a zapocitavani XP.

- 2026-10-13: Klik na prave vybranou ikonu hrdiny na mape nebo na jeho karte vyber zrusi a skryje i ukazatel dostrelu. Na kartach hrdinu v Rumble je pod ikonou tenky modry pruh postupu XP nad zivotnim pruhem; zobrazuje pomer zkusenosti k prahu dalsiho levelu a v ostatnich rezimech se skryva.

- 2026-10-12: Levelovani hrdinu plati pouze v aktualnim behu Rumble a restart ho maze. Za zabiti ziska 1 XP pouze hrdina, jehoz utok zasadil posledni ranu; prahy dalsich levelu jsou zaokrouhlene 10, 15, 23, 34, 51... XP a prebytek se prenasi. Kazdy level nasobi zakladni maximum HP i vsechny typy utoku koeficientem 1.2^(level-1) a hrdinu pri postupu vyleci na maximum. Cislo levelu je na odznaku karty hrdiny bez predpony, XP a dalsi prah jsou v napovede karty. Ostatni rezimy nadale pouzivaji puvodni persistentni RPG XP.

- 2026-10-12: Zivotni pruh sberace je nad jednotkou v Gathering i Rumble a zobrazuje aktualni pomer HP k maximu 20. Tecka nesene suroviny je posunuta jeste vys, aby pruh nezakryvala.

- 2026-10-02: Pri dorucovani fragmentu sberac vybira nejblizsiho ziveho hrdinu s energii pod maximem 20. Cil se prubezne prehodnocuje i behem cesty; hrdinove s plnou energii se preskakuji. Pokud zadny vhodny prijemce neni, sberac zustane stat s nakladem a pokracuje, az bude komu energii doplnit.

- Hrdinove maji v Rumble magickou energii `0-20`, zobrazenou fialovym pruhem pod HP a cooldown pruhem. Kazdy utocny cyklus spotrebuje `1` energii; pri nule hrdina neutoci. Zasilka 10 fragmentu dorucena sberacem nejblizsimu zivemu hrdinovi doplni `10` energie. Energie se jinak neregeneruje.
- Sberaci maji `20 HP` se zivotnim pruhem nad jednotkou; v Rumble je nepratele mohou zvolit jako cil stejne jako hrdiny, vcetne projektilu ZombieShootera. Mrtvy sberac zmizi z mapy.
- Pokud necinny sberac utrpi zasah a prezije, prejde do utoku zblizka na nejblizsiho ziveho nepritele. Uder pusobi `3` zraneni jednou za herni sekundu. Klik na nepritele s vybranymi sberaci zada utok na konkretni cil (i ve smisenem vyberu s hrdiny) a zrusi vyber. Sberac cil pronasleduje do melee dosahu a po jeho smrti zustane stat; novy prikaz utok prerusi. Tezba, dorucovani ani presun se pri napadeni automaticky neprerusuji.
- Mrtvy hrdina zustava jako zesedly gameplay card; kliknutim na kartu lze za `200` minci hrdinu ozivit s plnym HP a energii na jeho startovni pozici.

- Heroes now have HP and can die.
- Current baseline hero HP is `100`, stored per hero definition as `HeroDef.maxHp`; Brann is the current exception and now starts at `500 HP`.
- Current baseline hero attack range is about one sixth of the screen width, stored per hero definition as `HeroDef.attackRange`.
- All in-game hero renders now auto-face their active horizontal action: while moving left or attacking a target to their left, their sprite/animation is mirrored; once they are idle again, they return to the default orientation.
- Dead heroes disappear from the map, stop attacking, stop being selectable, and are ignored by enemy targeting.
- Selecting a hero on the map now also shows a context mode menu next to that hero.
- The context menu uses the same attack-mode icons that were previously shown in the old slot/card UI.
- Selecting or re-clicking a hero also shows a translucent circle for that hero's current attack range.
- The attack-range circle stays fully visible for `5` seconds and then fades out smoothly.
- The same attack-range circle now also appears for all heroes selected through multi-select, sharing the same unchanged visibility/fade timing.
- Selecting a hero now also shows a second horizontal context menu above the hero for behavior selection.
- In multi-select mode, hero context menus are hidden.
- Behavior menu now actively controls hero movement AI.
- `hold position`: hero stays at the chosen spot and attacks only enemies currently inside range.
- `offensive`: hero automatically moves toward the nearest targetable enemy until that enemy enters the hero's range; if no enemies exist, the hero stands still.
- `defensive`: hero holds a guard position, attacks while enemies are in range, retreats away from enemies that get too close, and returns to the guard position once the immediate threat is gone.
- Defensive retreat now locks a single longer escape target for about 2 seconds before another retreat can be triggered, which keeps the movement smooth.
- Manual move orders work in all behavior modes; while a hero is following a player-issued move target, behavior AI temporarily stops overriding that target and resumes only after arrival.
- Aerin: projectile; modes `normal`, `fast`, `strong`.
- Veyra: projectile; modes `rapid`, `explosive`, `lightning`.
- Thalor: modes `projectile`, `sword`, `energy`.
- Myris: modes `normal`, `ice`, `freeze`.
- Myris `normal` now reuses Veyra's old third attack behavior: a single-target lightning strike with the same fast timing and high damage profile.
- Kaelen: modes `normal`, `vine`, `healing`.
- Solenne: beam during sending; modes `normal`, `sunburst`, `radiant`.
- Ravik: modes `normal`, `voidburst`, `soul`.
- Ravik `soul` now hits only a single enemy with dark lightning and heals Ravik for `2%` of his max HP on each successful hit.
- Brann: modes `normal`, `earthquake`, `boulder`.
- Brann now also has a raised baseline survivability value of `500 HP`.
- Nyxra: modes `normal`, `lightning`, `voidchain`.
- Nyxra `normal` now also reuses Veyra's old third attack behavior: a single-target lightning strike with the same fast timing and high damage profile.
- Eldrin: modes `normal`, `cosmic`, `nova`.

Detailed balance values are documented in `INFO.txt` and `project_info.txt`.

## Enemy Rendering And Animation

- 2026-10-19: Odstranen docasny `_DebugCenterMarkerPainter` i jeho overlay; cervene debug krizky se uz nezobrazuji u hrdinu ani nepratel.

- 2026-10-19: `vampire` je zapojen do registru nepratel a animaci (20 HP, rychlost 16, melee 5 DPS jako FatZombie). Pouziva Vampire.png: chuze 8-15, utok 16-24, zasah 25-26, smrt 27-32. Spawn eventy `fat_zombie` se za behu meni na nahodne zamichane skupiny peti typu s vlastnim spritem (FatZombie, Vampire, ZombieFemale, SkullMage, ZombieShooter), kazdy jednou ve skupine. Plati od prvniho levelu i v Rumble; explicitni ostatni typy v JSON/editoru zustavaji zachovane. Pocty, casovani a nasobice vln se nemeni.

- 2026-10-19: Pridan sprite sheet `assets/enemies/Vampire.png` (33 snimku 90x90 v jednom radku, rozlozeni jako `FatZombie`: idle 0-7, chuze 8-15, utok drapy 16-24, zasah 25-26, smrt 27-32; chodidla na y=48, postava hledi doprava). Vygenerovan skriptem z pixel-art predlohy upira; napojen jako typ `vampire`.
- 2026-10-19: Pridan sprite sheet ducha `assets/workers/Spirit.png` (16 snimku 90x90 v jednom radku): 0-7 pohyb (vznaseni, vlneni ocasu, jiskry), 8-15 vyroba/carovani (zarici ruce, virici zare pred drapy). Postava hledi doprava. Slozka `assets/workers/` zatim neni v `pubspec.yaml` a sheet neni napojen v kodu.
- 2026-10-20: Pridan idle sprite sheet `assets/heroes/Aerin/Aerin_idle_sheet.png` (16 snimku 316x307 v jednom radku, odvozeno z `Aerin_default.png`): postava stoji, trup se lehce pohupuje (az 2.5 px, chodidla zustavaji na miste), leve kridlo se nataci +-2.5 a prave +-1.2 stupne s mirnym zpozdenim, mec se pohupuje +-2 stupne kolem uchopu (misto pod cepeli je doplneno zrcadlenim okolni textury nohou) a nad dlani plapola pixelovy ohen s jiskrami; smycka. Napojen jako Aerinuv in-game sprite.
- 2026-10-20: Pridan utocny sheet `assets/heroes/Aerin/Aerin_attack_sheet.png` (13 snimku 420x307 v jednom radku, 12 fps, ~1.08 s): napraha, Aerin natahne ruku s plamenem dopredu (predlokti se prodlouzi a zvedne, trup se nakloni, kridla se rozevrou), pri vypadu se prikrci az o 8 px (chodidla zustavaji na miste) a ruka s mecem se stahne dozadu (-12 px, cepel -8 stupnu), plamen v okamziku vypadu z dlane zmizi (vlastni ohniva koule ve sheetu neni, let zobrazuje jen herni projektil) a behem navratu ruky v dlani znovu naroste. Hrdina je ve snimku na stejnem miste jako v idle (316x307), extra sirka vpravo je rezerva pro natazenou ruku (obsah sahá do x~320). Prehrava se pri kazdem `_performAttack` Aerina (`_heroAttackAnimationRemainingTimes`, `_buildAerinAnimatedFrame`), potom se vraci idle. `_SpriteFramePainter` ma volitelne `layoutFrameWidth/Height`, aby sirsi snimek drzel meritko a polohu idle a pretekal doprava (pri zrcadleni doleva). `ClipRRect` v `_HeroUnitWidget` ted u pruhlednych spritu neorezava (`Clip.none`).
- 2026-10-20: Pridan sheet chuze `assets/heroes/Aerin/Aerin_walk_sheet.png` (12 snimku 316x307 v jednom radku, 12 fps, 2 kroky za cyklus): nohy se stridave vykyvuji od kycle o +-16 px u chodidla, svihova noha se zveda az o 11 px, trup se pohupuje az o 5 px (nejvys pri miju nohou) a pri kazdem kroku se kolebave predklani (predklon 1.2-4.8 px), mec se kyva s krokem o +-4.5 stupne a kridla mavaji jednou za krok; ohen v dlani plapola dal. Prehrava se v `_buildAerinWalkFrame`, kdyz `isMoving` a nebezi utok (priorita utok > chuze > idle); sheet se prednacita spolu s idle. Ukotveni i rozmer snimku jsou stejne jako u idle.

- Enemies now use sprite rendering from `assets/enemies/FatZombie.png`.
- The sprite sheet is split into `33` frames of `90x90`.
- Enemy sprites are mirrored horizontally during draw.
- Walk animation uses frames `8..15`.
- Attack animation uses frames `16..24`.
- `ZombieShooter` now uses `assets/enemies/ZombieShooter.png` with walk frames `7..15`, attack frames `16..21`, hit-reaction frames `22..26`, and the last `5` frames for death.
- `ZombieShooter` projectiles now use `assets/enemies/Projectile_zombie_shooter.png`; flight plays the first `4` frames in a loop and impact plays the last `4` frames once on the struck hero before the projectile effect disappears.
- If the sprite sheet fails to load, the old painted enemy fallback remains available.

## Enemy Death Behavior

- Enemies are not removed immediately at `hp <= 0`.
- On death, they enter a non-targetable dying state.
- Death animation plays once using the last 6 frames of the sprite sheet.
- After that, the final death frame remains visible for `5` seconds.
- During those 5 seconds, the corpse fades out smoothly.
- Dying enemies do not move, do not damage the wall, and are excluded from targeting / chaining / projectile collision logic.

## Camera / Map Interaction

- 2026-10-20: Rumble umoznuje pet dalsich kroku oddaleni pod vychozi zoom: 0.85, 0.70, 0.55, 0.40, 0.25. Tlacitka i kolecko pouzivaji stejny krok, pinch respektuje minimum 0.25. Start/restart zustava na 1.0, maximum 2.5 a ostatni rezimy beze zmeny. Pri minimu ma zvetsena mapa stejny zaber jako puvodni mapa pred zvetsenim.

- 2026-10-02: Vlevo pred kartami hrdinu je v Rumble spolecna karta sberacu s poctem volnych / vsech zivych sberacu; v Gathering je samostatne na stejnem miste. Bez volnych sberacu je seda a neaktivni. Klik vybira prave jednoho ziveho necineho sberace a rusi predchozi vyber. Volny znamena idle bez pohybu a tezby; ostatni prikazy se nepocitaji. Hitboxy karet hrdinu jsou posunute o novou kartu pro zachovani klikani a multiselectu.

- The map uses a cover-style default fit under the top HUD, aligned to top-left, and can crop on the right side on narrower displays.
- Zoom `+` and `-` buttons are present on screen.
- Manual zoom is handled through `TransformationController`.
- Touch map panning is now driven by a permanently visible square joystick in the bottom-left HUD area; dragging inside that joystick moves the camera continuously in the opposite visual map direction (camera up means the rendered map moves down).
- Two-finger touch panning is no longer used for camera movement.
- Pinch zoom on touch remains available, but it now adjusts zoom without also translating the camera from finger-centroid drift.
- Input positions are converted with `TransformationController.toScene(...)` where needed so manual targeting stays accurate.
- For map taps inside the zoomed gameplay view, pointer coordinates must be converted from the `InteractiveViewer` viewport (`globalToLocal`) before calling `TransformationController.toScene(...)`; using the transformed child `localPosition` directly causes offset targets.
- The old left hero card panel and the automode switch are removed from gameplay UI.
- A compact hero-card strip is now shown in the bottom-right gameplay HUD next to the speed panel.
- Each gameplay hero card shows the hero portrait used in hero selection and a small HP bar.
- Clicking a gameplay hero card selects that hero exactly like clicking the hero unit on the map.
- Dragging from a living gameplay hero card now also supports rectangle multi-select directly inside the bottom-right card strip; dead hero cards are ignored by that card-panel selection.
- When a hero dies, that hero's gameplay card remains visible but becomes greyed out.
- Nyxra now uses `assets/heroes/Nyxra/Nyxra.png` only for her in-game unit render; her gameplay/menu portrait remains `assets/heroes/hero_nyxra.png`.

## Enemy Targeting Behavior

- 2026-10-02: Nepratele se spawnuji v rozptylu kolem sve linie a tesne za pravym okrajem; z az 16 kandidatu se vybira volne misto. Prichody ve stejne linii maji minimalni nahodny rozestup 0.15-0.35 herni sekundy, delsi JSON pauzy zustavaji zachovane. Pocty i statistiky nepratel se nemeni a Rumble zachovava zacatky vln po 30 sekundach.
- Zivi nepratele se prubezne mekce rozestupuji na vzdalenost 36 jednotek, posun je omezen na 24 jednotek/s a sousede se hledaji v prostorove mrizce. U palisady se rozestupuji pouze svisle a neztraceji kontakt se zdi. K hrdinum i sberacum smeruji na individualni stabilni bod v pravem oblouku uvnitr sveho dosahu (vcetne strelcu); damage se stale kontroluje podle skutecne vzdalenosti k cili. Animace kazdeho nepritele zacina s nahodnym casovym posunem, smrt ma nadale vlastni casovani. Jde o mekke rozestupy, nikoli nepruchodne kolize.

- Each tick, every living enemy looks for the nearest living hero that is to the left of the enemy on the X axis.
- Heroes on the right side of an enemy are ignored by that enemy.
- If a valid hero exists, the enemy moves directly toward that hero using full 2D movement.
- `ZombieShooter` is the exception: it moves toward the nearest valid hero only until that hero is within medium ranged attack distance, then stops and fires one projectile per second instead of dealing contact DPS.
- If the enemy reaches melee range, it stops and damages that hero over time.
- If an enemy reaches the wall line, the wall becomes the immediate priority and the enemy attacks it instead of continuing to chase heroes behind that line.
- `ZombieShooter` also attacks the wall only in melee after reaching that wall line; it does not perform ranged shots against the wall.
- If no valid hero exists ahead of the enemy, the enemy moves straight left toward the wall and attacks the wall on contact.
- Enemy targeting is not locked; if the player moves a hero away, the enemy can immediately switch targets on the next tick.

## Save / RPG Notes

- 2026-10-07: V Rumble se odmena 1 zlato za smrt nepritele ihned pricita take do `_gatheringCoins`, tedy do HUD zasoby pouzivane pro nakup sberacu, staveb a oziveni hrdinu. Ulozeny zustatek nadale aktualizuje jedine existujici volani `RpgSystem.addCoins(1)`; odmena se nezdvojuje.

- The game uses slot-based save data.
- Coins, XP, unlocks, and other RPG progress are stored per save slot.
- Each enemy killed by the player's heroes now grants `1` coin immediately to the active save slot.
- During gameplay, each enemy death now also spawns a short floating `+1` coin reward effect above that enemy, which rises upward and fades out.
- Hero unlock gating is temporarily disabled: all heroes are now forced unlocked for both new and already existing save slots until the unlock economy is tuned again.
- After hero selection, the player now goes through a chapter-selection screen and then a level-selection screen before gameplay starts.
- After save-slot selection, the player now first enters a village hub screen that serves as the main crossroads for heroes/upgrades and the battle flow.
- The village screen now shows the player's current coin total in a fixed top-right overlay, so it stays in the same screen position even while the village map is panned or zoomed.
- The village hub now also contains a separate `Pruzkum` entry point with its own chapter/level placeholder flow, independent from village defense.
- There are currently 2 chapters in the selector, but only chapter 1 is unlocked.
- Chapter 1 currently contains 19 selectable levels.

## Change Log Context

- 2026-10-22: Ukazatel zivotu sberace (`_buildWorkerHpBar`) presunut tesne nad hlavu ducha: puvodni pruh byl 9 px nad hornim okrajem celeho render boxu 208 px (asi 50 px nad hlavou), pres celou sirku boxu, 5 px vysoky a poloprusvitny, takze nebyl citelny. Novy pruh je na `gatheringWorkerRenderSize * workerHpBarTopFactor` (0.13, ~27 px od horniho okraje boxu; postava zacina ~46 px), siroky `workerHpBarWidthFactor` 42 % boxu (~87 px), vysoky 9 px, s tmavym ramem a barvou plynule od zelene (plne HP) po cervenou jako u hrdinu. Tecka neseneho nakladu je 16 px nad nim. Plati v Gathering i Rumble.
- 2026-10-22: Obranna vez je animovana: `assets/backgrounds/tower_sheet.png` (12 snimku 249x397 v jednom radku, odvozeno z `tower.png`) - cervena vlajka na strese vlaje (sloupce latky se vlni, smerem k volnemu konci vic, se svetlem/stinem na zahybech), pochodne na ochozu plapola pixelovy plamen na 3px mrizce s teplou zari na dreve a stoupajici jiskrou. `_loadTowerSprite` nacita sheet, `_drawDefenseTower(canvas, {phase})` vybira snimek `(time * 10 + phase) % 12` (10 fps herniho casu, `towerSpriteFrameCount`), kresli s `FilterQuality.none`; postavene veze dostavaji fazi podle pozice, aby vlajky nevlaly synchronne. Staticky `tower.png` zustava pro ikonu ve stavebnim menu. Generator `make_tower.py` ve scratchpadu.
- 2026-10-22: Uvodni obrazovka `IntroScreen` je ve stejnem pixel-art stylu jako menu kapitol a levelu: kamenna zed (`PixelMenuBackground`), velky zlaty nadpis `loc.appName` pixelovym fontem mezi dvema shluky fialovych krystalu (`PixelCrystalPainter`, tri strepy se zari, pravy zrcadleny), zlaty ornament s rubinem (`PixelOrnamentPainter`), rubinove tlacitko `loc.playButton` + "!" s drahokamy (SaveSlotScreen) a kamenne tlacitko `loc.heroesButton` (HeroUpgradeScreen). Prepinac jazyka je vpravo nahore v kamennem ramu; jeho popup ma kamennou barvu a zlatou znacku vyberu (`language_switcher.dart`). Pri vysce pod 380 se prvky zmensi, obsah je ve `SingleChildScrollView`.
- 2026-10-22: Vyber kapitoly (`ChapterSelectScreen`) a vyber levelu (`LevelSelectScreen`) jsou v pixel-art stylu stredoveke fantasy podle predlohy tlacitka "Play!" (zlate ramy, rubinove vyplne, drahokamy). Novy soubor `lib/pixel_ui.dart`: `PixelFramePainter` (ram se zubatymi rohy, zlaty okraj se svetlou/tmavou hranou, cvocky, volitelne drahokamy po stranach, stinovani vyplne omezene na 4/5 pixelu), `PixelPanel`, `PixelButton` (rubinove/kamenne, stisk, sede pri `onPressed == null`), `PixelShieldPainter` (heraldicky stit 16x19 pixelu, vybrany ma zlatou zaru, `dimmed` sedy), `PixelStoneBackgroundPainter`/`PixelMenuBackground` (tmava kamenna zed s vinetou), `PixelTitleBanner` a `pixelTextStyle` (zlate pismo s tmavym 8smernym obrysem). Font Pixelify Sans (OFL, `assets/fonts/PixelifySans.ttf` + `PixelifySans-OFL.txt`, rodina `PixelifySans` v `pubspec.yaml`) ma ceskou diakritiku, texty menu jsou proto s hackami a carkami. Vyber levelu: nahore Zpět / banner kapitoly s nazvem / Editor, vlevo mrizka 19 stitu (pocet sloupcu se voli pro nejvetsi stity, dokoncene jsou smaragdove s hvezdou, vybrany se zvetsi), vpravo detail (Úroveň N, sila nepratel +X % HP s 10dilnym ukazatelem, stav Dobyto / Čeká na hrdiny) a tlacitko Hrát! / Znovu!. Klik vybira, dvojklik rovnou spousti; karusel `PageView` odstranen. Vyber kapitoly: dve karty s erbem (stit s rimskou cislici, zamcena seda se zamkem), klik vybira, dvojklik a tlacitko Pokračovat otevrou levely. Kapitoly jsou ve `_ChapterChoice.all` (s `roman`, `byNumber`). `_SelectionCard` zustava pro obrazovky Pruzkumu.
- 2026-10-22: Treti varianta stromu dreva `assets/buildings/tree3_sheet.png` (24 snimku 366x363, mrizka 6x4, 12 fps; staticky `tree3.png` 1046x1037) se zlutozelenou korunou, stejna animace jako ostatni stromy. Pridana do `woodTreeSheetAssets` s velikosti 110x109; `woodTreeSize` (nejvetsi varianta pro rozestupy) je nyni 110x118. Kazdy strom vybira nahodne ze tri variant. Maska listi v `make_tree.py` nove zahrnuje i zlute listy.
- 2026-10-22: Druha varianta stromu dreva `assets/buildings/tree2_sheet.png` (24 snimku 353x399, mrizka 6x4, 12 fps; staticky `tree2.png` 1008x1139, cerne pozadi i uzavrene cerne mezery mezi vetvemi odstraneny). Stejna animace jako `tree_sheet.png` (vitr, chveni listi, svetlo v zilach, jiskry); generator `make_tree.py` ma ted parametry nazev/GROUND/TOP/oblast jisker. Kazdy strom dostane pri generovani nahodnou variantu (`woodTreeSheetAssets`, `woodTreeSizes` 104x110 a 104x118, `_gatheringWoodVariants`), velikost varianty urcuje vykresleni (`_buildWoodTree`), klikaci elipsu i nepruchozi pudorys (`_woodTreeFootprints`, predpocitane po vygenerovani). Pocet stromu je 10x vyssi: `(5-10) * woodTreeCountMultiplier` = 50-100, rozestup stromu `woodTreeSpacing` 80, az `woodCount * 40` pokusu; na mensi mape Gathering se jich vejde mene. Stromy se vyhybaji i pevnemu jezirku many u baze (100). Pokusy pro kameny a jezirka zvyseny na 3000. `BuildingNavigation` zrychlena pro mnoho prekazek: `clear` nejdriv vyradi obdelniky mimo bounding box useku a `move` pouziva A* s euklidovskou heuristikou misto Dijkstry pres vsechny rohy; rozhrani i chovani (obchazeni, zastaveni pred uzavrenou cestou) se nemeni.
- 2026-10-22: Zdroje dreva v Gathering i Rumble jsou animovane magicke stromy `assets/buildings/tree_sheet.png` (24 snimku 326x343, mrizka 6x4, 12 fps; staticky `tree.png` 932x980 s pruhlednym pozadim, odstranen sum alfa < 20). Animace: cely strom se ve vetru ohyba (nahore az o 20 px zdrojoveho obrazku, koreny a kameny stoji), listi se navic lokalne chveje, po modrych zilach v kmeni putuji svetelne pulzy nahoru a kolem kmene stoupaji modre jiskry. Na mape `woodTreeSize` 104x110 se stredem v pozici dreva, kazdy strom ma podle pozice posunutou fazi. Klik na strom plati v elipse 45 % velikosti. Rozestupy: stromy mezi sebou `woodTreeSpacing` 90, od dolu polovina sirky dolu (min. `goldMineClearance`) + 52, mimo okoli portalu, cele ve svislem rozsahu mapy; kameny od stromu 64, jezirka many od stromu 100. Hnedy box 20x20 je jen fallback. Tezba (3 s, 10 dreva) beze zmeny. Generator `make_tree.py` ve scratchpadu. Stromy jsou nepruchozi prekazky ve spolecne navigaci `_navigation` (`lib/building_navigation.dart`): blokuje jen oblast kmene a korenu (obdelnik 50 % sirky x 30 % vysky stromu, stred +25 % vysky, odstup 10), koruna zustava pruchozi. Hrdinove, nepratele i sberaci strom obchazeji kolem rohu, sberac tezi drevo u okraje tohoto pudorysu.
- 2026-10-22: Novy nepritel `orc` (Orc, dvouhlavy zeleny ork): `assets/enemies/Orc.png`, 33 snimku 90x90 v jednom radku ve stejnem rozlozeni jako Devil/Vampire (idle 0-7, chuze 8-15, utok drapem 16-24 se zelenym obloukem, zasah 25-26, smrt 27-32 pad dozadu), chodidla na y=48, postava hledi doprava. Zaklad 38x44 px zmenseny z predlohy stejnym `devil_base.py`, generator `build_orc.py` ve scratchpadu (bez ocasu). Statistiky 20 HP, rychlost 16, melee 5 DPS. Je v `enemyTypeRegistry` i `_enemySpriteConfigs`, takze se objevuje v nahodnych skupinach misto `fat_zombie` eventu (nyni sedm typu ve skupine: FatZombie, Vampire, Devil, Orc, ZombieFemale, SkullMage, ZombieShooter) a je vybiratelny v editoru levelu.
- 2026-10-22: Novy nepritel `devil` (Devil): `assets/enemies/Devil.png`, 33 snimku 90x90 v jednom radku ve stejnem rozlozeni jako Vampire/FatZombie (idle 0-7 s mrskanim ocasu, chuze 8-15 s vetsim krokem a vlnenim ocasu, utok drapem 16-24 s ohnivym obloukem, zasah 25-26, smrt 27-32 pad dozadu), chodidla na y=48, postava hledi doprava. Zaklad 37x44 px zmenseny z dodane predlohy (`devil_base.py`, generator `build_devil.py` ve scratchpadu). Statistiky jako FatZombie/Vampire: 20 HP, rychlost 16, melee 5 DPS. Je v `enemyTypeRegistry` i `_enemySpriteConfigs`, takze se automaticky objevuje v nahodnych skupinach misto `fat_zombie` eventu (nyni sest typu ve skupine: FatZombie, Vampire, Devil, ZombieFemale, SkullMage, ZombieShooter) a je vybiratelny v editoru levelu.
- 2026-10-21: Zdroje many (fragmenty) v Gathering i Rumble jsou nove animovana magicka jezirka `assets/buildings/manaPool_sheet.png` (24 snimku 479x404, mrizka 6x4, 12 fps; staticky `manaPool.png` 1198x1010 s pruhlednym pozadim). Animace: vir uprostred se otaci, svetle pasy stekaji po vodopadech, svetelne pulzy putuji potucky k jezirku, pod vodopady se sireji kruhy, hladina se trpyti a stoupaji jiskry many. Na mape `manaPoolSize` 96x81 se stredem v pozici fragmentu; kazde jezirko ma podle pozice posunutou fazi animace. Klik na zdroj plati v elipse 45 % velikosti. Rozestupy: jezirka mezi sebou `manaPoolSpacing` 100, od stromu/kamenu 70, od dolu `goldMineClearance` + 48, mimo okoli portalu, cela ve svislem rozsahu mapy; pevne jezirko u baze je na (zed + 70, 44.5). Fialovy box 20x20 je jen fallback. Tezba, mnozstvi (10) i doruceni hrdinum beze zmeny.
- 2026-10-21: `assets/workers/Spirit.png` rozsiren na 24 snimku 90x90 (`workerSpriteFrameCount`): 0-7 pohyb/idle, 8-15 tezba/stavba, nove 16-23 utok drapy. Snimek 16 je zasah (pravy drap mrskl dolu-dopredu, tri zarici oblouky stop drapu), 17-19 dojezd a navrat, 20-22 napraha (drap nahoru-dozadu, telo se zaklani), 23 rychly svih se smouhou. Utocna animace se nepouziva podle `animationTime`, ale podle cooldownu utoku (`_workerFrameIndex`): hned po zasahu snimek 16, pred dalsim zasahem napraha. Plati jen pro prikaz `attack`, kdyz sberac stoji u cile; pri utoku na nepritele vlevo se sprite zrcadli (`_isWorkerFacingLeft`). Tezba a stavba nadale pouzivaji 8-15. Generator `build_spirit_attack.py` ve scratchpadu vychazi z pohyboveho snimku 0.
- 2026-10-21: `assets/heroes/Aerin/Aerin_walk_sheet.png` nahrazen behem (stale 12 snimku 316x307, stejne ukotveni jako idle), `_aerinWalkFramesPerSecond` 12 -> 14. Horni cast tela je prikrcena o 8 px a zkosena dopredu (13 px u hlavy, +-2 px dle kroku), pri kazdem kroku se zhoupne o 4 px (nejniz uprostred opory). Obe nohy jsou rozdelene na stehno a holen a pozuji se 2kostkovym IK (koleno vpred) po bezecke draze chodidla: opora 42 % cyklu, krok +-24 px, zdvih 16 px a kopnuti patou dozadu 10 px. Za nohama zustava ztmavena kopie puvodnich nohou (stin pod tunikou), pri zemi je mezera pruhledna. Mec se kyva +-8 stupnu, kridla vic mavaji. Generator vychazi z puvodniho skriptu chuze (`build_aerin_idle.py` + novy `build_aerin_run.py` ve scratchpadu).
- 2026-10-20: Zlaty dul v Gathering i Rumble je nove animovana jeskyne `assets/buildings/goldMine_sheet.png` (24 snimku 619x561, mrizka 6x4, 12 fps; staticky `goldMine.png` 1238x1122 s pruhlednym pozadim). Animace: virici spirala uvnitr jeskyne, pulzujici fialova zare z ustí, vlny energie putujici po sveticich zilach ven a jiskry vylétajici z jeskyne. Ve hre se kresli `goldMineSize` 150x136 se stredem v `_gatheringGoldPosition`; klik na zlato plati v obdelniku 80 % teto velikosti. Stromy, kameny a fragmenty drzi od dolu odstup `goldMineClearance` 90 (driv 44), dul se nespawnuje do okoli portalu a cely se vejde do mapy svisle. Zluty box 20x20 zustava jen jako fallback.
- 2026-10-20: Pridana budova portalu: `assets/buildings/portal.png` (staticka, pruhledne pozadi, 1138x1110) a animovany sheet `assets/buildings/portal_sheet.png` (24 snimku 569x555, mrizka 6 sloupcu x 4 radky, smycka; doporuceno ~12 fps = 2 s). Vir uvnitr portalu se otoci jednou za smycku (stredova cast rotuje, okraj zustava a jen se trpyti, stred pulzuje), kazdy z 19 krystalu ma posunuty diagonalni odlesk a pixelovou jiskru. Zatim neni napojen v kodu; slozka `assets/buildings/` uz je v `pubspec.yaml`.
- 2026-10-20: Aerinuv in-game sprite (jednotka na mape) ted pouziva novy idle sheet `assets/heroes/Aerin/Aerin_idle_sheet.png` (16 snimku 316x307 v jedne rade, prehravani 12 fps, `_aerinFrameCount = 16`) misto stareho `assets/heroes/Aerin_sheet.png`; portret v menu a na kartach zustava beze zmeny.

- 2026-09-30: Sberaci dostali melee utok za 3 zraneni kazdou herni sekundu, obranu pri napadeni v necinosti a rucni cileny utok. HP zvyseno z 10 na 20 a pruh pod jednotkou zvetsen pro lepsi citelnost.

- 2026-09-29: The default camera fit now uses the real `mapHeight` of the current mode instead of the base `400`, with a `max(...)` guarding against empty space on the right. At zoom-out, Rumble shows the whole map, `1600 x 800`, at once.
- 2026-09-29: Map height in Rumble is doubled (`400 -> 800`); `mapHeight`, `heroSpacerHeight` and `enemyLaneHeight` are now instance getters that depend on `widget.isRumble`. The terrain and wall images stretch to the new height, and the camera fits by the base height, so the map pans vertically.
- 2026-09-29: Rumble ted zacina se 2 sberaci (Gathering dal s 1). Sberaci jsou nove syte zeleni (`0xFF1FA82E`, tmave zeleny okraj) a vybrany sberac ma misto zeleneho bily okraj, aby vyber zustal citelny.
- 2026-09-29: Casovy rozestup mezi zacatky Rumble vln byl zvysen z 10 na 30 sekund.
- 2026-09-29: Sberac ted v jedne zasilce prenasi 10 fragmentu a maximalni magicka energie hrdinu byla zvysena z 10 na 20.
- 2026-09-24: Gathering i Rumble ted vzdy vytvori jeden dodatecny fialovy fragment nahore vedle baze; vedle nej zustava obvykly nahodny pocet fragmentu v mape.
- 2026-09-24: Rumble dostal vlastni pevny spawn plan nezavisly na levelovych JSON datech: 30 vln po 10 sekundach, s 1 nepritelem v prvni vlne a narustem o 2 nepratele v kazde dalsi vlne. Rumble uz nepouziva globalni 10x nasobeni poctu nepratel standardnich levelu.
- 2026-09-24: Opravena syntakticka chyba v `_GatheringTopBar`: po zoomovacich tlacitkach byly odstraneny dva nadbytecne uzaviraci tokeny, ktere blokovaly kompilaci `lib/main.dart`.
- Legacy notes migrated from `AGENTS.dm` on 2026-03-11.
- 2026-03-11: Enemies switched from painted shapes to sprite-sheet rendering using `assets/enemies/FatZombie.png`.
- 2026-03-12: The current enemy sprite type was renamed to `FatZombie` to keep naming clear before adding more enemy variants.
- 2026-03-11: Added separate walk and attack frame ranges for the goblin sprite.
- 2026-03-11: Enemy sprites are mirrored horizontally.
- 2026-03-11: Added on-screen zoom `+` and `-` controls and enabled controlled map zoom/pan behavior.
- 2026-03-11: Added enemy death sequence: last 6 frames play once, then the final corpse frame stays for 5 seconds and fades out.
- 2026-03-11: Heroes changed from fixed left-side slots to movable map units with click-to-select and click-to-move behavior.
- 2026-03-11: Movement now pauses hero attacks, but cooldown still ticks while the hero is moving.
- 2026-03-11: The old left hero card panel and automode UI were removed from the active game layout.
- 2026-03-11: After the movement refactor, helper class definitions in `main.dart` were repaired to restore shared gameplay/UI types used across the file.
- 2026-03-11: Hero selection was made more forgiving by using a larger object hitbox and by locking selection to the hero detected on pointer-down.
- 2026-03-11: Hero selection was further hardened by adding a dedicated `GestureDetector` hit area directly to each hero unit widget instead of relying only on the global map listener.
- 2026-03-11: Hero movement speed was reduced to make repositioning feel less abrupt.
- 2026-03-11: Enemies were changed from strict lane movement to dynamic 2D pursuit of the nearest living hero ahead of them on the X axis.
- 2026-03-11: Heroes now have HP, can be killed by enemies, disappear on death, and show a small HP bar above their cooldown bar.
- 2026-03-11: Hero move-order clicks were corrected to use viewport-based pointer conversion in `InteractiveViewer`, fixing offset destination positions.
- 2026-03-11: Selecting a hero now opens an on-map context menu for attack-mode switching, reusing the same icons as the former slot-based mode UI.
- 2026-03-13: Hero attack-range circle was decoupled from persistent selection and now reappears on every hero click, stays visible for 5 seconds, and then fades out smoothly.
- 2026-03-13: Added a second on-map hero context menu above the selected hero for behavior selection (`hold position`, `offensive`, `defensive`).
- 2026-03-13: Hero behavior selection is now wired into gameplay: `hold position` keeps current stationary behavior, `offensive` auto-advances into range of the nearest enemy, and `defensive` retreats from close threats before returning to its guard spot.
- 2026-03-13: Defensive behavior retreat distance was increased to make the escape step noticeably longer.
- 2026-03-13: Defensive retreat was changed from per-tick retargeting to a locked longer fallback move, so heroes retreat smoothly for roughly 2 seconds before evaluating another retreat.
- 2026-03-13: Manual repositioning now works even in `offensive` and `defensive` modes; AI behavior waits until the ordered move finishes before taking control again.
- 2026-03-13: Enemy wall priority was tightened so enemies that reach the wall attack it immediately and no longer chase heroes behind the wall line.
- 2026-03-13: Added drag multi-select with a square selection box; selected groups can receive a shared move order and spread into a small formation at the target point, while hero context menus stay hidden during multi-select.
- 2026-03-13: Group move-orders from multi-select now clear the selection immediately after the player clicks the destination.
- 2026-03-14: Clicking a targetable enemy with one or more selected heroes now issues a focused attack order; each hero moves into its own range for that enemy, keeps focus on that enemy only until it dies, and the selection clears right after the command.
- 2026-03-13: Zoom `+` and `-` controls were moved from their own second bar into the main top HUD bar, positioned immediately left of the menu button to give the map more vertical space.
- 2026-03-13: Fullscreen handling was hardened across the app: immersive sticky mode is now reapplied at startup and when the app resumes, and screen disposes no longer switch back to edge-to-edge, reducing Android status-bar bleed-through.
- 2026-03-13: The Flutter debug banner in the top-right corner was disabled in `MaterialApp`.
- 2026-03-13: Added a simple fixed defense tower in the upper-left area left of the wall; it auto-fires every 5 seconds at the nearest enemy within its own long range and deals 10 projectile damage per hit.
- 2026-03-13: `Restart` now fully resets the run to its initial state: wave/stat counters, game timer, hero positions, hero behavior/mode settings, zoom, selection state, and game speed all return to startup defaults.
- 2026-03-13: The gameplay map background now uses `assets/backgrounds/grass.png` stretched over the whole map area, with the old flat-color fill kept only as a fallback.
- 2026-03-15: The gameplay wall now uses `assets/backgrounds/palisade.png` as its visual representation, with the former simple painted wall kept as a fallback if the sprite fails to load.
- 2026-03-14: Added a compact bottom-right gameplay strip of hero cards with hero-select portraits and HP bars; clicking a card selects the same hero as a direct map click, and dead heroes keep a greyed-out card.
- 2026-03-14: Hero selection screen back navigation was fixed to return explicitly to `SaveSlotScreen`; both the on-screen `Zpet` button and system back now avoid falling into a blank white route after the earlier `pushReplacement` flow.
- 2026-03-14: Save-slot screen back navigation was also fixed to return explicitly to `IntroScreen`; both the on-screen `Zpet` button and system back now avoid the same blank white route issue caused by `pushReplacement`.
- 2026-03-14: Hero selection now includes a dedicated bottom-panel button that opens the existing hero-upgrade screen directly, so upgrades are reachable without going back through the intro screen.
- 2026-03-13: Zoomed map control was split by touch count: one finger always controls gameplay, while map panning activates only on two-finger gestures so drag multi-select still works when zoomed in.
- 2026-03-13: Two-finger map movement was reworked to use manual viewport-offset dragging from active touch positions, because `InteractiveViewer` did not provide reliable two-finger-only pan behavior in this setup.
- 2026-03-14: Two-finger map movement was loosened so it also works at the default zoom-out level; the offset clamp still limits movement to the real visible overflow area.
- 2026-03-13: Zoom button scaling now anchors around the center of the viewport instead of the top-left corner, so pressing `+` or `-` keeps the current center area stable.
- 2026-03-13: The default minimum zoom now fits the map to the available height under the top HUD, so the gameplay area fills the device height at maximum zoom-out.
- 2026-03-13: In-game Aerin rendering now overrides the shared hero portrait and uses `assets/heroes/Aerin_default.png`, while menu/select icons keep the original `hero_aerin.png` asset.
- 2026-03-13: Aerin's in-game sprite now renders as a transparent PNG-only unit with no colored tile background, border, or selection glow frame behind it.
- 2026-03-13: Aerin also skips the standard moving overlay, so no dark movement outline/icon appears around the transparent sprite while repositioning.
- 2026-03-13: In-game hero units were enlarged, and the hero tap radius was increased accordingly so selection remains comfortable.
- 2026-03-13: Aerin's in-game appearance now uses a looping animation for gameplay while menu icons still stay static.
- 2026-03-13: The Aerin animation path was hardened with `gaplessPlayback` and a fallback to `assets/heroes/Aerin_default.png`, so a broken frame does not show the generic white icon.
- 2026-03-13: Aerin's animated in-game sprite now renders with `FilterQuality.none` and antialiasing disabled, which avoids dark interpolation artifacts around transparent pixel-art edges.
- 2026-03-14: Aerin animation frames were converted into a single transparent sprite sheet `assets/heroes/Aerin_sheet.png`; the gameplay render now reads 31 frames of `479x404` from that sheet, which removes the black background at the asset level instead of trying to hide it in UI code.
- 2026-03-14: Aerin sprite-sheet playback was then corrected to use alignment-based frame cropping inside the hero widget; the earlier translate-based approach could leave the unit visually empty even though the sheet asset existed and loaded.
- 2026-03-14: Aerin sprite-sheet playback was then moved off widget-layout cropping entirely and now draws the selected frame via `ui.Image` + `drawImageRect`; this avoids blank renders caused by layout-based clipping of the very wide sheet.
- 2026-03-15: Starting gameplay from hero selection now goes through a new chapter-selection screen and then a level-selection screen; chapter 2 is already visible but locked, and chapter 1 currently exposes 19 levels.
- 2026-03-15: Level choice now feeds into gameplay difficulty by multiplying spawned enemy HP by `1.2^(level-1)` on top of the existing per-wave HP scaling.
- 2026-03-15: Returning from the hero-upgrade screen now reloads `PlayerProgress` on `HeroSelectScreen`, so newly unlocked heroes become immediately selectable without leaving the current flow.
- 2026-03-15: Enemies now store their spawned `maxHp` directly on each `_Enemy` instance; the gameplay HP bar therefore reflects the real per-level/per-wave HP value instead of the old fixed base constant.
- 2026-03-15: Chapter-selection cards now switch to a lower compact layout on narrower displays, reducing carousel height and card spacing so chapter tiles no longer overflow vertically.
- 2026-03-15: Chapter and level selection screens now use a vertical scroll container instead of a fixed full-height column, and their cards auto-densify further on very short viewports to avoid bottom overflow.
- 2026-03-15: Gameplay map now also supports pinch zoom with two fingers; spreading fingers apart increases zoom while the existing manual two-finger centroid pan remains active in the same gesture.
- 2026-03-15: After selecting a save slot, the player now enters a new `Vesnice` hub screen with buttons for hero upgrades, the battle flow, `Samanova chyse`, and `Management vesnice`; the last two currently only show a placeholder message.
- 2026-03-15: The `Vesnice` hub now uses a vertical scroll layout and collapses its menu grid to a single column on tighter displays so the screen no longer overflows.
- 2026-03-15: The gameplay wall now renders with `assets/backgrounds/palisade.png`; if the asset fails to load, the old simple painted wall line still appears.
- 2026-03-15: When the palisade wall sprite is available, the old in-map vertical wall HP line is now hidden so no line is drawn across the texture; wall HP remains visible in the top HUD.
- 2026-03-15: Heroes are now blocked from crossing to the left side of the wall; player orders stop them just before the wall, and level-start spawns were moved to the right side as well.
- 2026-03-15: When enemies attack the palisade, it now flashes white and shakes slightly as a hit reaction.
- 2026-03-16: The automatic defense tower in the upper-left gameplay area now renders from `assets/backgrounds/tower.png`; if the sprite fails to load, the old painted square fallback still appears.
- 2026-03-16: The in-game defense tower sprite was enlarged on the map for better visibility.
- 2026-03-16: The defense tower sprite width was kept unchanged, while its on-map height was increased slightly for a taller silhouette.
- 2026-03-16: The defense tower height was nudged up once more while keeping the same width.
- 2026-03-16: The defense tower sprite was then doubled again in both dimensions and moved lower on the map.
- 2026-03-16: Gameplay map controls now also support desktop input: mouse wheel zoom, middle-mouse drag panning, and `Space` + left-drag panning as a fallback, while touch devices keep the existing two-finger pan/pinch behavior.
- 2026-03-16: Desktop mouse-pan button detection was adjusted to use raw button bitmasks compatible with the current Flutter SDK, fixing undefined button constant compile errors.
- 2026-03-16: Desktop wheel-zoom handling was also switched to the `ui.PointerScrollEvent` type to match the file's aliased `dart:ui` imports and avoid compile errors.
- 2026-03-16: The desktop wheel-zoom fix was finalized by importing `PointerScrollEvent` explicitly from `package:flutter/gestures.dart`, because this SDK does not expose that type through the existing imports used in `main.dart`.
- 2026-03-16: The wall hit-flash overlay was refined to re-draw the palisade sprite with a white color filter, so only the non-transparent pixels flash instead of the entire wall rectangle.
- 2026-03-16: The defense tower now has a simple soft oval shadow drawn under it to ground the sprite visually on the map.
- 2026-03-16: The in-game defense tower sprite was scaled down slightly again while keeping the same map position.
- 2026-03-16: The defense tower width was reduced a bit more while its height and map position stayed unchanged.
- 2026-03-16: The defense tower width was trimmed once more by a small amount, with height and position still unchanged.
- 2026-03-16: The defense tower width was narrowed a little further again, while height and position remained unchanged.
- 2026-03-16: All in-game hero units now render with the same simple oval ground shadow used by the defense tower, including transparent-sprite heroes like Aerin.
- 2026-03-16: Enemies now also render with a simple oval ground shadow under their bodies/sprites, with a slightly softer fade while dying.
- 2026-03-16: Enemy ground shadows were shifted a bit upward so they sit closer under the enemy bodies.
- 2026-03-16: Enemy ground shadows were moved up once more because the previous offset still left them looking too detached from the bodies.
- 2026-03-16: Enemy ground shadows were raised again for a tighter contact feel under the sprites.
- 2026-03-16: Enemy ground shadows were lifted further again to sit noticeably tighter under the enemy sprites.
- 2026-03-16: Enemy ground shadows were nudged a final small step higher for tighter visual grounding.
- 2026-03-16: Created `assets/heroes/Veyra_sheet.png` as a single transparent sprite sheet from the 16 standing frames in `assets/heroes/Veyra/standing/`; the asset is prepared for later in-game animation wiring.
- 2026-03-16: Veyra now uses `assets/heroes/Veyra/standing/Veyra_sheet.png` as her animated in-game unit sprite, while menu/select views still keep the existing portrait asset.
- 2026-03-16: Added JSON-backed level definitions via `lib/level_data.dart` and `lib/level_repository.dart`; gameplay wave spawning now reads timed wave/event data per level instead of relying only on the old procedural spawn cadence.
- 2026-03-16: Added an internal `LevelEditorScreen`, opened from the level selection flow, which edits wave timing/spawn events, stores local SharedPreferences overrides, can reset them back to asset/default data, and can preview the selected level directly in-game.
- 2026-03-16: Added the first asset level definition at `assets/levels/chapter_1/level_01.json`; levels without explicit JSON assets still auto-generate a deterministic fallback template.
- 2026-03-16: Cleaned the black background out of `assets/heroes/Veyra/standing/Veyra_sheet.png` by converting the border-connected near-black background pixels to transparency, so Veyra now renders without a black rectangle around the sprite.
- 2026-03-17: Veyra's in-game ground shadow was moved a bit higher than the shared hero default so it sits closer under her transparent sprite.
- 2026-03-17: Veyra's in-game sprite-sheet render is now mirrored horizontally, without affecting other heroes that reuse the shared `_SpriteFramePainter`.
- 2026-03-17: All in-game hero units were enlarged again by increasing the shared `heroUnitSize`, and the hero tap radius was also raised slightly so direct selection remains comfortable.
- 2026-03-17: Hero unit size was then increased by roughly another 50% (`64 -> 96`), with the shared tap radius raised again to match the much larger on-map silhouettes.
- 2026-03-17: Transparent sprite-sheet heroes now keep a cached `ui.Image` copy of their loaded sheet and feed it back into `FutureBuilder.initialData`, which prevents Aerin/Veyra from briefly flashing the portrait fallback during multi-select drag rebuilds.
- 2026-03-17: The remaining multi-select flicker was addressed by giving each in-map hero widget a stable key; adding/removing the selection-square overlay in the shared `Stack` no longer causes hero elements to be re-mapped on pointer down/up.
- 2026-03-17: `_HeroUnitWidget` now explicitly accepts `super.key`, so the new stable hero keys compile correctly instead of failing on the named `key` parameter.
- 2026-03-17: Level completion is now persisted inside `PlayerProgress.completedLevels`; clearing the final wave triggers a victory dialog (`Ubranil jsi vesnici...`) and the level-selection cards show completed levels with a check-style state and `Dokonceno` label.
- 2026-03-17: The shared baseline attack range for all heroes was reduced by 50% (`mapWidth / 3 -> mapWidth / 6`), while the defense tower kept its previous longer range so only hero balance changed.
- 2026-03-17: Hero range indicators were made visually stronger (higher fill/border opacity and thicker outline) and now render for every hero in the current multi-selection, while keeping the same 5-second visibility and fade timing.
- 2026-03-17: All 10 heroes are now force-unlocked in `RpgSystem` for both default progress and loaded save slots, so hero purchase/access tuning can be revisited later without blocking selection or upgrades.
- 2026-03-17: Myris's first mode was changed to use the same single-target lightning cast that Veyra previously had in her third mode, including the same 1s sending, 2s cooldown, 30 damage, and bolt-style mode icon.
- 2026-03-17: Nyxra's first mode was also changed to that same single-target lightning cast, with 1s sending, 2s cooldown, 30 damage, and a bolt icon in the mode selector.
- 2026-03-17: Added a placeholder `Pruzkum` flow accessible from `VillageScreen`, with its own chapter selection (2 chapters) and level/location selection (2 per chapter); choosing a location currently ends in a placeholder dialog because exploration gameplay will be implemented later.
- 2026-03-17: Fixed a compile-time regression in `_performAttack` where Nyxra's branch had accidentally been overwritten with `_effectiveDamage` assignments; the attack branch now correctly calls lightning / voidchain casts again.
- 2026-03-17: Veyra now switches from her idle standing sheet to the animated APNG `assets/heroes/Veyra/attack/veyra_attack_1.png` exactly when she fires; all 29 attack frames play once and then the render automatically returns to the standing sprite.
- 2026-03-17: Veyra's attack render was then simplified for better web compatibility: during the attack window the game now shows the APNG asset directly for one full animation length (~2.9s) instead of trying to step APNG frames manually through `instantiateImageCodec`.
- 2026-03-17: Because the APNG still did not animate reliably in the web build, its 29 frames were extracted into `assets/heroes/Veyra/attack/Veyra_attack_sheet.png`; Veyra's attack now uses that real sprite sheet with one-shot frame playback and then returns to the standing sheet.
- 2026-03-17: Veyra's attack-playback trigger was then changed from a `_lastTime` timestamp to an explicit per-hero remaining-duration timer that is decremented in the main tick loop, so the attack sheet stays visible for the full intended playback window instead of depending on time-delta comparisons inside the widget.
- 2026-03-17: The extracted Veyra attack frames were then rearranged into a smaller grid sheet `assets/heroes/Veyra/attack/Veyra_attack_sheet_grid.png` and `_SpriteFramePainter` was extended with optional multi-row frame addressing, because the earlier single-row `14848px`-wide attack sheet was likely too wide for reliable web rendering.
- 2026-03-17: For debugging, Veyra's normal standing render was temporarily switched to the attack-frame grid derived from `assets/heroes/Veyra/attack/veyra_attack_1.png`, so the project can verify whether those frames render and animate at all before wiring them back only to the attack window.
- 2026-03-17: The root cause of Veyra's portrait fallback was then identified in `pubspec.yaml`: `assets/heroes/Veyra/attack/` had not been declared as a Flutter asset directory, so the new attack files were unavailable at runtime and the widget fell back to `hero_veyra.png`.
- 2026-03-17: After confirming the attack-frame asset now loads correctly, the temporary diagnostic standing override was removed; Veyra's idle render was restored to `assets/heroes/Veyra/standing/Veyra_sheet.png`, while the extracted attack sheet remains used only for the attack playback path.
- 2026-03-17: Added a new enemy type `ZombieFemale` using `assets/enemies/ZombieFemale.png`; it shares the same baseline stats as `FatGoblin`, now has its own sprite-sheet metadata/render path, and chapter 1 level 2 was moved to an explicit JSON asset that already mixes `zombie_female` spawns into its waves.
- 2026-03-17: Added another enemy type `Skull Mage` using `assets/enemies/Skull_mage_sprite_sheet.png`; for the first pass it uses the same baseline stats as `FatGoblin`, got its own sprite-sheet timing metadata (`walk 0..17`, `attack 18..24`, `death 25..29`), and was also mixed into chapter 1 level 2 for immediate testing.
- 2026-03-17: `ZombieFemale` sprite slicing was then corrected: the sheet is actually `35` frames of `62x37` rather than square `37x37` frames, with practical ranges `walk 0..14`, `attack 15..21`, and `death 22..28`; the earlier square slicing caused the broken flicker/misaligned animation.
- 2026-03-17: `ZombieFemale` was then visually shortened in render height only; its on-map width stays aligned with the shared enemy scale, but its drawn height is reduced by roughly one third so the sprite no longer looks overly tall.
- 2026-03-17: `ZombieFemale` animation ranges were then retuned to the correct frame windows: movement now uses `8..15`, attack uses `16..23`, and death uses the final `9` frames of the sheet.
- 2026-03-17: When the wall reaches `0 HP` and the run ends, the palisade visual is now hidden entirely instead of staying upright on the map; the fallback painted wall/HP line are also suppressed in that destroyed state so the wall appears to have actually fallen.
- 2026-03-18: `VillageScreen` now uses `assets/backgrounds/village_basic.png` as its full-screen background image, with a dark translucent overlay kept above it so the menu text and buttons remain readable.
- 2026-03-18: `VillageScreen` was then reworked toward a scrollable village-map layout: the background now lives inside the scrollable content so the player can pan through more of the village, and the old `Hrdinove` card was replaced by a centered clickable building using `assets/buildings/heroesAtrium.png` that opens the hero screen.
- 2026-03-18: The remaining village actions are now moving onto the map as well: `Branit vesnici` uses `assets/buildings/tower.png`, `Samanova chyse` uses `assets/buildings/shamanTent.png`, and `Management vesnice` uses `assets/buildings/atrium.png`, all placed at different positions on the village map while `Pruzkum` remains as the only card-style button for now.
- 2026-03-18: `VillageScreen` scrolling now works on both axes: the village map is wrapped in nested horizontal + vertical scroll views and its logical width was increased, so the player can pan sideways as well as downward across the village layout.
- 2026-03-18: All clickable map buildings on `VillageScreen` now render with a shared soft oval ground shadow underneath, so the hero atrium, tower, shaman tent, and management atrium sit more naturally on the village background.
- 2026-03-18: The shared `VillageScreen` building shadow was then enlarged and moved higher under each sprite, so the buildings feel more anchored instead of casting a tiny low-floating shadow.
- 2026-03-18: The same shared village-building shadow was then pushed a bit higher again and widened further, making the shadow read more clearly under the larger building sprites.
- 2026-03-18: `VillageScreen` map movement was then changed from nested axis-locked scroll views to free panning via `InteractiveViewer` with scaling disabled, so the player can drag the village smoothly in any direction, including diagonally.
- 2026-03-18: `VillageScreen` now also supports camera zoom: the map starts fully zoomed out to a contain-style fit of the viewport, touch devices can pinch to zoom, and desktop/web mouse users can zoom with the wheel around the cursor while keeping free panning.
- 2026-03-18: The default `VillageScreen` camera fit was then changed from contain-fit to width-fit in landscape, so the initial view fills the screen width and any extra map height remains available through panning.
- 2026-03-19: Gameplay map touch input was hardened so two-finger pan/pinch still works even if one finger lands directly on a hero unit; the shared raw pointer handling now also runs on the hero hitboxes instead of only on the empty-map overlay listener.
- 2026-03-19: The selected-hero context menus were visually pulled closer to the unit: the attack/mode menu now sits higher than before, while the behavior menu was lowered closer to the hero instead of floating too far away above it.
- 2026-03-19: The behavior menu under the selected hero was then nudged a bit lower again for a slightly looser gap from the unit, while the attack/mode menu stayed as previously adjusted.
- 2026-03-19: The same selected-hero behavior menu was then lowered by one more small step, keeping the attack/mode menu unchanged.
- 2026-03-19: Issuing a hero move order on the gameplay map now also shows the existing short-lived target marker at the clicked destination, both for single-hero orders and multi-select group movement, making the destination immediately visible to the player.
- 2026-03-19: The direct play button was restored to the `HeroSelectScreen` used for assigning heroes into battle slots, while the separate `HeroUpgradeScreen` opened from the village hero building no longer shows its own bottom `Hrát` button.
- 2026-03-19: The in-game pause/menu dialog no longer returns to the main menu; its button is now labeled `Zpět do vesnice` and routes straight back to `VillageScreen`.
- 2026-03-19: The shared default hero HP was increased from `20` to `100` by raising the `HeroDef.maxHp` default, so all heroes now start substantially tankier unless overridden individually.
- 2026-03-19: `HeroDetailScreen` now shows the selected hero portrait on the right side of the top XP info row, so the upgrade/detail header pairs the level and XP progress with a visible character portrait.
- 2026-03-19: The same top hero-detail info panel now also shows the hero's current base HP directly under the XP progress section, sourced from the active `HeroDef.maxHp` value.
- 2026-03-19: A temporary syntax break introduced while wrapping `LevelSelectScreen` in `PopScope` was repaired by restoring the correct `SafeArea -> LayoutBuilder` nesting, so the screen compiles again and keeps the safe fallback back-navigation to the village.
- 2026-03-19: The upper hero-assignment carousel on `HeroSelectScreen` was enlarged significantly and moved into a vertically centered band of the screen, so the tappable hero cards are larger and no longer stick to the top edge.
- 2026-03-19: The hero-detail HP readout under `XP Progress` was restyled from a plain text line into its own small stat tile, making the health value read as a separate upgrade-summary block.
- 2026-03-19: That HP tile was then moved below the entire top row of level/XP/portrait content, so it now sits as a separate full-width block under the header row instead of crowding the XP column.
- 2026-03-19: The HP tile was then pushed one level further out of the hero-detail layout, so it now renders below the whole bordered level/XP/portrait panel rather than inside that panel.
- 2026-03-20: The last remaining `Pruzkum` text card on `VillageScreen` was replaced by a clickable map building using `assets/buildings/explorerTent.png`, so exploration is now entered from a fifth building on the village map instead of a bottom button.
- 2026-03-20: All five clickable buildings on `VillageScreen` were enlarged to roughly double width, and their map positions were rebalanced so the bigger silhouettes still stay readable within the village layout.
- 2026-03-20: The `Branit vesnici` tower on `VillageScreen` was then returned to its original pre-scale width and moved further right, while the other four village buildings stayed enlarged.
- 2026-03-20: The `Samanova chyse` building on `VillageScreen` was then nudged slightly upward and more noticeably left to better fit the enlarged village composition.
- 2026-03-20: The same `Samanova chyse` building was then shifted another small step upward and left for a tighter final placement.
- 2026-03-20: The `Pruzkum` building on `VillageScreen` was then moved a large step upward to bring the exploration entry closer to the main village cluster.
- 2026-03-20: The `Pruzkum` building was then moved upward again by another larger step, making it sit much higher in the village map.
- 2026-03-20: The `Pruzkum` building sprite on `VillageScreen` is now rendered mirrored horizontally, using a new optional per-building flip flag in `_VillageMapBuilding`.
- 2026-03-20: `VillageScreen` building widths are now derived from fixed `mapWidth` ratios instead of `compact` viewport breakpoints, so all village buildings keep the same scale relative to the map across different display sizes.
- 2026-03-20: The `Management vesnice` building on `VillageScreen` was then moved upward by a small step while keeping its horizontal placement unchanged.
- 2026-03-20: `VillageScreen` now also uses a fixed logical map size (`1500 x 980`) instead of resizing the village canvas from the current viewport, so the background image and all building placements stay locked to the same coordinate system across resolutions.
- 2026-03-20: The `Pruzkum` building on `VillageScreen` was also moved behind the rest of the village cluster by drawing it earlier in the `Stack`, so the other buildings visually overlap it from the front.
- 2026-03-20: The `Management vesnice` building was then moved upward again by a larger step to place it noticeably higher in the village composition.
- 2026-03-20: The same `Management vesnice` building was then nudged upward by another smaller step for finer placement.
- 2026-03-20: All `VillageScreen` buildings except the `Branit vesnici` tower were then reduced by 20%, while the tower kept its previous width.
- 2026-03-20: The `Branit vesnici` tower was then moved a large step further right in the village map while keeping its size unchanged.
- 2026-03-20: The `Branit vesnici` tower was then brought into the foreground by drawing it later in the village `Stack`, so it visually overlaps the other buildings.
- 2026-03-20: The `Hrdinove` building on `VillageScreen` was then nudged a bit left while keeping its height and size unchanged.
- 2026-03-20: The text labels under all clickable buildings on `VillageScreen` were removed; the map now shows only the building sprites and their ground shadows.
- 2026-03-20: The top `Vesnice` title and its descriptive subtitle were also removed from `VillageScreen`, leaving the background map unobstructed except for the back button.
- 2026-03-20: Brann now uses the sprite asset `assets/heroes/Brann/brann.png` instead of the former `assets/heroes/hero_brann.png`.
- 2026-03-20: Brann's card portrait was then restored to `assets/heroes/hero_brann.png`, while only the in-game unit render now uses a dedicated `Brann` branch in `_HeroUnitWidget`.
- 2026-03-20: `pubspec.yaml` now also declares `assets/heroes/Brann/`; without that explicit asset directory, Brann's in-game sprite path fell back to the default icon at runtime even though the file existed on disk.
- 2026-03-20: Double-clicking a living hero card in the bottom gameplay HUD now selects that hero and recenters the current map camera directly on that hero while preserving the current zoom; dead hero cards still do nothing.
- 2026-03-21: Kaelen's third mode `spore` was fully replaced by `healing`: it now emits a short-range (`100`) healing pulse that restores `2 HP` to all living allied heroes in range including Kaelen, and this mode cycles even without enemies present.
- 2026-03-22: All in-game hero renders now flip horizontally while the hero is moving or actively attacking to the left, and they automatically return to their default orientation when idle again; the direction logic now applies consistently to static PNG unit sprites as well as sprite-sheet based heroes like Aerin and Veyra.
- 2026-03-24: Gameplay touch camera control was moved from two-finger panning to a permanently visible bottom-left joystick HUD; dragging the joystick now pans the camera continuously, two-finger touch no longer pans the map, and pinch zoom remains available without centroid-based touch panning.
- 2026-03-24: The bottom-right gameplay hero-card strip now also supports drag-rectangle multi-select starting from a living card; the resulting multi-selection feeds the same shared hero selection state as map multi-select, while dead cards remain non-selectable.
- 2026-03-24: Nyxra's in-game unit render now uses `assets/heroes/Nyxra/Nyxra.png`, while her card and menu portrait still use `assets/heroes/hero_nyxra.png`; `pubspec.yaml` was expanded with `assets/heroes/Nyxra/` so the new runtime sprite loads correctly.
- 2026-03-24: Ravik's third mode `soul` now uses a dark single-target lightning hit instead of the old chained bolt; each successful hit also restores `2%` of Ravik's max HP.
- 2026-03-25: Added a new enemy type `ZombieShooter` using `assets/enemies/ZombieShooter.png`; it stops at medium range (`180`) to fire `1` damage projectiles at heroes once per second, still attacks the wall in melee, its sprite-sheet render now includes dedicated hit-reaction frames `22..26`, chapter 1 level 2 now mixes it into the existing waves for immediate gameplay testing, and its projectile render now uses `assets/enemies/Projectile_zombie_shooter.png` with `4` looping flight frames plus `4` one-shot impact frames.
- 2026-03-25: Brann's in-game unit render now points to `assets/heroes/Brann/BrannIdle.png`, so references to Brann's "sprite" continue to affect only the moving map unit and not his card/menu portrait.
- 2026-03-25: Brann's in-game unit render now also switches to `assets/heroes/Brann/BrannAttack.png` whenever Brann is in his attack animation window, then returns to `assets/heroes/Brann/BrannIdle.png` afterward.
- 2026-03-25: Brann's attack sprite switching was then fixed by giving Brann his own runtime attack-animation timer in `_performAttack(...)`; without that timer, the widget stayed permanently on idle even while Brann was actually attacking.
- 2026-03-25: Brann's attack-animation timer was then extended to the full APNG playback length (`3.7s`, 37 frames at 100 ms) so `assets/heroes/Brann/BrannAttack.png` now gets enough on-screen time to finish completely before the render returns to idle.
- 2026-03-25: Brann's in-game sprite render was then moved onto the transparent-unit path as well, so his idle/attack assets no longer sit on the shared grey tile background and now show only the animation itself.
- 2026-03-25: Brann's in-game render now also switches to `assets/heroes/Brann/BrannWalk.png` while he is moving between map positions; once movement stops, the render returns to the existing attack/idle asset logic.
- 2026-03-25: A compile-time regression from the `_buildHeroImage(...)` parameter rename was then fixed by updating the remaining Veyra fallback call site from the old `isAerinInGameSprite` argument to `isTransparentInGameSprite`.
- 2026-03-25: Brann's in-game idle/walk/attack sprite renders are now scaled up by `2x` versus the original base size; the transparent hero render path also disables clipping for transparent units so the enlarged Brann sprite is not cut off by the old tile bounds.
- 2026-03-25: Brann's enlarged in-game sprite was then nudged upward inside the hero widget so the lower part no longer appears visually cut off after the size increase.
- 2026-03-25: Brann's moving in-game sprite was then given a wider dedicated widget footprint as well, so the enlarged walk render no longer gets visually clipped on the left/right edges while moving.
- 2026-03-26: Brann's in-game sprite scale was then reduced by one third (`2.0 -> 1.333...`) while keeping the wider wrapper footprint unchanged, so the sprite itself is less likely to clip vertically without losing the extra side clearance.
- 2026-03-26: Brann's render block was then made taller as well, so the higher `BrannAttack` sprite has more vertical room and no longer clips against the top edge during attacks.
- 2026-03-26: Brann's in-game sprite scale was then reduced by another third (`1.333... -> 0.888...`) while keeping the enlarged wrapper dimensions unchanged, so the sprite itself is smaller without giving back the extra anti-clipping space.
- 2026-03-26: The outer gameplay wrapper for Brann was then made taller too, so `_HeroUnitWidget` no longer overflows vertically when its own taller render area plus HP/cooldown bars are centered inside the map hit area.
- 2026-03-26: Brann's movement speed was reduced to half of the shared hero move speed, while all other heroes keep the original shared movement value.
- 2026-03-27: Brann's manual render offsets were reset back to zero so his sprite is centered directly inside the enlarged render box again for alignment testing against the debug cross.
- 2026-03-27: The actual map anchoring for Brann's enlarged wrapper was then fixed too; `Positioned(left/top)` now centers Brann using his real wrapper width/height instead of the old shared hero dimensions, so the debug cross, HP bar, and render box now share the same center.
- 2026-03-27: Brann's ground shadow was then narrowed to roughly one third of its previous visual width by using a dedicated larger horizontal inset, so the shadow no longer reads much wider than the unit itself.
- 2026-03-26: Added a temporary debug overlay that draws a red cross at the exact logical center of every living hero and active enemy, making it easier to compare collision/attack spacing against the visual sprite positions.
- 2026-04-02: Enemy kills by heroes now award `1` coin immediately to the active save slot; each kill also spawns a floating `+1` coin popup above the dying enemy, and `VillageScreen` now shows the current saved coin total in the top-right corner.
- 2026-04-03: The `VillageScreen` coin counter was moved out of the pannable/zoomable village map and into a fixed viewport overlay, so it now stays in the same top-right screen position at all times.
- 2026-04-04: The bottom-right gameplay hero cards next to the speed panel were given a slightly taller fixed height, eliminating the small `bottom overflowed by 2.0 pixels` layout warning without changing their behavior.
- 2026-09-21: Added the `Gathering` mode, opened from the village `atrium.png` building; it reuses the gameplay map and its camera controls while intentionally showing no heroes or active combat.
- 2026-09-21: Added the first Gathering economy loop: a grey worker repeatedly mines the same random 20px gold box for 3 seconds, returns to the wall with a yellow carry indicator, and deposits 10 persistent coins per trip.
- 2026-09-21: Gathering gained a repeatable `+ 200` worker-purchase button near the upper-left edge; every purchase deducts persistent coins and adds another independent grey miner at the wall.
- 2026-09-21: All Gathering workers became manually commandable: select a green-outlined worker, then click gold to mine, empty map to move/idle, or the base left of the wall to deposit; commands interrupt current work, including a gold return.
- 2026-09-22: Clicking the gold deposit now creates a persistent repeat-mining order: after each 3-second extraction and wall deposit, the selected worker automatically returns to the same gold until another command interrupts it.
- 2026-09-22: Added persistent wood resource storage and 5-10 brown tree boxes to Gathering; workers can repeat-mine a selected tree for 10 wood, shown by a brown carry dot, with wood displayed beside gold in the Gathering bar.
- 2026-09-22: Added persistent stone resource storage and 5-10 grey stone boxes to Gathering; workers can repeat-mine a selected stone for 10 stone, shown by a grey carry dot, with stone displayed beside gold and wood in the Gathering bar.
- 2026-09-22: Gathering workers now support rectangular multi-selection; commands issued to gold, wood, stone, base, or empty map apply to every selected worker, while a direct worker click selects only that worker.
- 2026-09-22: Added the `Rumble` mode from `assets/buildings/shamanTent.png`; it reuses hero/chapter/level selection, normal enemy waves and victory flow together with Gathering resources, worker purchases, and a shared hero/worker selection rectangle.
- 2026-09-22: Added `Fragments` as a fourth Gathering/Rumble map resource; 5-10 purple fragment boxes spawn on the map, workers mine one fragment for 3 seconds and deliver it to the nearest living hero, where it restores one point of the hero's 0-10 magic energy. Fragments are no longer shown as a global HUD counter.
- 2026-09-22: Gathering workers now have `10 HP`; enemies target living workers alongside heroes, including ranged `ZombieShooter` projectiles, and dead workers disappear from the map.
- 2026-09-23: Enemy spawn events now create ten times as many enemies while preserving each event's type, lane, and spacing.
- 2026-09-23: Added hero revival from the greyed-out gameplay card; reviving costs `200` persistent coins and restores the hero with full HP and magic energy at the starting position.
- 2026-09-22: Fixed the Gathering/Rumble worker-damage and manual-energy regressions that caused web compilation errors (`_GatheringWorker.destination` is now used correctly and magic-energy deduction stays inside manual attack logic).

## Legacy Historical Notes

- HP indicator is in a dedicated top bar above the map.
- Older map sizes mentioned in history: `800x320`, later `1600x640`.
- Older camera history mentioned free pan and zoom in `InteractiveViewer`.
- Second hero slot and multi-hero support were added earlier in project history.
- Older combat history mentioned a removed `casting` phase. Current implementation uses only `sending -> cooldown`.
- Hero cards, hero selection screen, speed controls, Aerin mode switch, landscape lock, and Thalor sword mode were all introduced earlier and are now part of the project baseline.
