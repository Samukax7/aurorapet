extends Control
class_name Jokenpo

## Minigame Pedra, Papel e Tesoura do AuroraPet.
## O jogador escolhe uma das três peças e a Aurora responde automaticamente.

signal match_completed(result: StringName, xp_reward: int)

const CHOICES: Array[StringName] = [&"pedra", &"papel", &"tesoura"]
const CHOICE_LABELS: Array[String] = ["PEDRA", "PAPEL", "TESOURA"]
const CHOICE_TEXTURES: Array[String] = [
	"res://assets/UI/minigames/jokenpo/pedra.png",
	"res://assets/UI/minigames/jokenpo/papel.png",
	"res://assets/UI/minigames/jokenpo/tesoura.png",
]
const WIN_XP := 15
const DRAW_XP := 5
const LOSS_XP := 2

var selected_index := 0
var player_choice := -1
var computer_choice := -1
var game_over := false
var _rng := RandomNumberGenerator.new()
var _normal_choice_style: StyleBoxFlat
var _selected_choice_style: StyleBoxFlat

@onready var status_label: Label = $Status
@onready var result_label: Label = $Result
@onready var hint_label: Label = $Hint
@onready var player_label: Label = $PlayerLabel
@onready var computer_label: Label = $ComputerLabel
@onready var player_icon: TextureRect = $PlayerIcon
@onready var computer_icon: TextureRect = $ComputerIcon
@onready var choice_buttons: Array[TextureButton] = [$Choices/Pedra, $Choices/Papel, $Choices/Tesoura]

func _ready() -> void:
	_rng.randomize()
	_build_choice_styles()
	for index in choice_buttons.size():
		choice_buttons[index].pressed.connect(_on_choice_pressed.bind(index))
	visible = false
	new_round()

func open_game() -> void:
	visible = true
	new_round()
	choice_buttons[selected_index].grab_focus()

func close_game() -> void:
	visible = false
	game_over = false

func new_round() -> void:
	selected_index = 0
	player_choice = -1
	computer_choice = -1
	game_over = false
	status_label.text = "ESCOLHA UM SÍMBOLO"
	result_label.text = ""
	hint_label.text = "D-PAD: MOVER   •   VERDE: CONFIRMAR   •   ROSA: SAIR"
	player_label.text = "SUA ESCOLHA"
	computer_label.text = "AURORA"
	player_icon.visible = false
	computer_icon.visible = false
	_update_selection()

func handle_direction(direction: Vector2i) -> void:
	if not visible or game_over:
		return
	var step := 1 if direction.x > 0 or direction.y > 0 else -1
	selected_index = wrapi(selected_index + step, 0, CHOICES.size())
	_update_selection()

func confirm() -> void:
	if not visible:
		return
	if game_over:
		new_round()
		return
	_play_round()

func back() -> void:
	if visible:
		close_game()

func _play_round() -> void:
	player_choice = selected_index
	computer_choice = _rng.randi_range(0, CHOICES.size() - 1)
	player_icon.texture = load(CHOICE_TEXTURES[player_choice]) as Texture2D
	computer_icon.texture = load(CHOICE_TEXTURES[computer_choice]) as Texture2D
	player_icon.visible = true
	computer_icon.visible = true
	player_label.text = "VOCÊ: " + CHOICE_LABELS[player_choice]
	computer_label.text = "AURORA: " + CHOICE_LABELS[computer_choice]
	var result := _evaluate_result(player_choice, computer_choice)
	_finish_match(result)

func _evaluate_result(player: int, computer: int) -> StringName:
	if player == computer:
		return &"empate"
	if (player == 0 and computer == 2) or (player == 1 and computer == 0) or (player == 2 and computer == 1):
		return &"vitoria"
	return &"derrota"

func _finish_match(result: StringName) -> void:
	game_over = true
	var reward := 0
	match result:
		&"vitoria":
			status_label.text = "VOCÊ VENCEU A RODADA!"
			result_label.text = "+%d XP" % WIN_XP
			reward = WIN_XP
		&"derrota":
			status_label.text = "AURORA VENCEU A RODADA"
			result_label.text = "+%d XP" % LOSS_XP
			reward = LOSS_XP
		&"empate":
			status_label.text = "EMPATE CÓSMICO"
			result_label.text = "+%d XP" % DRAW_XP
			reward = DRAW_XP
	hint_label.text = "VERDE: NOVA RODADA   •   ROSA: VOLTAR"
	match_completed.emit(result, reward)

func _update_selection() -> void:
	for index in choice_buttons.size():
		var selected := index == selected_index and not game_over
		choice_buttons[index].add_theme_stylebox_override("normal", _selected_choice_style if selected else _normal_choice_style)
		choice_buttons[index].add_theme_stylebox_override("hover", _selected_choice_style if selected else _normal_choice_style)
	status_label.text = "ESCOLHA: " + CHOICE_LABELS[selected_index] if not game_over else status_label.text

func _build_choice_styles() -> void:
	_normal_choice_style = StyleBoxFlat.new()
	_normal_choice_style.bg_color = Color(0.02, 0.06, 0.16, 0.35)
	_normal_choice_style.border_width_left = 2
	_normal_choice_style.border_width_top = 2
	_normal_choice_style.border_width_right = 2
	_normal_choice_style.border_width_bottom = 2
	_normal_choice_style.border_color = Color(0.26, 0.48, 0.72, 0.7)
	_normal_choice_style.corner_radius_top_left = 14
	_normal_choice_style.corner_radius_top_right = 14
	_normal_choice_style.corner_radius_bottom_right = 14
	_normal_choice_style.corner_radius_bottom_left = 14
	_selected_choice_style = StyleBoxFlat.new()
	_selected_choice_style.bg_color = Color(0.25, 0.7, 0.92, 0.2)
	_selected_choice_style.border_width_left = 4
	_selected_choice_style.border_width_top = 4
	_selected_choice_style.border_width_right = 4
	_selected_choice_style.border_width_bottom = 4
	_selected_choice_style.border_color = Color(0.55, 0.95, 1, 1)
	_selected_choice_style.corner_radius_top_left = 14
	_selected_choice_style.corner_radius_top_right = 14
	_selected_choice_style.corner_radius_bottom_right = 14
	_selected_choice_style.corner_radius_bottom_left = 14

func _on_choice_pressed(index: int) -> void:
	selected_index = index
	_update_selection()
	confirm()
