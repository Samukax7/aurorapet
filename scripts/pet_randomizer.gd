@tool
class_name PetRandomizer
extends Node2D

## Sorteia as peças modulares existentes e aplica uma paleta cósmica por modulação.
## A cena continua sendo a fonte principal: nenhum nó é criado ou removido.

signal palette_changed(pair_index: int, palette_name: StringName, base_color: Color, complementary_color: Color)
signal reaction_started(action: StringName, reaction_id: StringName)
signal cosmetic_equipped(item_id: StringName)

const COSMETIC_TEXTURES: Dictionary = {
	&"cosmic_orbit_crown": "res://assets/cosmetics/wardrobe/cosmic_orbit_crown_64.png",
	&"cosmic_star_scarf": "res://assets/cosmetics/wardrobe/cosmic_star_scarf_64.png",
	&"nebula_backpack": "res://assets/cosmetics/wardrobe/nebula_backpack_64.png",
	&"guardian_halo": "res://assets/cosmetics/wardrobe/guardian_halo_64.png",
	&"comet_tail_ribbon": "res://assets/cosmetics/wardrobe/comet_tail_ribbon_64.png",
	&"lunar_cape": "res://assets/cosmetics/wardrobe/lunar_cape_64.png",
}

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

@export_category("Cosméticos")
@export var equipped_cosmetic: StringName = &""

@export_category("Ajuste individual das caudas")
@export var apply_tail_variant_scales := true

@export_category("Feedback visual")
@export var reaction_animation_state: StringName = &"idle"
@export var reaction_shake_pixels := 4.0
@export var reaction_particle_duration := 0.75

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
var _reaction_tween: Tween
var _reaction_origin := Vector2.ZERO
var _reaction_scale := Vector2.ONE
var _sleep_eye_tween: Tween
var _sleep_eye_scale := Vector2.ONE
@onready var cosmetic_overlay: Sprite2D = get_node_or_null(^"CosmeticOverlay") as Sprite2D
@onready var eyes_sprite: Sprite2D = get_node_or_null(^"Olhos") as Sprite2D

func _ready() -> void:
	_reaction_origin = position
	_reaction_scale = scale
	if eyes_sprite != null:
		_sleep_eye_scale = eyes_sprite.scale
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
	if not equipped_cosmetic.is_empty():
		call_deferred("equip_cosmetic", equipped_cosmetic)

func equip_cosmetic(item_id: StringName) -> void:
	equipped_cosmetic = item_id
	if cosmetic_overlay == null:
		return
	var texture_path := String(COSMETIC_TEXTURES.get(item_id, ""))
	cosmetic_overlay.texture = load(texture_path) as Texture2D if not texture_path.is_empty() else null
	cosmetic_overlay.visible = cosmetic_overlay.texture != null
	cosmetic_overlay.z_index = 5
	match item_id:
		&"cosmic_orbit_crown", &"guardian_halo":
			cosmetic_overlay.position = Vector2(0, -94)
		&"cosmic_star_scarf", &"lunar_cape":
			cosmetic_overlay.position = Vector2(0, -32)
		&"nebula_backpack", &"comet_tail_ribbon":
			cosmetic_overlay.position = Vector2(0, 22)
		_:
			cosmetic_overlay.position = Vector2.ZERO
	cosmetic_equipped.emit(item_id)

