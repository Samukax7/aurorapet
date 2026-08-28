extends Node
class_name AuroraPetSave

## Persistência central do AuroraPet.
## O save registra o estado dos nós existentes sem criar ou remover peças do pet.

signal save_written(path: String)
signal save_loaded
signal save_failed(message: String)
signal world_progression_changed
signal eva_encounter_ready

@export var save_path := "user://aurorapet_save.json"
@export_range(1.0, 60.0, 1.0) var autosave_interval := 5.0

var pet_identity: PetIdentity
var pet_stats: PetStats
var pet_skills: PetSkills
var pet_evolution: PetEvolution
var pet_randomizer: PetRandomizer
var quarto_cosmico: QuartoCosmico
var batalha_exploracao: BatalhaDeExploracao
var eva_journey: EvaJourneyManager

var stellar_coins := 0
var cosmic_diary: Array[String] = []
var achievements: Dictionary = {}

var _configured := false
var _loading := false
var _dirty := false
var _autosave_elapsed := 0.0
var development_mode := false
var exploration_battles_completed := 0
var eva_encounter_battle_counter := 0
var eva_encounter_available := false
var eva_encounter_seen := false
var eva_adventure_unlocked := false
var eva_progress_stage_index := 1
var exploration_islands_unlocked: Array[StringName] = [&"data_city"]
var _dev_force_eva_encounter := false
const EXPLORATION_ISLAND_ORDER: Array[StringName] = [&"data_city", &"crystal_forest", &"volcanic_core", &"crystal_ruins", &"electric_abysm"]

func _process(delta: float) -> void:
	if not _configured or _loading or not _dirty:
		return
	_autosave_elapsed += delta
	if _autosave_elapsed >= autosave_interval:
		save_now()

func configure(
	identity: PetIdentity,
	stats: PetStats,
	skills: PetSkills,
	evolution: PetEvolution,
	randomizer: PetRandomizer,
	quarto: QuartoCosmico,
	batalha: BatalhaDeExploracao,
	eva: EvaJourneyManager = null
) -> void:
	pet_identity = identity
	pet_stats = stats
	pet_skills = skills
	pet_evolution = evolution
	pet_randomizer = randomizer
	quarto_cosmico = quarto
	batalha_exploracao = batalha
	eva_journey = eva
	_configured = true
	_connect_state_signals()

func set_development_session(active: bool) -> void:
	development_mode = active
	if active:
		# Sessão DEV é descartável: libera o laboratório inteiro sem gravar no save real.
		exploration_battles_completed = 999
		exploration_islands_unlocked = EXPLORATION_ISLAND_ORDER.duplicate()
		eva_encounter_available = false
		eva_encounter_seen = true
		eva_adventure_unlocked = true
		_dev_force_eva_encounter = true
		eva_progress_stage_index = 21
		_dirty = false
		_autosave_elapsed = 0.0
		world_progression_changed.emit()

func is_development_session() -> bool:
	return development_mode

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func register_exploration_battle() -> void:
	# O primeiro encontro da EVA acontece após três confrontos concluídos,
	# não apenas vitórias. Derrota também é parte da jornada até encontrá-la.
	if development_mode:
		return
	exploration_battles_completed += 1
	eva_encounter_battle_counter += 1
	if eva_adventure_unlocked:
		world_progression_changed.emit()
		mark_dirty()
		return
	if eva_encounter_battle_counter >= 3 and not eva_encounter_available:
		eva_encounter_battle_counter = 0
		eva_encounter_available = true
		eva_encounter_ready.emit()
	world_progression_changed.emit()
	mark_dirty()

func is_eva_encounter_available() -> bool:
	return eva_encounter_available

func consume_eva_encounter_trigger() -> bool:
	if development_mode and _dev_force_eva_encounter:
		_dev_force_eva_encounter = false
		return true
	if eva_encounter_available and not eva_adventure_unlocked:
		eva_encounter_available = false
		mark_dirty()
		return true
	return false

