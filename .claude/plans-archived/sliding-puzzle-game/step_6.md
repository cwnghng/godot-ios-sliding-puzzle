# Step 6: Implement snap logic

## Goal
When the player releases a dragged tile, snap it to the empty cell if it is closer to the empty space than to its origin; otherwise snap it back to its origin. Update the grid state and emit `move_made` only when the tile commits to the empty space. Reset drag state in all cases.

## Prerequisites
Step 5 complete (drag input and `_on_drag_released` stub exist).

## Files to touch
- `godot/scripts/PuzzleBoard.gd` — implement `_on_drag_released()` and add `move_count` variable

## Changes

### Move counter variable
```gdscript
var move_count: int = 0
```

### `_on_drag_released(touch_pos: Vector2)` — snap decision
```gdscript
func _on_drag_released(_touch_pos: Vector2) -> void:
    var tile = tiles[drag_tile_idx]
    # Current tile pixel position (already clamped to axis by _update_drag)
    var current_pos = tile.position
    # Distance from current position to each snap target
    var dist_to_empty  = current_pos.distance_to(drag_empty_px)
    var dist_to_origin = current_pos.distance_to(drag_origin_px)

    if dist_to_empty <= dist_to_origin:
        # Commit: snap to empty space
        tile.position = drag_empty_px
        grid[drag_tile_grid.y][drag_tile_grid.x] = -1
        grid[empty_pos.y][empty_pos.x] = drag_tile_idx
        empty_pos = drag_tile_grid
        move_count += 1
        move_made.emit(move_count)
    else:
        # Cancel: snap back to origin
        tile.position = drag_origin_px

    _reset_drag()
```

### `_reset_drag()`
```gdscript
func _reset_drag() -> void:
    dragging = false
    drag_tile_idx = -1
    drag_touch_id = -1
    drag_axis = -1
```

### `restart()` method (called by Main when restart button is pressed)
```gdscript
func restart() -> void:
    move_count = 0
    # Reset grid and tile positions to solved state
    for r in range(4):
        for c in range(4):
            var idx = r * 4 + c
            if idx < 15:
                grid[r][c] = idx
                tiles[idx].position = grid_to_pixel(c, r)
            else:
                grid[r][c] = -1
    empty_pos = Vector2i(3, 3)
    _reset_drag()
    shuffle()
    move_made.emit(move_count)   # reset counter label to 0
```

## Acceptance criteria
- [ ] Releasing a tile that is past the halfway point snaps it to the empty space
- [ ] Releasing a tile before the halfway point snaps it back to its origin
- [ ] `move_count` increments by 1 on each committed move
- [ ] `move_made` signal fires with the updated count after each commit
- [ ] `move_made` does NOT fire when the tile snaps back
- [ ] Grid state (`grid[][]` and `empty_pos`) is correct after each commit
- [ ] `restart()` resets the counter, reshuffles, and emits `move_made(0)`

## Test commands
```bash
# Play in editor:
# 1. Drag a tile just past halfway → confirm it snaps to empty space
# 2. Drag a tile less than halfway → confirm it returns to origin
# 3. Watch the move counter label; it should only increment on committed moves
```

## Rollback
`git revert` the commit, or remove `_on_drag_released()`, `_reset_drag()`, `restart()`, and `move_count` from PuzzleBoard.gd.

## Notes
- The "halfway" threshold emerges naturally from comparing `dist_to_empty` and `dist_to_origin` — no explicit midpoint calculation needed.
- `empty_pos = drag_tile_grid` is correct: after the tile moves into the empty cell, the cell the tile came from becomes the new empty cell.
- The snap is instant (no tween). A tween could be added later as a visual polish step without changing any game logic.
