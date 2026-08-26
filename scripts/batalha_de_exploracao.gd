extends Control
class_name BatalhaDeExploracao

## Combate de exploração adaptado do protótipo do Google AI Studio.
## A área mantém o sinal de pontos usado pelo Quarto Cósmico e trabalha com
## PetSkills/PetIdentity existentes, sem criar uma segunda identidade de pet.

signal points_changed(total_points: int)
signal area_closed
signal battle_completed(victory: bool, xp_reward: int, point_reward: int, log_text: String)
signal battle_started(enemy_name: String, enemy_faction: StringName)

const BATTLE_XP_REWARD := 50
const BATTLE_DEFEAT_XP := 10
const BATTLE_POINT_REWARD := 10
const EN_RECOVERY_PER_TURN := 8
const BASE_ENERGY := 80
const TOP_LEVEL_ACTIONS: Array[StringName] = [&"golpes", &"tecnica", &"defesa", &"fugir"]
const MOVE_ACTIONS: Array[StringName] = [&"golpe_fraco", &"golpe_forte", &"golpe_status"]
const TECHNIQUE_ACTIONS: Array[StringName] = [&"intuicao_cosmica"]
const ACTION_LABELS: Dictionary = {
	&"golpes": "GOLPES",
	&"tecnica": "TÉCNICA",
	&"defesa": "GUARDA",
	&"fugir": "FUGIR",
	&"golpe_fraco": "PULSO AURORA",
	&"golpe_forte": "IMPACTO ESTELAR",
	&"golpe_status": "SELO DO VAZIO",
	&"intuicao_cosmica": "ÓRBITA DA INTUIÇÃO",
}
const MOVE_EFFECT_TEXTURES: Dictionary = {
	&"golpe_fraco": "res://assets/battle/effects/pulso_aurora_64.png",
	&"golpe_forte": "res://assets/battle/effects/impacto_estelar_64.png",
	&"golpe_status": "res://assets/battle/effects/selo_vazio_64.png",
	&"intuicao_cosmica": "res://assets/battle/effects/mare_plasma_64.png",
	&"enemy": "res://assets/battle/effects/fragmento_nebular_64.png",
}
const TECHNIQUE_COST := 10

var exploration_points := 0
var selected_index := 0
var menu_level: StringName = &"root"
var phase: StringName = &"lobby"
var mode_context: StringName = &"training"
var exploration_area_id: StringName = &"data_city"
var is_player_turn := true
var battle_over := false
var player_guarding := false
var enemy_guarding := false
var enemy_weakened := false
var enemy_status: StringName = &""
var enemy_status_turns := 0
var player_accuracy_bonus := 0.0
var pending_player_action: StringName = &""
var player_hp := 0
var player_max_hp := 0
var player_en := 0
var player_max_en := 0
var enemy_hp := 0
var enemy_max_hp := 0
var enemy_level := 1
var enemy_name := "ECO"
var enemy_faction: StringName = &"trevas"
var enemy_strength := 8
var enemy_defense := 8
var enemy_agility := 8
var encounter_override_name := ""
var encounter_level_bonus := 0
var encounter_is_boss := false
var encounter_xp_reward := BATTLE_XP_REWARD
var encounter_point_reward := BATTLE_POINT_REWARD
var battle_turn := 0
var battle_logs: Array[String] = []
var _last_d20 := 0
var _boss_animation_time := 0.0
var _boss_origin := Vector2.ZERO
var _boss_tween: Tween
var _rng := RandomNumberGenerator.new()
var _pet_stats: PetStats
var _pet_skills: PetSkills
var _pet_identity: PetIdentity

