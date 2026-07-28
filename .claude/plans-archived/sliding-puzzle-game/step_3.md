# Step 3: Implement PuzzleBoard layout

## Goal
Create `PuzzleBoard.gd` and the `PuzzleBoard` Control node. On `_ready`, compute tile size and gap from the viewport, place the grid centered on screen, and create 15 `TextureRect` tile nodes each showing the correct slice of `art.png` via `AtlasTexture`. Tile 16 (bottom-right, index 15) is left empty.

## Prerequisites
Step 2 complete (Main.tscn exists with PuzzleBoard node placeholder).

## Files to touch
- `godot/scripts/PuzzleBoard.gd` — new script with layout logic
- `godot/scenes/Main.tscn` — attach `PuzzleBoard.gd` to the PuzzleBoard Control node

## Changes

### Key constants / computed values
```
GRID_SIZE    = 4
tile_size    = min(viewport_width, viewport_height) * 0.20
gap          = max(tile_size * 0.02, 4.0)
cell_size    = tile_size + gap          # stride between tile origins
grid_px      = 4 * tile_size + 3 * gap # total grid width/height
grid_origin  = (viewport_size - Vector2(grid_px, grid_px)) / 2.0
```

### Grid coordinate helpers
```gdscript
func grid_to_pixel(col: int, row: int) -> Vector2:
    return grid_origin + Vector2(col * cell_size, row * cell_size)

func pixel_to_grid(pos: Vector2) -> Vector2i:
    var local = pos - grid_origin
    return Vector2i(int(local.x / cell_size), int(local.y / cell_size))
```

### Board state
```gdscript
# grid[row][col] = tile_index (0..14), or -1 for empty
var grid: Array = []          # 4×4, populated in _build_board()
var empty_pos: Vector2i       # current grid position of the empty cell
var tiles: Array = []         # Array of TextureRect nodes, index = tile_index 0..14
```

Solved state: `grid[r][c] == r * 4 + c` for all (r,c) except empty cell at (3,3) which holds -1.

### AtlasTexture slicing
```gdscript
var source_tex = load("res://assets/images/art.png")
var img_size = source_tex.get_size()   # e.g. Vector2(1080, 1080)
var slice_w = img_size.x / 4.0
var slice_h = img_size.y / 4.0

func _make_atlas(tile_index: int) -> AtlasTexture:
    var col = tile_index % 4
    var row = tile_index / 4
    var atlas = AtlasTexture.new()
    atlas.atlas = source_tex
    atlas.region = Rect2(col * slice_w, row * slice_h, slice_w, slice_h)
    return atlas
```

### Tile creation
```gdscript
func _build_board():
    grid = []
    tiles = []
    empty_pos = Vector2i(3, 3)

    for r in range(4):
        var row_arr = []
        for c in range(4):
            var idx = r * 4 + c
            if idx == 15:
                row_arr.append(-1)   # empty cell
            else:
                row_arr.append(idx)
                var tr = TextureRect.new()
                tr.texture = _make_atlas(idx)
                tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                tr.stretch_mode = TextureRect.STRETCH_SCALE
                tr.custom_minimum_size = Vector2(tile_size, tile_size)
                tr.size = Vector2(tile_size, tile_size)
                tr.position = grid_to_pixel(c, r)
                tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
                add_child(tr)
                tiles.append(tr)
        grid.append(row_arr)
```

### PuzzleBoard node setup
- Node type: `Control`
- Anchors: full rect (so it covers the whole viewport for input)
- Script: `res://scripts/PuzzleBoard.gd`
- `mouse_filter = MOUSE_FILTER_STOP` so touch events are received

### Signals to declare
```gdscript
signal move_made(total_moves: int)
signal puzzle_solved(total_moves: int)
```

Connect these to Main.gd in `Main._ready()`:
```gdscript
puzzle_board.move_made.connect(_on_move_made)
puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
```

## Acceptance criteria
- [ ] Running the project shows 15 tiles arranged in a 4×4 grid, centered on screen
- [ ] Each tile displays the correct slice of art.png (dog top-left, etc.)
- [ ] Bottom-right cell is visibly empty
- [ ] Tile size is approximately 20% of the shorter viewport dimension
- [ ] Small gap is visible between tiles
- [ ] No script errors in the Godot output panel

## Test commands
```bash
# Open in Godot editor and press Play (F5)
# Visually confirm grid layout and image slicing
ls godot/scripts/PuzzleBoard.gd
```

## Rollback
`git revert` the commit, or delete `godot/scripts/PuzzleBoard.gd` and remove the script attachment from the PuzzleBoard node in Main.tscn.

## Notes
- `TextureRect.EXPAND_IGNORE_SIZE` + `STRETCH_SCALE` makes the texture fill the node's rect regardless of the source image size.
- `mouse_filter = MOUSE_FILTER_IGNORE` on individual tiles ensures touch events bubble up to the PuzzleBoard Control, which handles all input centrally.
- The `tiles` array is indexed by `tile_index` (0..14). `grid[r][c]` stores tile indices, not node references — this separation keeps state management clean.
