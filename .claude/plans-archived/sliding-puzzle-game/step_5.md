# Step 5: Implement drag input

## Goal
Handle touch input on `PuzzleBoard`. When the player touches a tile that is adjacent to the empty space, the tile follows the finger along the single valid axis (horizontal or vertical only), clamped so it cannot leave the region between its origin and the empty cell. Touching a non-adjacent tile does nothing.

## Prerequisites
Step 4 complete (grid state and tile nodes exist and are shuffled).

## Files to touch
- `godot/scripts/PuzzleBoard.gd` — add drag state variables and `_input()` handler

## Changes

### Drag state variables
```gdscript
var dragging: bool = false
var drag_tile_idx: int = -1       # index into tiles[]
var drag_tile_grid: Vector2i      # grid pos of the tile being dragged
var drag_origin_px: Vector2       # pixel position at drag start
var drag_empty_px: Vector2        # pixel position of the empty cell
var drag_axis: int = -1           # 0 = horizontal, 1 = vertical
var drag_touch_id: int = -1       # finger ID
```

### Hit-testing: which tile is at a pixel position
```gdscript
func _tile_at_pixel(pos: Vector2) -> Vector2i:
    # Returns grid cell (col, row) if pos lands on a tile, else (-1,-1)
    var gc = pixel_to_grid(pos)
    if gc.x < 0 or gc.x >= 4 or gc.y < 0 or gc.y >= 4:
        return Vector2i(-1, -1)
    # Confirm pos is inside the tile rect (not in the gap)
    var tile_origin = grid_to_pixel(gc.x, gc.y)
    var local = pos - tile_origin
    if local.x >= 0 and local.x <= tile_size and local.y >= 0 and local.y <= tile_size:
        return gc
    return Vector2i(-1, -1)
```

### Adjacency check
```gdscript
func _is_adjacent_to_empty(gc: Vector2i) -> bool:
    var diff = gc - empty_pos
    return (abs(diff.x) + abs(diff.y)) == 1
```

### `_input(event)` handler
```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not dragging:
            var gc = _tile_at_pixel(event.position)
            if gc == Vector2i(-1, -1):
                return
            if not _is_adjacent_to_empty(gc):
                return
            # Begin drag
            var diff = empty_pos - gc
            drag_axis = 0 if diff.x != 0 else 1   # 0=horizontal, 1=vertical
            dragging = true
            drag_touch_id = event.index
            drag_tile_idx = grid[gc.y][gc.x]
            drag_tile_grid = gc
            drag_origin_px = grid_to_pixel(gc.x, gc.y)
            drag_empty_px  = grid_to_pixel(empty_pos.x, empty_pos.y)
        elif not event.pressed and dragging and event.index == drag_touch_id:
            # Touch released — handled in step 6
            _on_drag_released(event.position)

    elif event is InputEventScreenDrag and dragging and event.index == drag_touch_id:
        _update_drag(event.position)
```

### `_update_drag(touch_pos: Vector2)` — move tile with finger
```gdscript
func _update_drag(touch_pos: Vector2) -> void:
    var tile = tiles[drag_tile_idx]
    # Compute raw delta from drag start
    var delta = touch_pos - (drag_origin_px + Vector2(tile_size, tile_size) * 0.5)
    # Project onto drag axis
    var new_pos = drag_origin_px
    if drag_axis == 0:   # horizontal
        var raw_x = drag_origin_px.x + delta.x
        var min_x = min(drag_origin_px.x, drag_empty_px.x)
        var max_x = max(drag_origin_px.x, drag_empty_px.x)
        new_pos.x = clamp(raw_x, min_x, max_x)
    else:                # vertical
        var raw_y = drag_origin_px.y + delta.y
        var min_y = min(drag_origin_px.y, drag_empty_px.y)
        var max_y = max(drag_origin_px.y, drag_empty_px.y)
        new_pos.y = clamp(raw_y, min_y, max_y)
    tile.position = new_pos
```

## Acceptance criteria
- [ ] Touching a tile adjacent to the empty space makes it follow the finger
- [ ] Movement is strictly horizontal OR vertical (no diagonal drift)
- [ ] The tile cannot be dragged past the empty space or back past its origin
- [ ] Touching a non-adjacent tile does nothing
- [ ] Two fingers don't interfere (second touch ignored while one drag is active)

## Test commands
```bash
# Play in Godot editor with "Emulate Touch From Mouse" enabled
# Click and drag adjacent tiles; verify axis constraint and clamping
```

## Rollback
`git revert` the commit, or remove the `_input()`, `_update_drag()`, and `_tile_at_pixel()` methods from PuzzleBoard.gd.

## Notes
- `event.index` is the finger ID. We capture it at touch-down and ignore all other finger events while a drag is active. This prevents two simultaneous drags.
- The delta is computed from the center of the tile, not from where the finger initially landed, to avoid a jump at drag start.
- `pixel_to_grid()` uses integer division, so it cleanly maps a pixel inside a gap to the nearest tile cell. The gap-exclusion check in `_tile_at_pixel` ensures taps in the gap don't accidentally start a drag.
