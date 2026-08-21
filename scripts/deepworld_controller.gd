extends Node2D
class_name DeepworldController

## Controla as camadas do Deepworld sem alterar a cascata do pet.
## O cenário troca por facção; a plataforma permanece fixa e serve como área comum de interação.

signal faction_background_changed(faction: StringName)

@export_category("Fundo por facção")
@export var default_faction: StringName = &"neutro"
@export var use_faction_backgrounds := false
@export var fallback_to_legacy_background := true
@export var faction_background_paths: Dictionary = {
	&"luz": "res://assets/fundo/faccoes/deepworld_luz.png",
	&"trevas": "res://assets/fundo/faccoes/deepworld_trevas.png",
	&"neutro": "res://assets/fundo/faccoes/deepworld_neutro.png",
}

@export_category("Camadas")
@export var legacy_background_path: NodePath = NodePath("Cenario/Fundo")
@export var faction_layer_paths: Dictionary = {
	&"luz": NodePath("Cenario/FundoLuz"),
	&"trevas": NodePath("Cenario/FundoTrevas"),
	&"neutro": NodePath("Cenario/FundoNeutro"),
}
@export var platform_path: NodePath = NodePath("Plataforma")
@export var pet_identity_path: NodePath = NodePath("Paisagem/Pet/PetIdentity")

var current_faction: StringName = &""

func _ready() -> void:
	if not use_faction_backgrounds:
		_show_legacy_background()
		return
	var identity := get_node_or_null(pet_identity_path) as PetIdentity
	if identity != null:
		identity.identity_generated.connect(_on_identity_generated)
		call_deferred("_apply_identity_faction")
	else:
		apply_faction(default_faction)

func _apply_identity_faction() -> void:
	if not use_faction_backgrounds:
		_show_legacy_background()
		return
	var identity := get_node_or_null(pet_identity_path) as PetIdentity
	if identity == null:
		apply_faction(default_faction)
		return
	identity.ensure_generated()
	apply_faction(identity.faction_id if not identity.faction_id.is_empty() else default_faction)

func _on_identity_generated(snapshot: Dictionary) -> void:
	if not use_faction_backgrounds:
		_show_legacy_background()
		return
	var faction_value: StringName = snapshot.get("faction", default_faction)
	apply_faction(faction_value)

func activate_default_background() -> void:
	## O modo DEV usa a paisagem legada/padrão e não altera a identidade do pet.
	use_faction_backgrounds = false
	_show_legacy_background()

func activate_faction_background(faction: StringName) -> void:
	## Abertura segura: o fundo por facção só entra depois da ficha de nascimento.
	use_faction_backgrounds = true
	apply_faction(faction)

func apply_faction(faction: StringName) -> void:
	if not use_faction_backgrounds:
		_show_legacy_background()
		return
	var safe_faction := faction if faction_background_paths.has(faction) else default_faction
	var selected_layer_path: NodePath = faction_layer_paths.get(safe_faction, NodePath())
	var selected_layer := get_node_or_null(selected_layer_path) as Sprite2D
	var legacy := get_node_or_null(legacy_background_path) as Sprite2D
	for layer_path in faction_layer_paths.values():
		var layer := get_node_or_null(layer_path) as Sprite2D
		if layer != null:
			layer.visible = false
	if selected_layer != null and selected_layer.texture != null:
		selected_layer.visible = true
		if legacy != null:
			legacy.visible = false
		current_faction = safe_faction
		faction_background_changed.emit(current_faction)
	elif fallback_to_legacy_background and legacy != null:
		legacy.visible = true
		current_faction = &"legacy"

func _show_legacy_background() -> void:
	var legacy := get_node_or_null(legacy_background_path) as Sprite2D
	for layer_path in faction_layer_paths.values():
		var layer := get_node_or_null(layer_path) as Sprite2D
		if layer != null:
			layer.visible = false
	if legacy != null:
		legacy.visible = true
	current_faction = &"legacy"
	faction_background_changed.emit(current_faction)

func get_current_faction() -> StringName:
	return current_faction
