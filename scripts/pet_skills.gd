extends Node
class_name PetSkills

## Árvore de habilidades e progressão do AuroraPet.
## O XP atual é o progresso dentro do nível; total_xp registra o histórico acumulado.

signal skills_changed(unlocked_skills: Array[StringName])
signal skill_tree_changed(all_skills: Array[StringName], unlocked_skills: Array[StringName])
signal skill_unlocked(skill_id: StringName)
signal progression_changed(level: int, xp: int)
signal level_up(new_level: int)

@export_category("Progressão")
@export_range(1, 100, 1) var level := 1
@export_range(0, 999999, 1) var xp := 0
@export_range(0, 999999, 1) var total_xp := 0

@export_category("Atributos de treino")
@export_range(0, 100, 1) var strength := 10
@export_range(0, 100, 1) var defense := 10
@export_range(0, 100, 1) var agility := 10
@export_range(0, 100, 1) var intelligence := 10
@export_range(0, 100, 1) var resistance := 10

@export_category("Habilidades desbloqueadas")
@export var unlocked_skills: Array[StringName] = [&"golpe_fraco"]

const CATEGORY_UNLOCK_LEVELS: Dictionary = {
	&"comer": 1,
	&"cuidar": 1,
	&"jogar": 2,
	&"treinar": 4,
	&"batalhar": 6,
}

const ACTION_UNLOCK_LEVELS: Dictionary = {
	&"fruta_estelar": 1,
	&"limpar_sujeira": 1,
	&"nectar_cosmico": 2,
	&"banquete_nebulosa": 3,
	&"dar_remedio": 2,
	&"dormir": 1,
	&"banho": 99,
	&"jokenpo": 3,
	&"jogo_da_velha": 2,
	&"2048": 5,
	&"batalha_exploracao": 6,
}

const SKILLS: Dictionary = {
	&"golpe_fraco": {
		"name": "Golpe Fraco",
		"description": "Ataque básico de baixo custo.",
		"slot": "ataque",
		"cost": 10,
		"en_cost": 10,
		"power": 14,
		"accuracy": 0.90,
		"level": 1,
		"xp": 0,
		"attribute": &"forca",
		"attribute_value": 0,
		"requires": &"",
	},
	&"golpe_forte": {
		"name": "Golpe Forte",
		"description": "Ataque poderoso que consome mais energia.",
		"slot": "ataque",
		"cost": 25,
		"en_cost": 25,
		"power": 26,
		"accuracy": 0.78,
		"level": 2,
		"xp": 100,
		"attribute": &"forca",
		"attribute_value": 12,
		"requires": &"",
	},
	&"golpe_status": {
		"name": "Golpe de Status",
		"description": "Aplica um efeito tático no adversário.",
		"slot": "status",
		"cost": 15,
		"en_cost": 15,
		"power": 12,
		"accuracy": 0.86,
		"level": 2,
		"xp": 100,
		"attribute": &"inteligencia",
		"attribute_value": 12,
		"requires": &"",
	},
	&"defesa": {
		"name": "Defesa",
		"description": "Reduz dano recebido e recupera controle do combate.",
		"slot": "defesa",
		"cost": 20,
		"en_cost": 5,
		"power": 0,
		"accuracy": 1.0,
		"level": 2,
		"xp": 100,
		"attribute": &"defesa",
		"attribute_value": 12,
		"requires": &"",
	},
	&"golpe_fraco_avancado": {
		"name": "Golpe Fraco Avançado",
		"description": "Versão aprimorada do ataque básico.",
		"slot": "ataque",
		"cost": 8,
		"en_cost": 8,
		"power": 18,
		"accuracy": 0.94,
		"level": 3,
		"xp": 300,
		"attribute": &"agilidade",
		"attribute_value": 15,
		"requires": &"golpe_fraco",
	},
	&"golpe_forte_avancado": {
		"name": "Golpe Forte Avançado",
		"description": "Ataque de alto impacto desbloqueado pela evolução.",
		"slot": "ataque",
		"cost": 30,
		"en_cost": 30,
		"power": 32,
		"accuracy": 0.72,
		"level": 4,
		"xp": 600,
		"attribute": &"forca",
		"attribute_value": 20,
		"requires": &"golpe_forte",
	},
	&"status_avancado": {
		"name": "Status Avançado",
		"description": "Efeito tático com maior duração e precisão.",
		"slot": "status",
		"cost": 18,
		"en_cost": 18,
		"power": 16,
		"accuracy": 0.90,
		"level": 4,
		"xp": 600,
		"attribute": &"inteligencia",
		"attribute_value": 20,
		"requires": &"golpe_status",
	},
	&"defesa_avancada": {
		"name": "Defesa Avançada",
		"description": "Postura defensiva com recuperação ampliada.",
		"slot": "defesa",
		"cost": 22,
		"en_cost": 8,
		"power": 0,
		"accuracy": 1.0,
		"level": 4,
		"xp": 600,
		"attribute": &"defesa",
		"attribute_value": 20,
		"requires": &"defesa",
	},
}

@onready var evolution: PetEvolution = get_parent().get_node_or_null(^"PetEvolution") as PetEvolution

