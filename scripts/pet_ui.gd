@tool
class_name PetUI
extends Control

## UI do pet com menu principal de cinco categorias e submenus contextuais.
## O estado das ações continua sendo encaminhado pelo ConsoleController.

signal action_requested(action: StringName)
signal selection_changed(action: StringName)
signal status_visibility_changed(visible: bool)
signal submenu_visibility_changed(visible: bool, category: StringName)

@export_category("Menu principal")
@export var menu_visible := true
@export_range(0, 4, 1) var selected_index := 0

@export_category("Submenu")
@export var submenu_visible := false
@export var active_category: StringName = &""
@export_range(0, 2, 1) var submenu_selected_index := 0

@export_category("Status")
@export var status_visible := true
@export_range(0.0, 100.0, 1.0) var hunger := 82.0
@export_range(0.0, 100.0, 1.0) var energy := 76.0
@export_range(0.0, 100.0, 1.0) var mood := 68.0
@export_range(0.0, 100.0, 1.0) var health := 91.0

const ACTIONS: Array[StringName] = [&"comer", &"cuidar", &"jogar", &"treinar", &"batalhar"]
const SLOT_NAMES: Array[StringName] = [&"Comer", &"Cuidar", &"Jogar", &"Treinar", &"Batalhar"]
const STATUS_NAMES: Array[StringName] = [&"Fome", &"Energia", &"Humor", &"Saude"]
const MENU_GLOW_SHADER: Shader = preload("res://shaders/menu_selection_glow.gdshader")
const MENU_GLOW_DURATION := 0.5

const SUBMENU_DEFINITIONS: Dictionary = {
	&"comer": [
		{"action": &"fruta_estelar", "label": "Fruta Estelar", "icon": "res://assets/UI/submenus/fruta_estelar.png"},
		{"action": &"nectar_cosmico", "label": "Néctar Cósmico", "icon": "res://assets/UI/submenus/nectar_cosmico.png"},
		{"action": &"banquete_nebulosa", "label": "Banquete Nebulosa", "icon": "res://assets/UI/submenus/banquete_nebulosa.png"},
	],
	&"cuidar": [
		{"action": &"dar_remedio", "label": "Dar Remédio", "icon": "res://assets/UI/submenus/dar_remedio.png"},
		{"action": &"limpar_sujeira", "label": "Limpar Sujeira", "icon": "res://assets/UI/submenus/limpar_sujeira.png"},
		{"action": &"dormir", "label": "Dormir", "icon": "res://assets/UI/dormir.png"},
	],
	&"jogar": [
		{"action": &"jokenpo", "label": "Jokenpô", "icon": "res://assets/UI/submenus/jokenpo.png"},
		{"action": &"jogo_da_velha", "label": "Jogo da Velha", "icon": "res://assets/UI/submenus/jogo_da_velha.png"},
		{"action": &"2048", "label": "2048", "icon": "res://assets/UI/submenus/2048.png"},
	],
}

var _slots: Array[TextureButton] = []
var _status_bars: Dictionary = {}
var _status_labels: Dictionary = {}
var _submenu_options: Array[TextureButton] = []
var _submenu_option_labels: Array[Label] = []
var _submenu_title: Label
var _submenu_hint: Label
var _selection_label: Label
var _hint_label: Label
var _needs_summary_label: Label
var _progression_label: Label
var _glow_materials: Array[ShaderMaterial] = []
var _glow_tween: Tween

func _ready() -> void:
	_cache_menu_nodes()
	_connect_menu_buttons()
	_setup_menu_glows()
	_refresh_selection()
	_refresh_status_bars()
	_set_menu_visibility(menu_visible)
	_set_status_visibility(status_visible)
	_set_submenu_visibility(submenu_visible)
	_refresh_submenu()