@onready var status_label: Label = $Status
@onready var points_label: Label = $Points
@onready var result_label: Label = $Result
@onready var hint_label: Label = $Hint
@onready var lobby_card: Panel = $LobbyCard
@onready var battle_card: Panel = $BattleCard
@onready var player_name_label: Label = $BattleCard/PlayerName
@onready var player_hp_label: Label = $BattleCard/PlayerHP
@onready var player_hp_bar: ProgressBar = $BattleCard/PlayerHPBar
@onready var player_en_label: Label = $BattleCard/PlayerEN
@onready var player_en_bar: ProgressBar = $BattleCard/PlayerENBar
@onready var enemy_name_label: Label = $BattleCard/EnemyName
@onready var enemy_hp_label: Label = $BattleCard/EnemyHP
@onready var enemy_hp_bar: ProgressBar = $BattleCard/EnemyHPBar
@onready var turn_label: Label = $BattleCard/Turn
@onready var action_label: Label = $BattleCard/Action
@onready var command_menu_label: Label = $BattleCard/CommandMenu
@onready var emotion_strip: TextureRect = $EmotionStrip
@onready var player_panel: NinePatchRect = $BattleCard/PlayerPanel
@onready var enemy_panel: NinePatchRect = $BattleCard/EnemyPanel
@onready var boss_sprite: TextureRect = $BattleCard/BossSprite
@onready var action_button_1: NinePatchRect = $BattleCard/ActionButton1
@onready var action_button_2: NinePatchRect = $BattleCard/ActionButton2
@onready var action_button_3: NinePatchRect = $BattleCard/ActionButton3
@onready var action_button_4: NinePatchRect = $BattleCard/ActionButton4
@onready var log_frame: NinePatchRect = $BattleCard/LogFrame
@onready var option_1_label: Label = $BattleCard/ActionButton1/Label
@onready var option_2_label: Label = $BattleCard/ActionButton2/Label
@onready var option_3_label: Label = $BattleCard/ActionButton3/Label
@onready var option_4_label: Label = $BattleCard/ActionButton4/Label
@onready var log_label: Label = $BattleCard/Log
@onready var move_effect: TextureRect = $BattleCard/MoveEffect
@onready var victory_audio: AudioStreamPlayer = $VictoryAudio

func _ready() -> void:
	visible = false
	_boss_origin = boss_sprite.position if boss_sprite != null else Vector2.ZERO
	_load_battle_visual_assets()
	_update_points()
	_show_lobby()

func _load_battle_visual_assets() -> void:
	if OS.has_feature("headless") or DisplayServer.get_name().to_lower() == "headless":
		return
	var button_cyan := load("res://assets/UI/battle/battle_button_cyan.png") as Texture2D
	var button_blue := load("res://assets/UI/battle/battle_button_blue.png") as Texture2D
	var log_cyan := load("res://assets/UI/battle/battle_log_cyan.png") as Texture2D
	var emotions := load("res://assets/UI/battle/battle_emotions_strip.png") as Texture2D
	if button_cyan != null:
		for node in [player_panel, action_button_1, action_button_3]:
			node.texture = button_cyan
	if button_blue != null:
		for node in [enemy_panel, action_button_2, action_button_4]:
			node.texture = button_blue
	if log_cyan != null:
		log_frame.texture = log_cyan
	if emotions != null:
		emotion_strip.texture = emotions

func _process(delta: float) -> void:
	if boss_sprite == null or not boss_sprite.visible or phase != &"battle":
		return
	_boss_animation_time += delta
	boss_sprite.position.y = _boss_origin.y + sin(_boss_animation_time * 2.4) * 3.0
	boss_sprite.rotation = sin(_boss_animation_time * 1.7) * 0.018

func configure_mode(context: StringName) -> void:
	mode_context = context

func get_mode_context() -> StringName:
	return mode_context

func configure_exploration_area(area_id: StringName) -> void:
	exploration_area_id = area_id
	mode_context = &"exploration"

func is_boss_encounter() -> bool:
	return encounter_is_boss

func configure(pet_stats: PetStats, pet_skills: PetSkills, pet_identity: PetIdentity) -> void:
	_pet_stats = pet_stats
	_pet_skills = pet_skills
	_pet_identity = pet_identity
	var seed_value := pet_identity.identity_seed if pet_identity != null else 777123
	_rng.seed = abs(seed_value) + 9173

func configure_encounter(encounter_name: String, level_bonus: int = 0, is_boss: bool = false) -> void:
	encounter_override_name = encounter_name
	encounter_level_bonus = level_bonus
	encounter_is_boss = is_boss
	encounter_xp_reward = BATTLE_XP_REWARD + (50 if is_boss else 0)
	encounter_point_reward = BATTLE_POINT_REWARD + (15 if is_boss else 0)

func open_area() -> void:
	visible = true
	_show_lobby()
	grab_focus()

