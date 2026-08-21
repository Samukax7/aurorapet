extends Control
class_name BatalhaDeExploracao

## Combate de exploração adaptado do protótipo do Google AI Studio.
## A área mantém o sinal de pontos usado pelo Quarto Cósmico e trabalha com
## PetSkills/PetIdentity existentes, sem criar uma segunda identidade de pet.

signal points_changed(total_points: int)
signal area_closed
signal battle_completed(victory: bool, xp_reward: int, point_reward: int, log_text: String)

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
	&"golpe_fraco": "GOLPE FRACO",
	&"golpe_forte": "GOLPE FORTE",
	&"golpe_status": "GOLPE DE STATUS",
	&"intuicao_cosmica": "INTUIÇÃO CÓSMICA",
}
const TECHNIQUE_COST := 10

var exploration_points := 0
var selected_index := 0
var menu_level: StringName = &"root"
var phase: StringName = &"lobby"
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
var battle_turn := 0
var battle_logs: Array[String] = []
var _last_d20 := 0
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
@onready var log_label: Label = $BattleCard/Log

func _ready() -> void:
	visible = false
	_update_points()
	_show_lobby()

func configure(pet_stats: PetStats, pet_skills: PetSkills, pet_identity: PetIdentity) -> void:
	_pet_stats = pet_stats
	_pet_skills = pet_skills
	_pet_identity = pet_identity
	var seed_value := pet_identity.identity_seed if pet_identity != null else 777123
	_rng.seed = abs(seed_value) + 9173

func open_area() -> void:
	visible = true
	_show_lobby()
	grab_focus()