func _ready() -> void:
	_normalize_unlocked_skills()
	_try_unlock_available_skills()
	_emit_skill_state()
	progression_changed.emit(level, xp)
	if evolution != null:
		evolution.sync_with_level(level)

func is_category_unlocked(category: StringName) -> bool:
	return level >= int(CATEGORY_UNLOCK_LEVELS.get(category, 1))

func is_action_unlocked(action: StringName) -> bool:
	return level >= int(ACTION_UNLOCK_LEVELS.get(action, CATEGORY_UNLOCK_LEVELS.get(action, 1)))

func get_unlock_level(action: StringName) -> int:
	if ACTION_UNLOCK_LEVELS.has(action):
		return int(ACTION_UNLOCK_LEVELS[action])
	return int(CATEGORY_UNLOCK_LEVELS.get(action, 1))

func get_unlock_message(action: StringName) -> String:
	if is_action_unlocked(action):
		return "CONTEÚDO DISPONÍVEL"
	return "DESBLOQUEIA NO NÍVEL %d" % get_unlock_level(action)

func get_skill(skill_id: StringName) -> Dictionary:
	return SKILLS.get(skill_id, {}).duplicate(true)

func get_all_skills() -> Array[StringName]:
	var ids: Array[StringName] = []
	for skill_id in SKILLS.keys():
		ids.append(skill_id)
	return ids

func is_unlocked(skill_id: StringName) -> bool:
	return unlocked_skills.has(skill_id)

func can_unlock(skill_id: StringName) -> bool:
	if is_unlocked(skill_id) or not SKILLS.has(skill_id):
		return false
	var skill: Dictionary = SKILLS[skill_id]
	var required_skill: StringName = skill["requires"]
	if not required_skill.is_empty() and not is_unlocked(required_skill):
		return false
	if level < int(skill["level"]) or total_xp < int(skill["xp"]):
		return false
	return get_attribute(StringName(skill["attribute"])) >= int(skill["attribute_value"])

func unlock_skill(skill_id: StringName) -> bool:
	if not can_unlock(skill_id):
		return false
	unlocked_skills.append(skill_id)
	_emit_skill_state()
	skill_unlocked.emit(skill_id)
	return true

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	total_xp += amount
	xp += amount
	var leveled_up := false
	while level < 100 and xp >= xp_required_for_next_level():
		xp -= xp_required_for_next_level()
		level += 1
		leveled_up = true
		level_up.emit(level)
		if evolution != null:
			evolution.sync_with_level(level)
		_try_unlock_available_skills()
	_try_unlock_available_skills()
	progression_changed.emit(level, xp)
	if leveled_up:
		_emit_skill_state()

func xp_required_for_next_level() -> int:
	return level * 100

func get_progress_ratio() -> float:
	return clampf(float(xp) / float(xp_required_for_next_level()), 0.0, 1.0)

func train_attribute(attribute: StringName, amount: int = 1) -> void:
	match attribute:
		&"forca": strength = clampi(strength + amount, 0, 100)
		&"defesa": defense = clampi(defense + amount, 0, 100)
		&"agilidade": agility = clampi(agility + amount, 0, 100)
		&"inteligencia": intelligence = clampi(intelligence + amount, 0, 100)
		&"resistencia": resistance = clampi(resistance + amount, 0, 100)
		_:
			push_warning("Atributo de treino desconhecido: %s" % attribute)
			return
	_try_unlock_available_skills()

func apply_identity_bias(bias: Dictionary) -> void:
	if bias.is_empty():
		return
	strength = clampi(strength + int(bias.get("forca", 0)), 0, 100)
	defense = clampi(defense + int(bias.get("defesa", 0)), 0, 100)
	agility = clampi(agility + int(bias.get("agilidade", 0)), 0, 100)
	intelligence = clampi(intelligence + int(bias.get("inteligencia", 0)), 0, 100)
	resistance = clampi(resistance + int(bias.get("resistencia", 0)), 0, 100)
	_try_unlock_available_skills()

## Reinicia a progressão para o nascimento de um novo pet.
## A identidade escolhida aplica o bônus de linhagem depois deste reset.
func reset_for_new_pet() -> void:
	level = 1
	xp = 0
	total_xp = 0
	strength = 10
	defense = 10
	agility = 10
	intelligence = 10
	resistance = 10
	unlocked_skills = [&"golpe_fraco"]
	_emit_skill_state()
	progression_changed.emit(level, xp)

func get_attribute(attribute: StringName) -> int:
	match attribute:
		&"forca": return strength
		&"defesa": return defense
		&"agilidade": return agility
		&"inteligencia": return intelligence
		&"resistencia": return resistance
	return 0

func _try_unlock_available_skills() -> void:
	for skill_id in SKILLS.keys():
		unlock_skill(skill_id)

func _emit_skill_state() -> void:
	skills_changed.emit(unlocked_skills.duplicate())
	skill_tree_changed.emit(get_all_skills(), unlocked_skills.duplicate())

func _normalize_unlocked_skills() -> void:
	var valid_skills: Array[StringName] = []
	for skill_id in unlocked_skills:
		if SKILLS.has(skill_id) and not valid_skills.has(skill_id):
			valid_skills.append(skill_id)
	if valid_skills.is_empty():
		valid_skills.append(&"golpe_fraco")
	unlocked_skills = valid_skills
