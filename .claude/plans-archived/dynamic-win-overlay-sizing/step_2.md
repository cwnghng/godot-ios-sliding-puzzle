# Step 2: Add `_apply_dynamic_sizing()` and call it from `_ready()`

## Goal
Compute font size and node offsets from the viewport size at startup, and apply them to all four UI nodes so they scale correctly on any iPhone resolution.

## Prerequisites
Step 1 must be complete (`win_label` and `move_counter_label` onready vars exist).

## Files to touch
- `godot/scripts/Main.gd` — add `_apply_dynamic_sizing()` function and call it from `_ready()`

## Changes

### Sizing rationale
All values are derived from `tile_size = min(vp.x, vp.y) * 0.20`, which is identical to `PuzzleBoard.gd:35`. At a 375px viewport (iPhone SE logical width), `tile_size = 75`, reproducing the original hardcoded values:

| Original pixel | tile_size multiple |
|---|---|
| font_size 32 | tile_size × 0.43 ≈ 32 |
| WinLabel ±150 wide | tile_size × 2.0 |
| WinLabel top −80 / −40 | tile_size × −1.07 / −0.53 |
| MovesLabel ±100 wide | tile_size × 1.33 |
| MovesLabel top −20 / +20 | tile_size × −0.27 / +0.27 |
| RestartButton ±80 wide | tile_size × 1.07 |
| RestartButton top +40 / +80 | tile_size × 0.53 / 1.07 |
| MoveCounterLabel ±100 wide | tile_size × 1.33 |
| MoveCounterLabel top +20 / +60 | tile_size × 0.27 / 0.80 |

### Add the function

```gdscript
func _apply_dynamic_sizing() -> void:
	var vp = get_viewport_rect().size
	var vp_min = min(vp.x, vp.y)
	var tile_size = vp_min * 0.20
	var font_size = int(tile_size * 0.43)

	# Font sizes
	win_label.add_theme_font_size_override("font_size", font_size)
	win_moves_label.add_theme_font_size_override("font_size", font_size)
	restart_button.add_theme_font_size_override("font_size", font_size)
	move_counter_label.add_theme_font_size_override("font_size", font_size)

	# WinLabel offsets (center-anchored)
	win_label.offset_left   = -tile_size * 2.0
	win_label.offset_right  =  tile_size * 2.0
	win_label.offset_top    = -tile_size * 1.07
	win_label.offset_bottom = -tile_size * 0.53

	# MovesLabel offsets (center-anchored)
	win_moves_label.offset_left   = -tile_size * 1.33
	win_moves_label.offset_right  =  tile_size * 1.33
	win_moves_label.offset_top    = -tile_size * 0.27
	win_moves_label.offset_bottom =  tile_size * 0.27

	# RestartButton offsets (center-anchored) + minimum tap size
	restart_button.offset_left   = -tile_size * 1.07
	restart_button.offset_right  =  tile_size * 1.07
	restart_button.offset_top    =  tile_size * 0.53
	restart_button.offset_bottom =  tile_size * 1.07
	restart_button.custom_minimum_size = Vector2(tile_size * 2.13, tile_size * 0.53)

	# MoveCounterLabel offsets (top-center-anchored)
	move_counter_label.offset_left   = -tile_size * 1.33
	move_counter_label.offset_right  =  tile_size * 1.33
	move_counter_label.offset_top    =  tile_size * 0.27
	move_counter_label.offset_bottom =  tile_size * 0.80
```

### Call it from `_ready()`

Add `_apply_dynamic_sizing()` as the first call inside `_ready()`:

```gdscript
func _ready():
	_apply_dynamic_sizing()
	restart_button.pressed.connect(_on_restart_pressed)
	puzzle_board.move_made.connect(_on_move_made)
	puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
	win_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
```

## Acceptance criteria
- [ ] `_apply_dynamic_sizing()` is defined and called first in `_ready()`
- [ ] All four nodes receive a `font_size` theme override
- [ ] All four nodes have their offsets set from `tile_size` multiples
- [ ] RestartButton has `custom_minimum_size` set
- [ ] On a simulated or real high-resolution iPhone, the win overlay text and button are visibly larger than before and proportionate to the puzzle board

## Test commands
```bash
# No automated tests — build and run on an iPhone simulator or device.
# Solve the puzzle (or temporarily call puzzle_solved.emit() from _ready() to force the overlay)
# and verify the overlay text fills the screen comfortably.
```

## Rollback
`git revert` the commit, or remove `_apply_dynamic_sizing()` and its call from `_ready()`.

## Notes
- `add_theme_font_size_override` wins over the `LabelSettings` resource set in the tscn — no tscn edits needed.
- The `MoveCounterLabel` uses `anchors_preset = 5` (top-center) in the tscn, so its offset origin is the top-center of the viewport. The offset values above match that anchor.
- If the overlay looks vertically cramped or too spread out on a particular device, adjust the `tile_size` multipliers for `offset_top` / `offset_bottom` on each node. The font size multiplier (0.43) should stay stable.
