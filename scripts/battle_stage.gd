extends Node2D

## Palco visual da batalha dentro do Deepworld.
## Composição de batalha formada por três atores independentes:
## pet do usuário, Eco modular espelhado e Boss com sprite próprio.

@onready var player_combatant: Node2D = $PlayerBattleActor
@onready var eco_combatant: Node2D = $EchoBattleActor
@onready var boss_actor: Node2D = $BossBattleActor
@onready var player_caption: Label = $PlayerCaption
@onready var eco_caption: Label = $EcoCaption
@onready var stage_banner: Label = $StageBanner

var _player_source: PetRandomizer
var _enemy_name := "ECO"
var _enemy_faction: StringName = &"neutro"

const PLAYER_BATTLE_POSITION := Vector2(-1180, -65)
const ENEMY_BATTLE_POSITION := Vector2(1180, -85)
const COMBATANT_BATTLE_SCALE := Vector2(1.8, 1.8)
const BOSS_BATTLE_SCALE := Vector2(2.15, 2.15)
const BOSS_TEXTURES: Dictionary = {
	"gorgon glitch": "res://assets/bosses/gorgon_glitch.png",
	"prisma guard": "res://assets/bosses/prisma_guard.png",
	"core overlord": "res://assets/bosses/core_overlord.png",
	"ignis vectis": "res://assets/bosses/ignis_vectis.png",
	"arquiteto do esquecimento": "res://assets/bosses/arquiteto_do_esquecimento.png",
	"o eco absoluto": "res://assets/bosses/eco_absoluto.png",
}

func _ready() -> void:
	visible = false
	stage_banner.text = "CAMPO DE EXPLORAÇÃO"
	player_caption.text = "PET"
	eco_caption.text = "ECO"
	if eco_combatant != null:
		eco_combatant.self_modulate = Color(0.72, 0.48, 0.9, 0.96)
	if boss_actor != null:
		boss_actor.visible = false
	_apply_battle_transforms()

func show_battle_stage(source_pet: Node = null) -> void:
	visible = true
	_apply_battle_transforms()
	_player_source = source_pet as PetRandomizer
	_sync_player_appearance()
	if player_combatant != null:
		player_combatant.visible = true
	if eco_combatant != null:
		eco_combatant.call("configure_echo", _player_source, true, false)
	_update_enemy_visual()
	_update_captions()

func hide_battle_stage() -> void:
	visible = false

func play_player_battle_animation(animation_name: StringName = &"idle") -> void:
	if player_combatant != null:
		player_combatant.call("play_battle_animation", animation_name)

func play_enemy_battle_animation(animation_name: StringName = &"idle") -> void:
	if boss_actor != null and boss_actor.visible:
		boss_actor.call("play_battle_animation", animation_name)
	elif eco_combatant != null:
		eco_combatant.call("play_battle_animation", animation_name)

func get_enemy_battle_animation_duration(animation_name: StringName = &"idle") -> float:
	if boss_actor != null and boss_actor.visible and boss_actor.has_method("get_battle_animation_duration"):
		return float(boss_actor.call("get_battle_animation_duration", animation_name))
	return 0.0

func play_enemy_action_animation(action: StringName) -> StringName:
	var animation_name: StringName = &"attack_basic"
	match action:
		&"golpe_forte":
			animation_name = &"attack_charged"
		&"escudo", &"defesa":
			animation_name = &"defend"
		&"golpe_fraco", &"golpe_status":
			animation_name = &"attack_basic"
	play_enemy_battle_animation(animation_name)
	return animation_name

func _apply_battle_transforms() -> void:
	if player_combatant != null:
		player_combatant.position = PLAYER_BATTLE_POSITION
		player_combatant.scale = Vector2(-COMBATANT_BATTLE_SCALE.x, COMBATANT_BATTLE_SCALE.y)
		player_combatant.z_index = 6
	if eco_combatant != null:
		eco_combatant.position = ENEMY_BATTLE_POSITION
		eco_combatant.scale = COMBATANT_BATTLE_SCALE
		eco_combatant.z_index = 6
	if boss_actor != null:
		boss_actor.position = ENEMY_BATTLE_POSITION
		boss_actor.scale = BOSS_BATTLE_SCALE
		boss_actor.z_index = 7

func set_enemy_profile(enemy_name: String, enemy_faction: StringName) -> void:
	_enemy_name = enemy_name if not enemy_name.is_empty() else "ECO"
	_enemy_faction = enemy_faction
	_update_eco_palette()
	_update_enemy_visual()
	_update_captions()

func _sync_player_appearance() -> void:
	if player_combatant == null:
		return
	player_combatant.self_modulate = Color.WHITE
	if _player_source == null:
		if not _is_headless_display():
			player_combatant.call("prepare_development_appearance")
		return
	if _is_headless_display():
		return
	player_combatant.call("set_part_variant", &"eyes", _player_source.eyes_variant)
	player_combatant.call("set_part_variant", &"ears", _player_source.ears_variant)
	player_combatant.call("set_part_variant", &"wings", _player_source.wings_variant)
	player_combatant.call("set_part_variant", &"tail", _player_source.tail_variant)
	if _player_source.palette_pair_index >= 0:
		player_combatant.call("apply_palette_index", _player_source.palette_pair_index)
	else:
		player_combatant.call("prepare_development_appearance")

func _update_eco_palette() -> void:
	if eco_combatant == null:
		return
	if not _is_headless_display():
		var palette_index := 8
		match _enemy_faction:
			&"luz": palette_index = 6
			&"trevas": palette_index = 7
			&"neutro": palette_index = 8
		eco_combatant.call("apply_palette_index", palette_index)
	eco_combatant.self_modulate = Color(0.72, 0.48, 0.9, 0.96)

func _update_enemy_visual() -> void:
	var boss_path := String(BOSS_TEXTURES.get(_enemy_name.strip_edges().to_lower(), ""))
	var boss_texture := load(boss_path) as Texture2D if not boss_path.is_empty() else null
	var is_boss_visual := boss_texture != null
	if boss_actor != null:
		boss_actor.call("set_boss_texture", boss_texture)
		if is_boss_visual:
			boss_actor.call("configure_boss_profile", _enemy_name)
		boss_actor.visible = is_boss_visual
		boss_actor.modulate = Color.WHITE
	if eco_combatant != null:
		eco_combatant.visible = not is_boss_visual

func _update_captions() -> void:
	if player_caption != null:
		player_caption.text = "PET"
	if eco_caption != null:
		eco_caption.text = "%s  •  %s" % [_enemy_name.to_upper(), String(_enemy_faction).to_upper()]

func _is_headless_display() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name().to_lower() == "headless"
