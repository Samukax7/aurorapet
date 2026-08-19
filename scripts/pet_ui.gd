@tool
class_name PetUI
extends Control

## UI do pet com menu inferior e status no topo.
## O botão amarelo alterna a barra de status; o botão rosa alterna o menu.

signal action_requested(action: StringName)
signal selection_changed(action: StringName)
signal status_visibility_changed(visible: bool)

@export_category("Menu")
@export var menu_visible := true
@export_range(0, 4, 1) var selected_index := 0

@export_category("Status")
@export var status_visible := true
@export_range(0.0, 100.0, 1.0) var hunger := 82.0
@export_range(0.0, 100.0, 1.0) var energy := 76.0
@export_range(0.0, 100.0, 1.0) var mood := 68.0
@export_range(0.0, 100.0, 1.0) var health := 91.0

const ACTIONS: Array[StringName] = [&"comer", &"brincar", &"limpar", &"treinar", &"dormir"]
const SLOT_NAMES: Array[StringName] = [&"Comer", &"Brincar", &"Limpar", &"Treinar", &"Dormir"]
const STATUS_NAMES: Array[StringName] = [&"Fome", &"Energia", &"Humor", &"Saude"]

var _slots: Array[Control] = []
var _status_bars: Dictionary = {}
var _status_labels: Dictionary = {}
var _selection_label: Label
var _hint_label: Label

func _ready() -> void:
	_cache_menu_nodes()
	_refresh_selection()
	_refresh_status_bars()
	_set_menu_visibility(menu_visible)
	_set_status_visibility(status_visible)

func _cache_menu_nodes() -> void:
	_slots.clear()
	_status_bars.clear()
	_status_labels.clear()
	for slot_name in SLOT_NAMES:
		var slot := get_node_or_null(NodePath("ActionBar/ActionMenu/" + String(slot_name))) as Control
		if slot != null:
			_slots.append(slot)
	for status_name in STATUS_NAMES:
		var bar := get_node_or_null(NodePath("StatusBar/StatusItems/" + String(status_name) + "/Bar")) as ProgressBar
		if bar != null:
			_status_bars[status_name] = bar
		var status_label := get_node_or_null(NodePath("StatusBar/StatusItems/" + String(status_name) + "/Label")) as Label
		if status_label != null:
			_status_labels[status_name] = status_label
	_selection_label = get_node_or_null(^"SelectedAction") as Label
	_hint_label = get_node_or_null(^"StatusBar/Hint") as Label

## Move a seleção com o D-pad entre os cinco ícones inferiores.
func move_selection(direction: Vector2i) -> void:
	if ACTIONS.is_empty():
		return
	var step := 1 if direction.x > 0 or direction.y > 0 else -1
	selected_index = wrapi(selected_index + step, 0, ACTIONS.size())
	_refresh_selection()

func confirm_selected() -> void:
	if ACTIONS.is_empty():
		return
	action_requested.emit(ACTIONS[selected_index])
	if _hint_label != null:
		_hint_label.text = "AÇÃO: " + String(ACTIONS[selected_index]).to_upper()

func toggle_menu() -> void:
	menu_visible = not menu_visible
	_set_menu_visibility(menu_visible)

## Alterna as quatro barras superiores pelo botão amarelo.
func toggle_status() -> void:
	status_visible = not status_visible
	_set_status_visibility(status_visible)
	status_visibility_changed.emit(status_visible)

func set_status_visibility(value: bool) -> void:
	status_visible = value
	_set_status_visibility(value)
	status_visibility_changed.emit(value)

func set_status(status: StringName, value: float) -> void:
	var safe_value := clampf(value, 0.0, 100.0)
	match status:
		&"fome": hunger = safe_value
		&"energia": energy = safe_value
		&"humor": mood = safe_value
		&"saude": health = safe_value
		_:
			push_warning("Status desconhecido: %s" % status)
			return
	_refresh_status_bars()

func set_status_values(new_hunger: float, new_energy: float, new_mood: float, new_health: float) -> void:
	hunger = clampf(new_hunger, 0.0, 100.0)
	energy = clampf(new_energy, 0.0, 100.0)
	mood = clampf(new_mood, 0.0, 100.0)
	health = clampf(new_health, 0.0, 100.0)
	_refresh_status_bars()

func set_selected_action(action: StringName) -> void:
	var index := ACTIONS.find(action)
	if index >= 0:
		selected_index = index
		_refresh_selection()

func _refresh_selection() -> void:
	if ACTIONS.is_empty():
		return
	selected_index = clampi(selected_index, 0, ACTIONS.size() - 1)
	for index in _slots.size():
		var slot := _slots[index]
		var is_selected := index == selected_index
		slot.modulate = Color(1.0, 1.0, 1.0, 1.0 if is_selected else 0.62)
		slot.scale = Vector2(1.04, 1.04) if is_selected else Vector2.ONE
	if _selection_label != null:
		_selection_label.text = String(ACTIONS[selected_index]).to_upper()
	selection_changed.emit(ACTIONS[selected_index])

func _refresh_status_bars() -> void:
	var values := {
		&"Fome": hunger,
		&"Energia": energy,
		&"Humor": mood,
		&"Saude": health,
	}
	for status_name in values:
		var value: float = values[status_name]
		if _status_bars.has(status_name):
			_status_bars[status_name].value = value
		if _status_labels.has(status_name):
			_status_labels[status_name].text = String(status_name).to_upper() + " " + str(roundi(value)) + "%"

func _set_menu_visibility(value: bool) -> void:
	var menu := get_node_or_null(^"ActionBar") as Control
	if menu != null:
		menu.visible = value

func _set_status_visibility(value: bool) -> void:
	var status_bar := get_node_or_null(^"StatusBar") as Control
	if status_bar != null:
		status_bar.visible = value
