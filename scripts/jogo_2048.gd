extends Control
class_name Jogo2048

## Minijogo 2048 do AuroraPet.
## O tabuleiro usa o D-pad para mover as peças; o botão verde reinicia após o fim.

signal match_completed(result: StringName, xp_reward: int)

const SIZE := 4
const WIN_TILE := 2048
const WIN_XP := 20
const GOOD_RUN_XP := 8
const BASIC_RUN_XP := 3

var board: Array = []
var score := 0
var best_tile := 0
var game_over := false
var game_won := false
var reward_emitted := false
var selected_cell := Vector2i(1, 1)
var _rng := RandomNumberGenerator.new()
var _cells: Array[Button] = []

@onready var status_label: Label = $Status
@onready var score_label: Label = $Score
@onready var best_label: Label = $Best
@onready var result_label: Label = $Result
@onready var hint_label: Label = $Hint
@onready var grid: GridContainer = $Board

func _ready() -> void:
	_rng.randomize()
	for child in grid.get_children():
		if child is Button:
			_cells.append(child as Button)
	for index in _cells.size():
		_cells[index].pressed.connect(_on_cell_pressed.bind(index))
	visible = false
	new_game()

func open_game() -> void:
	visible = true
	new_game()

func close_game() -> void:
	visible = false
	game_over = false

func new_game() -> void:
	board.clear()
	for y in SIZE:
		var row: Array = []
		for x in SIZE:
			row.append(0)
		board.append(row)
	score = 0
	best_tile = 0
	game_over = false
	game_won = false
	reward_emitted = false
	selected_cell = Vector2i(1, 1)
	_spawn_tile()
	_spawn_tile()
	_update_best_tile()
	status_label.text = "FORME O BLOCO 2048"
	result_label.text = ""
	hint_label.text = "D-PAD: MOVER   •   VERDE: NOVA PARTIDA   •   ROSA: SAIR"
	_update_labels()
	_render_board()

func handle_direction(direction: Vector2i) -> void:
	if not visible or game_over:
		return
	if direction == Vector2i.ZERO:
		return
	if direction.x < 0:
		selected_cell.x = wrapi(selected_cell.x - 1, 0, SIZE)
	elif direction.x > 0:
		selected_cell.x = wrapi(selected_cell.x + 1, 0, SIZE)
	elif direction.y < 0:
		selected_cell.y = wrapi(selected_cell.y - 1, 0, SIZE)
	elif direction.y > 0:
		selected_cell.y = wrapi(selected_cell.y + 1, 0, SIZE)
	_move_board(direction)

func confirm() -> void:
	if not visible:
		return
	if game_over:
		new_game()
	else:
		status_label.text = "USE O D-PAD PARA MOVER AS PEÇAS"

func back() -> void:
	if visible:
		close_game()

func _move_board(direction: Vector2i) -> void:
	var before: Array = board.duplicate(true)
	var gained := 0
	if direction.x != 0:
		for y in SIZE:
			var line: Array = []
			for x in SIZE:
				line.append(board[y][x])
			if direction.x > 0:
				line.reverse()
			var merged := _merge_line(line)
			line = merged.line
			gained += int(merged.gain)
			if direction.x > 0:
				line.reverse()
			for x in SIZE:
				board[y][x] = line[x]
	else:
		for x in SIZE:
			var column: Array = []
			for y in SIZE:
				column.append(board[y][x])
			if direction.y > 0:
				column.reverse()
			var merged_column := _merge_line(column)
			column = merged_column.line
			gained += int(merged_column.gain)
			if direction.y > 0:
				column.reverse()
			for y in SIZE:
				board[y][x] = column[y]
	if board == before:
		status_label.text = "NENHUMA PEÇA PODE MOVER"
		_render_board()
		return
	score += gained
	_spawn_tile()
	_update_best_tile()
	_render_board()
	if best_tile >= WIN_TILE:
		_finish_game(true)
	elif _has_no_moves():
		_finish_game(false)
	else:
		status_label.text = "MOVA E UNA OS BLOCOS IGUAIS"