func _cache_menu_nodes() -> void:
	_slots.clear()
	_status_bars.clear()
	_status_labels.clear()
	_submenu_options.clear()
	_submenu_option_labels.clear()
	for slot_name in SLOT_NAMES:
		var slot := get_node_or_null(NodePath("ActionBar/ActionMenu/" + String(slot_name))) as TextureButton
		if slot != null:
			_slots.append(slot)
	for status_name in STATUS_NAMES:
		var bar := get_node_or_null(NodePath("StatusBar/StatusItems/" + String(status_name) + "/Bar")) as ProgressBar
		if bar != null:
			_status_bars[status_name] = bar
		var status_label := get_node_or_null(NodePath("StatusBar/StatusItems/" + String(status_name) + "/Label")) as Label
		if status_label != null:
			_status_labels[status_name] = status_label
	for index in 3:
		var option := get_node_or_null(NodePath("SubmenuOverlay/Panel/Margin/Content/Options/Option%d/Icon" % (index + 1))) as TextureButton
		var option_label := get_node_or_null(NodePath("SubmenuOverlay/Panel/Margin/Content/Options/Option%d/Label" % (index + 1))) as Label
		if option != null:
			_submenu_options.append(option)
		if option_label != null:
			_submenu_option_labels.append(option_label)
	_selection_label = get_node_or_null(^"SelectedAction") as Label
	_hint_label = get_node_or_null(^"StatusBar/Hint") as Label
	_needs_summary_label = get_node_or_null(^"StatusBar/NeedsSummary") as Label
	_progression_label = get_node_or_null(^"ProgressionFeedback") as Label
	_submenu_title = get_node_or_null(^"SubmenuOverlay/Panel/Margin/Content/Title") as Label
	_submenu_hint = get_node_or_null(^"SubmenuOverlay/Panel/Margin/Content/Hint") as Label

func _setup_menu_glows() -> void:
	_glow_materials.clear()
	for slot in _slots:
		var material := ShaderMaterial.new()
		material.shader = MENU_GLOW_SHADER
		material.set_shader_parameter("glow_strength", 0.0)
		slot.material = material
		_glow_materials.append(material)

func _connect_menu_buttons() -> void:
	for index in _slots.size():
		var slot := _slots[index]
		if not slot.pressed.is_connected(_on_menu_slot_pressed):
			slot.pressed.connect(_on_menu_slot_pressed.bind(index))
	for index in _submenu_options.size():
		var option := _submenu_options[index]
		if not option.pressed.is_connected(_on_submenu_option_pressed):
			option.pressed.connect(_on_submenu_option_pressed.bind(index))

func _on_menu_slot_pressed(index: int) -> void:
	selected_index = clampi(index, 0, ACTIONS.size() - 1)
	confirm_selected()

func _on_submenu_option_pressed(index: int) -> void:
	submenu_selected_index = index
	confirm_selected()

## Move a seleção no menu principal ou no submenu aberto.
func move_selection(direction: Vector2i) -> void:
	if submenu_visible:
		_move_submenu_selection(direction)
		return
	if ACTIONS.is_empty():
		return
	var step := 1 if direction.x > 0 or direction.y > 0 else -1
	selected_index = wrapi(selected_index + step, 0, ACTIONS.size())
	_refresh_selection()

func confirm_selected() -> void:
	if submenu_visible:
		_confirm_submenu_selected()
		return
	if ACTIONS.is_empty():
		return
	var action := ACTIONS[selected_index]
	if SUBMENU_DEFINITIONS.has(action):
		open_submenu(action)
		return
	action_requested.emit(action)
	if _hint_label != null:
		_hint_label.text = "AÇÃO: " + String(action).to_upper()

func open_submenu(category: StringName) -> void:
	if not SUBMENU_DEFINITIONS.has(category):
		return
	active_category = category
	submenu_selected_index = 0
	_set_submenu_visibility(true)
	_refresh_submenu()
	if not _submenu_options.is_empty():
		_submenu_options[0].grab_focus()

func close_submenu() -> void:
	if not submenu_visible:
		return
	_set_submenu_visibility(false)
	active_category = &""
	submenu_selected_index = 0
	_refresh_selection()

func _move_submenu_selection(direction: Vector2i) -> void:
	var entries: Array = SUBMENU_DEFINITIONS.get(active_category, [])
	if entries.is_empty():
		return
	var step := 1 if direction.x > 0 or direction.y > 0 else -1
	submenu_selected_index = wrapi(submenu_selected_index + step, 0, entries.size())
	_refresh_submenu()

