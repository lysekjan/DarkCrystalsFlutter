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
- Main flow: intro screen -> hero selection -> game scene.
- Core gameplay logic is concentrated mainly in `lib/main.dart`.

## Current Gameplay Model

- Map size is `1600 x 400`.
- The wall is still anchored near the left side at `x = 100`.
- There are 5 hero slots.
- Enemies spawn on the right side in 5 lanes but can now move freely through the map.
- The wall has `300 HP`.
- Enemy base HP is `20`, scaled by wave.
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
- During movement, the hero cannot attack.
- During movement, cooldown continues to progress normally.
- If cooldown finishes during movement, the attack is queued and starts only after the hero reaches the destination.
- If no valid enemy target exists, heroes do not spend an attack cycle.
- After cooldown reaches zero without a target, the hero waits in a ready state and starts `sending` immediately once a valid target appears.
- A hero can begin auto-attack only if at least one enemy is inside that hero's current attack range.

## Hero Mechanics

- Heroes now have HP and can die.
- Current baseline hero HP is `20`, stored per hero definition as `HeroDef.maxHp`.
- Current baseline hero attack range is about one third of the screen width, stored per hero definition as `HeroDef.attackRange`.
- Dead heroes disappear from the map, stop attacking, stop being selectable, and are ignored by enemy targeting.
- Selecting a hero on the map now also shows a context mode menu next to that hero.
- The context menu uses the same attack-mode icons that were previously shown in the old slot/card UI.
- Selecting or re-clicking a hero also shows a translucent circle for that hero's current attack range.
- The attack-range circle stays fully visible for `5` seconds and then fades out smoothly.
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
- Kaelen: modes `normal`, `vine`, `spore`.
- Solenne: beam during sending; modes `normal`, `sunburst`, `radiant`.
- Ravik: modes `normal`, `voidburst`, `soul`.
- Brann: modes `normal`, `earthquake`, `boulder`.
- Nyxra: modes `normal`, `lightning`, `voidchain`.
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

- The map is fit-to-width by default.
- Zoom `+` and `-` buttons are present on screen.
- Manual zoom is handled through `TransformationController`.
- When zoomed in, panning is enabled.
- Input positions are converted with `TransformationController.toScene(...)` where needed so manual targeting stays accurate.
- For map taps inside the zoomed gameplay view, pointer coordinates must be converted from the `InteractiveViewer` viewport (`globalToLocal`) before calling `TransformationController.toScene(...)`; using the transformed child `localPosition` directly causes offset targets.
- The old left hero card panel and the automode switch are removed from gameplay UI.

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
- 2026-03-13: Zoom `+` and `-` controls were moved from their own second bar into the main top HUD bar, positioned immediately left of the menu button to give the map more vertical space.
- 2026-03-13: Fullscreen handling was hardened across the app: immersive sticky mode is now reapplied at startup and when the app resumes, and screen disposes no longer switch back to edge-to-edge, reducing Android status-bar bleed-through.
- 2026-03-13: The Flutter debug banner in the top-right corner was disabled in `MaterialApp`.
- 2026-03-13: Added a simple fixed defense tower in the upper-left area left of the wall; it auto-fires every 5 seconds at the nearest enemy within hero-range distance and deals 10 projectile damage per hit.
- 2026-03-13: `Restart` now fully resets the run to its initial state: wave/stat counters, game timer, hero positions, hero behavior/mode settings, zoom, selection state, and game speed all return to startup defaults.

## Legacy Historical Notes

- HP indicator is in a dedicated top bar above the map.
- Older map sizes mentioned in history: `800x320`, later `1600x640`.
- Older camera history mentioned free pan and zoom in `InteractiveViewer`.
- Second hero slot and multi-hero support were added earlier in project history.
- Older combat history mentioned a removed `casting` phase. Current implementation uses only `sending -> cooldown`.
- Hero cards, hero selection screen, speed controls, Aerin mode switch, landscape lock, and Thalor sword mode were all introduced earlier and are now part of the project baseline.
