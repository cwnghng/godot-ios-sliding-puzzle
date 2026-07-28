# Step 7: Implement win detection & overlay

## Goal
After each confirmed tile move, check whether the grid matches the solved state. If it does, emit `puzzle_solved` with the move count. In `Main.gd`, receive that signal and show the win overlay (which already exists from step 2). Verify the restart button resets and reshuffles correctly.

## Prerequisites
Step 6 complete (`move_made` signal fires on each confirmed move; `restart()` exists).

## Files to touch
- `godot/scripts/PuzzleBoard.gd` — add `_is_solved()` and call it in `_on_drag_released()`
- `godot/scripts/Main.gd` — wire up `puzzle_solved` signal and `_on_puzzle_solved()` handler

## Changes

### `_is_solved()` in PuzzleBoard.gd
```gdscript
func _is_solved() -> bool:
    for r in range(4):
        for c in range(4):
            var expected = r * 4 + c
            if expected == 15:
                if grid[r][c] != -1:
                    return false
            else:
                if grid[r][c] != expected:
                    return false
    return true
```

### Call `_is_solved()` in `_on_drag_released()` — add after `move_made.emit()`
```gdscript
    if dist_to_empty <= dist_to_origin:
        # ... existing commit logic ...
        move_count += 1
        move_made.emit(move_count)
        if _is_solved():
            puzzle_solved.emit(move_count)
```

### Wire signals in Main.gd `_ready()`
```gdscript
func _ready():
    puzzle_board.move_made.connect(_on_move_made)
    puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
    restart_button.pressed.connect(_on_restart_pressed)
```

### `_on_puzzle_solved` in Main.gd
```gdscript
func _on_puzzle_solved(total_moves: int) -> void:
    win_moves_label.text = "Moves: %d" % total_moves
    win_overlay.visible = true
```

### `_on_restart_pressed` in Main.gd
```gdscript
func _on_restart_pressed() -> void:
    win_overlay.visible = false
    puzzle_board.restart()
```

### WinOverlay input blocking
The WinOverlay Control node must have `mouse_filter = MOUSE_FILTER_STOP` so touches on the overlay don't pass through to PuzzleBoard beneath it. Set this in the scene or via code in `Main._ready()`:
```gdscript
win_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
```

## Acceptance criteria
- [ ] Manually solving the puzzle (or testing with a nearly-solved shuffle) triggers the win overlay
- [ ] Win overlay shows the correct move count
- [ ] Touching the puzzle board while the win overlay is visible does nothing (overlay blocks input)
- [ ] Pressing "Play Again" hides the overlay, resets the move counter to 0, and presents a new shuffled puzzle
- [ ] Winning a second time shows the correct move count for that round (not cumulative)
- [ ] No script errors in the Godot output panel

## Test commands
```bash
# To test win detection quickly:
# 1. Temporarily change SHUFFLE_MOVES to 1 in PuzzleBoard.gd
# 2. Play — puzzle will be nearly solved; make the one correct move
# 3. Verify win overlay appears with "Moves: 1"
# 4. Press Play Again — verify reset and reshuffle
# 5. Restore SHUFFLE_MOVES to 200
```

## Rollback
`git revert` the commit, or remove `_is_solved()` from PuzzleBoard.gd and `_on_puzzle_solved()` / signal connections from Main.gd.

## Notes
- `_is_solved()` checks the empty cell explicitly (expects `grid[3][3] == -1`) as well as all 15 tile positions.
- The solved check runs only after a committed move — never during a drag — so there is no risk of triggering a false win mid-drag.
- The WinOverlay's `MOUSE_FILTER_STOP` is the critical detail: without it, taps on the overlay would pass through and start unintended drags.