func play_reaction(action: StringName, reaction_id: StringName = &"") -> void:
	var selected_reaction := reaction_id if not reaction_id.is_empty() else action
	reaction_animation_state = selected_reaction
	if _reaction_tween != null:
		_reaction_tween.kill()
	position = _reaction_origin
	scale = _reaction_scale
	rotation = 0.0

	# O tremor curto permanece como assinatura comum, mas cada ação ganha
	# uma silhueta própria para o jogador reconhecer a resposta do pet.
	_reaction_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_reaction_tween.tween_property(self, "position", _reaction_origin + Vector2(-reaction_shake_pixels, 0), 0.05)
	_reaction_tween.tween_property(self, "position", _reaction_origin + Vector2(reaction_shake_pixels, 0), 0.08)
	match selected_reaction:
		&"comer", &"fruta_estelar", &"nectar_cosmico", &"banquete_nebulosa":
			_reaction_tween.tween_property(self, "scale", _reaction_scale * Vector2(1.08, 0.92), 0.10)
			_reaction_tween.tween_property(self, "scale", _reaction_scale * Vector2(0.96, 1.06), 0.12)
			_reaction_tween.tween_property(self, "scale", _reaction_scale, 0.12)
		&"brincar", &"jokenpo", &"jogo_da_velha", &"2048":
			_reaction_tween.tween_property(self, "position", _reaction_origin + Vector2(0, -12), 0.14)
			_reaction_tween.tween_property(self, "position", _reaction_origin + Vector2(0, 0), 0.18)
		&"limpar_sujeira":
			_reaction_tween.tween_property(self, "rotation", deg_to_rad(-6.0), 0.08)
			_reaction_tween.tween_property(self, "rotation", deg_to_rad(6.0), 0.12)
			_reaction_tween.tween_property(self, "rotation", 0.0, 0.10)
		&"dar_remedio":
			_reaction_tween.tween_property(self, "scale", _reaction_scale * Vector2(0.94, 1.08), 0.16)
			_reaction_tween.tween_property(self, "scale", _reaction_scale, 0.18)
		&"treinar":
			_reaction_tween.tween_property(self, "position", _reaction_origin + Vector2(0, -8), 0.10)
			_reaction_tween.tween_property(self, "scale", _reaction_scale * Vector2(1.10, 0.90), 0.10)
			_reaction_tween.tween_property(self, "position", _reaction_origin, 0.12)
			_reaction_tween.tween_property(self, "scale", _reaction_scale, 0.14)
		&"dormir":
			_reaction_tween.tween_property(self, "scale", _reaction_scale * Vector2(0.96, 0.92), 0.18)
			_reaction_tween.tween_property(self, "rotation", deg_to_rad(-4.0), 0.14)
			_reaction_tween.tween_property(self, "rotation", 0.0, 0.16)
		&"recusa", &"refusal", &"blocked":
			_reaction_tween.tween_property(self, "rotation", deg_to_rad(-7.0), 0.08)
			_reaction_tween.tween_property(self, "rotation", deg_to_rad(7.0), 0.12)
			_reaction_tween.tween_property(self, "rotation", 0.0, 0.10)
	_reaction_tween.tween_property(self, "position", _reaction_origin, 0.10)

	var particle_path := "ReactionParticles/" + String(selected_reaction)
	var particles := get_node_or_null(NodePath(particle_path)) as CPUParticles2D
	if particles != null:
		particles.lifetime = reaction_particle_duration
		particles.restart()
	var animation_player := get_node_or_null(^"AnimationPlayer") as AnimationPlayer
	if animation_player != null and animation_player.has_animation(selected_reaction):
		animation_player.play(selected_reaction)
	reaction_started.emit(action, selected_reaction)

func set_sleeping_visual(value: bool) -> void:
	if _sleep_eye_tween != null:
		_sleep_eye_tween.kill()
	if eyes_sprite != null:
		# Durante o sono, achata somente a altura: a largura permanece normal.
		var target_scale := _sleep_eye_scale * Vector2(1.0, 0.18) if value else _sleep_eye_scale
		_sleep_eye_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_sleep_eye_tween.tween_property(eyes_sprite, "scale", target_scale, 0.22)
	if value:
		self_modulate = Color(0.72, 0.78, 1.0, 1.0)
	else:
		self_modulate = Color.WHITE

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

## Sorteia um modelo normal e mantém as texturas sem tintura de paleta.
func prepare_development_appearance() -> void:
	randomize_pet()
	palette_pair_index = -1
	palette_name = &"neutro_dev"
	base_color = Color.WHITE
	complementary_color = Color.WHITE
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
