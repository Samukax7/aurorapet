extends Control
class_name BatalhaDeExploracao

## Combate de exploração por turnos do AuroraPet.
## A primeira versão usa três faixas horizontais funcionais; a grade 3x3 é visual.
## O pet visual é reutilizado por BattleStage sem recriar a estrutura modular.

signal points_changed(total_points: int)
signal area_closed
signal battle_completed(victory: bool, xp_reward: int, point_reward: int, log_text: String)
signal battle_started(enemy_name: String, enemy_faction: StringName)

const BATTLE_XP_REWARD := 50
const BATTLE_DEFEAT_XP := 10
const BATTLE_POINT_REWARD := 10
const EN_RECOVERY_PER_TURN := 8
const BASE_ENERGY := 80
const INTRO_DURATION := 1.5
const INTRO_FLICK_SPEED := 18.0
const TOP_LEVEL_ACTIONS: Array[StringName] = [&"golpes", &"tecnica", &"defesa", &"fugir"]
const MOVE_ACTIONS: Array[StringName] = [&"golpe_fraco", &"golpe_forte"]
const TECHNIQUE_ACTIONS: Array[StringName] = [&"intuicao_cosmica", &"duplo_prisma", &"corte_bifurcado", &"eclipse_total"]
const DEV_SPECIAL_ACTION: StringName = &"pulso_dev"
const DEFENSE_ACTIONS: Array[StringName] = [&"escudo", &"golpe_status"]
const LANE_NAMES: Array[String] = ["SUPERIOR", "CENTRAL", "INFERIOR"]
const LANE_Y: Array[float] = [211.0, 280.0, 349.0]
const BATTLE_ACTION_UNLOCK_LEVELS: Dictionary = {
	&"intuicao_cosmica": 2,
	&"duplo_prisma": 3,
	&"corte_bifurcado": 4,
	&"eclipse_total": 6,
}
const BOSS_BATTLE_BACKGROUND_TEXTURES: Dictionary = {
	"gorgon glitch": "res://assets/bosses/gorgon_glitch/gorgon_glitch_battle_background.jpg",
}
const ULTIMATE_MIN_ENERGY := 30
const ULTIMATE_ENERGY_SCALE := 0.55
const TECHNIQUE_DEFINITIONS: Dictionary = {
	&"intuicao_cosmica": {"en_cost": 10, "power": 20, "accuracy": 0.82},
	&"duplo_prisma": {"en_cost": 18, "power": 24, "accuracy": 0.80},
	&"corte_bifurcado": {"en_cost": 24, "power": 28, "accuracy": 0.76},
}
const ULTIMATE_DEFINITION: Dictionary = {"en_cost": 0, "power": 34, "accuracy": 0.78}
const DEV_SPECIAL_DEFINITION: Dictionary = {"en_cost": 0, "power": 9999, "accuracy": 1.0}
const ACTION_LABELS: Dictionary = {
	&"golpes": "ATAQUE",
	&"tecnica": "S. ATTACK",
	&"defesa": "DEFESA",
	&"fugir": "FUGIR",
	&"golpe_fraco": "PULSO AURORA",
	&"golpe_forte": "IMPACTO ESTELAR",
	&"golpe_status": "SELO DO VAZIO",
&"intuicao_cosmica": "ÓRBITA DA INTUIÇÃO",
&"duplo_prisma": "PRISMA DUPLO",
&"corte_bifurcado": "CORTE BIFURCADO",
&"eclipse_total": "ECLIPSE TOTAL",
&"pulso_dev": "PULSO DEV • TESTE RÁPIDO",
&"escudo": "ESCUDO",

}
const MOVE_EFFECT_TEXTURES: Dictionary = {
	&"golpe_fraco": "res://assets/battle/effects/pulso_aurora_64.png",
	&"golpe_forte": "res://assets/battle/effects/impacto_estelar_64.png",
	&"golpe_status": "res://assets/battle/effects/selo_vazio_64.png",
	&"intuicao_cosmica": "res://assets/battle/effects/mare_plasma_64.png",
&"duplo_prisma": "res://assets/battle/effects/mare_plasma_64.png",
&"corte_bifurcado": "res://assets/battle/effects/impacto_estelar_64.png",
&"eclipse_total": "res://assets/battle/effects/selo_vazio_64.png",
&"pulso_dev": "res://assets/battle/effects/impacto_estelar_64.png",
&"enemy": "res://assets/battle/effects/fragmento_nebular_64.png",

}
const TECHNIQUE_COST := 10
const PLAYER_PROJECTILE_ORIGIN := Vector2(160, 262)
const ENEMY_PROJECTILE_ORIGIN := Vector2(920, 262)
const PLAYER_PROJECTILE_TARGET := Vector2(920, 262)
const ENEMY_PROJECTILE_TARGET := Vector2(160, 262)
const PROJECTILE_TRAVEL_DURATION := 0.28

var exploration_points := 0
var development_mode := false
var selected_index := 0
var menu_level: StringName = &"root"
var phase: StringName = &"lobby"
var battle_step: StringName = &"action_select"
var mode_context: StringName = &"training"
var exploration_area_id: StringName = &"data_city"
var is_player_turn := true
var battle_over := false
var player_guarding := false
var enemy_guarding := false
var enemy_weakened := false
var enemy_status_turns := 0
var pending_player_action: StringName = &""
var pending_enemy_action: StringName = &""
var player_attack_lane := 1
var player_defense_lane := 1
var enemy_attack_lane := 1
var enemy_defense_lane := 1
var lane_cursor := 1
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
var ultimate_energy_used := 0
var current_attack_lanes: Array[int] = []
var battle_logs: Array[String] = []
var _last_d20 := 0
var _intro_elapsed := 0.0
var _boss_animation_time := 0.0
var _boss_origin := Vector2.ZERO
var _boss_tween: Tween
var _resolution_tween: Tween
var _result_return_tween: Tween
var _using_boss_intro := false
var _rng := RandomNumberGenerator.new()
var _pet_stats: PetStats
var _pet_skills: PetSkills
var _pet_identity: PetIdentity
var _player_pet_source: PetRandomizer
var mobile_presentation := false