func _confirm_submenu_selected() -> void:
	var entries: Array = SUBMENU_DEFINITIONS.get(active_category, [])
	if entries.is_empty():
		return
	var index := clampi(submenu_selected_index, 0, entries.size() - 1)
	var action: StringName = entries[index]["action"]
	var category := active_category
	close_submenu()
	action_requested.emit(action)
	if _hint_label != null:
		_hint_label.text = String(entries[index]["label"]).to_upper()
	submenu_visibility_changed.emit(false, category)

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

func set_needs_summary(snapshot: Dictionary) -> void:
	if _needs_summary_label == null:
		return
	var hygiene_value := roundi(float(snapshot.get("hygiene", 0.0)))
	var discipline_value := roundi(float(snapshot.get("discipline", 0.0)))
	var weight_value := roundi(float(snapshot.get("weight", 0.0)))
	var illness := "  •  DOENTE" if bool(snapshot.get("is_sick", false)) else ""
	var sleeping := "  •  DORMINDO" if bool(snapshot.get("is_sleeping", false)) else ""
	_needs_summary_label.text = "HIGIENE %d%%  •  DISCIPLINA %d%%  •  PESO %d%s%s" % [hygiene_value, discipline_value, weight_value, illness, sleeping]

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

func show_progression_message(message: String) -> void:
	if _progression_label == null:
		return
	_progression_label.text = message
	_progression_label.visible = true
	if not Engine.is_editor_hint() and is_inside_tree():
		get_tree().create_timer(2.5).timeout.connect(_hide_progression_message)

func _hide_progression_message() -> void:
	if _progression_label != null:
		_progression_label.visible = false

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
	_pulse_selected_glow()
	selection_changed.emit(ACTIONS[selected_index])

func _pulse_selected_glow() -> void:
	if _glow_tween != null:
		_glow_tween.kill()
	for material in _glow_materials:
		material.set_shader_parameter("glow_strength", 0.0)
	if selected_index < 0 or selected_index >= _glow_materials.size():
		return
	var selected_material := _glow_materials[selected_index]
	_glow_tween = create_tween()
	_glow_tween.set_trans(Tween.TRANS_SINE)
	_glow_tween.set_ease(Tween.EASE_OUT)
	_glow_tween.tween_method(_set_glow_strength.bind(selected_material), 0.0, 1.0, 0.12)
	_glow_tween.tween_method(_set_glow_strength.bind(selected_material), 1.0, 0.0, MENU_GLOW_DURATION - 0.12)

func _set_glow_strength(strength: float, material: ShaderMaterial) -> void:
	material.set_shader_parameter("glow_strength", strength)

func _refresh_submenu() -> void:
	var entries: Array = SUBMENU_DEFINITIONS.get(active_category, [])
	if _submenu_title != null:
		_submenu_title.text = String(active_category).to_upper() if not active_category.is_empty() else "SUBMENU"
	for index in _submenu_options.size():
		var option := _submenu_options[index]
		var label := _submenu_option_labels[index] if index < _submenu_option_labels.size() else null
		var available := index < entries.size()
		option.visible = available
		if label != null:
			label.visible = available
		if not available:
			continue
		var entry: Dictionary = entries[index]
		option.texture_normal = load(String(entry["icon"])) as Texture2D
		option.tooltip_text = String(entry["label"])
		if label != null:
			label.text = String(entry["label"])
		var selected := index == submenu_selected_index
		option.modulate = Color.WHITE if selected else Color(1.0, 1.0, 1.0, 0.58)
		option.scale = Vector2(1.06, 1.06) if selected else Vector2.ONE
	if _submenu_hint != null:
		if entries.is_empty():
			_submenu_hint.text = "SEM OPÇÕES DISPONÍVEIS"
		else:
			_submenu_hint.text = "D-PAD: escolher   •   VERDE: confirmar   •   ROSA: voltar"

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

func _set_submenu_visibility(value: bool) -> void:
	submenu_visible = value
	var overlay := get_node_or_null(^"SubmenuOverlay") as Control
	if overlay != null:
		overlay.visible = value
	submenu_visibility_changed.emit(value, active_category)