func close_area() -> void:
	visible = false
	phase = &"lobby"
	if victory_audio != null:
		victory_audio.stop()
	area_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not visible or direction == Vector2i.ZERO:
		return
	if phase == &"battle":
		var menu_actions := _get_menu_actions()
		if menu_actions.is_empty():
			return
		selected_index = wrapi(selected_index + (1 if direction.x > 0 or direction.y > 0 else -1), 0, menu_actions.size())
		_update_battle_ui()
	elif phase == &"result":
		selected_index = 0
		_update_result_ui()
	else:
		selected_index = wrapi(selected_index + (1 if direction.x > 0 or direction.y > 0 else -1), 0, 2)
		status_label.text = "%s: %s" % [_mode_title(), "PARTIR" if selected_index == 0 else "EQUIPAMENTO"]

func confirm() -> void:
	if not visible:
		return
	match phase:
		&"lobby":
			if selected_index == 0:
				_start_battle()
			else:
				status_label.text = "EQUIPAMENTO DA EXPLORAÇÃO"
				result_label.text = "EQUIPAMENTO SERÁ DETALHADO NO LEVEL DESIGN"
				hint_label.text = "D-PAD: NAVEGAR   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR"
		&"battle":
			_confirm_battle_menu()
		&"result":
			_start_battle()

func back() -> void:

	if not visible:
		return
	if phase == &"battle" and menu_level != &"root":
		menu_level = &"root"
		selected_index = 0
		_update_battle_ui()
		return
	close_area()

func is_in_submenu() -> bool:
	return phase == &"battle" and menu_level != &"root"

func add_exploration_points(amount: int) -> void:
	if amount <= 0:
		return
	exploration_points += amount
	_update_points()
	points_changed.emit(exploration_points)

func get_exploration_points() -> int:
	return exploration_points

func get_phase() -> StringName:
	return phase

func get_selected_action() -> StringName:
	if phase != &"battle":
		return &""
	var menu_actions := _get_menu_actions()
	if menu_actions.is_empty():
		return &""
	return menu_actions[clampi(selected_index, 0, menu_actions.size() - 1)]

func _start_battle() -> void:
	phase = &"battle"
	battle_over = false
	is_player_turn = true
	player_guarding = false
	enemy_guarding = false
	enemy_weakened = false
	enemy_status = &""
	enemy_status_turns = 0
	player_accuracy_bonus = 0.0
	pending_player_action = &""
	menu_level = &"root"
	selected_index = 0
	battle_turn = 1
	battle_logs.clear()
	_last_d20 = 0

	var strength := _get_attribute(&"forca", 10)
	var defense := _get_attribute(&"defesa", 10)
	var agility := _get_attribute(&"agilidade", 10)
	var resistance := maxi(0, _get_attribute(&"resistencia", 10))
	player_max_hp = 70 + resistance * 3 + (_pet_skills.level * 10 if _pet_skills != null else 10)
	player_hp = player_max_hp
	player_max_en = BASE_ENERGY + resistance * 2
	player_en = player_max_en
	var player_level := _pet_skills.level if _pet_skills != null else 1
	enemy_level = maxi(1, player_level + encounter_level_bonus + _rng.randi_range(-1, 1))
	enemy_faction = _opposing_faction()
	if not encounter_override_name.is_empty():
		enemy_name = encounter_override_name
	elif mode_context == &"exploration":
		enemy_name = "ECO %s" % String(_area_encounter_label()).to_upper()
	else:
		enemy_name = _make_enemy_name()
	_update_boss_sprite()
	var boss_bonus := 4 if encounter_is_boss else 0

	enemy_strength = maxi(5, strength + _rng.randi_range(-2, 2) + boss_bonus)
	enemy_defense = maxi(5, defense + _rng.randi_range(-2, 2) + boss_bonus)
	enemy_agility = maxi(5, agility + _rng.randi_range(-2, 2) + (2 if encounter_is_boss else 0))
	enemy_max_hp = 60 + enemy_level * 18 + resistance * 2 + (80 if encounter_is_boss else 0)
	enemy_hp = enemy_max_hp

	_add_log("ECO: %s • LV%d" % [enemy_name, enemy_level])
	battle_started.emit(enemy_name, enemy_faction)
	_update_battle_ui()

func _confirm_battle_menu() -> void:
	if phase != &"battle" or battle_over or not is_player_turn:
		return
	var action := get_selected_action()
	if menu_level == &"root":
		match action:
			&"golpes":
				menu_level = &"moves"
				selected_index = 0
			&"tecnica":
				menu_level = &"techniques"
				selected_index = 0
			&"defesa":
				_execute_player_action(&"defesa")
			&"fugir":
				_attempt_escape()
		_update_battle_ui()
		return
	_execute_player_action(action)

