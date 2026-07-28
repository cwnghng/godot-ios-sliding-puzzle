extends Node2D

@onready var puzzle_board = $CanvasLayer/PuzzleBoard
@onready var move_counter_label = $CanvasLayer/MoveCounterLabel
@onready var win_overlay = $CanvasLayer/WinOverlay
@onready var win_label = $CanvasLayer/WinOverlay/WinLabel
@onready var win_moves_label = $CanvasLayer/WinOverlay/MovesLabel
@onready var restart_button = $CanvasLayer/WinOverlay/RestartButton

func _ready():
	_apply_dynamic_sizing()
	restart_button.pressed.connect(_on_restart_pressed)
	puzzle_board.move_made.connect(_on_move_made)
	puzzle_board.puzzle_solved.connect(_on_puzzle_solved)
	win_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

func _apply_dynamic_sizing() -> void:
	var vp = get_viewport_rect().size
	var vp_min = min(vp.x, vp.y)
	var tile_size = vp_min * 0.20
	var font_size = int(tile_size * 0.43)

	win_label.add_theme_font_size_override("font_size", font_size)
	win_moves_label.add_theme_font_size_override("font_size", font_size)
	restart_button.add_theme_font_size_override("font_size", font_size)
	move_counter_label.add_theme_font_size_override("font_size", font_size)

	win_label.offset_left   = -tile_size * 2.0
	win_label.offset_right  =  tile_size * 2.0
	win_label.offset_top    = -tile_size * 1.07
	win_label.offset_bottom = -tile_size * 0.53

	win_moves_label.offset_left   = -tile_size * 1.33
	win_moves_label.offset_right  =  tile_size * 1.33
	win_moves_label.offset_top    = -tile_size * 0.27
	win_moves_label.offset_bottom =  tile_size * 0.27

	restart_button.offset_left   = -tile_size * 1.07
	restart_button.offset_right  =  tile_size * 1.07
	restart_button.offset_top    =  tile_size * 0.53
	restart_button.offset_bottom =  tile_size * 1.07
	restart_button.custom_minimum_size = Vector2(tile_size * 2.13, tile_size * 0.53)

	move_counter_label.offset_left   = -tile_size * 1.33
	move_counter_label.offset_right  =  tile_size * 1.33
	move_counter_label.offset_top    =  tile_size * 0.27
	move_counter_label.offset_bottom =  tile_size * 0.80

func _on_move_made(total_moves: int):
	move_counter_label.text = "Moves: %d" % total_moves

func _on_puzzle_solved(total_moves: int):
	win_moves_label.text = "Moves: %d" % total_moves
	win_overlay.visible = true

func _on_restart_pressed():
	win_overlay.visible = false
	puzzle_board.restart()