func mark_eva_encounter_seen() -> void:
	# Aceitar EVA encerra definitivamente o gatilho da exploração.
	eva_encounter_seen = true
	eva_encounter_available = false
	eva_encounter_battle_counter = 0
	unlock_exploration_island(&"crystal_forest")
	world_progression_changed.emit()
	mark_dirty()

func reset_eva_encounter_after_refusal() -> void:
	# Recusar não marca o encontro como concluído: ele poderá reaparecer após três vitórias.
	eva_encounter_available = false
	eva_encounter_battle_counter = 0
	world_progression_changed.emit()
	mark_dirty()

func unlock_eva_adventure() -> void:
	eva_adventure_unlocked = true
	world_progression_changed.emit()
	mark_dirty()

func unlock_next_exploration_island() -> void:
	for area_id in EXPLORATION_ISLAND_ORDER:
		if not exploration_islands_unlocked.has(area_id):
			unlock_exploration_island(area_id)
			return

func unlock_exploration_island(area_id: StringName) -> void:
	if area_id.is_empty() or exploration_islands_unlocked.has(area_id):
		return
	exploration_islands_unlocked.append(area_id)
	world_progression_changed.emit()
	mark_dirty()

func is_exploration_island_unlocked(area_id: StringName) -> bool:
	return exploration_islands_unlocked.has(area_id)

func mark_dirty() -> void:
	if development_mode or _loading:
		return
	_dirty = true
	_autosave_elapsed = 0.0

func save_now() -> bool:
	if development_mode:
		return false
	if not _configured:
		save_failed.emit("SAVE NÃO CONFIGURADO")
		return false
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		save_failed.emit("NÃO FOI POSSÍVEL ABRIR O SAVE")
		return false
	var payload := _build_payload()
	file.store_string(JSON.stringify(payload))
	file.close()
	_dirty = false
	_autosave_elapsed = 0.0
	save_written.emit(save_path)
	return true

func load_now() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		save_failed.emit("SAVE NÃO PÔDE SER LIDO")
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		save_failed.emit("FORMATO DE SAVE INVÁLIDO")
		return false
	_loading = true
	var data: Dictionary = parsed
	var identity_data: Variant = data.get("identity", {})
	if (typeof(identity_data) != TYPE_DICTIONARY or (identity_data as Dictionary).is_empty()) and data.has("identity_seed"):
		identity_data = {
			"identity_seed": int(data.get("identity_seed", 0)),
			"access_code": String(data.get("access_code", "")),
			"name": String(data.get("name", "")),
			"faction": String(data.get("faction", "neutro")),
			"lineage": String(data.get("lineage", "")),
		}
	_restore_identity(identity_data)
	_restore_skills(data.get("skills", {}))
	_restore_stats(data.get("stats", {}))
	_restore_evolution(data.get("evolution", {}))
	_restore_randomizer(data.get("appearance", {}))
	_restore_world(data.get("world", {}))
	_loading = false
	_dirty = false
	_autosave_elapsed = 0.0
	save_loaded.emit()
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	_dirty = false