@onready var blackout_panel: Panel = $BlackoutPanel
@onready var blackout_text: Label = $BlackoutPanel/Text
@onready var lobby_card: Panel = $LobbyCard
@onready var status_label: Label = $LobbyCard/Status
@onready var battle_card: Control = $BattleCard
@onready var player_name_label: Label = $BattleCard/PlayerCard/PlayerName
@onready var player_level_label: Label = $BattleCard/PlayerCard/PlayerLevel
@onready var player_hp_label: Label = $BattleCard/PlayerCard/PlayerHP
@onready var player_hp_bar: ProgressBar = $BattleCard/PlayerCard/PlayerHPBar
@onready var player_en_label: Label = $BattleCard/PlayerCard/PlayerEN
@onready var player_en_bar: ProgressBar = $BattleCard/PlayerCard/PlayerENBar
@onready var enemy_name_label: Label = $BattleCard/EnemyCard/EnemyName
@onready var enemy_level_label: Label = $BattleCard/EnemyCard/EnemyLevel
@onready var enemy_hp_label: Label = $BattleCard/EnemyCard/EnemyHP
@onready var enemy_hp_bar: ProgressBar = $BattleCard/EnemyCard/EnemyHPBar
@onready var turn_label: Label = $BattleCard/TurnLabel
@onready var action_label: Label = $BattleCard/ActionLabel
@onready var command_menu_label: Label = $BattleCard/CommandMenuLabel
@onready var log_label: Label = $BattleCard/LogFrame/Log
@onready var result_label: Label = $Result
@onready var hint_label: Label = $Hint
@onready var d20_value_label: Label = $BattleCard/D20Badge/Value
@onready var lane_marker: Panel = $BattleCard/LaneMarker
@onready var lane_readout: Label = $BattleCard/LaneReadout
@onready var ultimate_status: Label = $BattleCard/UltimateSlot/Status
@onready var action_buttons: Array[Button] = [
	$BattleCard/ActionPanel/ActionButton1,
	$BattleCard/ActionPanel/ActionButton2,
	$BattleCard/ActionPanel/ActionButton3,
	$BattleCard/ActionPanel/ActionButton4,
]
@onready var move_effect: TextureRect = $BattleCard/MoveEffect
@onready var impact_effect: Label = $BattleCard/ImpactEffect
@onready var impact_effects: Array[Label] = [$BattleCard/ImpactEffect, $BattleCard/ImpactEffect2, $BattleCard/ImpactEffect3]
@onready var player_card: Panel = $BattleCard/PlayerCard
@onready var enemy_card: Panel = $BattleCard/EnemyCard
@onready var victory_audio: AudioStreamPlayer = $VictoryAudio
@onready var boss_battle_background: TextureRect = $BossBattleBackground
@onready var boss_intro_controller: Control = $BossIntroController

func _ready() -> void:
	visible = false
	for index in action_buttons.size():
		action_buttons[index].pressed.connect(_on_touch_action_pressed.bind(index))
	if boss_intro_controller != null and not boss_intro_controller.is_connected("presentation_finished", Callable(self, "_on_boss_presentation_finished")):
		boss_intro_controller.connect("presentation_finished", Callable(self, "_on_boss_presentation_finished"))
	_show_lobby()

func set_mobile_presentation(active_mobile: bool) -> void:
	mobile_presentation = active_mobile

func _on_touch_action_pressed(index: int) -> void:
	if not visible or phase != &"battle" or battle_step == &"resolving":
		return
	selected_index = clampi(index, 0, action_buttons.size() - 1)
	_update_battle_ui()
	if mobile_presentation:
		confirm()

func _process(delta: float) -> void:
	if phase == &"intro" and _using_boss_intro:
		return
	if phase == &"intro":
		_intro_elapsed += delta
		var flick: float = 0.86 + abs(sin(_intro_elapsed * INTRO_FLICK_SPEED)) * 0.14
		blackout_panel.modulate.a = flick
		blackout_text.modulate.a = 0.68 + abs(sin(_intro_elapsed * INTRO_FLICK_SPEED * 1.7)) * 0.32
		blackout_text.scale = Vector2.ONE * (1.0 + abs(sin(_intro_elapsed * 7.0)) * 0.025)
		if _intro_elapsed >= INTRO_DURATION:
			_begin_battle_after_intro()
		return
	if phase != &"battle":
		return

func configure_mode(context: StringName) -> void:
	mode_context = context

func set_development_mode(active: bool) -> void:
	development_mode = active
	_update_battle_ui()

func is_development_mode() -> bool:
	return development_mode

func get_mode_context() -> StringName:
	return mode_context

func configure_exploration_area(area_id: StringName) -> void:
	exploration_area_id = area_id
	mode_context = &"exploration"

func is_boss_encounter() -> bool:
	return encounter_is_boss

