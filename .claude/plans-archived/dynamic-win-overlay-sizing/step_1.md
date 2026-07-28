# Step 1: Add missing onready refs

## Goal
Add `@onready` references for `WinLabel` and `MoveCounterLabel` to `Main.gd` so the dynamic sizing function in Step 2 can access them.

## Prerequisites
None.

## Files to touch
- `godot/scripts/Main.gd` — add two `@onready` variable declarations

## Changes
Add these two lines in the `@onready` block at the top of `Main.gd`, alongside the existing refs:

```gdscript
@onready var win_label = $CanvasLayer/WinOverlay/WinLabel
@onready var move_counter_label = $CanvasLayer/MoveCounterLabel
```

The block should look like this afterward:

```gdscript
@onready var puzzle_board = $CanvasLayer/PuzzleBoard
@onready var move_counter_label = $CanvasLayer/MoveCounterLabel
@onready var win_overlay = $CanvasLayer/WinOverlay
@onready var win_label = $CanvasLayer/WinOverlay/WinLabel
@onready var win_moves_label = $CanvasLayer/WinOverlay/MovesLabel
@onready var restart_button = $CanvasLayer/WinOverlay/RestartButton
```

## Acceptance criteria
- [ ] `win_label` and `move_counter_label` are declared as `@onready` vars in `Main.gd`
- [ ] Node paths match the paths in `Main.tscn`
- [ ] Project still opens without errors in Godot editor

## Test commands
```bash
# No automated tests — open in Godot editor and confirm no script errors in the Output panel
```

## Rollback
`git revert` the commit, or manually delete the two added lines.

## Notes
`MoveCounterLabel` is a sibling of `WinOverlay` under `CanvasLayer`, not a child of it — confirm the node path from `Main.tscn:22`.
