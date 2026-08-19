extends Node
class_name PetStats

## Sistema de necessidades do AuroraPet inspirado em V-Pets clássicos.
## O ritmo é relaxado: o pet sinaliza necessidades críticas e registra histórico,
## mas não possui morte permanente nesta etapa.

signal stats_changed(hunger: float, energy: float, mood: float, health: float)
signal needs_changed(snapshot: Dictionary)
signal action_performed(action: StringName)
signal critical_state_changed(is_critical: bool)
signal attention_changed(active: bool, reason: StringName)
signal illness_changed(is_sick: bool)
signal sleep_state_changed(is_sleeping: bool)

@export_category("Valores iniciais")
@export_range(0.0, 100.0, 1.0) var hunger := 82.0
@export_range(0.0, 100.0, 1.0) var energy := 76.0
@export_range(0.0, 100.0, 1.0) var mood := 68.0
@export_range(0.0, 100.0, 1.0) var health := 91.0
@export_range(0.0, 100.0, 1.0) var hygiene := 86.0
@export_range(0.0, 100.0, 1.0) var discipline := 62.0
@export_range(0.0, 100.0, 0.1) var weight := 18.0

@export_category("Decaimento tranquilo por segundo")
@export var decay_enabled := true
@export_range(0.0, 1.0, 0.001) var hunger_decay := 0.025
@export_range(0.0, 1.0, 0.001) var energy_decay := 0.018
@export_range(0.0, 1.0, 0.001) var mood_decay := 0.012
@export_range(0.0, 1.0, 0.001) var hygiene_decay := 0.020
@export_range(0.0, 1.0, 0.001) var discipline_decay := 0.004
@export_range(0.0, 5.0, 0.05) var decay_multiplier := 1.0
@export_range(0.25, 5.0, 0.25) var decay_tick_interval := 1.0

@export_category("Proteção da saúde")
@export_range(0.0, 100.0, 1.0) var critical_hunger_threshold := 15.0
@export_range(0.0, 100.0, 1.0) var critical_energy_threshold := 15.0
@export_range(0.0, 100.0, 1.0) var critical_mood_threshold := 15.0
@export_range(0.0, 100.0, 1.0) var critical_hygiene_threshold := 18.0
@export_range(0.0, 1.0, 0.001) var critical_health_decay := 0.02
@export var health_falls_only_when_critical := true

@export_category("Chamadas e erros de cuidado")
@export_range(1.0, 3600.0, 1.0) var attention_response_window_seconds := 900.0
@export_range(1.0, 300.0, 1.0) var hygiene_illness_delay_seconds := 120.0
@export_range(0.0, 1.0, 0.001) var illness_health_decay := 0.05
@export_range(0.0, 20.0, 0.5) var discipline_loss_per_care_mistake := 4.0
@export_range(0.0, 20.0, 0.5) var discipline_gain_per_training := 4.0

@export_category("Sono")
@export_range(1.0, 120.0, 1.0) var sleep_recovery_duration_seconds := 12.0
@export_range(0.0, 10.0, 0.1) var sleep_energy_recovery_per_second := 2.4
@export_range(0.0, 5.0, 0.1) var sleep_mood_recovery_per_second := 0.25

@export_category("Resistência")
@export var use_skill_resistance := true
@export_range(0.0, 100.0, 1.0) var resistance := 0.0
@export_range(0.0, 1.0, 0.01) var resistance_decay_reduction := 0.50

@export_category("Histórico de cuidado")
@export_range(0, 999999, 1) var missed_calls := 0
@export_range(0, 999999, 1) var care_mistakes := 0
@export_range(0, 999999, 1) var discipline_mistakes := 0
@export_range(0, 999999, 1) var excessive_meals := 0
@export_range(0, 999999, 1) var meals_served := 0
@export_range(0, 999999, 1) var games_played := 0

var is_sick := false
var is_sleeping := false
var attention_reason: StringName = &""
var _decay_accumulator := 0.0
var _sleep_remaining := 0.0
var _hygiene_critical_elapsed := 0.0
var _attention_elapsed := 0.0
var _last_critical_state := false

func _ready() -> void:
	_clamp_values()
	_last_critical_state = _is_needs_critical()
	_emit_all_state()

func _process(delta: float) -> void:
	if delta <= 0.0:
		return
	if is_sleeping:
		_process_sleep(delta)
	else:
		if not decay_enabled:
			return
		_decay_accumulator += delta
		if _decay_accumulator >= decay_tick_interval:
			var elapsed := _decay_accumulator
			_decay_accumulator = 0.0
			_apply_decay(elapsed)
	_update_attention(delta)
	_update_illness(delta)