func _connect_state_signals() -> void:
	if pet_stats != null:
		if not pet_stats.stats_changed.is_connected(_on_stats_signal):
			pet_stats.stats_changed.connect(_on_stats_signal)
		if not pet_stats.action_performed.is_connected(_on_action_signal):
			pet_stats.action_performed.connect(_on_action_signal)
		if not pet_stats.sleep_state_changed.is_connected(_on_sleep_signal):
			pet_stats.sleep_state_changed.connect(_on_sleep_signal)
	if pet_skills != null:
		if not pet_skills.progression_changed.is_connected(_on_progression_signal):
			pet_skills.progression_changed.connect(_on_progression_signal)
		if not pet_skills.skills_changed.is_connected(_on_skills_signal):
			pet_skills.skills_changed.connect(_on_skills_signal)
	if pet_identity != null and not pet_identity.identity_generated.is_connected(_on_identity_signal):
		pet_identity.identity_generated.connect(_on_identity_signal)
	if pet_evolution != null and not pet_evolution.evolution_changed.is_connected(_on_evolution_signal):
		pet_evolution.evolution_changed.connect(_on_evolution_signal)
	if pet_randomizer != null and not pet_randomizer.palette_changed.is_connected(_on_palette_signal):
		pet_randomizer.palette_changed.connect(_on_palette_signal)
	if quarto_cosmico != null:
		if not quarto_cosmico.points_changed.is_connected(_on_points_signal):
			quarto_cosmico.points_changed.connect(_on_points_signal)
		if not quarto_cosmico.purchase_completed.is_connected(_on_purchase_completed_signal):
			quarto_cosmico.purchase_completed.connect(_on_purchase_completed_signal)
	if batalha_exploracao != null:
		if not batalha_exploracao.points_changed.is_connected(_on_points_signal):
			batalha_exploracao.points_changed.connect(_on_points_signal)
		if not batalha_exploracao.battle_completed.is_connected(_on_battle_completed_signal):
			batalha_exploracao.battle_completed.connect(_on_battle_completed_signal)
	if eva_journey != null:
		if not eva_journey.eva_stage_changed.is_connected(_on_eva_state_signal):
			eva_journey.eva_stage_changed.connect(_on_eva_state_signal)
		if not eva_journey.memory_unlocked.is_connected(_on_eva_memory_signal):
			eva_journey.memory_unlocked.connect(_on_eva_memory_signal)
		if not eva_journey.journey_choice_made.is_connected(_on_eva_choice_signal):
			eva_journey.journey_choice_made.connect(_on_eva_choice_signal)
		if not eva_journey.affection_changed.is_connected(_on_eva_affection_signal):
			eva_journey.affection_changed.connect(_on_eva_affection_signal)

func _on_stats_signal(_hunger: float, _energy: float, _mood: float, _health: float) -> void:
	mark_dirty()

func _on_action_signal(action: StringName) -> void:
	match action:
		&"fruta_estelar", &"nectar_cosmico", &"banquete_nebulosa":
			record_diary("PRIMEIRA_REFEICAO")
			unlock_achievement("CUIDADOR_ESTELAR")
			stellar_coins += 1
		&"jokenpo", &"jogo_da_velha", &"2048":
			record_diary("PRIMEIRO_MINIJOGO")
			unlock_achievement("JOGADOR_COSMICO")
			stellar_coins += 2
		&"treinar":
			record_diary("PRIMEIRO_TREINO")
			unlock_achievement("DISCIPLINA_COSMICA")
		&"batalhar":
			record_diary("PRIMEIRA_BATALHA")
	mark_dirty()

func _on_sleep_signal(_sleeping: bool) -> void:
	mark_dirty()

func _on_progression_signal(_level: int, _xp: int) -> void:
	mark_dirty()

func _on_skills_signal(_skills: Array[StringName]) -> void:
	mark_dirty()

func _on_identity_signal(_snapshot: Dictionary) -> void:
	mark_dirty()

func _on_evolution_signal(_stage: int, _stage_name: StringName, _visual_scale: float) -> void:
	mark_dirty()

func _on_palette_signal(_pair_index: int, _palette_name: StringName, _base_color: Color, _complementary_color: Color) -> void:
	mark_dirty()

func _on_points_signal(_total_points: int) -> void:
	mark_dirty()

func _on_battle_completed_signal(victory: bool, _xp_reward: int, _point_reward: int, _log_text: String) -> void:
	if victory:
		stellar_coins += 5
		record_diary("BATALHA_VENCIDA")
		unlock_achievement("EXPLORADOR_DEEPWORLD")
	mark_dirty()

func _on_eva_state_signal(_stage: StringName) -> void:
	mark_dirty()

