@tool
class_name PetRandomizer
extends Node2D

## Sorteia as peças modulares já existentes na cena Pet.
## A cena continua sendo a fonte principal da composição: cada peça é um Sprite2D
## editável, e este script apenas troca sua textura quando solicitado.

const EYES_PATH := "res://assets/pet_modular/modulos/olhos/eye_%02d.png"
const EARS_PATH := "res://assets/pet_modular/modulos/orelhas/ear_%02d.png"
const WINGS_PATH := "res://assets/pet_modular/modulos/asas/wing_%02d.png"
const TAILS_PATH := "res://assets/pet_modular/modulos/caudas/tail_%02d.png"

@export_category("Sorteio")
@export var randomize_on_ready := false
@export var randomize_in_editor := false
@export var randomize_each_run := true
@export var random_seed_value: int = 0

@export_category("Peças incluídas no sorteio")
@export var randomize_eyes := true
@export var randomize_ears := true
@export var randomize_wings := true
@export var randomize_tail := true

@export_category("Variantes atuais")
@export_range(1, 5, 1) var eyes_variant: int = 1
@export_range(1, 5, 1) var ears_variant: int = 1
@export_range(1, 5, 1) var wings_variant: int = 1
@export_range(1, 5, 1) var tail_variant: int = 1

var _randomizer := RandomNumberGenerator.new()

func _ready() -> void:
	if Engine.is_editor_hint():
		if randomize_in_editor:
			call_deferred("randomize_pet")
		return
	if randomize_on_ready:
		randomize_pet()

## Sorteia somente as peças habilitadas e mantém os nós da cena intactos.
func randomize_pet() -> void:
	_prepare_randomizer()
	if randomize_eyes:
		eyes_variant = _random_variant()
	if randomize_ears:
		ears_variant = _random_variant()
	if randomize_wings:
		wings_variant = _random_variant()
	if randomize_tail:
		tail_variant = _random_variant()
	_apply_variants()

## Permite sortear novamente a partir de outros sistemas, como o menu ou um botão.
func reroll() -> void:
	randomize_pet()

## Permite definir uma peça individual durante a prototipagem.
func set_part_variant(part: StringName, variant: int) -> void:
	var safe_variant := clampi(variant, 1, 5)
	match part:
		&"eyes": eyes_variant = safe_variant
		&"ears": ears_variant = safe_variant
		&"wings": wings_variant = safe_variant
		&"tail": tail_variant = safe_variant
		_:
			push_warning("Peça modular desconhecida: %s" % part)
			return
	_apply_variants()

func _prepare_randomizer() -> void:
	if randomize_each_run or random_seed_value == 0:
		_randomizer.randomize()
	else:
		_randomizer.seed = random_seed_value

func _random_variant() -> int:
	return _randomizer.randi_range(1, 5)

func _apply_variants() -> void:
	_set_texture(&"Olhos", EYES_PATH % clampi(eyes_variant, 1, 5))
	_set_texture(&"Orelhas", EARS_PATH % clampi(ears_variant, 1, 5))
	_set_texture(&"Asas", WINGS_PATH % clampi(wings_variant, 1, 5))
	_set_texture(&"Cauda", TAILS_PATH % clampi(tail_variant, 1, 5))

func _set_texture(layer_name: StringName, asset_path: String) -> void:
	var layer := get_node_or_null(NodePath(String(layer_name))) as Sprite2D
	if layer == null:
		push_warning("Camada modular ausente na cena Pet: %s" % layer_name)
		return
	var texture := load(asset_path) as Texture2D
	if texture == null:
		push_warning("Não foi possível carregar o asset modular: %s" % asset_path)
		return
	layer.texture = texture