func configure(pet_stats: PetStats, pet_skills: PetSkills, pet_identity: PetIdentity, player_pet: PetRandomizer = null) -> void:
	_pet_stats = pet_stats
	_pet_skills = pet_skills
	_pet_identity = pet_identity
	_player_pet_source = player_pet
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
	if boss_intro_controller != null:
		boss_intro_controller.call("skip")
	_using_boss_intro = false
	if boss_battle_background != null:
		boss_battle_background.visible = false
	phase = &"lobby"
	battle_step = &"action_select"
	if _resolution_tween != null:
		_resolution_tween.kill()
	if _result_return_tween != null:
		_result_return_tween.kill()
	if victory_audio != null:
		victory_audio.stop()
	area_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not visible or direction == Vector2i.ZERO or phase == &"intro" or battle_step == &"resolving":
		return
	if phase == &"battle" and battle_step in [&"attack_lane", &"defense_lane"]:
		var step := 1 if direction.x > 0 or direction.y > 0 else -1
		lane_cursor = wrapi(lane_cursor + step, 0, 3)
		_update_battle_ui()
		return
	if phase == &"battle":
		var menu_actions := _get_menu_actions()
		if menu_actions.is_empty():
			return
		var delta := 1 if direction.x > 0 or direction.y > 0 else -1
		selected_index = wrapi(selected_index + delta, 0, menu_actions.size())
		_update_battle_ui()
	elif phase == &"lobby":
		selected_index = wrapi(selected_index + (1 if direction.x > 0 or direction.y > 0 else -1), 0, 2)
		_update_lobby_ui()
	elif phase == &"result":
		selected_index = 0
		_update_result_ui()

func confirm() -> void:
	if not visible or phase == &"intro":
		return
	match phase:
		&"lobby":
			if selected_index == 0:
				_start_battle()
			else:
				status_label.text = "EQUIPAMENTO EM DESENVOLVIMENTO"
		&"battle":
			_confirm_battle_step()
		&"result":
			close_area()

func back() -> void:
	if not visible:
		return
	if phase == &"intro":
		close_area()
		return
	if phase == &"battle":
		if battle_step in [&"attack_lane", &"defense_lane"]:
			pending_player_action = &""
			battle_step = &"action_select"
			menu_level = &"root"
			selected_index = 0
			_update_battle_ui()
			return
		if menu_level != &"root":
			menu_level = &"root"
			battle_step = &"action_select"
			selected_index = 0
			_update_battle_ui()
			return
	close_area()

func is_in_submenu() -> bool:
	return phase == &"battle" and (menu_level != &"root" or battle_step != &"action_select")

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
	var menu_actions := _get_menu_actions()
	if menu_actions.is_empty():
		return &""
	return menu_actions[clampi(selected_index, 0, menu_actions.size() - 1)]

func _start_battle() -> void:
	if _pet_stats != null and _pet_stats.is_sleeping:
		_add_log("PET ESTÁ DORMINDO")
		return
	if _pet_stats != null and _pet_stats.is_fainted:
		_add_log("PET ESTÁ DESMAIADO • CUIDADOS URGENTES")
		return
	phase = &"intro"
	battle_step = &"resolving"
	battle_over = false
	is_player_turn = true
	player_guarding = false
	enemy_guarding = false
	enemy_weakened = false
	
	enemy_status_turns = 0
	pending_player_action = &""
	pending_enemy_action = &""
	menu_level = &"root"
	selected_index = 0
	lane_cursor = 1
	battle_turn = 1
	battle_logs.clear()
	if _pet_stats != null and _pet_stats.hunger < 50.0:
		_add_log("PET HESITA: FOME REDUZ FORÇA E DEFESA")
	if _pet_stats != null and _pet_stats.energy < 30.0:
		_add_log("PET SONOLENTO: PRECISÃO E AGILIDADE REDUZIDAS")
	_last_d20 = 0
	ultimate_energy_used = 0
	current_attack_lanes.clear()

	var strength := _get_attribute(&"forca", 10)
	var defense := _get_attribute(&"defesa", 10)
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
	enemy_strength = maxi(5, strength + _rng.randi_range(-2, 2) + (4 if encounter_is_boss else 0))
	enemy_defense = maxi(5, defense + _rng.randi_range(-2, 2) + (4 if encounter_is_boss else 0))
	enemy_agility = maxi(5, _get_attribute(&"agilidade", 8) + _rng.randi_range(-2, 2) + (2 if encounter_is_boss else 0))
	enemy_max_hp = 60 + enemy_level * 18 + resistance * 2 + (80 if encounter_is_boss else 0)
	enemy_hp = enemy_max_hp
	enemy_defense_lane = _rng.randi_range(0, 2)
	_update_boss_sprite()
	_add_log("ECO DETECTADO • PREPARE-SE")
	battle_started.emit(enemy_name, enemy_faction)
	_update_battle_bars()
	lobby_card.visible = false
	battle_card.visible = true
	blackout_panel.visible = true
	blackout_panel.modulate.a = 1.0
	blackout_text.modulate.a = 1.0
	_intro_elapsed = 0.0
	_update_battle_ui()
	if _start_boss_presentation():
		return

func _begin_battle_after_intro() -> void:
	if phase != &"intro":
		return
	_using_boss_intro = false
	if boss_intro_controller != null:
		boss_intro_controller.call("skip")
	if boss_battle_background != null:
		boss_battle_background.visible = encounter_is_boss and not String(BOSS_BATTLE_BACKGROUND_TEXTURES.get(enemy_name.strip_edges().to_lower(), "")).is_empty()
	blackout_panel.visible = false
	phase = &"battle"
	battle_step = &"action_select"
	is_player_turn = true
	_add_log("SUA VEZ")
	_update_battle_ui()

func _start_boss_presentation() -> bool:
	_using_boss_intro = false
	if not encounter_is_boss or mode_context != &"eva" or boss_intro_controller == null:
		return false
	if not bool(boss_intro_controller.call("has_package", enemy_name)):
		return false
	var background_path := String(BOSS_BATTLE_BACKGROUND_TEXTURES.get(enemy_name.strip_edges().to_lower(), ""))
	var background_texture := load(background_path) as Texture2D if not background_path.is_empty() else null
	if boss_battle_background != null:
		boss_battle_background.texture = background_texture
		boss_battle_background.visible = false
	_using_boss_intro = bool(boss_intro_controller.call("play_for_boss", enemy_name))
	return _using_boss_intro

func _on_boss_presentation_finished() -> void:
	if phase != &"intro" or not _using_boss_intro:
		return
	_begin_battle_after_intro()