func _on_eva_memory_signal(_fragment_id: int, _text: String) -> void:
	mark_dirty()

func _on_eva_choice_signal(_helped: bool) -> void:
	mark_dirty()

func _on_eva_affection_signal(_value: int) -> void:
	mark_dirty()

func _on_purchase_completed_signal(item_id: StringName, _price: int, _remaining_points: int, _accumulated_value: int) -> void:
	record_diary("COMPRA_" + String(item_id).to_upper())
	unlock_achievement("PRIMEIRA_COMPRA")
	mark_dirty()

func record_diary(entry: String) -> void:
	if entry.is_empty() or cosmic_diary.has(entry):
		return
	cosmic_diary.append(entry)
	mark_dirty()

func unlock_achievement(achievement_id: String) -> void:
	if achievement_id.is_empty() or bool(achievements.get(achievement_id, false)):
		return
	achievements[achievement_id] = true
	mark_dirty()

func add_stellar_coins(amount: int) -> void:
	if amount <= 0:
		return
	stellar_coins += amount
	mark_dirty()

func _build_payload() -> Dictionary:
	var points: int = 0
	var shop_total_value: int = 0
	if quarto_cosmico != null:
		points = quarto_cosmico.exploration_points
		shop_total_value = quarto_cosmico.shop_total_value
	elif batalha_exploracao != null:
		points = batalha_exploracao.get_exploration_points()
	return {
		"version": 3,
		"saved_at": Time.get_unix_time_from_system(),
		"identity": _serialize_identity(),
		"stats": _serialize_stats(),
		"skills": _serialize_skills(),
		"evolution": _serialize_evolution(),
		"appearance": _serialize_appearance(),
		"world": {
				"exploration_points": points,
	"exploration_battles_completed": exploration_battles_completed,
					"eva_encounter_battle_counter": eva_encounter_battle_counter,
					"eva_encounter_available": eva_encounter_available,
				"eva_encounter_seen": eva_encounter_seen,
				"eva_adventure_unlocked": eva_adventure_unlocked,
				"eva_progress_stage_index": eva_progress_stage_index,
				"exploration_islands_unlocked": _serialize_island_unlocks(),
				"eva_journey": eva_journey.to_save_data() if eva_journey != null else {},
			"shop_total_value": shop_total_value,
			"owned_items": _serialize_owned_items(),
			"stellar_coins": stellar_coins,
			"cosmic_diary": cosmic_diary.duplicate(),
			"achievements": achievements.duplicate(true),
		},
	}

func _serialize_island_unlocks() -> Array[String]:
	var islands: Array[String] = []
	for area_id in exploration_islands_unlocked:
		islands.append(String(area_id))
	return islands

func _serialize_owned_items() -> Array[String]:
	var items: Array[String] = []
	if quarto_cosmico != null:
		for item_id in quarto_cosmico.get_owned_items():
			items.append(String(item_id))
	return items

func _serialize_identity() -> Dictionary:
	if pet_identity == null:
		return {}
	var trait_values: Array[String] = []
	for trait_value in pet_identity.traits:
		trait_values.append(String(trait_value))
	var palette_values: Array[String] = []
	for palette_name in pet_identity.preferred_palette_names:
		palette_values.append(String(palette_name))
	return {
		"identity_seed": pet_identity.identity_seed,
		"access_code": pet_identity.get_access_code(),
		"name": pet_identity.pet_name,
		"gender": String(pet_identity.gender),
		"faction": String(pet_identity.faction_id),
		"faction_label": pet_identity.faction_label,
		"lineage": String(pet_identity.lineage_id),
		"lineage_label": pet_identity.lineage_label,
		"element": String(pet_identity.element),
		"traits": trait_values,
		"attribute_bias": pet_identity.attribute_bias.duplicate(true),
		"preferred_palette_names": palette_values,
		"part_weights": pet_identity.part_weights.duplicate(true),
	}

