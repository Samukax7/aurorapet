extends Node
class_name EvaJourneyManager

## Gerencia a campanha narrativa da EVA separadamente do pet procedural e do modo DEV.
## A progressão é baseada em escolhas e memórias, não no nível do pet do jogador.

signal eva_stage_changed(new_stage: StringName)
signal memory_unlocked(fragment_id: int, text: String)
signal journey_choice_made(helped: bool)
signal affection_changed(value: int)
signal chapter_changed(chapter: int, title: String)

const SAVE_KEY := "eva_journey"
const MAX_AFFECTION := 100
const MAX_CHAPTER := 6

enum EvaStage {
	BEBE,
	CRIANCA,
	ADOLESCENTE,
	JOVEM_ADULTA,
	ANCIA,
	LENDARIA,
	DEUSA_RAPOSA,
}

const MEMORIES: Dictionary = {
	1: "Eu me lembro... Havia luz. Tanta luz que parecia cantar. Mas então, a luz se cansou. As estrelas fecharam os olhos uma a uma.",
	2: "Eu não era apenas poeira. Alguém guardou todos os pensamentos daquele mundo dentro de mim. Eu sou o arquivo de tudo o que existiu.",
	3: "Eu entendo agora a equação das coisas. O amor, a dor e o tempo não são falhas no sistema.",
	4: "A força de uma estrela moribunda não serve para destruir. Serve para dar luz aos novos mundos.",
	5: "Nada se perde. Cada passo, batalha e carinho gravou um novo código da existência.",
	6: "Agora eu sou a luz que guiará este novo universo. Obrigada por me ensinar o que é ter um coração.",
}

const CHAPTERS: Dictionary = {
	1: {"title": "O Silêncio dos Ecos", "region": "Ruínas Digitais", "boss": "Gorgon_Glitch"},
	2: {"title": "O Espelho Fragmentado", "region": "Floresta Cristalina", "boss": "Prisma_Guard"},
	3: {"title": "Os Algoritmos Esquecidos", "region": "Abismo Elétrico", "boss": "Core_Overlord"},
	4: {"title": "A Forja da Supernova", "region": "Mar de Plasma Estelar", "boss": "Ignis_Vectis"},
	5: {"title": "O Abismo da Memória", "region": "Vazio Primordial", "boss": "Arquiteto do Esquecimento"},
	6: {"title": "O Retorno à Origem", "region": "Origem da Criação", "boss": "O Eco Absoluto"},
}

var current_stage := EvaStage.BEBE
var affection_level := 0
var current_chapter := 0
var helped_eva := false
var journey_started := false
var journey_completed := false
var unlocked_fragments: Array[int] = []
var choice_recorded := false

func choose_help_eva(choice: bool) -> void:
	choice_recorded = true
	helped_eva = choice
	journey_started = choice
	if choice:
		current_chapter = maxi(current_chapter, 1)
		_add_affection(10)
		chapter_changed.emit(current_chapter, get_current_chapter_title())
	else:
		current_chapter = 0
	journey_choice_made.emit(choice)

func start_journey() -> bool:
	if journey_completed:
		return false
	if not choice_recorded:
		choose_help_eva(true)
		return true
	if not helped_eva:
		return false
	journey_started = true
	if current_chapter == 0:
		current_chapter = 1
	chapter_changed.emit(current_chapter, get_current_chapter_title())
	return true

func record_care(amount: int = 1) -> void:
	if not journey_started:
		return
	_add_affection(amount)

func record_shared_activity(activity: StringName) -> void:
	if not journey_started:
		return
	match activity:
		&"battle", &"exploration":
			_add_affection(3)
		&"play", &"training":
			_add_affection(2)
		&"care", &"sleep":
			_add_affection(1)

func complete_current_chapter() -> bool:
	if not journey_started or current_chapter <= 0 or current_chapter > MAX_CHAPTER:
		return false
	if not unlocked_fragments.has(current_chapter):
		unlocked_fragments.append(current_chapter)
		var text := String(MEMORIES.get(current_chapter, ""))
		_evolve_eva()
		memory_unlocked.emit(current_chapter, text)
	if current_chapter >= MAX_CHAPTER:
		journey_completed = true
		return true
	current_chapter += 1
	chapter_changed.emit(current_chapter, get_current_chapter_title())
	return true

func unlock_next_memory() -> bool:
	if current_chapter <= 0:
		return false
	return complete_current_chapter()

func get_current_chapter_title() -> String:
	var chapter: Dictionary = CHAPTERS.get(current_chapter, {})
	return String(chapter.get("title", "Campanha bloqueada"))

func get_current_chapter_data() -> Dictionary:
	return (CHAPTERS.get(current_chapter, {}) as Dictionary).duplicate(true)

func get_eva_stage_name() -> StringName:
	return StringName(EvaStage.keys()[current_stage].to_lower())

func get_eva_skill_bonus() -> Dictionary:
	match current_stage:
		EvaStage.BEBE:
			return {"crit_bonus": 0.0, "defense_bonus": 0.0}
		EvaStage.CRIANCA:
			return {"crit_bonus": 0.05, "defense_bonus": 2.0}
		EvaStage.ADOLESCENTE:
			return {"crit_bonus": 0.10, "defense_bonus": 5.0}
		EvaStage.JOVEM_ADULTA:
			return {"crit_bonus": 0.15, "defense_bonus": 10.0, "can_fly": true}
		EvaStage.ANCIA:
			return {"crit_bonus": 0.20, "defense_bonus": 15.0, "xp_boost": 1.25}
		EvaStage.LENDARIA, EvaStage.DEUSA_RAPOSA:
			return {"crit_bonus": 0.30, "defense_bonus": 25.0, "xp_boost": 1.50, "auto_heal": true}
	return {}

func to_save_data() -> Dictionary:
	return {
		"current_stage": int(current_stage),
		"affection_level": affection_level,
		"current_chapter": current_chapter,
		"helped_eva": helped_eva,
		"journey_started": journey_started,
		"journey_completed": journey_completed,
		"choice_recorded": choice_recorded,
		"unlocked_fragments": unlocked_fragments.duplicate(),
	}

func restore_save_data(raw_data: Variant) -> void:
	if typeof(raw_data) != TYPE_DICTIONARY:
		return
	var data: Dictionary = raw_data
	current_stage = clampi(int(data.get("current_stage", current_stage)), EvaStage.BEBE, EvaStage.DEUSA_RAPOSA)
	affection_level = clampi(int(data.get("affection_level", affection_level)), 0, MAX_AFFECTION)
	current_chapter = clampi(int(data.get("current_chapter", current_chapter)), 0, MAX_CHAPTER)
	helped_eva = bool(data.get("helped_eva", helped_eva))
	journey_started = bool(data.get("journey_started", journey_started))
	journey_completed = bool(data.get("journey_completed", journey_completed))
	choice_recorded = bool(data.get("choice_recorded", choice_recorded))
	unlocked_fragments.clear()
	for fragment_id in data.get("unlocked_fragments", []):
		var valid_id := clampi(int(fragment_id), 1, 6)
		if not unlocked_fragments.has(valid_id):
			unlocked_fragments.append(valid_id)

func _add_affection(amount: int) -> void:
	var previous := affection_level
	affection_level = clampi(affection_level + amount, 0, MAX_AFFECTION)
	if affection_level != previous:
		affection_changed.emit(affection_level)

func _evolve_eva() -> void:
	var target_stage := clampi(unlocked_fragments.size(), 0, EvaStage.DEUSA_RAPOSA)
	if target_stage > current_stage:
		current_stage = target_stage
		eva_stage_changed.emit(get_eva_stage_name())
