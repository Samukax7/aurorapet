class_name BattleStage
extends Node2D

## Palco visual da batalha dentro do Deepworld.
## Reutiliza instâncias de pet.tscn e não altera o save nem cria camadas em runtime.

@onready var player_combatant: PetRandomizer = $PlayerCombatant
@onready var eco_combatant: PetRandomizer = $EcoCombatant
@onready var player_caption: Label = $PlayerCaption
@onready var eco_caption: Label = $EcoCaption
@onready var stage_banner: Label = $StageBanner

var _player_source: PetRandomizer
var _enemy_name := "ECO"
var _enemy_faction: StringName = &"neutro"

func _ready() -> void:
	visible = false
	stage_banner.text = "CAMPO DE EXPLORAÇÃO"
	player_caption.text = "PET"
	eco_caption.text = "ECO"
	if eco_combatant != null:
		eco_combatant.self_modulate = Color(0.72, 0.48, 0.9, 0.96)

func show_battle_stage(source_pet: Node = null) -> void:
	visible = true
	_player_source = source_pet as PetRandomizer
	_sync_player_appearance()
	if player_combatant != null:
		player_combatant.visible = true
	if eco_combatant != null:
		eco_combatant.visible = true
	_update_captions()

func hide_battle_stage() -> void:
	visible = false

func set_enemy_profile(enemy_name: String, enemy_faction: StringName) -> void:
	_enemy_name = enemy_name if not enemy_name.is_empty() else "ECO"
	_enemy_faction = enemy_faction
	_update_eco_palette()
	_update_captions()

func _sync_player_appearance() -> void:
	if player_combatant == null:
		return
	player_combatant.self_modulate = Color.WHITE
	if _player_source == null:
		if not _is_headless_display():
			player_combatant.prepare_development_appearance()
		return
	if _is_headless_display():
		return
	player_combatant.set_part_variant(&"eyes", _player_source.eyes_variant)
	player_combatant.set_part_variant(&"ears", _player_source.ears_variant)
	player_combatant.set_part_variant(&"wings", _player_source.wings_variant)
	player_combatant.set_part_variant(&"tail", _player_source.tail_variant)
	if _player_source.palette_pair_index >= 0:
		player_combatant.apply_palette_index(_player_source.palette_pair_index)
	else:
		player_combatant.prepare_development_appearance()

func _update_eco_palette() -> void:
	if eco_combatant == null:
		return
	if not _is_headless_display():
		var palette_index := 8
		match _enemy_faction:
			&"luz": palette_index = 6
			&"trevas": palette_index = 7
			&"neutro": palette_index = 8
		eco_combatant.apply_palette_index(palette_index)
	eco_combatant.self_modulate = Color(0.72, 0.48, 0.9, 0.96)

func _update_captions() -> void:
	if player_caption != null:
		player_caption.text = "PET"
	if eco_caption != null:
		eco_caption.text = "%s  •  %s" % [_enemy_name.to_upper(), String(_enemy_faction).to_upper()]

func _is_headless_display() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name().to_lower() == "headless"
