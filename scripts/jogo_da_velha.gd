extends Control
class_name JogoDaVelha

## Minigame Jogo da Velha do AuroraPet.
## O jogador usa O e a IA usa X. A cena recebe os assets pela composição visual.
## O layout do tabuleiro é recalculado a partir da área efetivamente desenhada
## pelo TextureRect, evitando que o modo KEEP_ASPECT_CENTERED desloque as peças.

signal match_completed(result: StringName, xp_reward: int)

const PLAYER := "O"
const COMPUTER := "X"
const WIN_XP := 20
const DRAW_XP := 8
const LOSS_XP := 3

# Frações medidas no asset gradetictactoe.png (1024x1024).
# A textura possui margem transparente e duas linhas internas fora do terço exato.
const GRID_USED_RECT := Rect2(0.0654297, 0.0693359, 0.8691406, 0.8701172)
const GRID_LINE_X := Vector2(0.3491211, 0.6499023)
const GRID_LINE_Y := Vector2(0.3500977, 0.6499023)
const CELL_GUIDE_INSET := Vector2(8.0, 7.0)
const MARK_WIDTH_FACTOR := 0.84

var board: Array[String] = []
var selected_index := 0
var game_over := false
var player_turn := true
var _rng := RandomNumberGenerator.new()
var _normal_cell_style: StyleBoxFlat
var _selected_cell_style: StyleBoxFlat
var _guide_style: StyleBoxFlat
var _guides: Control

@onready var board_texture_rect: TextureRect = $Board
@onready var status_label: Label = $Status
@onready var hint_label: Label = $Hint
@onready var result_label: Label = $Result
@onready var mark_nodes: Array[TextureRect] = [
	$Marks/Mark0, $Marks/Mark1, $Marks/Mark2,
	$Marks/Mark3, $Marks/Mark4, $Marks/Mark5,
	$Marks/Mark6, $Marks/Mark7, $Marks/Mark8,
]
@onready var cell_buttons: Array[Button] = [
	$Cells/Cell0, $Cells/Cell1, $Cells/Cell2,
	$Cells/Cell3, $Cells/Cell4, $Cells/Cell5,
	$Cells/Cell6, $Cells/Cell7, $Cells/Cell8,
]

func _ready() -> void:
	_rng.randomize()
	_build_cell_styles()
	_ensure_guides()
	_layout_board_elements()
	for index in cell_buttons.size():
		cell_buttons[index].pressed.connect(_on_cell_pressed.bind(index))
	visible = false
	new_round()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		call_deferred("_layout_board_elements")

func open_game() -> void:
	visible = true
	_layout_board_elements()
	new_round()
	cell_buttons[selected_index].grab_focus()

func close_game() -> void:
	visible = false
	game_over = false

func new_round() -> void:
	board.clear()
	for index in 9:
		board.append("")
	selected_index = 0
	game_over = false
	player_turn = true
	result_label.text = ""
	status_label.text = "SUA VEZ — SELECIONE UMA CASA"
	hint_label.text = "D-PAD: MOVER  •  VERDE: COLOCAR  •  ROSA: SAIR"
	_update_board()

func handle_direction(direction: Vector2i) -> void:
	if not visible or game_over:
		return
	var row := selected_index / 3
	var column := selected_index % 3
	if direction.x != 0:
		column = clampi(column + signi(direction.x), 0, 2)
	elif direction.y != 0:
		row = clampi(row + signi(direction.y), 0, 2)
	selected_index = row * 3 + column
	_update_selection()

func confirm() -> void:
	if not visible:
		return
	if game_over:
		new_round()
		return
	_try_player_move(selected_index)

func back() -> void:
	if visible:
		close_game()

func _try_player_move(index: int) -> void:
	if not player_turn or index < 0 or index >= board.size():
		return
	if not board[index].is_empty():
		status_label.text = "ESSA CASA JÁ ESTÁ OCUPADA — ESCOLHA OUTRA"
		return
	board[index] = PLAYER
	_update_board()
	var result := _evaluate_board()
	if not result.is_empty():
		_finish_match(result)
		return
	player_turn = false
	status_label.text = "AURORA ESTÁ PENSANDO..."
	if is_inside_tree():
		get_tree().create_timer(0.35).timeout.connect(_computer_move)

func _computer_move() -> void:
	if not visible or game_over:
		return
	var choice := _choose_computer_move()
	if choice < 0:
		return
	board[choice] = COMPUTER
	_update_board()
	var result := _evaluate_board()
	if not result.is_empty():
		_finish_match(result)
		return
	player_turn = true
	status_label.text = "SUA VEZ — SELECIONE UMA CASA"

