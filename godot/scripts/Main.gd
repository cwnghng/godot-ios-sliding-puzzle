extends Node2D

@onready var puzzle_board = $CanvasLayer/PuzzleBoard
@onready var move_counter_label = $CanvasLayer/MoveCounterLabel
@onready var win_overlay = $CanvasLayer/WinOverlay
@onready var win_moves_label = $CanvasLayer/WinOverlay/MovesLabel
@onready var restart_button = $CanvasLayer/WinOverlay/RestartButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	puzzle_board.move_made.connect(_on_move_made)
	puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
	win_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_move_made(total_moves: int):
	move_counter_label.text = "Moves: %d" % total_moves

func _on_puzzle_solved(total_moves: int):
	win_moves_label.text = "Moves: %d" % total_moves
	win_overlay.visible = true

func _on_restart_pressed():
	win_overlay.visible = false
	puzzle_board.restart()
