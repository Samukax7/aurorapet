@tool
class_name PetRandomizer
extends Node2D

## Sorteia as peças modulares existentes e aplica uma paleta cósmica por modulação.
## A cena continua sendo a fonte principal: nenhum nó é criado ou removido.

signal palette_changed(pair_index: int, palette_name: StringName, base_color: Color, complementary_color: Color)

const EYES_PATH := "res://assets/pet_modular/modulos/olhos/eye_%02d.png"
const EARS_PATH := "res://assets/pet_modular/modulos/orelhas/ear_%02d.png"
const WINGS_PATH := "res://assets/pet_modular/modulos/asas/wing_%02d.png"
const TAILS_PATH := "res://assets/pet_modular/modulos/caudas/tail_%02d.png"

## Escalas locais calculadas para equalizar a altura visível das cinco caudas.
## A variante 01 preserva a escala manual já aprovada na cena Pet.
const TAIL_SCALE_PROFILES: Dictionary = {
	1: Vector2(-0.68833846, 0.7042247),
	2: Vector2(-0.316, 0.324),
	3: Vector2(-0.349, 0.357),
	4: Vector2(-0.334, 0.341),
	5: Vector2(-0.360, 0.368),
}

## Dez pares, totalizando vinte cores cósmicas contrastantes com o fundo anil.
const COSMIC_PALETTE: Array[Dictionary] = [
	{"name": &"coral_nebulosa", "base": "#FF6B7A", "complementary": "#6BFFF0"},
	{"name": &"laranja_solar", "base": "#FFB347", "complementary": "#4793FF"},
	{"name": &"dourado_estelar", "base": "#FFE27A", "complementary": "#7A97FF"},
	{"name": &"verde_plasma", "base": "#B8F06A", "complementary": "#A26AF0"},
	{"name": &"esmeralda_aurora", "base": "#5AF0B0", "complementary": "#F05A9A"},
	{"name": &"ciano_cometa", "base": "#55E9FF", "complementary": "#FF6B55"},
	{"name": &"azul_eletrico", "base": "#79D8FF", "complementary": "#FFA079"},
	{"name": &"magenta_galactico", "base": "#FF68E1", "complementary": "#68FF86"},
	{"name": &"violeta_cosmico", "base": "#E28CFF", "complementary": "#A9FF8C"},
	{"name": &"rosa_quasar", "base": "#FF9BCE", "complementary": "#9BFFCC"},
]

@export_category("Sorteio")
@export var randomize_on_ready := true
@export var use_identity_weights := true
@export var identity_path: NodePath = NodePath("PetIdentity")
@export var randomize_in_editor := false
@export var randomize_each_run := true
@export var random_seed_value: int = 0
@export var randomize_palette_on_ready := true
@export var randomize_palette_in_editor := false
@export var palette_seed_value: int = 0

@export_category("Ajuste individual das caudas")
@export var apply_tail_variant_scales := true

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

@export_category("Paleta atual")
@export_range(-1, 9, 1) var palette_pair_index: int = -1
@export var palette_name: StringName = &""
@export var base_color := Color.WHITE
@export var complementary_color := Color.WHITE

var _randomizer := RandomNumberGenerator.new()
var _palette_randomizer := RandomNumberGenerator.new()

func _ready() -> void:
	if Engine.is_editor_hint():
		if randomize_in_editor:
			call_deferred("randomize_pet")
		if randomize_palette_in_editor:
			call_deferred("reroll_palette")
		return
	if randomize_on_ready:
		randomize_pet()
	if randomize_palette_on_ready:
		reroll_palette()

## Sorteia somente as peças habilitadas e mantém os nós da cena intactos.
func randomize_pet() -> void:
	_prepare_randomizer()
	var identity := _get_identity()
	if randomize_eyes:
		eyes_variant = identity.choose_part_variant(&"eyes", _randomizer) if identity != null and use_identity_weights else _random_variant()
	if randomize_ears:
		ears_variant = identity.choose_part_variant(&"ears", _randomizer) if identity != null and use_identity_weights else _random_variant()
	if randomize_wings:
		wings_variant = identity.choose_part_variant(&"wings", _randomizer) if identity != null and use_identity_weights else _random_variant()
	if randomize_tail:
		tail_variant = identity.choose_part_variant(&"tail", _randomizer) if identity != null and use_identity_weights else _random_variant()
	_apply_variants()