func _confirm_battle_step() -> void:
	if battle_over or not is_player_turn:
		return
	if battle_step == &"action_select":
		if menu_level == &"root":
			var root_action := get_selected_action()
			match root_action:
				&"golpes":
					menu_level = &"moves"
					selected_index = 0
					battle_step = &"submenu_select"
				&"tecnica":
					menu_level = &"techniques"
					selected_index = 0
					battle_step = &"submenu_select"
				&"defesa":
					menu_level = &"defense"
					selected_index = 0
					battle_step = &"submenu_select"
				&"fugir":
					_attempt_escape()
			_update_battle_ui()
			return
	if battle_step == &"submenu_select":
		var action := get_selected_action()
		if not _is_action_available(action):
			_add_log("AÇÃO BLOQUEADA")
			_update_battle_ui()
			return
		pending_player_action = action
		lane_cursor = 1
		if action == &"escudo":
			battle_step = &"defense_lane"
			_add_log("PREPARE O ESCUDO • ESCOLHA A FAIXA")
		elif action == &"eclipse_total":
			battle_step = &"defense_lane"
			_add_log("ECLIPSE TOTAL COBRE AS 3 FAIXAS • PREPARE A DEFESA")
		else:
			battle_step = &"attack_lane"
			_add_log("ESCOLHA A TRAJETÓRIA DO ATAQUE")
		_update_battle_ui()
		return
	if battle_step == &"attack_lane":
		player_attack_lane = lane_cursor
		lane_cursor = 1
		battle_step = &"defense_lane"
		_add_log("ATAQUE NA FAIXA %s • PREPARE A DEFESA" % LANE_NAMES[player_attack_lane])
		_update_battle_ui()
		return
	if battle_step == &"defense_lane":
		player_defense_lane = lane_cursor
		_add_log("DEFESA PREPARADA • FAIXA %s" % LANE_NAMES[player_defense_lane])
		_resolve_player_action()

func _resolve_player_action() -> void:
	battle_step = &"resolving"
	is_player_turn = false
	var action := pending_player_action
	if action == &"escudo":
		if player_en < 5:
			_add_log("EN INSUFICIENTE • ESCUDO FALHOU")
		else:
			player_en -= 5
			player_guarding = true
			_play_stage_animation(&"player", &"defend")
			_add_log("PET ATIVA ESCUDO")
			_update_battle_ui()
			_queue_enemy_turn()
			return
	var skill: Dictionary = _pet_skills.get_skill(action) if _pet_skills != null else {}
	var technique: Dictionary = TECHNIQUE_DEFINITIONS.get(action, {})
	if action == DEV_SPECIAL_ACTION:
		technique = DEV_SPECIAL_DEFINITION.duplicate(true)
	var ultimate := action == &"eclipse_total"
	var en_cost := int(technique.get("en_cost", skill.get("en_cost", skill.get("cost", 8))))
	if ultimate:
		if not _is_action_available(action) or player_en < ULTIMATE_MIN_ENERGY:
			_add_log("ULTIMATE BLOQUEADA • EN MÍNIMO %d" % ULTIMATE_MIN_ENERGY)
			_update_battle_ui()
			_queue_enemy_turn()
			return
		ultimate_energy_used = player_en
		player_en = 0
	else:
		if player_en < en_cost:
			_add_log("EN INSUFICIENTE")
			_update_battle_ui()
			_queue_enemy_turn()
			return
		player_en -= en_cost
	_play_stage_animation(&"player", &"attack_charged" if action in TECHNIQUE_ACTIONS or action == DEV_SPECIAL_ACTION or action == &"golpe_forte" else &"attack_basic")
	var d20 := _roll_d20()

	var care_accuracy_modifier := _pet_stats.get_order_accuracy_modifier() if _pet_stats != null else 0.0
	var mental_accuracy_bonus := float(_get_attribute(&"inteligencia", 10) - 10) * 0.003 if action in TECHNIQUE_ACTIONS else 0.0
	var accuracy := clampf(float(technique.get("accuracy", skill.get("accuracy", 0.82))) + float(_get_attribute(&"agilidade", 10) - 10) * 0.005 + mental_accuracy_bonus + care_accuracy_modifier, 0.20, 0.98)
	var dev_instant_kill := development_mode and action == DEV_SPECIAL_ACTION
	if not dev_instant_kill and (d20 <= 2 or (d20 != 20 and _rng.randf() > accuracy)):
		ultimate_energy_used = 0
		_add_log("PET ATACA • %s • FALHOU" % String(ACTION_LABELS.get(action, action)))
		_update_battle_ui()
		_queue_enemy_turn()
		return
	var power := int(technique.get("power", skill.get("power", 12)))
	var risk_critical := _pet_stats != null and _rng.randf() < _pet_stats.get_risk_critical_bonus()
	var is_critical := d20 == 20 or risk_critical
	var attack_lanes := _get_attack_lanes(action, player_attack_lane)
	current_attack_lanes = attack_lanes.duplicate()
	var total_damage := 0
	if dev_instant_kill:
		total_damage = enemy_hp
		enemy_guarding = false
		_add_log("INSTANT KILL DEV â€¢ LUTA ENCERRADA EM UM GOLPE")
	else:
		for lane in attack_lanes:
			var lane_bonus := _lane_multiplier(lane, enemy_defense_lane)
			var lane_power := power
			if ultimate:
				var energy_ratio := clampf(float(ultimate_energy_used) / float(maxi(1, player_max_en)), 0.0, 1.0)
				lane_power = int(float(power) * (1.0 + energy_ratio * ULTIMATE_ENERGY_SCALE))
			var damage := _calculate_player_hit_damage(lane_power, lane_bonus)
			if is_critical:
				damage = int(float(damage) * 1.50)
			total_damage += damage
	if enemy_guarding:
		total_damage = maxi(2, int(float(total_damage) * 0.40))
		enemy_guarding = false
		_add_log("ECO EM GUARDA • DANO REDUZIDO")
	enemy_hp = maxi(0, enemy_hp - total_damage)
	_play_move_effect(action, is_critical, attack_lanes)
	if total_damage > 0:
		_play_stage_animation(&"enemy", &"hurt")
	if ultimate:
		_add_log("PET USA ECLIPSE TOTAL • 3 FAIXAS • -%d HP • EN %d" % [total_damage, ultimate_energy_used])
		ultimate_energy_used = 0
	else:
		_add_log("PET ATACA • %s • %d IMPACTO(S) • -%d HP" % [String(ACTION_LABELS.get(action, action)), attack_lanes.size(), total_damage])
	if attack_lanes.size() > 1:
		_add_log("TRAJETÓRIA MÚLTIPLA • %s" % _lanes_as_text(attack_lanes))
	if is_critical:
		_add_log("%s • CRÍTICO" % ("D20: 20" if d20 == 20 else "OUSADIA"))
	if action == &"golpe_status":
		enemy_weakened = true
		enemy_status_turns = 2 if is_critical else 1
		_add_log("ECO ENFRAQUECIDO")
	_update_battle_ui()
	if enemy_hp <= 0:
		_finish_battle(true)
		return
	_queue_enemy_turn()

