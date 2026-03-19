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

## Project Summary

- Project: `Dark Crystals`
- Type: Flutter arcade / lane-defense game with a custom game loop and `CustomPainter` rendering.
- Main flow: intro screen -> hero selection -> chapter selection -> level selection -> game scene.
- Core gameplay logic is concentrated mainly in `lib/main.dart`.

## Current Gameplay Model

- Map size is `1600 x 400`.
- The wall is still anchored near the left side at `x = 100`.
- Heroes can no longer move or spawn to the left of the wall; move orders are clamped so they stop just to the right of it.
- There are 5 hero slots.
- Enemies spawn on the right side in 5 lanes but can now move freely through the map.
- The wall has `300 HP`.
- Enemy base HP is `20`, scaled by wave.
- Selected chapter currently only gates access; selected level also multiplies enemy HP by `1.2^(level-1)`.
- Level spawn composition is now driven by per-level `LevelDef` JSON data (`waves` with timed spawn `events`).
- If a level does not yet have JSON data or a local editor override, the game falls back to a deterministic generated legacy template so existing levels remain playable.
- Completing all waves in a level now counts as defending the village: gameplay shows a victory dialog and the active save slot marks that chapter/level pair as completed.
- Enemy move speed is `16`.
- Enemy damage to both wall and heroes is currently `5 DPS`.
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

- Heroes now have HP and can die.
- Current baseline hero HP is `20`, stored per hero definition as `HeroDef.maxHp`.
- Current baseline hero attack range is about one sixth of the screen width, stored per hero definition as `HeroDef.attackRange`.
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
- Kaelen: modes `normal`, `vine`, `spore`.
- Solenne: beam during sending; modes `normal`, `sunburst`, `radiant`.
- Ravik: modes `normal`, `voidburst`, `soul`.
- Brann: modes `normal`, `earthquake`, `boulder`.
- Nyxra: modes `normal`, `lightning`, `voidchain`.
- Nyxra `normal` now also reuses Veyra's old third attack behavior: a single-target lightning strike with the same fast timing and high damage profile.
- Eldrin: modes `normal`, `cosmic`, `nova`.

Detailed balance values are documented in `INFO.txt` and `project_info.txt`.

## Enemy Rendering And Animation

- Enemies now use sprite rendering from `assets/enemies/FatZombie.png`.
- The sprite sheet is split into `33` frames of `90x90`.
- Enemy sprites are mirrored horizontally during draw.
- Walk animation uses frames `8..15`.
- Attack animation uses frames `16..24`.
- If the sprite sheet fails to load, the old painted enemy fallback remains available.

## Enemy Death Behavior

- Enemies are not removed immediately at `hp <= 0`.
- On death, they enter a non-targetable dying state.
- Death animation plays once using the last 6 frames of the sprite sheet.
- After that, the final death frame remains visible for `5` seconds.
- During those 5 seconds, the corpse fades out smoothly.
- Dying enemies do not move, do not damage the wall, and are excluded from targeting / chaining / projectile collision logic.

## Camera / Map Interaction

- The map uses a cover-style default fit under the top HUD, aligned to top-left, and can crop on the right side on narrower displays.
- Zoom `+` and `-` buttons are present on screen.
- Manual zoom is handled through `TransformationController`.
- When zoomed in, single-touch gestures remain reserved for gameplay; map panning is handled manually from the centroid of two active touches instead of relying on `InteractiveViewer` pan gestures.
- The same manual two-finger map panning now also remains available at the default zoom-out level, not only after zooming in.
- Input positions are converted with `TransformationController.toScene(...)` where needed so manual targeting stays accurate.
- For map taps inside the zoomed gameplay view, pointer coordinates must be converted from the `InteractiveViewer` viewport (`globalToLocal`) before calling `TransformationController.toScene(...)`; using the transformed child `localPosition` directly causes offset targets.
- The old left hero card panel and the automode switch are removed from gameplay UI.
- A compact hero-card strip is now shown in the bottom-right gameplay HUD next to the speed panel.
- Each gameplay hero card shows the hero portrait used in hero selection and a small HP bar.
- Clicking a gameplay hero card selects that hero exactly like clicking the hero unit on the map.
- When a hero dies, that hero's gameplay card remains visible but becomes greyed out.

## Enemy Targeting Behavior

- Each tick, every living enemy looks for the nearest living hero that is to the left of the enemy on the X axis.
- Heroes on the right side of an enemy are ignored by that enemy.
- If a valid hero exists, the enemy moves directly toward that hero using full 2D movement.
- If the enemy reaches melee range, it stops and damages that hero over time.
- If an enemy reaches the wall line, the wall becomes the immediate priority and the enemy attacks it instead of continuing to chase heroes behind that line.
- If no valid hero exists ahead of the enemy, the enemy moves straight left toward the wall and attacks the wall on contact.
- Enemy targeting is not locked; if the player moves a hero away, the enemy can immediately switch targets on the next tick.

## Save / RPG Notes

- The game uses slot-based save data.
- Coins, XP, unlocks, and other RPG progress are stored per save slot.
- Hero unlock gating is temporarily disabled: all heroes are now forced unlocked for both new and already existing save slots until the unlock economy is tuned again.
- After hero selection, the player now goes through a chapter-selection screen and then a level-selection screen before gameplay starts.
- After save-slot selection, the player now first enters a village hub screen that serves as the main crossroads for heroes/upgrades and the battle flow.
- The village hub now also contains a separate `Pruzkum` entry point with its own chapter/level placeholder flow, independent from village defense.
- There are currently 2 chapters in the selector, but only chapter 1 is unlocked.
- Chapter 1 currently contains 19 selectable levels.

## Change Log Context

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

## Legacy Historical Notes

- HP indicator is in a dedicated top bar above the map.
- Older map sizes mentioned in history: `800x320`, later `1600x640`.
- Older camera history mentioned free pan and zoom in `InteractiveViewer`.
- Second hero slot and multi-hero support were added earlier in project history.
- Older combat history mentioned a removed `casting` phase. Current implementation uses only `sending -> cooldown`.
- Hero cards, hero selection screen, speed controls, Aerin mode switch, landscape lock, and Thalor sword mode were all introduced earlier and are now part of the project baseline.