func close_area() -> void:
	visible = false
	phase = &"lobby"
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
		status_label.text = "EXPLORAÇÃO: %s" % ("PARTIR" if selected_index == 0 else "EQUIPAMENTO")

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
	enemy_level = maxi(1, player_level + _rng.randi_range(-1, 1))
	enemy_faction = _opposing_faction()
	enemy_name = _make_enemy_name()
	enemy_strength = maxi(5, strength + _rng.randi_range(-2, 2))
	enemy_defense = maxi(5, defense + _rng.randi_range(-2, 2))
	enemy_agility = maxi(5, agility + _rng.randi_range(-2, 2))
	enemy_max_hp = 60 + enemy_level * 18 + resistance * 2
	enemy_hp = enemy_max_hp

	_add_log("ECO DETECTADO: %s LV%d emergiu do vácuo." % [enemy_name, enemy_level])
	_add_log("A exploração usa D20, vantagens de facção e guarda tática.")
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
		_add_log("AÇÃO BLOQUEADA: %s ainda não foi desbloqueada." % String(ACTION_LABELS[action]))
		_update_battle_ui()
		return
	if action == &"intuicao_cosmica":
		_execute_technique(resolve_after_enemy)
		return
	if not resolve_after_enemy and not _player_wins_initiative(action):
		pending_player_action = action
		is_player_turn = false
		_add_log("O ECO venceu a iniciativa e agirá primeiro.")
		_enemy_turn()
		return
	if _pet_stats != null and _pet_stats.audacity > 65.0 and _pet_stats.obedience < 40.0 and _rng.randf() < 0.20:
		_add_log("REBELDIA: o pet recusou a ordem de combate neste turno.")
		_begin_next_round()
		return

	var skill := _pet_skills.get_skill(action) if _pet_skills != null else {}
	var en_cost := int(skill.get("en_cost", skill.get("cost", 10)))
	if action == &"defesa":
		en_cost = 5
	if player_en < en_cost:
		_add_log("ENERGIA INSUFICIENTE: precisa de %d EN (atual %d)." % [en_cost, player_en])
		_begin_next_round()
		return
	is_player_turn = false
	player_en = maxi(0, player_en - en_cost)
	_add_log("CUSTO DE EN: -%d" % en_cost)
	if action == &"defesa":
		player_guarding = true
		_add_log("GUARDA ESTELAR ativada: próximo dano recebido reduzido em 60%.")
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
		_add_log("D20 FALHA TÁTICA (%d): o golpe perdeu força." % d20)
		if resolve_after_enemy:
			_begin_next_round()
		else:
			_enemy_turn()
		return
	if d20 != 20 and _rng.randf() > accuracy:
		_add_log("FALHA DE PRECISÃO: %s não encontrou o Eco." % String(ACTION_LABELS[action]))
		if resolve_after_enemy:
			_begin_next_round()
		else:
			_enemy_turn()
		return

	var damage := maxi(6, int(float((_get_attribute(&"forca", 10) + (_pet_skills.level if _pet_skills != null else 1)) * power) / float(enemy_defense * 0.7 + 10.0) * multiplier))
	if enemy_guarding:
		damage = maxi(2, int(float(damage) * 0.40))
		enemy_guarding = false
		_add_log("GUARDA DO ECO absorveu parte do impacto.")
	if d20 == 20:
		damage = int(float(damage) * 1.50)
		_add_log("D20 CRÍTICO PERFEITO (%d): dano massivo." % d20)
	else:
		_add_log("D20 %d: %s causou %d HP." % [d20, String(ACTION_LABELS[action]), damage])
	enemy_hp = maxi(0, enemy_hp - damage)
	if action == &"golpe_status":
		enemy_status = &"enfraquecido"
		enemy_status_turns = 2 if d20 == 20 else 1
		_add_log("STATUS: ECO ENFRAQUECIDO por %d turno(s)." % enemy_status_turns)
	_add_log("%s recebeu -%d HP." % [enemy_name, damage])
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
		_add_log("O ECO venceu a iniciativa; a técnica será usada depois do ataque.")
		_enemy_turn()
		return
	if player_en < TECHNIQUE_COST:
		_add_log("ENERGIA INSUFICIENTE: Intuição exige %d EN." % TECHNIQUE_COST)
		_begin_next_round()
		return
	is_player_turn = false
	player_en = maxi(0, player_en - TECHNIQUE_COST)
	player_accuracy_bonus = minf(0.25, player_accuracy_bonus + 0.15)
	_add_log("INTUIÇÃO CÓSMICA preparada: +15% de precisão no próximo golpe.")
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
	_add_log("INICIATIVA: PET %d + %d%s / ECO %d + %d." % [player_d20, _get_attribute(&"agilidade", 10), " + prioridade" if priority > 0 else "", enemy_d20, enemy_agility])
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
		_add_log("FUGA BEM-SUCEDIDA: a expedição foi encerrada.")
		close_area()
		return
	_add_log("FUGA FALHOU: D20 %d contra alvo %d." % [d20, escape_target])
	_enemy_turn()

