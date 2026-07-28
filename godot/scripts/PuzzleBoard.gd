extends Control

signal move_made(total_moves: int)
signal puzzle_solved(total_moves: int)

const GRID_SIZE = 4
const SHUFFLE_MOVES = 200
const DIRECTIONS = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

var tile_size: float
var gap: float
var cell_size: float
var grid_origin: Vector2

var grid: Array = []
var empty_pos: Vector2i
var tiles: Array = []

var source_tex: Texture2D
var slice_w: float
var slice_h: float

var move_count: int = 0

var dragging: bool = false
var drag_tile_idx: int = -1
var drag_tile_grid: Vector2i
var drag_origin_px: Vector2
var drag_empty_px: Vector2
var drag_axis: int = -1
var drag_touch_id: int = -1

func _ready():
	var vp = get_viewport_rect().size
	tile_size = min(vp.x, vp.y) * 0.20
	gap = max(tile_size * 0.02, 4.0)
	cell_size = tile_size + gap
	var grid_px = 4 * tile_size + 3 * gap
	grid_origin = (vp - Vector2(grid_px, grid_px)) / 2.0

	source_tex = load("res://assets/images/art.png")
	var img_size = source_tex.get_size()
	slice_w = img_size.x / 4.0
	slice_h = img_size.y / 4.0

	_build_board()
	shuffle()

func grid_to_pixel(col: int, row: int) -> Vector2:
	return grid_origin + Vector2(col * cell_size, row * cell_size)

func pixel_to_grid(pos: Vector2) -> Vector2i:
	var local = pos - grid_origin
	return Vector2i(int(local.x / cell_size), int(local.y / cell_size))

func _make_atlas(tile_index: int) -> AtlasTexture:
	var col = tile_index % 4
	var row = tile_index / 4
	var atlas = AtlasTexture.new()
	atlas.atlas = source_tex
	atlas.region = Rect2(col * slice_w, row * slice_h, slice_w, slice_h)
	return atlas

func _build_board():
	for child in get_children():
		child.queue_free()
	grid = []
	tiles = []
	empty_pos = Vector2i(3, 3)

	for r in range(4):
		var row_arr = []
		for c in range(4):
			var idx = r * 4 + c
			if idx == 15:
				row_arr.append(-1)
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

func _apply_move(tile_pos: Vector2i) -> void:
	var tile_idx = grid[tile_pos.y][tile_pos.x]
	grid[empty_pos.y][empty_pos.x] = tile_idx
	grid[tile_pos.y][tile_pos.x] = -1
	tiles[tile_idx].position = grid_to_pixel(empty_pos.x, empty_pos.y)
	empty_pos = tile_pos

func shuffle() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var last_move = Vector2i(-1, -1)
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
		last_move = empty_pos
		_apply_move(chosen)

func _tile_at_pixel(pos: Vector2) -> Vector2i:
	var gc = pixel_to_grid(pos)
	if gc.x < 0 or gc.x >= 4 or gc.y < 0 or gc.y >= 4:
		return Vector2i(-1, -1)
	var tile_origin = grid_to_pixel(gc.x, gc.y)
	var local = pos - tile_origin
	if local.x >= 0 and local.x <= tile_size and local.y >= 0 and local.y <= tile_size:
		return gc
	return Vector2i(-1, -1)

func _is_adjacent_to_empty(gc: Vector2i) -> bool:
	var diff = gc - empty_pos
	return (abs(diff.x) + abs(diff.y)) == 1

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not dragging:
			var gc = _tile_at_pixel(event.position)
			if gc == Vector2i(-1, -1):
				return
			if not _is_adjacent_to_empty(gc):
				return
			var diff = empty_pos - gc
			drag_axis = 0 if diff.x != 0 else 1
			dragging = true
			drag_touch_id = event.index
			drag_tile_idx = grid[gc.y][gc.x]
			drag_tile_grid = gc
			drag_origin_px = grid_to_pixel(gc.x, gc.y)
			drag_empty_px = grid_to_pixel(empty_pos.x, empty_pos.y)
		elif not event.pressed and dragging and event.index == drag_touch_id:
			_on_drag_released(event.position)
	elif event is InputEventScreenDrag and dragging and event.index == drag_touch_id:
		_update_drag(event.position)

func _update_drag(touch_pos: Vector2) -> void:
	var tile = tiles[drag_tile_idx]
	var delta = touch_pos - (drag_origin_px + Vector2(tile_size, tile_size) * 0.5)
	var new_pos = drag_origin_px
	if drag_axis == 0:
		var raw_x = drag_origin_px.x + delta.x
		var min_x = min(drag_origin_px.x, drag_empty_px.x)
		var max_x = max(drag_origin_px.x, drag_empty_px.x)
		new_pos.x = clamp(raw_x, min_x, max_x)
	else:
		var raw_y = drag_origin_px.y + delta.y
		var min_y = min(drag_origin_px.y, drag_empty_px.y)
		var max_y = max(drag_origin_px.y, drag_empty_px.y)
		new_pos.y = clamp(raw_y, min_y, max_y)
	tile.position = new_pos

func _on_drag_released(_touch_pos: Vector2) -> void:
	var tile = tiles[drag_tile_idx]
	var current_pos = tile.position
	var dist_to_empty = current_pos.distance_to(drag_empty_px)
	var dist_to_origin = current_pos.distance_to(drag_origin_px)

	if dist_to_empty <= dist_to_origin:
		tile.position = drag_empty_px
		grid[drag_tile_grid.y][drag_tile_grid.x] = -1
		grid[empty_pos.y][empty_pos.x] = drag_tile_idx
		empty_pos = drag_tile_grid
		move_count += 1
		move_made.emit(move_count)
		if _is_solved():
			puzzle_solved.emit(move_count)
	else:
		tile.position = drag_origin_px

	_reset_drag()

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

func _reset_drag() -> void:
	dragging = false
	drag_tile_idx = -1
	drag_touch_id = -1
	drag_axis = -1

func restart() -> void:
	move_count = 0
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
	move_made.emit(move_count)