func _serialize_stats() -> Dictionary:
	if pet_stats == null:
		return {}
	return {
		"hunger": pet_stats.hunger,
		"energy": pet_stats.energy,
		"mood": pet_stats.mood,
		"health": pet_stats.health,
		"hygiene": pet_stats.hygiene,
		"discipline": pet_stats.discipline,
		"obedience": pet_stats.obedience,
		"audacity": pet_stats.audacity,
		"weight": pet_stats.weight,
		"is_sick": pet_stats.is_sick,
		"is_sleeping": pet_stats.is_sleeping,
		"attention_reason": String(pet_stats.attention_reason),
		"special_need": String(pet_stats.special_need),
		"special_need_wish": String(pet_stats.special_need_wish),
		"poop_visible": pet_stats.poop_visible,
		"newborn_tutorial_active": pet_stats.newborn_tutorial_active,
		"newborn_tutorial_step": String(pet_stats.newborn_tutorial_step),
		"newborn_tutorial_fed": pet_stats.newborn_tutorial_fed,
		"current_reaction": String(pet_stats.current_reaction),
		"missed_calls": pet_stats.missed_calls,
		"care_mistakes": pet_stats.care_mistakes,
		"discipline_mistakes": pet_stats.discipline_mistakes,
		"excessive_meals": pet_stats.excessive_meals,
		"meals_served": pet_stats.meals_served,
		"games_played": pet_stats.games_played,
	}

func _serialize_skills() -> Dictionary:
	if pet_skills == null:
		return {}
	var unlocked: Array[String] = []
	for skill_id in pet_skills.unlocked_skills:
		unlocked.append(String(skill_id))
	return {
		"level": pet_skills.level,
		"xp": pet_skills.xp,
		"total_xp": pet_skills.total_xp,
		"strength": pet_skills.strength,
		"defense": pet_skills.defense,
		"agility": pet_skills.agility,
		"intelligence": pet_skills.intelligence,
		"resistance": pet_skills.resistance,
		"unlocked_skills": unlocked,
	}

func _serialize_evolution() -> Dictionary:
	if pet_evolution == null:
		return {}
	return {
		"stage": pet_evolution.stage,
		"stage_name": String(pet_evolution.stage_name),
		"visual_scale": pet_evolution.visual_scale,
	}

func _serialize_appearance() -> Dictionary:
	if pet_randomizer == null:
		return {}
	return {
		"eyes_variant": pet_randomizer.eyes_variant,
		"ears_variant": pet_randomizer.ears_variant,
		"wings_variant": pet_randomizer.wings_variant,
		"tail_variant": pet_randomizer.tail_variant,
		"palette_pair_index": pet_randomizer.palette_pair_index,
		"palette_name": String(pet_randomizer.palette_name),
	}

func _restore_identity(raw_data: Variant) -> void:
	if pet_identity == null or typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	pet_identity.identity_seed = int(data.get("identity_seed", pet_identity.identity_seed))
	pet_identity.faction_id = StringName(String(data.get("faction", pet_identity.faction_id)))
	pet_identity.faction_label = String(data.get("faction_label", pet_identity.faction_label))
	pet_identity.lineage_id = StringName(String(data.get("lineage", pet_identity.lineage_id)))
	pet_identity.lineage_label = String(data.get("lineage_label", pet_identity.lineage_label))
	pet_identity.element = StringName(String(data.get("element", pet_identity.element)))
	pet_identity.gender = StringName(String(data.get("gender", pet_identity.gender)))
	pet_identity.pet_name = String(data.get("name", pet_identity.pet_name))
	pet_identity.traits.clear()
	for trait_value in data.get("traits", []):
		pet_identity.traits.append(StringName(String(trait_value)))
	pet_identity.attribute_bias = data.get("attribute_bias", {}).duplicate(true)
	pet_identity.preferred_palette_names.clear()
	for palette_name in data.get("preferred_palette_names", []):
		pet_identity.preferred_palette_names.append(StringName(String(palette_name)))
	pet_identity.part_weights = data.get("part_weights", {}).duplicate(true)
	pet_identity.identity_generated.emit(pet_identity.get_identity_snapshot())