func _enemy_turn() -> void:
	if phase != &"battle" or battle_over:
		return
	player_en = mini(player_max_en, player_en + EN_RECOVERY_PER_TURN)
	_add_log("RECUPERAÇÃO DE EN: +%d (atual %d/%d)." % [EN_RECOVERY_PER_TURN, player_en, player_max_en])
	if _rng.randf() < 0.20 and not enemy_guarding:
		enemy_guarding = true
		_add_log("%s ativou postura defensiva." % enemy_name)
		_begin_next_round()
		return

	var enemy_d20 := _roll_d20()
	var multiplier := _faction_multiplier(enemy_faction, _player_faction())
	if enemy_d20 <= 2:
		_add_log("D20 DO ECO FALHOU (%d): o ataque não conectou." % enemy_d20)
		_begin_next_round()
		return
	if enemy_d20 == 20:
		multiplier *= 1.40
		_add_log("D20 CRÍTICO DO ECO (%d)." % enemy_d20)
	var power := 18
	var damage := maxi(5, int(float(enemy_strength * power) / float(_get_attribute(&"defesa", 10) * 0.7 + 10.0) * multiplier))
	if enemy_status == &"enfraquecido" and enemy_status_turns > 0:
		damage = maxi(2, int(float(damage) * 0.70))
		enemy_status_turns -= 1
		_add_log("STATUS ENFRAQUECIDO reduziu o dano do Eco.")
		if enemy_status_turns <= 0:
			enemy_status = &""
	if player_guarding:
		damage = maxi(2, int(float(damage) * 0.40))
		player_guarding = false
		_add_log("GUARDA ESTELAR absorveu 60% do dano.")
	player_hp = maxi(0, player_hp - damage)
	_add_log("%s atacou e causou -%d HP." % [enemy_name, damage])
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
	var xp_reward := BATTLE_XP_REWARD if victory else BATTLE_DEFEAT_XP
	var point_reward := BATTLE_POINT_REWARD if victory else 0
	if victory:
		_add_log("VITÓRIA: o Eco foi dissipado. +%d XP | +%d PONTOS." % [xp_reward, point_reward])
		add_exploration_points(point_reward)
		status_label.text = "EXPEDIÇÃO CONCLUÍDA"
		result_label.text = "VITÓRIA CONTRA %s" % enemy_name
	else:
		_add_log("DERROTA: o pet ficou sem HP. A expedição terminou.")
		status_label.text = "EXPEDIÇÃO INTERROMPIDA"
		result_label.text = "DERROTA CONTRA %s" % enemy_name
	battle_completed.emit(victory, xp_reward, point_reward, "Encontro contra %s" % enemy_name)
	_update_result_ui()

func _show_lobby() -> void:
	phase = &"lobby"
	menu_level = &"root"
	selected_index = 0
	pending_player_action = &""
	battle_over = false
	lobby_card.visible = true
	battle_card.visible = false
	status_label.text = "ÁREA PRONTA PARA EXPLORAÇÃO"
	result_label.text = "ENCONTROS GERAM PONTOS PARA O QUARTO CÓSMICO"
	hint_label.text = "D-PAD: PARTIR/EQUIPAMENTO   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR"
	_update_points()

func _update_result_ui() -> void:
	lobby_card.visible = false
	battle_card.visible = true
	command_menu_label.text = "RESULTADO DO ENCONTRO\nVERDE: NOVA EXPEDIÇÃO\nROSA: VOLTAR"
	action_label.text = "VERDE: NOVA EXPEDIÇÃO   •   ROSA: VOLTAR"
	turn_label.text = "RESULTADO DA EXPEDIÇÃO"
	log_label.text = _logs_as_text()
	hint_label.text = "VERDE: NOVA EXPEDIÇÃO   •   ROSA: VOLTAR"
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
	var menu_lines: Array[String] = []
	for index in range(menu_actions.size()):
		var option := menu_actions[index]
		var marker := ">" if index == selected_index else " "
		var state_text := "" if _is_action_available(option) else " [BLOQUEADA]"
		menu_lines.append("%s %d. %s%s" % [marker, index + 1, String(ACTION_LABELS.get(option, option)), state_text])
	command_menu_label.text = "\n".join(menu_lines)
	turn_label.text = "TURNO %02d  •  %s" % [battle_turn, "SUA VEZ" if is_player_turn else "TURNO DO ECO"]
	if menu_level == &"root":
		action_label.text = "COMANDOS DE BATALHA  •  %s  •  VERDE: ENTRAR" % action_name
	else:
		action_label.text = "SUBMENU  •  %s  •  VERDE: USAR  •  ROSA: VOLTAR" % action_name
	log_label.text = _logs_as_text()
	hint_label.text = "D-PAD: NAVEGAR   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR"
	_update_battle_bars()

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
		points_label.text = "PONTOS DE EXPLORAÇÃO: %05d" % exploration_points

func _add_log(message: String) -> void:
	battle_logs.push_front(message)
	if battle_logs.size() > 8:
		battle_logs.resize(8)

func _logs_as_text() -> String:
	if battle_logs.is_empty():
		return "AGUARDANDO REGISTROS..."
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
