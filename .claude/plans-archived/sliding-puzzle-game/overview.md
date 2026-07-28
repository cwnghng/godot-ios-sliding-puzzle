# Plan: Sliding Puzzle Game

## Objective
Build a 4×4 sliding puzzle in Godot 4.7 (portrait, iOS). The player drags tiles adjacent to the empty space along a single axis; tiles snap on release. The puzzle is guaranteed solvable at start. A win overlay appears when solved, showing move count and a restart button.

## Background & context
- **Project state:** Greenfield — no scenes or scripts exist. Only `project.godot` and `assets/images/art.png`.
- **Godot version:** 4.7, Mobile renderer, canvas_items stretch (expand aspect).
- **Image:** `assets/images/art.png` — ~1080×1080 kawaii animal illustration. Will be split into 16 equal `AtlasTexture` regions (one per tile).
- **Layout formula:**
  - `tile_size = min(viewport.x, viewport.y) × 0.20`
  - `gap = max(tile_size × 0.02, 4.0)`
  - Grid width = `4 × tile_size + 3 × gap`
  - Grid anchored to center of viewport

## Approach
One main scene (`Main.tscn` + `Main.gd`) owns a `PuzzleBoard` node. `PuzzleBoard.gd` holds all game logic: grid state, shuffle, win detection, move counter. Each tile is a `TextureRect` controlled by `PuzzleBoard` — no per-tile script needed, since all interaction is handled centrally via `_input` events on the board. `AtlasTexture` slices the image at runtime so no pre-split assets are needed.

## Constraints & decisions
- Portrait orientation locked in `project.godot`
- Tile drag constrained to single axis (horizontal OR vertical) toward empty space
- Snap on touch release: closer to empty space → move there; closer to origin → return
- Shuffle uses random valid moves from solved state (guarantees solvability)
- Move counter incremented only on confirmed tile placement (not on drag)
- Win detected after every confirmed move; win overlay blocks input
- No tile number labels, no sound, no animations beyond drag/snap
- GDScript throughout

## Out of scope
- Sound effects or music
- Animated transitions
- Persistence (save state, high scores)
- Tile number labels
- Landscape orientation
- Multiple puzzle images or difficulty levels

## Steps (overview)
1. [Configure project settings](./step_1.md) — lock portrait orientation, enable touch emulation in editor, set main scene path
2. [Create Main scene](./step_2.md) — `Main.tscn` with CanvasLayer root, PuzzleBoard Control node, move counter Label, and win overlay
3. [Implement PuzzleBoard layout](./step_3.md) — compute tile_size/gap, center the 4×4 grid, create 15 TextureRect tiles with AtlasTexture slices
4. [Implement shuffle](./step_4.md) — solvable shuffle via N random valid moves from solved state
5. [Implement drag input](./step_5.md) — detect touch on tile adjacent to empty space, constrain motion to single axis, follow finger within bounds
6. [Implement snap logic](./step_6.md) — on touch release snap to empty space or back to origin; update grid state; increment move counter
7. [Implement win detection & overlay](./step_7.md) — check solved state after each confirmed move; show overlay with move count and restart button

## Testing strategy
Manual play-testing in the Godot editor (mouse simulates touch via "Emulate Touch From Mouse"). Verify: tiles adjacent to empty space drag correctly; non-adjacent tiles ignore input; snap goes to correct position; move counter increments only on confirmed moves; win overlay appears correctly; restart reshuffles and resets counter.

## Migration & rollback
Greenfield — `git revert` any commit to undo. No data migration needed.

## Risks & open questions
- `viewport.get_visible_rect().size` is available only after the scene is in the tree; layout must run in `_ready()`.
- `InputEventScreenTouch` / `InputEventScreenDrag` are the correct events for mobile; editor testing uses "Emulate Touch From Mouse".
- `AtlasTexture` requires the source texture to be loaded — default PNG import settings are fine.