func _execute_player_action(action: StringName, resolve_after_enemy: bool = false) -> void:
	if action != &"defesa" and action not in MOVE_ACTIONS and action not in TECHNIQUE_ACTIONS:
		return
	if action in MOVE_ACTIONS and _pet_skills != null and not _pet_skills.is_unlocked(action):
		_update_battle_ui()
		return
	if action == &"intuicao_cosmica":
		_execute_technique(resolve_after_enemy)
		return
	if not resolve_after_enemy and not _player_wins_initiative(action):
		pending_player_action = action
		is_player_turn = false
		_enemy_turn()
		return
	if _pet_stats != null and _pet_stats.audacity > 65.0 and _pet_stats.obedience < 40.0 and _rng.randf() < 0.20:
		_add_log("PET RECUSOU A ORDEM")
		_begin_next_round()
		return

	var skill := _pet_skills.get_skill(action) if _pet_skills != null else {}
	var en_cost := int(skill.get("en_cost", skill.get("cost", 10)))
	if action == &"defesa":
		en_cost = 5
	if player_en < en_cost:
		_add_log("EN INSUFICIENTE")
		_begin_next_round()
		return
	is_player_turn = false
	player_en = maxi(0, player_en - en_cost)
	if action == &"defesa":
		player_guarding = true
		_add_log("GUARDA ATIVA")
		if resolve_after_enemy:
			_begin_next_round()
		else:
			_enemy_turn()
		return

	var d20 := _roll_d20()
	var multiplier := _faction_multiplier(_player_faction(), enemy_faction)
	var power := int(skill.get("power", 12))
	var accuracy := clampf(float(skill.get("accuracy", 0.85)) + float(_get_attribute(&"agilidade", 10) - 10) * 0.005 + player_accuracy_bonus, 0.45, 0.98)
	player_accuracy_bonus = 0.0
	if d20 <= 2:
		_add_log("GOLPE FALHOU")
		if resolve_after_enemy:
			_begin_next_round()
		else:
			_enemy_turn()
		return
	if d20 != 20 and _rng.randf() > accuracy:
		_add_log("GOLPE FALHOU")
		if resolve_after_enemy:
			_begin_next_round()
		else:
			_enemy_turn()
		return

	var damage := maxi(6, int(float((_get_attribute(&"forca", 10) + (_pet_skills.level if _pet_skills != null else 1)) * power) / float(enemy_defense * 0.7 + 10.0) * multiplier))
	if enemy_guarding:
		damage = maxi(2, int(float(damage) * 0.40))
		enemy_guarding = false
		_add_log("ECO EM GUARDA")
	if d20 == 20:
		damage = int(float(damage) * 1.50)
	enemy_hp = maxi(0, enemy_hp - damage)
	_play_move_effect(action, d20 == 20)
	_add_log("CRÍTICO • -%d HP" % damage if d20 == 20 else "%s • -%d HP" % [String(ACTION_LABELS[action]), damage])
	if action == &"golpe_status":
		enemy_status = &"enfraquecido"
		enemy_status_turns = 2 if d20 == 20 else 1
		_add_log("ECO ENFRAQUECIDO")
	if enemy_hp <= 0:
		_finish_battle(true)
		return
	if resolve_after_enemy:
		_begin_next_round()
	else:
		_enemy_turn()

func _execute_technique(resolve_after_enemy: bool = false) -> void:
	if not resolve_after_enemy and not _player_wins_initiative(&"intuicao_cosmica"):
		pending_player_action = &"intuicao_cosmica"
		is_player_turn = false
		_enemy_turn()
		return
	if player_en < TECHNIQUE_COST:
		_add_log("EN INSUFICIENTE")
		_begin_next_round()
		return
	is_player_turn = false
	player_en = maxi(0, player_en - TECHNIQUE_COST)
	player_accuracy_bonus = minf(0.25, player_accuracy_bonus + 0.15)
	_add_log("INTUIÇÃO ATIVA")
	if resolve_after_enemy:
		_begin_next_round()
	else:
		_enemy_turn()