func _restore_stats(raw_data: Variant) -> void:
	if pet_stats == null or typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	pet_stats.hunger = float(data.get("hunger", pet_stats.hunger))
	pet_stats.energy = float(data.get("energy", pet_stats.energy))
	pet_stats.mood = float(data.get("mood", pet_stats.mood))
	pet_stats.health = float(data.get("health", pet_stats.health))
	pet_stats.hygiene = float(data.get("hygiene", pet_stats.hygiene))
	pet_stats.discipline = float(data.get("discipline", pet_stats.discipline))
	pet_stats.obedience = float(data.get("obedience", pet_stats.obedience))
	pet_stats.audacity = float(data.get("audacity", pet_stats.audacity))
	pet_stats.weight = float(data.get("weight", pet_stats.weight))
	pet_stats.is_sick = bool(data.get("is_sick", pet_stats.is_sick))
	pet_stats.is_sleeping = bool(data.get("is_sleeping", pet_stats.is_sleeping))
	pet_stats.attention_reason = StringName(String(data.get("attention_reason", pet_stats.attention_reason)))
	pet_stats.special_need = StringName(String(data.get("special_need", pet_stats.special_need)))
	pet_stats.special_need_wish = StringName(String(data.get("special_need_wish", pet_stats.special_need_wish)))
	pet_stats.poop_visible = bool(data.get("poop_visible", pet_stats.poop_visible))
	pet_stats.newborn_tutorial_active = bool(data.get("newborn_tutorial_active", pet_stats.newborn_tutorial_active))
	pet_stats.newborn_tutorial_step = StringName(String(data.get("newborn_tutorial_step", pet_stats.newborn_tutorial_step)))
	pet_stats.newborn_tutorial_fed = bool(data.get("newborn_tutorial_fed", pet_stats.newborn_tutorial_fed))
	pet_stats.current_reaction = StringName(String(data.get("current_reaction", pet_stats.current_reaction)))
	pet_stats.missed_calls = int(data.get("missed_calls", pet_stats.missed_calls))
	pet_stats.care_mistakes = int(data.get("care_mistakes", pet_stats.care_mistakes))
	pet_stats.discipline_mistakes = int(data.get("discipline_mistakes", pet_stats.discipline_mistakes))
	pet_stats.excessive_meals = int(data.get("excessive_meals", pet_stats.excessive_meals))
	pet_stats.meals_served = int(data.get("meals_served", pet_stats.meals_served))
	pet_stats.games_played = int(data.get("games_played", pet_stats.games_played))
	pet_stats._clamp_values()
	pet_stats._emit_all_state()
	pet_stats._emit_critical_state_if_changed()
	pet_stats.sleep_state_changed.emit(pet_stats.is_sleeping)
	pet_stats.illness_changed.emit(pet_stats.is_sick)
	pet_stats.poop_state_changed.emit(pet_stats.poop_visible)

func _restore_skills(raw_data: Variant) -> void:
	if pet_skills == null or typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	pet_skills.level = int(data.get("level", pet_skills.level))
	pet_skills.xp = int(data.get("xp", pet_skills.xp))
	pet_skills.total_xp = int(data.get("total_xp", pet_skills.total_xp))
	pet_skills.strength = int(data.get("strength", pet_skills.strength))
	pet_skills.defense = int(data.get("defense", pet_skills.defense))
	pet_skills.agility = int(data.get("agility", pet_skills.agility))
	pet_skills.intelligence = int(data.get("intelligence", pet_skills.intelligence))
	pet_skills.resistance = int(data.get("resistance", pet_skills.resistance))
	pet_skills.unlocked_skills.clear()
	for skill_id in data.get("unlocked_skills", []):
		pet_skills.unlocked_skills.append(StringName(String(skill_id)))
	if pet_skills.unlocked_skills.is_empty():
		pet_skills.unlocked_skills.append(&"golpe_fraco")
	pet_skills.progression_changed.emit(pet_skills.level, pet_skills.xp)
	pet_skills.skills_changed.emit(pet_skills.unlocked_skills.duplicate())
	pet_skills.skill_tree_changed.emit(pet_skills.get_all_skills(), pet_skills.unlocked_skills.duplicate())

