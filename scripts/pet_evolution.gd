extends Node
class_name PetEvolution

## Controla os estágios de vida do Pet e aplica crescimento visual na cena pet.tscn.
## A evolução acontece por nível e pode ser consultada ou forçada durante a prototipagem.

signal evolution_started(previous_stage: int, new_stage: int)
signal evolution_completed(stage: int, stage_name: StringName, visual_scale: float)
signal evolution_changed(stage: int, stage_name: StringName, visual_scale: float)

@export_category("Estágio atual")
@export_range(0, 6, 1) var stage := 0
@export var stage_name: StringName = &"bebe"
@export_range(0.1, 3.0, 0.01) var visual_scale := 1.0

@export_category("Crescimento")
@export var apply_visual_growth := true
@export var growth_root_path: NodePath = NodePath("..")

@export_category("Variações visuais")
@export var apply_visual_variants := true
@export var apply_initial_stage_profile := false
@export var randomizer_path: NodePath = NodePath("..")

const STAGE_DATA: Dictionary = {
	0: {"name": &"bebe", "label": "Bebê", "level": 1, "scale": 1.00},
	1: {"name": &"crianca", "label": "Criança", "level": 10, "scale": 1.15},
	2: {"name": &"juvenil", "label": "Juvenil", "level": 20, "scale": 1.30},
	3: {"name": &"jovem", "label": "Jovem", "level": 30, "scale": 1.50},
	4: {"name": &"adulto", "label": "Adulto", "level": 50, "scale": 1.75},
	5: {"name": &"forma_maxima", "label": "Forma Máxima", "level": 75, "scale": 2.00},
	6: {"name": &"entidade_cosmica", "label": "Entidade Cósmica", "level": 100, "scale": 2.30},
}

func _ready() -> void:
	stage = clampi(stage, 0, STAGE_DATA.size() - 1)
	_apply_stage_data(stage, false)

func sync_with_level(level: int) -> void:
	var target_stage := get_stage_for_level(level)
	if target_stage > stage:
		while stage < target_stage:
			evolve_to(stage + 1)
	else:
		_apply_stage_data(stage, false)

func get_stage_for_level(level: int) -> int:
	var target_stage := 0
	for stage_id in STAGE_DATA.keys():
		if level >= int(STAGE_DATA[stage_id]["level"]):
			target_stage = max(target_stage, int(stage_id))
	return target_stage

func get_stage_data(stage_id: int = stage) -> Dictionary:
	return STAGE_DATA.get(stage_id, STAGE_DATA[0]).duplicate(true)

func get_current_stage_label() -> String:
	return String(get_stage_data()["label"])

func evolve_to(new_stage: int) -> bool:
	new_stage = clampi(new_stage, 0, STAGE_DATA.size() - 1)
	if new_stage <= stage:
		return false
	var previous_stage := stage
	evolution_started.emit(previous_stage, new_stage)
	stage = new_stage
	_apply_stage_data(stage, true)
	evolution_completed.emit(stage, stage_name, visual_scale)
	return true

func force_next_evolution() -> bool:
	return evolve_to(stage + 1)

func _apply_stage_data(stage_id: int, emit_change: bool) -> void:
	var data: Dictionary = STAGE_DATA[stage_id]
	stage_name = data["name"]
	visual_scale = float(data["scale"])
	if apply_visual_growth:
		var growth_root := get_node_or_null(growth_root_path) as Node2D
		if growth_root != null:
			growth_root.scale = Vector2.ONE * visual_scale
	var should_apply_profile := apply_visual_variants and (emit_change or stage_id > 0 or apply_initial_stage_profile)
	if should_apply_profile:
		var randomizer := get_node_or_null(randomizer_path) as PetRandomizer
		if randomizer != null:
			randomizer.apply_evolution_profile(stage_id)
	if emit_change:
		evolution_changed.emit(stage, stage_name, visual_scale)