func _player_wins_initiative(action: StringName) -> bool:
	var player_d20 := _roll_d20()
	var enemy_d20 := _roll_d20()
	var priority := 1 if action == &"defesa" else 0
	var player_score := player_d20 + _get_attribute(&"agilidade", 10) + priority
	var enemy_score := enemy_d20 + enemy_agility
	if player_score == enemy_score:
		return player_d20 >= enemy_d20
	return player_score > enemy_score

func _begin_next_round() -> void:
	if phase != &"battle" or battle_over:
		return
	if not pending_player_action.is_empty():
		var pending := pending_player_action
		pending_player_action = &""
		is_player_turn = true
		_execute_player_action(pending, true)
		return
	battle_turn += 1
	is_player_turn = true
	menu_level = &"root"
	selected_index = 0
	_update_battle_ui()

func _attempt_escape() -> void:
	is_player_turn = false
	var d20 := _roll_d20()
	var escape_score := d20 + _get_attribute(&"agilidade", 10)
	var escape_target := 12 + enemy_agility / 2
	if d20 == 20 or escape_score >= escape_target:
		_add_log("FUGA BEM-SUCEDIDA")
		close_area()
		return
	_add_log("FUGA FALHOU")
	_enemy_turn()

func _enemy_turn() -> void:
	if phase != &"battle" or battle_over:
		return
	player_en = mini(player_max_en, player_en + EN_RECOVERY_PER_TURN)

	if _rng.randf() < 0.20 and not enemy_guarding:
		enemy_guarding = true
		_add_log("ECO EM GUARDA")
		_begin_next_round()
		return

	var enemy_d20 := _roll_d20()
	var multiplier := _faction_multiplier(enemy_faction, _player_faction())
	if enemy_d20 <= 2:
		_add_log("ECO ERROU")
		_begin_next_round()
		return
	if enemy_d20 == 20:
		multiplier *= 1.40
	var power := 18
	var damage := maxi(5, int(float(enemy_strength * power) / float(_get_attribute(&"defesa", 10) * 0.7 + 10.0) * multiplier))
	if enemy_status == &"enfraquecido" and enemy_status_turns > 0:
		damage = maxi(2, int(float(damage) * 0.70))
		enemy_status_turns -= 1
		if enemy_status_turns <= 0:
			enemy_status = &""
	if player_guarding:
		damage = maxi(2, int(float(damage) * 0.40))
		player_guarding = false
		_add_log("GUARDA REDUZIU DANO")
	player_hp = maxi(0, player_hp - damage)
	_play_move_effect(&"enemy", enemy_d20 == 20)
	_add_log("ECO CRÍTICO • -%d HP" % damage if enemy_d20 == 20 else "ECO • -%d HP" % damage)
	if player_hp <= 0:
		_finish_battle(false)
		return
	_begin_next_round()

func _finish_battle(victory: bool) -> void:
	battle_over = true
	phase = &"result"
	is_player_turn = false
	menu_level = &"root"
	pending_player_action = &""
	var xp_reward := encounter_xp_reward if victory else BATTLE_DEFEAT_XP
	var point_reward := encounter_point_reward if victory else 0
	if victory:
		if victory_audio != null:
			victory_audio.play()
		_add_log("VITÓRIA • +%d XP • +%d PONTOS" % [xp_reward, point_reward])
		add_exploration_points(point_reward)
		status_label.text = "%s CONCLUÍDA" % _mode_title()
		result_label.text = "VITÓRIA CONTRA %s" % enemy_name
	else:
		_add_log("DERROTA")
		status_label.text = "%s INTERROMPIDA" % _mode_title()
		result_label.text = "DERROTA CONTRA %s" % enemy_name
	battle_completed.emit(victory, xp_reward, point_reward, "Encontro contra %s" % enemy_name)
	_update_result_ui()

func _play_move_effect(action: StringName, critical: bool = false) -> void:
	if move_effect == null:
		return
	var texture_path := String(MOVE_EFFECT_TEXTURES.get(action, ""))
	if texture_path.is_empty():
		return
	move_effect.texture = load(texture_path) as Texture2D
	if move_effect.texture == null:
		return
	if action != &"enemy" and encounter_is_boss:
		_boss_hit_feedback()
	move_effect.visible = true
	move_effect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	move_effect.scale = Vector2(0.58, 0.58) if not critical else Vector2(0.78, 0.78)
	move_effect.rotation = -0.08 if action == &"enemy" else 0.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(move_effect, "scale", Vector2.ONE * (1.18 if critical else 1.0), 0.14)
	tween.parallel().tween_property(move_effect, "modulate:a", 0.0, 0.32)
	tween.tween_callback(move_effect.hide)