func _get_attack_lanes(action: StringName, selected_lane: int) -> Array[int]:
	var safe_lane := clampi(selected_lane, 0, LANE_NAMES.size() - 1)
	match action:
		&"duplo_prisma":
			# Dois impactos simultâneos: a faixa escolhida e a faixa adjacente.
			var adjacent := 1 if safe_lane == 0 else (1 if safe_lane == 2 else 0)
			return [safe_lane, adjacent]
		&"corte_bifurcado":
			# Sequência 2+1: dois cortes na faixa escolhida e um corte aleatório
			# em outra faixa, preservando a leitura tática do D20.
			var other_lanes: Array[int] = [0, 1, 2]
			other_lanes.erase(safe_lane)
			var random_lane := other_lanes[_rng.randi_range(0, other_lanes.size() - 1)]
			return [safe_lane, safe_lane, random_lane]
		&"eclipse_total":
			return [0, 1, 2]
		_:
			return [safe_lane]

func _calculate_player_hit_damage(power: int, lane_bonus: float) -> int:
	var multiplier := _faction_multiplier(_player_faction(), enemy_faction)
	if _pet_stats != null:
		multiplier *= _pet_stats.get_risk_power_multiplier()
	return maxi(4, int(float((_get_attribute(&"forca", 10) + (_pet_skills.level if _pet_skills != null else 1)) * power) / float(enemy_defense * 0.7 + 10.0) * multiplier * lane_bonus))

func _lanes_as_text(lanes: Array[int]) -> String:
	var labels: Array[String] = []
	for lane in lanes:
		labels.append(LANE_NAMES[clampi(lane, 0, LANE_NAMES.size() - 1)])
	return " + ".join(labels)

func _queue_enemy_turn() -> void:
	if _resolution_tween != null:
		_resolution_tween.kill()
	_resolution_tween = create_tween()
	_resolution_tween.tween_interval(0.48)
	_resolution_tween.tween_callback(_resolve_enemy_turn)

func _resolve_enemy_turn() -> void:
	if battle_over or phase != &"battle":
		return
	pending_enemy_action = _choose_enemy_action()
	enemy_attack_lane = _rng.randi_range(0, 2)
	_play_enemy_action_animation(pending_enemy_action)
	enemy_defense_lane = _rng.randi_range(0, 2)
	_add_log("ECO PREPARA • %s • FAIXA %s" % [String(ACTION_LABELS.get(pending_enemy_action, pending_enemy_action)), LANE_NAMES[enemy_attack_lane]])
	_update_battle_ui()
	if _resolution_tween != null:
		_resolution_tween.kill()
	_resolution_tween = create_tween()
	_resolution_tween.tween_interval(0.42)
	_resolution_tween.tween_callback(_apply_enemy_action)

func _apply_enemy_action() -> void:
	if battle_over or phase != &"battle":
		return
	var action := pending_enemy_action
	if action == &"escudo":
		enemy_guarding = true
		_add_log("ECO ATIVA ESCUDO")
		_update_battle_ui()
		_begin_next_round()
		return
	var d20 := _roll_d20()
	var lane_gap: int = abs(player_defense_lane - enemy_attack_lane)
	var defense_multiplier := 1.0 if lane_gap >= 2 else (0.62 if lane_gap == 1 else 0.0)
	if action == &"golpe_status":
		defense_multiplier *= 0.9
	var base_damage := maxi(4, int(float(enemy_strength * 18) / float(_get_attribute(&"defesa", 10) * 0.7 + 10.0) * _faction_multiplier(enemy_faction, _player_faction())))
	var damage := int(float(base_damage) * defense_multiplier)
	if enemy_weakened:
		damage = int(float(damage) * 0.70)
		if enemy_status_turns > 0:
			enemy_status_turns -= 1
		if enemy_status_turns <= 0:
			enemy_weakened = false
	if player_guarding:
		damage = int(float(damage) * 0.40)
		player_guarding = false
		_add_log("ESCUDO REDUZIU O DANO")
	if d20 == 20:
		damage = int(float(damage) * 1.40)
	if lane_gap == 0:
		_add_log("DEFESA PERFEITA • ATAQUE DESVIADO")
	if damage <= 0:
		_add_log("ECO USA %s • SEM DANO" % String(ACTION_LABELS.get(action, action)))
	else:
		player_hp = maxi(0, player_hp - damage)
		_play_stage_animation(&"player", &"hurt")
		_play_move_effect(&"enemy", d20 == 20, [player_defense_lane])
		_add_log("ECO USA %s • -%d HP" % [String(ACTION_LABELS.get(action, action)), damage])
	if d20 == 20:
		_add_log("D20: 20 • CRÍTICO DO ECO")
	if action == &"golpe_status" and damage > 0:
		_add_log("PET SOB PRESSÃO")
	_update_battle_ui()
	if player_hp <= 0:
		_finish_battle(false)
		return
	_begin_next_round()