func _restore_evolution(raw_data: Variant) -> void:
	if pet_evolution == null or typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	pet_evolution.stage = clampi(int(data.get("stage", pet_evolution.stage)), 0, 6)
	pet_evolution.stage_name = StringName(String(data.get("stage_name", pet_evolution.stage_name)))
	pet_evolution.visual_scale = float(data.get("visual_scale", pet_evolution.visual_scale))
	var growth_root := pet_evolution.get_node_or_null(pet_evolution.growth_root_path) as Node2D
	if growth_root != null:
		growth_root.scale = Vector2.ONE * pet_evolution.visual_scale
	pet_evolution.evolution_changed.emit(pet_evolution.stage, pet_evolution.stage_name, pet_evolution.visual_scale)

func _restore_randomizer(raw_data: Variant) -> void:
	if pet_randomizer == null or typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	pet_randomizer.set_part_variant(&"eyes", int(data.get("eyes_variant", pet_randomizer.eyes_variant)))
	pet_randomizer.set_part_variant(&"ears", int(data.get("ears_variant", pet_randomizer.ears_variant)))
	pet_randomizer.set_part_variant(&"wings", int(data.get("wings_variant", pet_randomizer.wings_variant)))
	pet_randomizer.set_part_variant(&"tail", int(data.get("tail_variant", pet_randomizer.tail_variant)))
	var palette_index := int(data.get("palette_pair_index", pet_randomizer.palette_pair_index))
	if palette_index >= 0:
		pet_randomizer.apply_palette_index(palette_index)

func _restore_world(raw_data: Variant) -> void:
	if typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	exploration_battles_completed = maxi(0, int(data.get("exploration_battles_completed", exploration_battles_completed)))
	eva_encounter_battle_counter = clampi(int(data.get("eva_encounter_battle_counter", exploration_battles_completed % 3)), 0, 2)
	eva_encounter_available = bool(data.get("eva_encounter_available", exploration_battles_completed >= 3 and not eva_encounter_seen))
	eva_encounter_seen = bool(data.get("eva_encounter_seen", false))
	eva_adventure_unlocked = bool(data.get("eva_adventure_unlocked", false))
	eva_progress_stage_index = clampi(int(data.get("eva_progress_stage_index", eva_progress_stage_index)), 1, 21)
	exploration_islands_unlocked.clear()
	for area_id in data.get("exploration_islands_unlocked", ["data_city"]):
		exploration_islands_unlocked.append(StringName(String(area_id)))
	if exploration_islands_unlocked.is_empty():
		exploration_islands_unlocked.append(&"data_city")
	var points := maxi(0, int(data.get("exploration_points", 0)))
	if batalha_exploracao != null:
		batalha_exploracao.exploration_points = points
		batalha_exploracao.points_changed.emit(points)
	if quarto_cosmico != null:
		quarto_cosmico.shop_total_value = maxi(0, int(data.get("shop_total_value", 0)))
		quarto_cosmico.set_owned_items(data.get("owned_items", []))
		quarto_cosmico.set_exploration_points(points)
	if eva_journey != null:
		eva_journey.restore_save_data(data.get("eva_journey", {}))
	stellar_coins = maxi(0, int(data.get("stellar_coins", stellar_coins)))
	cosmic_diary.clear()
	for entry in data.get("cosmic_diary", []):
		cosmic_diary.append(String(entry))
	achievements = data.get("achievements", {}).duplicate(true)