func _process_sleep(delta: float) -> void:
	energy += sleep_energy_recovery_per_second * delta
	mood += sleep_mood_recovery_per_second * delta
	_sleep_remaining -= delta
	_clamp_values()
	if _sleep_remaining <= 0.0:
		is_sleeping = false
		sleep_state_changed.emit(false)
	_emit_all_state()

func _apply_decay(elapsed: float) -> void:
	var effective_multiplier := decay_multiplier * _get_resistance_factor()
	hunger -= hunger_decay * effective_multiplier * elapsed
	energy -= energy_decay * effective_multiplier * elapsed
	mood -= mood_decay * effective_multiplier * elapsed
	hygiene -= hygiene_decay * effective_multiplier * elapsed
	discipline -= discipline_decay * effective_multiplier * elapsed

	if hygiene <= critical_hygiene_threshold:
		_hygiene_critical_elapsed += elapsed
	else:
		_hygiene_critical_elapsed = 0.0

	var critical_count := _get_critical_count()
	if health_falls_only_when_critical and critical_count > 0:
		health -= critical_health_decay * effective_multiplier * critical_count * elapsed
	elif not health_falls_only_when_critical:
		health -= critical_health_decay * effective_multiplier * elapsed
	if is_sick:
		health -= illness_health_decay * effective_multiplier * elapsed

	_clamp_values()
	_emit_critical_state_if_changed()
	_emit_all_state()

func _update_illness(_delta: float) -> void:
	if not is_sick and _hygiene_critical_elapsed >= hygiene_illness_delay_seconds:
		_set_illness(true)

func _update_attention(delta: float) -> void:
	var next_reason := _evaluate_attention_reason()
	if next_reason != attention_reason:
		attention_reason = next_reason
		_attention_elapsed = 0.0
		attention_changed.emit(not attention_reason.is_empty(), attention_reason)
		_emit_needs_state()
		return
	if attention_reason.is_empty():
		return
	_attention_elapsed += delta
	if _attention_elapsed >= attention_response_window_seconds:
		_register_care_mistake()
		_attention_elapsed = 0.0
		attention_reason = &""
		attention_changed.emit(false, &"")
		_emit_needs_state()

func _evaluate_attention_reason() -> StringName:
	if is_sleeping:
		return &""
	if is_sick:
		return &"doenca"
	if hunger <= critical_hunger_threshold:
		return &"fome"
	if energy <= critical_energy_threshold:
		return &"sono"
	if mood <= critical_mood_threshold:
		return &"humor"
	if hygiene <= critical_hygiene_threshold:
		return &"higiene"
	return &""

func _register_care_mistake() -> void:
	missed_calls += 1
	care_mistakes += 1
	discipline_mistakes += 1
	discipline -= discipline_loss_per_care_mistake
	_clamp_values()

func perform_action(action: StringName) -> void:
	match action:
		&"comer":
			_apply_food(18.0, 0.0, 1.0, 1.0)
		&"fruta_estelar":
			_apply_food(18.0, 2.0, 1.0, 1.0)
		&"nectar_cosmico":
			_apply_food(28.0, 4.0, 2.0, 2.0)
		&"banquete_nebulosa":
			_apply_food(42.0, 6.0, 3.0, 4.0)
		&"brincar", &"jokenpo":
			_apply_game(18.0, 10.0, 6.0)
		&"jogo_da_velha":
			_apply_game(20.0, 8.0, 5.0)
		&"2048":
			_apply_game(22.0, 12.0, 4.0)
		&"limpar", &"limpar_sujeira":
			hygiene += 35.0
			health += 14.0
			mood += 8.0
			energy -= 3.0
			_hygiene_critical_elapsed = 0.0
		&"dar_remedio":
			if is_sick:
				_set_illness(false)
				health += 24.0
			else:
				health += 2.0
			mood -= 1.0
			energy -= 2.0
		&"treinar":
			mood += 10.0
			energy -= 18.0
			hunger -= 10.0
			health += 3.0
			discipline += discipline_gain_per_training
		&"dormir":
			_start_sleep()
			mood += 5.0
			hunger -= 7.0
			health += 2.0
		_:
			push_warning("Ação desconhecida: %s" % action)
			return
	_clamp_values()
	_refresh_attention_after_action()
	_emit_critical_state_if_changed()
	_emit_all_state()
	action_performed.emit(action)