func _merge_line(line: Array) -> Dictionary:
	var compact: Array = []
	for value in line:
		if int(value) > 0:
			compact.append(int(value))
	var merged: Array = []
	var gain := 0
	var index := 0
	while index < compact.size():
		if index + 1 < compact.size() and compact[index] == compact[index + 1]:
			var value: int = int(compact[index]) * 2
			merged.append(value)
			gain += value
			index += 2
		else:
			merged.append(compact[index])
			index += 1
	while merged.size() < SIZE:
		merged.append(0)
	return {"line": merged, "gain": gain}

func _spawn_tile() -> void:
	var empty: Array[Vector2i] = []
	for y in SIZE:
		for x in SIZE:
			if board[y][x] == 0:
				empty.append(Vector2i(x, y))
	if empty.is_empty():
		return
	var cell := empty[_rng.randi_range(0, empty.size() - 1)]
	board[cell.y][cell.x] = 4 if _rng.randf() < 0.1 else 2

func _update_best_tile() -> void:
	best_tile = 0
	for row in board:
		for value in row:
			best_tile = maxi(best_tile, int(value))

func _has_no_moves() -> bool:
	for y in SIZE:
		for x in SIZE:
			if board[y][x] == 0:
				return false
			if x + 1 < SIZE and board[y][x] == board[y][x + 1]:
				return false
			if y + 1 < SIZE and board[y][x] == board[y + 1][x]:
				return false
	return true

func _finish_game(won: bool) -> void:
	game_over = true
	game_won = won
	var reward := WIN_XP if won else (GOOD_RUN_XP if best_tile >= 128 else BASIC_RUN_XP)
	if won:
		status_label.text = "VOCÊ ALCANÇOU O 2048!"
		result_label.text = "+%d XP   •   VITÓRIA CÓSMICA" % reward
	else:
		status_label.text = "FIM DE JOGO   •   MELHOR BLOCO: %d" % best_tile
		result_label.text = "+%d XP   •   TENTE NOVAMENTE" % reward
	hint_label.text = "VERDE: NOVA PARTIDA   •   ROSA: VOLTAR"
	if not reward_emitted:
		reward_emitted = true
		match_completed.emit(&"vitoria" if won else &"fim_de_jogo", reward)

func _update_labels() -> void:
	score_label.text = "PONTOS %06d" % score
	best_label.text = "MELHOR %d" % best_tile

func _render_board() -> void:
	_update_labels()
	for index in _cells.size():
		var x := index % SIZE
		var y := index / SIZE
		var value: int = int(board[y][x])
		var cell := _cells[index]
		cell.text = "" if value == 0 else str(value)
		cell.add_theme_font_size_override("font_size", 29 if value < 100 else 24 if value < 1000 else 20)
		cell.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
		cell.add_theme_color_override("font_outline_color", Color(0.015, 0.03, 0.1, 1.0))
		cell.add_theme_constant_override("outline_size", 5)
		var style := StyleBoxFlat.new()
		style.bg_color = _tile_color(value)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = Color(0.35, 0.78, 0.98, 0.95) if Vector2i(x, y) == selected_cell else Color(0.12, 0.28, 0.5, 0.9)
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		cell.add_theme_stylebox_override("normal", style)
		cell.add_theme_stylebox_override("hover", style)
		cell.add_theme_stylebox_override("pressed", style)

func _tile_color(value: int) -> Color:
	match value:
		0: return Color(0.035, 0.09, 0.2, 0.85)
		2: return Color(0.12, 0.25, 0.48, 1.0)
		4: return Color(0.16, 0.34, 0.62, 1.0)
		8: return Color(0.1, 0.55, 0.72, 1.0)
		16: return Color(0.16, 0.7, 0.75, 1.0)
		32: return Color(0.25, 0.75, 0.62, 1.0)
		64: return Color(0.6, 0.75, 0.35, 1.0)
		128: return Color(0.94, 0.7, 0.25, 1.0)
		256: return Color(0.98, 0.5, 0.28, 1.0)
		512: return Color(0.96, 0.32, 0.45, 1.0)
		1024: return Color(0.72, 0.3, 0.72, 1.0)
		_: return Color(0.48, 0.28, 0.9, 1.0)

func _on_cell_pressed(index: int) -> void:
	selected_cell = Vector2i(index % SIZE, index / SIZE)
	_render_board()
	status_label.text = "D-PAD: MOVER AS PEÇAS"
