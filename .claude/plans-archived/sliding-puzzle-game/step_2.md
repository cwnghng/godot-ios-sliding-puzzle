# Step 2: Create Main scene

## Goal
Create the scene tree skeleton: `Main.tscn` with a move counter Label and a win overlay (hidden by default). No game logic yet — just the node structure that later steps will populate.

## Prerequisites
Step 1 complete (main scene path set in project.godot).

## Files to touch
- `godot/scenes/Main.tscn` — new scene file
- `godot/scripts/Main.gd` — new script (minimal, wires up the board signal)

## Changes

### Directory structure to create
```
godot/scenes/
godot/scripts/
```

### Main.tscn node tree
```
Main  (Node2D, script: res://scripts/Main.gd)
└── CanvasLayer
    ├── PuzzleBoard  (Control, script: res://scripts/PuzzleBoard.gd)  [created in step 3]
    ├── MoveCounterLabel  (Label)
    │     anchors: top-center
    │     text: "Moves: 0"
    └── WinOverlay  (Control, full-rect anchors, visible=false)
          ├── WinBackground  (ColorRect, full-rect, color=#000000 alpha=0.7)
          ├── WinLabel  (Label, text="You solved it!", centered)
          ├── MovesLabel  (Label, text="Moves: 0", centered, below WinLabel)
          └── RestartButton  (Button, text="Play Again", centered)
```

### Main.gd
```gdscript
extends Node2D

@onready var puzzle_board = $CanvasLayer/PuzzleBoard
@onready var move_counter_label = $CanvasLayer/MoveCounterLabel
@onready var win_overlay = $CanvasLayer/WinOverlay
@onready var win_moves_label = $CanvasLayer/WinOverlay/MovesLabel
@onready var restart_button = $CanvasLayer/WinOverlay/RestartButton

func _ready():
    restart_button.pressed.connect(_on_restart_pressed)

func _on_move_made(total_moves: int):
    move_counter_label.text = "Moves: %d" % total_moves

func _on_puzzle_solved(total_moves: int):
    win_moves_label.text = "Moves: %d" % total_moves
    win_overlay.visible = true

func _on_restart_pressed():
    win_overlay.visible = false
    puzzle_board.restart()
```

Signals `move_made` and `puzzle_solved` will be emitted by `PuzzleBoard` (wired in step 3). The connections from PuzzleBoard → Main are made in `PuzzleBoard._ready()` after the board emits them, or in `Main._ready()` after the board node is ready.

### MoveCounterLabel positioning
- Anchor preset: Top Center
- Offset top: 20px
- Font size: 32 (set via theme override)
- Horizontal alignment: Center

### WinOverlay layout
- Control anchors: full rect (0,0,1,1) so it covers the whole screen
- WinBackground: ColorRect full rect, color `Color(0, 0, 0, 0.7)`
- WinLabel, MovesLabel, RestartButton: centered vertically and horizontally using anchor preset Center, with vertical offsets (-80, -20, +60) respectively

## Acceptance criteria
- [ ] `godot/scenes/Main.tscn` exists and opens in the editor without errors
- [ ] WinOverlay node exists and is hidden by default (`visible = false`)
- [ ] MoveCounterLabel is visible at the top of the screen showing "Moves: 0"
- [ ] RestartButton exists inside WinOverlay
- [ ] Main.gd compiles without errors

## Test commands
```bash
# Open in Godot editor — scene should load cleanly in the Scene panel
ls godot/scenes/Main.tscn godot/scripts/Main.gd
```

## Rollback
`git revert` the commit, or delete `godot/scenes/Main.tscn` and `godot/scripts/Main.gd`.

## Notes
`PuzzleBoard.gd` doesn't exist yet — the `@onready` reference will cause an editor warning until step 3. That's fine; the script is not run during this step.
