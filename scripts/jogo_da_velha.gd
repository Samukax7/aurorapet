extends Control
class_name JogoDaVelha

## Minigame Jogo da Velha do AuroraPet.
## O jogador usa O e a IA usa X. A cena recebe os assets pela composição visual.

signal match_completed(result: StringName, xp_reward: int)

const PLAYER := "O"
const COMPUTER := "X"
const WIN_XP := 20
const DRAW_XP := 8
const LOSS_XP := 3

var board: Array[String] = []
var selected_index := 0
var game_over := false
var player_turn := true
var _rng := RandomNumberGenerator.new()
var _normal_cell_style: StyleBoxFlat
var _selected_cell_style: StyleBoxFlat

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
	for index in cell_buttons.size():
		cell_buttons[index].pressed.connect(_on_cell_pressed.bind(index))
	visible = false
	new_round()

func open_game() -> void:
	visible = true
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
	status_label.text = "SUA VEZ — ESCOLHA UMA CASA"
	hint_label.text = "D-PAD: MOVER   •   VERDE: JOGAR   •   ROSA: SAIR"
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
		status_label.text = "ESSA CASA JÁ ESTÁ OCUPADA"
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
	status_label.text = "SUA VEZ — ESCOLHA UMA CASA"

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
	hint_label.text = "VERDE: NOVA PARTIDA   •   ROSA: VOLTAR"
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

func _build_cell_styles() -> void:
	_normal_cell_style = StyleBoxFlat.new()
	_normal_cell_style.bg_color = Color(0, 0, 0, 0)
	_normal_cell_style.border_width_left = 0
	_normal_cell_style.border_width_top = 0
	_normal_cell_style.border_width_right = 0
	_normal_cell_style.border_width_bottom = 0
	_selected_cell_style = StyleBoxFlat.new()
	_selected_cell_style.bg_color = Color(0.3, 0.85, 1.0, 0.12)
	_selected_cell_style.border_width_left = 3
	_selected_cell_style.border_width_top = 3
	_selected_cell_style.border_width_right = 3
	_selected_cell_style.border_width_bottom = 3
	_selected_cell_style.border_color = Color(0.55, 0.95, 1.0, 0.9)
	_selected_cell_style.corner_radius_top_left = 12
	_selected_cell_style.corner_radius_top_right = 12
	_selected_cell_style.corner_radius_bottom_right = 12
	_selected_cell_style.corner_radius_bottom_left = 12

func _on_cell_pressed(index: int) -> void:
	selected_index = index
	_update_selection()
	confirm()
