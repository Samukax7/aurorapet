extends Node
class_name PetSkills

## Árvore de habilidades inicial do AuroraPet.
## A estrutura é local e independente do visual do pet, pronta para futura UI e combate.

signal skills_changed(unlocked_skills: Array[StringName])
signal skill_unlocked(skill_id: StringName)
signal progression_changed(level: int, xp: int)

@export_category("Progressão")
@export_range(1, 100, 1) var level := 1
@export_range(0, 999999, 1) var xp := 0

@export_category("Atributos de treino")
@export_range(0, 100, 1) var strength := 10
@export_range(0, 100, 1) var defense := 10
@export_range(0, 100, 1) var agility := 10
@export_range(0, 100, 1) var intelligence := 10

@export_category("Habilidades desbloqueadas")
@export var unlocked_skills: Array[StringName] = [&"golpe_fraco"]

const SKILLS: Dictionary = {
	&"golpe_fraco": {
		"name": "Golpe Fraco",
		"description": "Ataque básico de baixo custo.",
		"slot": "ataque",
		"cost": 10,
		"level": 1,
		"xp": 0,
		"attribute": &"forca",
		"attribute_value": 0,
	},
	&"golpe_forte": {
		"name": "Golpe Forte",
		"description": "Ataque poderoso que consome mais energia.",
		"slot": "ataque",
		"cost": 25,
		"level": 2,
		"xp": 100,
		"attribute": &"forca",
		"attribute_value": 12,
	},
	&"golpe_status": {
		"name": "Golpe de Status",
		"description": "Aplica um efeito tático no adversário.",
		"slot": "status",
		"cost": 15,
		"level": 2,
		"xp": 100,
		"attribute": &"inteligencia",
		"attribute_value": 12,
	},
	&"defesa": {
		"name": "Defesa",
		"description": "Reduz dano recebido e recupera controle do combate.",
		"slot": "defesa",
		"cost": 20,
		"level": 2,
		"xp": 100,
		"attribute": &"defesa",
		"attribute_value": 12,
	},
}

func _ready() -> void:
	_normalize_unlocked_skills()
	skills_changed.emit(unlocked_skills.duplicate())
	progression_changed.emit(level, xp)

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
	if level < int(skill["level"]) or xp < int(skill["xp"]):
		return false
	return get_attribute(StringName(skill["attribute"])) >= int(skill["attribute_value"])

func unlock_skill(skill_id: StringName) -> bool:
	if not can_unlock(skill_id):
		return false
	unlocked_skills.append(skill_id)
	skills_changed.emit(unlocked_skills.duplicate())
	skill_unlocked.emit(skill_id)
	return true

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount
	while level < 100 and xp >= xp_required_for_next_level():
		xp -= xp_required_for_next_level()
		level += 1
		_try_unlock_available_skills()
	progression_changed.emit(level, xp)

func xp_required_for_next_level() -> int:
	return level * 100

func train_attribute(attribute: StringName, amount: int = 1) -> void:
	match attribute:
		&"forca": strength = clampi(strength + amount, 0, 100)
		&"defesa": defense = clampi(defense + amount, 0, 100)
		&"agilidade": agility = clampi(agility + amount, 0, 100)
		&"inteligencia": intelligence = clampi(intelligence + amount, 0, 100)
		_:
			push_warning("Atributo de treino desconhecido: %s" % attribute)
			return
	_try_unlock_available_skills()

func get_attribute(attribute: StringName) -> int:
	match attribute:
		&"forca": return strength
		&"defesa": return defense
		&"agilidade": return agility
		&"inteligencia": return intelligence
	return 0

func _try_unlock_available_skills() -> void:
	for skill_id in SKILLS.keys():
		unlock_skill(skill_id)

func _normalize_unlocked_skills() -> void:
	var valid_skills: Array[StringName] = []
	for skill_id in unlocked_skills:
		if SKILLS.has(skill_id) and not valid_skills.has(skill_id):
			valid_skills.append(skill_id)
	if valid_skills.is_empty():
		valid_skills.append(&"golpe_fraco")
	unlocked_skills = valid_skills