func _boss_hit_feedback() -> void:
	if boss_sprite == null or not boss_sprite.visible:
		return
	if _boss_tween != null:
		_boss_tween.kill()
	boss_sprite.modulate = Color(1.0, 0.48, 0.62, 1.0)
	_boss_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_boss_tween.tween_property(boss_sprite, "modulate", Color.WHITE, 0.12)
	_boss_tween.parallel().tween_property(boss_sprite, "scale", Vector2(1.08, 0.94), 0.10)
	_boss_tween.tween_property(boss_sprite, "scale", Vector2.ONE, 0.16)

func _update_boss_sprite() -> void:
	if boss_sprite == null:
		return
	boss_sprite.visible = false
	if mode_context != &"eva" or not encounter_is_boss:
		return
	var asset_name := ""
	var normalized_name := enemy_name.to_lower()
	if normalized_name.contains("gorgon"):
		asset_name = "gorgon_glitch"
	elif normalized_name.contains("prisma"):
		asset_name = "prisma_guard"
	elif normalized_name.contains("core"):
		asset_name = "core_overlord"
	elif normalized_name.contains("ignis"):
		asset_name = "ignis_vectis"
	elif normalized_name.contains("arquiteto"):
		asset_name = "arquiteto_do_esquecimento"
	elif normalized_name.contains("absoluto"):
		asset_name = "eco_absoluto"
	if asset_name.is_empty():
		return
	var texture := load("res://assets/bosses/%s.png" % asset_name) as Texture2D
	if texture == null:
		return
	boss_sprite.texture = texture
	boss_sprite.visible = true
	boss_sprite.position = _boss_origin
	boss_sprite.rotation = 0.0
	boss_sprite.modulate = Color(1, 1, 1, 1)
	boss_sprite.scale = Vector2(0.78, 0.78)
	if _boss_tween != null:
		_boss_tween.kill()
	_boss_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_boss_tween.tween_property(boss_sprite, "scale", Vector2.ONE, 0.32)

func _area_encounter_label() -> String:
	match exploration_area_id:
		&"crystal_ruins": return "CRISTALINO"
		&"electric_abysm": return "ELÉTRICO"
		&"volcanic_core": return "VULCÂNICO"
		&"crystal_forest": return "FLORAL"
		_: return "DEEPWORLD"

func _mode_title() -> String:
	match mode_context:
		&"exploration": return "EXPLORAÇÃO DEEPWORLD"
		&"eva": return "AVENTURA COM EVA"
		_: return "SALA DE TREINOS"

func _show_lobby() -> void:
	phase = &"lobby"
	if boss_sprite != null:
		boss_sprite.visible = false
	menu_level = &"root"
	selected_index = 0
	pending_player_action = &""
	battle_over = false
	lobby_card.visible = true
	battle_card.visible = false
	status_label.text = ""
	result_label.text = ""
	hint_label.text = ""
	_update_points()

func _update_result_ui() -> void:
	lobby_card.visible = false
	battle_card.visible = true
	command_menu_label.text = "RESULTADO DO ENCONTRO"
	option_1_label.text = "◆ NOVA EXPEDIÇÃO"
	option_2_label.text = ""
	option_3_label.text = ""
	option_4_label.text = ""
	for label in [option_1_label, option_2_label, option_3_label, option_4_label]:
		label.add_theme_color_override("font_color", Color(0.05, 0.04, 0.13, 1))
	action_label.text = "VERDE: NOVA EXPEDIÇÃO   •   ROSA: VOLTAR"
	turn_label.text = "RESULTADO"
	log_label.text = _logs_as_text()
	hint_label.text = ""
	_update_battle_bars()

func _get_menu_actions() -> Array[StringName]:
	var actions: Array[StringName] = []
	match menu_level:
		&"moves": actions.append_array(MOVE_ACTIONS)
		&"techniques": actions.append_array(TECHNIQUE_ACTIONS)
		_: actions.append_array(TOP_LEVEL_ACTIONS)
	return actions

func _is_action_available(action: StringName) -> bool:
	if action in [&"golpes", &"tecnica", &"defesa", &"fugir", &"intuicao_cosmica"]:
		return true
	return _pet_skills == null or _pet_skills.is_unlocked(action)