func _choose_computer_move() -> int:
	var winning := _find_tactical_move(COMPUTER)
	if winning >= 0:
		return winning
	var blocking := _find_tactical_move(PLAYER)
	if blocking >= 0:
		return blocking
	if board[4].is_empty():
		return 4
	var corners: Array[int] = []
	for index in [0, 2, 6, 8]:
		if board[index].is_empty():
			corners.append(index)
	if not corners.is_empty():
		return corners[_rng.randi_range(0, corners.size() - 1)]
	var available: Array[int] = []
	for index in board.size():
		if board[index].is_empty():
			available.append(index)
	return available[_rng.randi_range(0, available.size() - 1)] if not available.is_empty() else -1

func _find_tactical_move(symbol: String) -> int:
	for index in board.size():
		if not board[index].is_empty():
			continue
		board[index] = symbol
		var wins := _check_winner(symbol)
		board[index] = ""
		if wins:
			return index
	return -1

func _evaluate_board() -> StringName:
	if _check_winner(PLAYER):
		return &"vitoria"
	if _check_winner(COMPUTER):
		return &"derrota"
	for value in board:
		if value.is_empty():
			return &""
	return &"empate"

func _check_winner(symbol: String) -> bool:
	var lines := [
		[0, 1, 2], [3, 4, 5], [6, 7, 8],
		[0, 3, 6], [1, 4, 7], [2, 5, 8],
		[0, 4, 8], [2, 4, 6],
	]
	for line in lines:
		if board[line[0]] == symbol and board[line[1]] == symbol and board[line[2]] == symbol:
			return true
	return false

func _finish_match(result: StringName) -> void:
	game_over = true
	player_turn = false
	var reward := 0
	match result:
		&"vitoria":
			status_label.text = "VOCÊ VENCEU!"
			result_label.text = "+%d XP" % WIN_XP
			reward = WIN_XP
		&"derrota":
			status_label.text = "AURORA VENCEU"
			result_label.text = "+%d XP DE EXPERIÊNCIA" % LOSS_XP
			reward = LOSS_XP
		&"empate":
			status_label.text = "EMPATE CÓSMICO"
			result_label.text = "+%d XP" % DRAW_XP
			reward = DRAW_XP
	hint_label.text = "VERDE: NOVA PARTIDA  •  ROSA: VOLTAR"
	match_completed.emit(result, reward)

func _update_board() -> void:
	for index in mark_nodes.size():
		var mark := mark_nodes[index]
		mark.visible = not board[index].is_empty()
		if board[index] == PLAYER:
			mark.texture = preload("res://assets/UI/minigames/jogo_da_velha/bolinha_tictactoe.png")
		elif board[index] == COMPUTER:
			mark.texture = preload("res://assets/UI/minigames/jogo_da_velha/xis_tictactoe.png")
	_update_selection()

func _update_selection() -> void:
	for index in cell_buttons.size():
		var selected := index == selected_index and not game_over
		cell_buttons[index].add_theme_stylebox_override("normal", _selected_cell_style if selected else _normal_cell_style)
		cell_buttons[index].add_theme_stylebox_override("hover", _selected_cell_style if selected else _normal_cell_style)
		cell_buttons[index].add_theme_stylebox_override("focus", _selected_cell_style if selected else _normal_cell_style)

func _build_cell_styles() -> void:
	_normal_cell_style = StyleBoxFlat.new()
	_normal_cell_style.bg_color = Color(0, 0, 0, 0)
	_normal_cell_style.border_width_left = 0
	_normal_cell_style.border_width_top = 0
	_normal_cell_style.border_width_right = 0
	_normal_cell_style.border_width_bottom = 0

	_selected_cell_style = StyleBoxFlat.new()
	_selected_cell_style.bg_color = Color(0.3, 0.85, 1.0, 0.18)
	_selected_cell_style.border_width_left = 3
	_selected_cell_style.border_width_top = 3
	_selected_cell_style.border_width_right = 3
	_selected_cell_style.border_width_bottom = 3
	_selected_cell_style.border_color = Color(0.55, 0.95, 1.0, 0.95)
	_selected_cell_style.shadow_color = Color(0.25, 0.85, 1.0, 0.45)
	_selected_cell_style.shadow_size = 4
	_selected_cell_style.corner_radius_top_left = 10
	_selected_cell_style.corner_radius_top_right = 10
	_selected_cell_style.corner_radius_bottom_right = 10
	_selected_cell_style.corner_radius_bottom_left = 10

	_guide_style = StyleBoxFlat.new()
	_guide_style.bg_color = Color(0.18, 0.52, 0.72, 0.06)
	_guide_style.border_width_left = 1
	_guide_style.border_width_top = 1
	_guide_style.border_width_right = 1
	_guide_style.border_width_bottom = 1
	_guide_style.border_color = Color(0.45, 0.9, 1.0, 0.24)
	_guide_style.corner_radius_top_left = 8
	_guide_style.corner_radius_top_right = 8
	_guide_style.corner_radius_bottom_right = 8
	_guide_style.corner_radius_bottom_left = 8