func _apply_food(hunger_gain: float, mood_gain: float, health_gain: float, weight_gain: float) -> void:
	if hunger >= 94.0:
		excessive_meals += 1
		mood -= 2.0
	else:
		meals_served += 1
		hunger += hunger_gain
		mood += mood_gain
		health += health_gain
		weight += weight_gain

func _apply_game(mood_gain: float, energy_cost: float, hunger_cost: float) -> void:
	games_played += 1
	mood += mood_gain
	energy -= energy_cost
	hunger -= hunger_cost
	weight = maxf(0.0, weight - 1.0)

func _start_sleep() -> void:
	is_sleeping = true
	_sleep_remaining = sleep_recovery_duration_seconds
	attention_reason = &""
	_attention_elapsed = 0.0
	sleep_state_changed.emit(true)
	attention_changed.emit(false, &"")

func _refresh_attention_after_action() -> void:
	var next_reason := _evaluate_attention_reason()
	if next_reason != attention_reason:
		attention_reason = next_reason
		_attention_elapsed = 0.0
		attention_changed.emit(not attention_reason.is_empty(), attention_reason)

func cure_illness() -> void:
	if is_sick:
		_set_illness(false)
		health += 24.0
		_clamp_values()
		_emit_all_state()

func set_stat(stat: StringName, value: float) -> void:
	match stat:
		&"fome": hunger = value
		&"energia": energy = value
		&"humor": mood = value
		&"saude": health = value
		&"higiene": hygiene = value
		&"disciplina": discipline = value
		_:
			push_warning("Status desconhecido: %s" % stat)
			return
	_clamp_values()
	_emit_critical_state_if_changed()
	_emit_all_state()

func is_needs_critical() -> bool:
	return _is_needs_critical()

func get_needs_snapshot() -> Dictionary:
	return {
		"hunger": hunger,
		"energy": energy,
		"mood": mood,
		"health": health,
		"hygiene": hygiene,
		"discipline": discipline,
		"weight": weight,
		"is_sick": is_sick,
		"is_sleeping": is_sleeping,
		"attention_active": not attention_reason.is_empty(),
		"attention_reason": attention_reason,
		"missed_calls": missed_calls,
		"care_mistakes": care_mistakes,
		"discipline_mistakes": discipline_mistakes,
		"excessive_meals": excessive_meals,
	}

func get_attention_message() -> String:
	match attention_reason:
		&"fome": return "O PET ESTÁ COM FOME"
		&"sono": return "O PET ESTÁ COM SONO"
		&"humor": return "O PET QUER BRINCAR"
		&"higiene": return "O PET PRECISA DE CUIDADOS"
		&"doenca": return "O PET PRECISA DE REMÉDIO"
	return ""

func get_resistance_value() -> float:
	if use_skill_resistance:
		var pet_skills := get_parent().get_node_or_null(^"PetSkills") as PetSkills
		if pet_skills != null:
			return clampf((pet_skills.strength + pet_skills.defense + pet_skills.agility + pet_skills.intelligence) / 4.0, 0.0, 100.0)
	return resistance

func _get_resistance_factor() -> float:
	var reduction := clampf(get_resistance_value() / 100.0 * resistance_decay_reduction, 0.0, 0.75)
	return 1.0 - reduction

func _get_critical_count() -> int:
	var count := 0
	if hunger <= critical_hunger_threshold:
		count += 1
	if energy <= critical_energy_threshold:
		count += 1
	if mood <= critical_mood_threshold:
		count += 1
	if hygiene <= critical_hygiene_threshold:
		count += 1
	return count

func _is_needs_critical() -> bool:
	return _get_critical_count() > 0 or is_sick

func _emit_critical_state_if_changed() -> void:
	var current_critical_state := _is_needs_critical()
	if current_critical_state != _last_critical_state:
		_last_critical_state = current_critical_state
		critical_state_changed.emit(current_critical_state)

func _set_illness(value: bool) -> void:
	if is_sick == value:
		return
	is_sick = value
	illness_changed.emit(is_sick)
	_emit_critical_state_if_changed()

func _clamp_values() -> void:
	hunger = clampf(hunger, 0.0, 100.0)
	energy = clampf(energy, 0.0, 100.0)
	mood = clampf(mood, 0.0, 100.0)
	health = clampf(health, 0.0, 100.0)
	hygiene = clampf(hygiene, 0.0, 100.0)
	discipline = clampf(discipline, 0.0, 100.0)
	weight = clampf(weight, 0.0, 100.0)

func _emit_all_state() -> void:
	stats_changed.emit(hunger, energy, mood, health)
	_emit_needs_state()

func _emit_needs_state() -> void:
	needs_changed.emit(get_needs_snapshot())