func _update_battle_ui() -> void:
	lobby_card.visible = false
	battle_card.visible = true
	var menu_actions := _get_menu_actions()
	var action := get_selected_action()
	var action_name := String(ACTION_LABELS.get(action, action)).to_upper()
	command_menu_label.text = "AÇÕES DE BATALHA" if menu_level == &"root" else "SUBMENU DE AÇÕES"
	_update_action_button(option_1_label, menu_actions, 0)
	_update_action_button(option_2_label, menu_actions, 1)
	_update_action_button(option_3_label, menu_actions, 2)
	_update_action_button(option_4_label, menu_actions, 3)
	turn_label.text = "T%02d • %s" % [battle_turn, "SUA VEZ" if is_player_turn else "ECO"]
	if menu_level == &"root":
		action_label.text = action_name
	else:
		action_label.text = action_name
	log_label.text = _logs_as_text()
	hint_label.text = ""
	_update_battle_bars()

func _update_action_button(label: Label, menu_actions: Array[StringName], index: int) -> void:
	if index >= menu_actions.size():
		label.text = ""
		label.add_theme_color_override("font_color", Color(0.42, 0.42, 0.5, 1))
		return
	var option := menu_actions[index]
	var marker := "◆ " if index == selected_index else ""
	var state_text := "\nBLOQUEADA" if not _is_action_available(option) else ""
	label.text = "%s%s%s" % [marker, String(ACTION_LABELS.get(option, option)), state_text]
	label.add_theme_color_override("font_color", Color(0.38, 0.03, 0.2, 1) if index == selected_index else Color(0.05, 0.04, 0.13, 1))

func _update_battle_bars() -> void:
	player_name_label.text = "PET  •  %s" % _get_pet_name()
	player_hp_label.text = "HP %d / %d" % [player_hp, player_max_hp]
	player_hp_bar.max_value = maxi(1, player_max_hp)
	player_hp_bar.value = player_hp
	player_en_label.text = "EN %d / %d" % [player_en, player_max_en]
	player_en_bar.max_value = maxi(1, player_max_en)
	player_en_bar.value = player_en
	enemy_name_label.text = "%s  •  LV%d" % [enemy_name, enemy_level]
	enemy_hp_label.text = "HP %d / %d" % [enemy_hp, enemy_max_hp]
	enemy_hp_bar.max_value = maxi(1, enemy_max_hp)
	enemy_hp_bar.value = enemy_hp

func _update_points() -> void:
	if points_label != null:
		points_label.text = "PONTOS %05d" % exploration_points

func _add_log(message: String) -> void:
	battle_logs.push_front(message)
	if battle_logs.size() > 3:
		battle_logs.resize(3)

func _logs_as_text() -> String:
	if battle_logs.is_empty():
		return ""
	return "\n".join(battle_logs)

func _roll_d20() -> int:
	_last_d20 = _rng.randi_range(1, 20)
	return _last_d20

func _get_attribute(attribute: StringName, fallback: int) -> int:
	if _pet_skills == null:
		return fallback
	match attribute:
		&"forca": return _pet_skills.strength
		&"defesa": return _pet_skills.defense
		&"agilidade": return _pet_skills.agility
		&"inteligencia": return _pet_skills.intelligence
		&"resistencia": return _pet_skills.resistance
	return fallback

func _get_pet_name() -> String:
	return _pet_identity.pet_name if _pet_identity != null and not _pet_identity.pet_name.is_empty() else "AURORAPET"

func _player_faction() -> StringName:
	return _pet_identity.faction_id if _pet_identity != null and not _pet_identity.faction_id.is_empty() else &"neutro"

func _opposing_faction() -> StringName:
	match _player_faction():
		&"luz": return &"trevas"
		&"trevas": return &"neutro"
	return &"luz"

func _make_enemy_name() -> String:
	var names := ["ECO DE %s" % _get_pet_name(), "REFLEXO DO VÁCUO", "SOMBRA DE %s" % _get_pet_name()]
	return names[_rng.randi_range(0, names.size() - 1)]

func _faction_multiplier(attacker: StringName, defender: StringName) -> float:
	if (attacker == &"luz" and defender == &"trevas") or (attacker == &"trevas" and defender == &"neutro") or (attacker == &"neutro" and defender == &"luz"):
		return 1.30
	if attacker == defender:
		return 0.90
	return 1.0
