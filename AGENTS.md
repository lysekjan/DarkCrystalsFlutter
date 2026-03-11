# AGENTS.md

## Working Rules For This Project

- Communicate with the user in Czech.
- At the start of each new iteration, read `project_info.txt`. If the file is renamed, read the current `project_info` file instead.
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
- Enemies spawn on the right side in 5 lanes and move left toward the wall.
- The wall has `300 HP`.
- Enemy base HP is `20`, scaled by wave.
- Enemy move speed is `16`.
- Enemy touch targeting uses a tolerant tap radius.
- Game speed can be switched between `1x`, `2x`, `4x`, and `8x`.
- Default game speed is `2x`.

## Hero Cycle

- Heroes use two phases only: `sending -> cooldown`.
- The game now effectively runs in automatic attack mode all the time.
- Heroes are selectable directly on the map.
- Clicking a hero selects it.
- Clicking a map position while a hero is selected gives that hero a move order.
- During movement, the hero cannot attack.
- During movement, cooldown continues to progress normally.
- If cooldown finishes during movement, the attack is queued and starts only after the hero reaches the destination.

## Hero Mechanics

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

- Enemies now use sprite rendering from `assets/enemies/FatGoblin.png`.
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
- The old left hero card panel and the automode switch are removed from gameplay UI.

## Save / RPG Notes

- The game uses slot-based save data.
- Coins, XP, unlocks, and other RPG progress are stored per save slot.

## Change Log Context

- Legacy notes migrated from `AGENTS.dm` on 2026-03-11.
- 2026-03-11: Enemies switched from painted shapes to sprite-sheet rendering using `assets/enemies/FatGoblin.png`.
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

## Legacy Historical Notes

- HP indicator is in a dedicated top bar above the map.
- Older map sizes mentioned in history: `800x320`, later `1600x640`.
- Older camera history mentioned free pan and zoom in `InteractiveViewer`.
- Second hero slot and multi-hero support were added earlier in project history.
- Older combat history mentioned a removed `casting` phase. Current implementation uses only `sending -> cooldown`.
- Hero cards, hero selection screen, speed controls, Aerin mode switch, landscape lock, and Thalor sword mode were all introduced earlier and are now part of the project baseline.