## Sorteia uma nova paleta e aplica a mesma cor ao conjunto base/orelhas/cauda.
## Olhos e asas recebem automaticamente a cor complementar.
func reroll_palette() -> void:
	_prepare_palette_randomizer()
	var identity := _get_identity()
	if identity != null and use_identity_weights:
		var preferred := identity.get_preferred_palette_names()
		if not preferred.is_empty():
			var selected_name: StringName = preferred[_palette_randomizer.randi_range(0, preferred.size() - 1)]
			for index in range(COSMIC_PALETTE.size()):
				if COSMIC_PALETTE[index]["name"] == selected_name:
					apply_palette_index(index)
					return
	apply_palette_index(_palette_randomizer.randi_range(0, COSMIC_PALETTE.size() - 1))

func apply_palette_index(index: int) -> void:
	if COSMIC_PALETTE.is_empty():
		return
	palette_pair_index = posmod(index, COSMIC_PALETTE.size())
	var palette: Dictionary = COSMIC_PALETTE[palette_pair_index]
	palette_name = palette["name"]
	base_color = Color(String(palette["base"]))
	complementary_color = Color(String(palette["complementary"]))
	_apply_palette_colors()
	palette_changed.emit(palette_pair_index, palette_name, base_color, complementary_color)

## Permite testar a próxima paleta sem depender de um novo sorteio.
func cycle_palette(step: int = 1) -> void:
	var next_index := 0 if palette_pair_index < 0 else palette_pair_index + step
	apply_palette_index(next_index)

## Permite sortear novamente as peças a partir de outros sistemas.
func reroll() -> void:
	randomize_pet()
	reroll_palette()

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

## Aplica a combinação de variantes associada ao estágio de evolução.
func apply_evolution_profile(stage: int) -> void:
	var profile: Dictionary = {
		0: {"eyes": 1, "ears": 1, "wings": 1, "tail": 1},
		1: {"eyes": 2, "ears": 2, "wings": 1, "tail": 2},
		2: {"eyes": 3, "ears": 3, "wings": 2, "tail": 3},
		3: {"eyes": 4, "ears": 3, "wings": 3, "tail": 4},
		4: {"eyes": 5, "ears": 4, "wings": 4, "tail": 5},
		5: {"eyes": 5, "ears": 5, "wings": 5, "tail": 5},
		6: {"eyes": 5, "ears": 5, "wings": 5, "tail": 5},
	}.get(clampi(stage, 0, 6), {})
	if profile.is_empty():
		return
	eyes_variant = int(profile["eyes"])
	ears_variant = int(profile["ears"])
	wings_variant = int(profile["wings"])
	tail_variant = int(profile["tail"])
	_apply_variants()

func get_palette_info() -> Dictionary:
	return {
		"index": palette_pair_index,
		"name": palette_name,
		"base": base_color,
		"complementary": complementary_color,
	}

func _prepare_randomizer() -> void:
	if randomize_each_run or random_seed_value == 0:
		_randomizer.randomize()
	else:
		_randomizer.seed = random_seed_value

func _prepare_palette_randomizer() -> void:
	if randomize_each_run or palette_seed_value == 0:
		_palette_randomizer.randomize()
	else:
		_palette_randomizer.seed = palette_seed_value

func _random_variant() -> int:
	return _randomizer.randi_range(1, 5)

func _get_identity() -> PetIdentity:
	if not use_identity_weights:
		return null
	var identity := get_node_or_null(identity_path) as PetIdentity
	if identity != null:
		identity.ensure_generated()
	return identity

func _apply_variants() -> void:
	_set_texture(&"Olhos", EYES_PATH % clampi(eyes_variant, 1, 5))
	_set_texture(&"Orelhas", EARS_PATH % clampi(ears_variant, 1, 5))
	_set_texture(&"Asas", WINGS_PATH % clampi(wings_variant, 1, 5))
	_set_texture(&"Cauda", TAILS_PATH % clampi(tail_variant, 1, 5))
	_apply_tail_variant_scale()

func _apply_tail_variant_scale() -> void:
	if not apply_tail_variant_scales:
		return
	var tail := get_node_or_null(^"Cauda") as Sprite2D
	if tail == null:
		return
	var variant := clampi(tail_variant, 1, 5)
	tail.scale = TAIL_SCALE_PROFILES.get(variant, TAIL_SCALE_PROFILES[1])

func _apply_palette_colors() -> void:
	_set_modulate(&"CorpoBase", base_color)
	_set_modulate(&"Orelhas", base_color)
	_set_modulate(&"Cauda", base_color)
	_set_modulate(&"Olhos", complementary_color)
	_set_modulate(&"Asas", complementary_color)

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

func _set_modulate(layer_name: StringName, color: Color) -> void:
	var layer := get_node_or_null(NodePath(String(layer_name))) as Sprite2D
	if layer == null:
		push_warning("Camada para recolorir ausente na cena Pet: %s" % layer_name)
		return
	layer.self_modulate = color