func _begin_next_round() -> void:
	if phase != &"battle" or battle_over:
		return
	var energy_recovered := mini(EN_RECOVERY_PER_TURN, maxi(0, player_max_en - player_en))
	if energy_recovered > 0:
		player_en += energy_recovered
		_add_log("EN RECUPERADA • +%d" % energy_recovered)
	battle_turn += 1
	is_player_turn = true
	battle_step = &"action_select"
	menu_level = &"root"
	selected_index = 0
	pending_player_action = &""
	_add_log("SUA VEZ")
	_update_battle_ui()

func _attempt_escape() -> void:
	battle_step = &"resolving"
	is_player_turn = false
	var d20 := _roll_d20()
	var escape_score := d20 + _get_attribute(&"agilidade", 10)
	var escape_target := 12 + enemy_agility / 2
	if d20 == 20 or escape_score >= escape_target:
		_add_log("FUGA BEM-SUCEDIDA • D20 %d" % d20)
		_update_battle_ui()
		close_area()
		return
	_add_log("FUGA FALHOU • ECO ATACA")
	_update_battle_ui()
	_queue_enemy_turn()

func _finish_battle(victory: bool) -> void:
	battle_over = true
	phase = &"result"
	battle_step = &"result"
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
		result_label.text = "VITÓRIA CONTRA %s" % enemy_name
	else:
		_add_log("DERROTA")
		result_label.text = "DERROTA CONTRA %s" % enemy_name
	var result_delay := 1.4
	if victory:
		_play_stage_animation(&"enemy", &"defeat")
		var stage := get_node_or_null(^"../Deepworld/BattleStage") as Node2D
		if stage != null and stage.has_method("get_enemy_battle_animation_duration"):
			result_delay = maxf(result_delay, float(stage.call("get_enemy_battle_animation_duration", &"defeat")) + 0.25)
	else:
		_play_stage_animation(&"player", &"defeat")
	battle_completed.emit(victory, xp_reward, point_reward, "Encontro contra %s" % enemy_name)
	_update_result_ui()
	if _result_return_tween != null:
		_result_return_tween.kill()
	_result_return_tween = create_tween()
	_result_return_tween.tween_interval(result_delay)
	_result_return_tween.tween_callback(_return_from_result)

func _return_from_result() -> void:
	if phase == &"result" and visible:
		close_area()

func _play_move_effect(action: StringName, critical: bool = false, target_lanes: Array = []) -> void:
	if move_effect == null:
		return
	var texture_path := String(MOVE_EFFECT_TEXTURES.get(action, ""))
	if texture_path.is_empty():
		return
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return
	var target_is_player := action == &"enemy"
	var lanes: Array[int] = []
	for lane_value in target_lanes:
		lanes.append(int(lane_value))
	if lanes.is_empty():
		lanes = [player_defense_lane if target_is_player else enemy_defense_lane]
	for impact_index in lanes.size():
		var lane := clampi(lanes[impact_index], 0, LANE_NAMES.size() - 1)
		var origin_lane := enemy_attack_lane if target_is_player else player_attack_lane
		var origin_x := ENEMY_PROJECTILE_ORIGIN.x if target_is_player else PLAYER_PROJECTILE_ORIGIN.x
		var target_x := ENEMY_PROJECTILE_TARGET.x if target_is_player else PLAYER_PROJECTILE_TARGET.x
		var start_position := Vector2(origin_x, LANE_Y[clampi(origin_lane, 0, LANE_NAMES.size() - 1)])
		var target_position := Vector2(target_x, LANE_Y[lane])
		var projectile: TextureRect = move_effect if impact_index == 0 else _get_projectile_slot(impact_index)
		if projectile == null:
			continue
		projectile.texture = texture
		projectile.pivot_offset = projectile.size * 0.5
		projectile.position = start_position - projectile.size * 0.5
		projectile.rotation = 0.0
		projectile.visible = true
		projectile.modulate = Color(1.0, 0.45, 0.62, 1.0) if target_is_player else Color(0.48, 0.94, 1.0, 1.0)
		projectile.scale = Vector2(0.34, 0.34) if not critical else Vector2(0.46, 0.46)
		var travel_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		var sequence_delay := float(impact_index) * (0.10 if action == &"corte_bifurcado" else 0.0)
		if sequence_delay > 0.0:
			travel_tween.tween_interval(sequence_delay)
		travel_tween.tween_property(projectile, "position", target_position - projectile.size * 0.5, PROJECTILE_TRAVEL_DURATION)
		travel_tween.parallel().tween_property(projectile, "rotation", -0.35 if target_is_player else 0.35, PROJECTILE_TRAVEL_DURATION)
		travel_tween.parallel().tween_property(projectile, "scale", Vector2(0.66, 0.66) if not critical else Vector2(0.82, 0.82), PROJECTILE_TRAVEL_DURATION)
		travel_tween.tween_callback(_show_impact.bind(target_position, target_is_player, critical, impact_index))
		travel_tween.tween_interval(0.22)
		travel_tween.tween_callback(projectile.hide)

func _get_projectile_slot(index: int) -> TextureRect:
	if index == 1:
		return get_node_or_null(^"BattleCard/MoveEffect2") as TextureRect
	if index == 2:
		return get_node_or_null(^"BattleCard/MoveEffect3") as TextureRect
	return move_effect

