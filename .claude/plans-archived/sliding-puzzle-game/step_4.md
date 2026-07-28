# Step 4: Implement shuffle

## Goal
Add a `shuffle()` method to `PuzzleBoard.gd` that randomizes the grid by performing N random valid moves from the solved state, guaranteeing the result is always solvable. Call it at the end of `_ready()` so the puzzle starts shuffled.

## Prerequisites
Step 3 complete (PuzzleBoard.gd exists with grid state and tile nodes).

## Files to touch
- `godot/scripts/PuzzleBoard.gd` — add `shuffle()` and `_apply_move()` methods, call shuffle in `_ready()`

## Changes

### Constants
```gdscript
const SHUFFLE_MOVES = 200   # enough randomness; odd number avoids trivial reversal
```

### Direction vectors (reusable across shuffle and input)
```gdscript
const DIRECTIONS = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
# up, down, left, right — relative to a tile moving toward empty
```

### `_apply_move(tile_grid_pos: Vector2i)` — moves a tile into the empty cell
```gdscript
func _apply_move(tile_pos: Vector2i) -> void:
    var tile_idx = grid[tile_pos.y][tile_pos.x]
    grid[empty_pos.y][empty_pos.x] = tile_idx
    grid[tile_pos.y][tile_pos.x] = -1
    # Snap the TextureRect to its new pixel position
    tiles[tile_idx].position = grid_to_pixel(empty_pos.x, empty_pos.y)
    empty_pos = tile_pos
```

### `shuffle()` — random valid moves
```gdscript
func shuffle() -> void:
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var last_move = Vector2i(-1, -1)   # prevent immediate reversal
    for i in range(SHUFFLE_MOVES):
        var candidates = []
        for d in DIRECTIONS:
            var neighbor = empty_pos + d
            if neighbor.x >= 0 and neighbor.x < 4 and neighbor.y >= 0 and neighbor.y < 4:
                if neighbor != last_move:
                    candidates.append(neighbor)
        if candidates.is_empty():
            continue
        var chosen = candidates[rng.randi() % candidates.size()]
        last_move = empty_pos   # the cell that was empty is now occupied — prevent going back
        _apply_move(chosen)
```

### Call in `_ready()`
```gdscript
func _ready():
    _compute_layout()
    _build_board()
    shuffle()
```

### Why this guarantees solvability
Every move in `_apply_move()` is a legal sliding-puzzle move. Starting from the solved state and applying only legal moves always produces a reachable (solvable) configuration. The 15-puzzle has exactly half of all permutations reachable from solved; this approach stays in that half by construction.

## Acceptance criteria
- [ ] Running the project shows tiles in a shuffled (non-solved) arrangement
- [ ] Repeated restarts produce different shuffles
- [ ] The puzzle is solvable (can be manually solved in the editor)
- [ ] No two consecutive moves reverse each other (last_move guard works)

## Test commands
```bash
# Press Play in Godot editor multiple times; confirm different shuffles appear
# No automated test command — visual verification
```

## Rollback
`git revert` the commit, or remove the `shuffle()` call from `_ready()` to restore a solved starting state.

## Notes
- 200 moves is well above the "God's number" for the 15-puzzle (~80 moves) so the result is effectively fully random within the reachable set.
- `last_move` stores the *previously empty* cell, preventing the shuffle from immediately reversing the last step. This doesn't overly constrain randomness — it just avoids degenerate back-and-forth sequences.