func _ensure_guides() -> void:
	_guides = get_node_or_null("Guides") as Control
	if _guides == null:
		_guides = Control.new()
		_guides.name = "Guides"
		_guides.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_guides)
		move_child(_guides, get_node("Board").get_index() + 1)
	_guides.z_index = 1
	$Marks.z_index = 2
	$Cells.z_index = 3
	for index in 9:
		var guide := _guides.get_node_or_null("Guide%d" % index) as Panel
		if guide == null:
			guide = Panel.new()
			guide.name = "Guide%d" % index
			guide.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_guides.add_child(guide)
		guide.add_theme_stylebox_override("panel", _guide_style)

func _layout_board_elements() -> void:
	if board_texture_rect == null or board_texture_rect.texture == null:
		return
	var board_rect := Rect2(board_texture_rect.position, board_texture_rect.size)
	var texture_size := board_texture_rect.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	# Board usa KEEP_ASPECT_CENTERED: primeiro encontramos o quadrado realmente desenhado.
	var draw_rect := board_rect
	if board_texture_rect.stretch_mode == 5:
		var fit_scale := minf(board_rect.size.x / texture_size.x, board_rect.size.y / texture_size.y)
		draw_rect.size = texture_size * fit_scale
		draw_rect.position = board_rect.position + (board_rect.size - draw_rect.size) * 0.5

	var used_rect := Rect2(
		draw_rect.position + Vector2(draw_rect.size.x * GRID_USED_RECT.position.x, draw_rect.size.y * GRID_USED_RECT.position.y),
		Vector2(draw_rect.size.x * GRID_USED_RECT.size.x, draw_rect.size.y * GRID_USED_RECT.size.y)
	)
	var x_edges := PackedFloat32Array([
		used_rect.position.x,
		lerpf(draw_rect.position.x, draw_rect.end.x, GRID_LINE_X.x),
		lerpf(draw_rect.position.x, draw_rect.end.x, GRID_LINE_X.y),
		used_rect.end.x,
	])
	var y_edges := PackedFloat32Array([
		used_rect.position.y,
		lerpf(draw_rect.position.y, draw_rect.end.y, GRID_LINE_Y.x),
		lerpf(draw_rect.position.y, draw_rect.end.y, GRID_LINE_Y.y),
		used_rect.end.y,
	])

	# Compensa a escala vertical calibrada do ScreenContent para manter O/X legíveis.
	var inherited_scale := get_global_transform().get_scale()
	var display_compensation := 1.0
	if absf(inherited_scale.y) > 0.001:
		display_compensation = absf(inherited_scale.x / inherited_scale.y)
	for index in 9:
		var row := index / 3
		var column := index % 3
		var cell := Rect2(
			Vector2(x_edges[column], y_edges[row]),
			Vector2(x_edges[column + 1] - x_edges[column], y_edges[row + 1] - y_edges[row]),
		)
		cell_buttons[index].position = cell.position
		cell_buttons[index].size = cell.size

		var mark_width := cell.size.x * MARK_WIDTH_FACTOR
		var mark_height := minf(cell.size.y * 0.84, mark_width * display_compensation)
		var mark_size := Vector2(mark_width, mark_height)
		mark_nodes[index].position = cell.get_center() - mark_size * 0.5
		mark_nodes[index].size = mark_size
		mark_nodes[index].stretch_mode = 0

		var guide := _guides.get_node("Guide%d" % index) as Panel
		guide.position = cell.position + CELL_GUIDE_INSET
		guide.size = cell.size - CELL_GUIDE_INSET * 2.0

func _on_cell_pressed(index: int) -> void:
	selected_index = index
	_update_selection()
	confirm()