func _show_impact(target_position: Vector2, target_is_player: bool, critical: bool, impact_index: int = 0) -> void:
	var impact := impact_effect
	if impact_index >= 0 and impact_index < impact_effects.size() and impact_effects[impact_index] != null:
		impact = impact_effects[impact_index]
	if impact == null:
		return
	impact.position = target_position - impact.size * 0.5
	impact.rotation = -0.08 if target_is_player else 0.08
	impact.scale = Vector2(0.45, 0.45) if not critical else Vector2(0.62, 0.62)
	impact.modulate = Color(1.0, 0.36, 0.52, 1.0) if target_is_player else Color(0.42, 1.0, 0.78, 1.0)
	impact.visible = true
	var impact_tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(impact, "scale", Vector2(1.18, 1.18) if critical else Vector2.ONE, 0.10)
	impact_tween.parallel().tween_property(impact, "modulate:a", 0.0, 0.24 if critical else 0.20)
	impact_tween.tween_callback(impact.hide)
	var target_card: Panel = player_card if target_is_player else enemy_card
	if target_card != null:
		var original_modulate := target_card.modulate
		target_card.modulate = Color(1.0, 0.58, 0.64, 1.0) if target_is_player else Color(0.58, 1.0, 0.84, 1.0)
		var card_tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		card_tween.tween_property(target_card, "modulate", original_modulate, 0.18)

func _update_boss_sprite() -> void:
	# A renderização do Boss pertence ao BattleStage/BossBattleActor.
	# O nó estático legado da UI não participa mais da composição.
	return

func _play_stage_animation(actor: StringName, animation_name: StringName) -> void:
	var stage := get_node_or_null(^"../Deepworld/BattleStage") as Node2D
	if stage == null:
		return
	if actor == &"player":
		stage.call("play_player_battle_animation", animation_name)
	else:
		stage.call("play_enemy_battle_animation", animation_name)

func _play_enemy_action_animation(action: StringName) -> void:
	var stage := get_node_or_null(^"../Deepworld/BattleStage") as Node2D
	if stage != null and stage.has_method("play_enemy_action_animation"):
		stage.call("play_enemy_action_animation", action)
		return
	var animation_name: StringName = &"attack_charged" if action == &"golpe_forte" else (&"defend" if action == &"escudo" else &"attack_basic")
	_play_stage_animation(&"enemy", animation_name)

func _show_lobby() -> void:
	phase = &"lobby"
	battle_step = &"action_select"
	menu_level = &"root"
	selected_index = 0
	battle_over = false
	is_player_turn = true
	lobby_card.visible = true
	battle_card.visible = false
	blackout_panel.visible = false
	if boss_intro_controller != null:
		boss_intro_controller.call("skip")
	_using_boss_intro = false
	if boss_battle_background != null:
		boss_battle_background.visible = false
	result_label.visible = false
	hint_label.visible = false
	_update_lobby_ui()
	_update_points()

func _update_lobby_ui() -> void:
	var status := get_node_or_null(^"LobbyCard/Status") as Label
	var points := get_node_or_null(^"LobbyCard/Points") as Label
	var hint := get_node_or_null(^"LobbyCard/Hint") as Label
	if status != null:
		status.text = "%s" % _mode_title()
	if points != null:
		points.text = "PONTOS %05d" % exploration_points
	if hint != null:
		hint.text = "VERDE: PARTIR   •   ROSA: VOLTAR"

func _update_result_ui() -> void:
	lobby_card.visible = false
	battle_card.visible = true
	result_label.visible = true
	hint_label.visible = true
	turn_label.text = "RESULTADO DO ENCONTRO"
	command_menu_label.text = "BATALHA ENCERRADA"
	action_label.text = "VERDE: NOVA EXPEDIÇÃO   •   ROSA: VOLTAR"
	lane_marker.visible = false
	for button in action_buttons:
		button.disabled = true
		button.text = ""
	log_label.text = _logs_as_text()
	hint_label.text = ""
	_update_battle_bars()

func _update_battle_ui() -> void:
	lobby_card.visible = false
	battle_card.visible = true
	result_label.visible = false
	hint_label.visible = true
	var menu_actions := _get_menu_actions()
	_update_action_button(0, menu_actions)
	_update_action_button(1, menu_actions)
	_update_action_button(2, menu_actions)
	_update_action_button(3, menu_actions)
	var step_title := "SUA VEZ"
	var instruction := "ESCOLHA UMA AÇÃO"
	if battle_step == &"submenu_select":
		step_title = "ESCOLHA O GOLPE"
		instruction = "VERDE: SELECIONAR   •   ROSA: VOLTAR"
	elif battle_step == &"attack_lane":
		step_title = "TRAJETÓRIA DO ATAQUE"
		instruction = "MOVA A MARCAÇÃO VERDE E CONFIRME"
	elif battle_step == &"defense_lane":
		step_title = "PREPARAÇÃO DEFENSIVA"
		instruction = "ESCOLHA ONDE O PET VAI SE DEFENDER"
	elif battle_step == &"resolving":
		step_title = "RESOLVENDO TURNO"
		instruction = "AGUARDE"
	turn_label.text = "T%02d • %s" % [battle_turn, step_title]
	command_menu_label.text = "AÇÕES DE BATALHA" if menu_level == &"root" else "SUBMENU • %s" % String(menu_level).to_upper()
	action_label.text = instruction
	log_label.text = _logs_as_text()
	_update_battle_bars()
	_update_lane_marker()
	hint_label.text = "D-PAD: NAVEGAR   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR"
	ultimate_status.text = _get_ultimate_status()

func _get_ultimate_status() -> String:
	var required_level := int(BATTLE_ACTION_UNLOCK_LEVELS[&"eclipse_total"])
	var current_level := _pet_skills.level if _pet_skills != null else 1
	if current_level < required_level:
		return "ECLIPSE TOTAL • 3 FAIXAS\nDESBLOQUEIA NO NÍVEL %d" % required_level
	if player_en < ULTIMATE_MIN_ENERGY:
		return "ECLIPSE TOTAL • 3 FAIXAS\nCARREGUE EN • %d / %d" % [player_en, ULTIMATE_MIN_ENERGY]
	return "ECLIPSE TOTAL • 3 FAIXAS\nPRONTA • CONSUME TODA A ENERGIA"

