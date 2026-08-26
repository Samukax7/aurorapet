extends Control
class_name GuardaRoupasCosmico

signal wardrobe_closed
signal cosmetic_equipped(item_id: StringName)

const ITEMS: Array[Dictionary] = [
	{"id": &"cosmic_orbit_crown", "name": "COROA ÓRBITA", "slot": "CABEÇA", "texture": "res://assets/cosmetics/wardrobe/cosmic_orbit_crown_64.png"},
	{"id": &"cosmic_star_scarf", "name": "CACHECOL ESTELAR", "slot": "PESCOÇO", "texture": "res://assets/cosmetics/wardrobe/cosmic_star_scarf_64.png"},
	{"id": &"nebula_backpack", "name": "MOCHILA NEBULOSA", "slot": "COSTAS", "texture": "res://assets/cosmetics/wardrobe/nebula_backpack_64.png"},
	{"id": &"guardian_halo", "name": "HALO GUARDIÃO", "slot": "AURA", "texture": "res://assets/cosmetics/wardrobe/guardian_halo_64.png"},
	{"id": &"comet_tail_ribbon", "name": "FITA COMETA", "slot": "CAUDA", "texture": "res://assets/cosmetics/wardrobe/comet_tail_ribbon_64.png"},
	{"id": &"lunar_cape", "name": "CAPA LUNAR", "slot": "CORPO", "texture": "res://assets/cosmetics/wardrobe/lunar_cape_64.png"},
]

var selected_index := 0
var equipped_item: StringName = &""
var active := false

@onready var item_buttons: Array[Button] = [
	$Panel/Items/Item01,
	$Panel/Items/Item02,
	$Panel/Items/Item03,
	$Panel/Items/Item04,
	$Panel/Items/Item05,
	$Panel/Items/Item06,
]
@onready var preview_accessory: Sprite2D = $Panel/Preview/Accessory
@onready var selected_label: Label = $Panel/Selected
@onready var result_label: Label = $Panel/Result

func _ready() -> void:
	visible = false
	for index in item_buttons.size():
		item_buttons[index].pressed.connect(func(): _select_from_button(index))
	_render()

func open_wardrobe(current_equipped: StringName = &"") -> void:
	equipped_item = current_equipped
	selected_index = 0
	active = true
	visible = true
	_render()
	grab_focus()

func close_wardrobe() -> void:
	if not active:
		return
	active = false
	visible = false
	wardrobe_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not active or direction == Vector2i.ZERO:
		return
	if direction.x < 0 or direction.y < 0:
		selected_index = wrapi(selected_index - 1, 0, ITEMS.size())
	else:
		selected_index = wrapi(selected_index + 1, 0, ITEMS.size())
	_render()

func confirm() -> void:
	if not active:
		return
	var item: Dictionary = ITEMS[selected_index]
	equipped_item = item["id"] as StringName
	result_label.text = "EQUIPADO: " + String(item["name"])
	cosmetic_equipped.emit(equipped_item)
	_render()

func back() -> void:
	close_wardrobe()

func get_equipped_item() -> StringName:
	return equipped_item

func _select_from_button(index: int) -> void:
	if not active:
		return
	selected_index = clampi(index, 0, ITEMS.size() - 1)
	_render()

func _render() -> void:
	if not is_node_ready():
		return
	for index in item_buttons.size():
		item_buttons[index].button_pressed = index == selected_index
	var item: Dictionary = ITEMS[selected_index]
	selected_label.text = "%s  •  SLOT: %s" % [String(item["name"]), String(item["slot"])]
	preview_accessory.texture = load(String(item["texture"])) as Texture2D
	preview_accessory.position = _preview_position(item["slot"] as String)
	result_label.text = "VERDE: EQUIPAR   •   ITEM ATUAL: %s" % (String(equipped_item) if not equipped_item.is_empty() else "NENHUM")

func _preview_position(slot: String) -> Vector2:
	match slot:
		"CABEÇA", "AURA":
			return Vector2(250, 155)
		"COSTAS", "CAUDA":
			return Vector2(250, 270)
		"PESCOÇO":
			return Vector2(250, 300)
		_:
			return Vector2(250, 320)