func _update_action_button(index: int, menu_actions: Array[StringName]) -> void:
	if index >= action_buttons.size():
		return
	var button := action_buttons[index]
	if index >= menu_actions.size():
		button.text = ""
		button.disabled = true
		button.modulate = Color(0.45, 0.46, 0.58, 0.55)
		return
	var option := menu_actions[index]
	button.disabled = false
	button.text = ("▶ " if index == selected_index else "") + String(ACTION_LABELS.get(option, option))
	button.modulate = Color(1.2, 1.18, 1.35, 1.0) if index == selected_index else Color.WHITE

func _update_lane_marker() -> void:
	if lane_marker == null:
		return
	var lane_active := phase == &"battle" and battle_step in [&"attack_lane", &"defense_lane"]
	lane_marker.visible = lane_active
	if not lane_active:
		lane_readout.visible = false
		return
	lane_marker.position.y = LANE_Y[lane_cursor] - 35.0
	lane_readout.visible = true
	lane_readout.position.y = LANE_Y[lane_cursor] - 50.0
	lane_readout.text = ("TRAJETÓRIA: " if battle_step == &"attack_lane" else "DEFESA: ") + LANE_NAMES[lane_cursor]

func _update_battle_bars() -> void:
	player_name_label.text = _get_pet_name()
	player_level_label.text = "LV%d" % (_pet_skills.level if _pet_skills != null else 1)
	player_hp_label.text = "HP %d / %d" % [player_hp, player_max_hp]
	player_hp_bar.max_value = maxi(1, player_max_hp)
	player_hp_bar.value = player_hp
	player_en_label.text = "EN %d / %d" % [player_en, player_max_en]
	player_en_bar.max_value = maxi(1, player_max_en)
	player_en_bar.value = player_en
	enemy_name_label.text = enemy_name
	enemy_level_label.text = "LV%d" % enemy_level
	enemy_hp_label.text = "HP %d / %d" % [enemy_hp, enemy_max_hp]
	enemy_hp_bar.max_value = maxi(1, enemy_max_hp)
	enemy_hp_bar.value = enemy_hp
	d20_value_label.text = str(_last_d20) if _last_d20 > 0 else "—"

func _update_points() -> void:
	var points := get_node_or_null(^"LobbyCard/Points") as Label
	if points != null:
		points.text = "PONTOS %05d" % exploration_points

func _add_log(message: String) -> void:
	battle_logs.push_front(message)
	if battle_logs.size() > 4:
		battle_logs.resize(4)

func _logs_as_text() -> String:
	return "\n".join(battle_logs) if not battle_logs.is_empty() else ""

func _roll_d20() -> int:
	_last_d20 = _rng.randi_range(1, 20)
	return _last_d20

func _lane_multiplier(attacker_lane: int, defender_lane: int) -> float:
	var gap: int = abs(attacker_lane - defender_lane)
	if gap == 0:
		return 1.18
	if gap == 1:
		return 1.0
	return 0.82

func _choose_enemy_action() -> StringName:
	if encounter_is_boss and _rng.randf() < 0.18:
		return &"escudo"
	var options: Array[StringName] = [&"golpe_fraco", &"golpe_forte", &"golpe_status"]
	if encounter_is_boss and _rng.randf() < 0.25:
		return &"golpe_status"
	return options[_rng.randi_range(0, options.size() - 1)]

func _get_menu_actions() -> Array[StringName]:
	match menu_level:
		&"moves": return MOVE_ACTIONS.duplicate()
		&"techniques":
			var techniques: Array[StringName] = TECHNIQUE_ACTIONS.duplicate()
			if development_mode:
				techniques.push_front(DEV_SPECIAL_ACTION)
			return techniques
		&"defense": return DEFENSE_ACTIONS.duplicate()
		_: return TOP_LEVEL_ACTIONS.duplicate()

func _is_action_available(action: StringName) -> bool:
	if action == DEV_SPECIAL_ACTION:
		return development_mode
	if action in [&"golpes", &"tecnica", &"defesa", &"fugir", &"escudo"]:
		return true
	if BATTLE_ACTION_UNLOCK_LEVELS.has(action):
		return _pet_skills == null or _pet_skills.level >= int(BATTLE_ACTION_UNLOCK_LEVELS[action])
	return _pet_skills == null or _pet_skills.is_unlocked(action)

func _get_attribute(attribute: StringName, fallback: int) -> int:
	if _pet_skills == null:
		return fallback
	var base_value := fallback
	match attribute:
		&"forca": base_value = _pet_skills.strength
		&"defesa": base_value = _pet_skills.defense
		&"agilidade": base_value = _pet_skills.agility
		&"inteligencia": base_value = _pet_skills.intelligence
		&"resistencia": return _pet_skills.resistance
	if _pet_stats == null:
		return base_value
	return maxi(1, roundi(float(base_value) * _pet_stats.get_care_attribute_multiplier(attribute)))

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

func _area_encounter_label() -> String:
	match exploration_area_id:
		&"crystal_ruins": return "CRISTALINO"
		&"electric_abysm": return "ELÉTRICO"
		&"volcanic_core": return "VULCÂNICO"
		&"crystal_forest": return "FLORAL"
		_: return "DEEPWORLD"

func _mode_title() -> String:
	match mode_context:
		&"exploration": return "BATALHA DE EXPLORAÇÃO"
		&"eva": return "BATALHA DA JORNADA EVA"
		_: return "SALA DE TREINOS"

func _update_result_message() -> void:
	if result_label != null:
		result_label.visible = true
