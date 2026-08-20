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
		{"action": &"jogo_da_velha", "label": "Jogo da Velha", "icon": "res://assets/UI/submenus/jogo_da_velha.png"},
		{"action": &"jokenpo", "label": "Jokenpô", "icon": "res://assets/UI/submenus/jokenpo.png"},
		{"action": &"2048", "label": "2048", "icon": "res://assets/UI/submenus/2048.png"},
	],
	&"batalhar": [
		{"action": &"batalha_exploracao", "label": "Batalha de Exploração", "icon": "res://assets/UI/batalhar.png"},
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
var _system_message_panel: Panel
var _system_message_label: Label
var _pet_message_bubble: Panel
var _pet_message_label: Label
var _poop_marker: Control
var _special_need_indicator: Control
var _special_need_icon: Label
var _special_need_wish_icon: Label
var _sleep_indicator: Label
var _message_tween: Tween
var _sleeping := false
var _glow_materials: Array[ShaderMaterial] = []
var _glow_tween: Tween
var _selected_bob_tween: Tween
var _selected_bob_slot: Control
var _selected_bob_base_y := 0.0
var _selection_frame: Panel
var _pet_skills: PetSkills

func _ready() -> void:
	_cache_menu_nodes()
	_connect_menu_buttons()
	_setup_menu_glows()
	_refresh_selection()
	call_deferred("_update_selection_frame")
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
	_selection_frame = get_node_or_null(^"ActionBar/ActionMenu/Comer/SelectionFrame") as Panel
	_hint_label = get_node_or_null(^"StatusBar/Hint") as Label
	_needs_summary_label = get_node_or_null(^"StatusBar/NeedsSummary") as Label
	_progression_label = get_node_or_null(^"ProgressionFeedback") as Label
	_system_message_panel = get_node_or_null(^"SystemMessagePanel") as Panel
	_system_message_label = get_node_or_null(^"SystemMessagePanel/Label") as Label
	_pet_message_bubble = get_node_or_null(^"PetMessageBubble") as Panel
	_pet_message_label = get_node_or_null(^"PetMessageBubble/Label") as Label
	_poop_marker = get_node_or_null(^"PoopMarker") as Control
	_special_need_indicator = get_node_or_null(^"SpecialNeedIndicator") as Control
	_special_need_icon = get_node_or_null(^"SpecialNeedIndicator/NeedIcon") as Label
	_special_need_wish_icon = get_node_or_null(^"SpecialNeedIndicator/WishIcon") as Label
	_sleep_indicator = get_node_or_null(^"SleepIndicator") as Label
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

func set_progression_source(skills: PetSkills) -> void:
	_pet_skills = skills
	refresh_progression_locks()

func refresh_progression_locks() -> void:
	_refresh_selection()
	_refresh_submenu()

func _is_category_unlocked(action: StringName) -> bool:
	return _pet_skills == null or _pet_skills.is_category_unlocked(action)

func _is_action_unlocked(action: StringName) -> bool:
	return _pet_skills == null or _pet_skills.is_action_unlocked(action)

func _unlock_message(action: StringName) -> String:
	if _pet_skills == null:
		return "CONTEÚDO DISPONÍVEL"
	return _pet_skills.get_unlock_message(action)

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
	if not _is_category_unlocked(action):
		show_progression_message(_unlock_message(action))
		return
	if SUBMENU_DEFINITIONS.has(action):
		open_submenu(action)
		return
	action_requested.emit(action)
	if _hint_label != null:
		_hint_label.text = "AÇÃO: " + String(action).to_upper()

func open_submenu(category: StringName) -> void:
	if not _is_category_unlocked(category):
		show_progression_message(_unlock_message(category))
		return
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
	if not _is_action_unlocked(action):
		show_progression_message(_unlock_message(action))
		_refresh_submenu()
		return
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
	show_system_message(message)

func show_system_message(message: String) -> void:
	if _system_message_panel == null or _system_message_label == null:
		return
	_system_message_label.text = message
	_system_message_panel.visible = true
	if _message_tween != null:
		_message_tween.kill()
	_message_tween = create_tween()
	_system_message_panel.modulate.a = 0.0
	_message_tween.tween_property(_system_message_panel, "modulate:a", 1.0, 0.18)
	if not Engine.is_editor_hint() and is_inside_tree():
		get_tree().create_timer(3.2).timeout.connect(_hide_system_message)

func show_pet_message(message: String) -> void:
	if _pet_message_bubble == null or _pet_message_label == null:
		return
	_pet_message_label.text = message
	_pet_message_bubble.visible = true
	_pet_message_bubble.modulate.a = 0.0
	if _message_tween != null:
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_property(_pet_message_bubble, "modulate:a", 1.0, 0.16)
	if not Engine.is_editor_hint() and is_inside_tree():
		get_tree().create_timer(2.6).timeout.connect(_hide_pet_message)

func get_pet_reaction_message(reaction_id: StringName) -> String:
	match reaction_id:
		&"comer": return "NHAM! ISSO ESTAVA BOM!"
		&"brincar": return "QUE LEGAL!"
		&"limpar": return "AHH... MELHOROU!"
		&"remedio": return "VOU FICAR BEM!"
		&"treinar": return "VOU TENTAR MAIS!"
		&"dormir": return "Zzz..."
	return "..."

func get_special_need_message(need: StringName, wish: StringName) -> String:
	if need == &"brincar":
		return "QUERO BRINCAR DE JOGO DA VELHA!"
	if need == &"treinar":
		return "QUERO TREINAR FORÇA!"
	return "ESTOU QUERENDO ALGO..."

func set_poop_visible(value: bool) -> void:
	if _poop_marker != null:
		_poop_marker.visible = value

func set_special_need(need: StringName, wish: StringName, active: bool) -> void:
	if _special_need_indicator == null:
		return
	_special_need_indicator.visible = active
	if not active:
		return
	if _special_need_icon != null:
		_special_need_icon.text = "!"
	if _special_need_wish_icon != null:
		_special_need_wish_icon.text = "✦" if wish == &"jogo_da_velha" else "▲"

func set_sleeping(value: bool) -> void:
	_sleeping = value
	var action_bar := get_node_or_null(^"ActionBar") as Control
	if action_bar != null:
		action_bar.modulate = Color(0.48, 0.56, 0.72, 0.62) if value else Color.WHITE
		action_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE if value else Control.MOUSE_FILTER_PASS
	if value:
		close_submenu()
	if _sleep_indicator != null:
		_sleep_indicator.visible = value
	if _selection_label != null and value:
		_selection_label.text = "DORMINDO • ENERGIA RECUPERANDO"

func _hide_system_message() -> void:
	if _system_message_panel != null:
		_system_message_panel.visible = false

func _hide_pet_message() -> void:
	if _pet_message_bubble != null:
		_pet_message_bubble.visible = false

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
		var action := ACTIONS[index]
		var is_selected := index == selected_index
		var unlocked := _is_category_unlocked(action)
		if not unlocked:
			slot.modulate = Color(0.42, 0.48, 0.62, 0.46 if not is_selected else 0.7)
		else:
			slot.modulate = Color(1.0, 1.0, 1.0, 1.0 if is_selected else 0.62)
		slot.scale = Vector2(1.04, 1.04) if is_selected and unlocked else Vector2.ONE
		var label := slot.get_node_or_null(^"Label") as Label
		if label != null:
			label.text = String(action).to_upper() if unlocked else String(action).to_upper() + "\nNÍVEL " + str(_pet_skills.get_unlock_level(action) if _pet_skills != null else 1)
		if _selection_label != null:
			var selected_action := ACTIONS[selected_index]
			_selection_label.text = String(selected_action).to_upper() if _is_category_unlocked(selected_action) else _unlock_message(selected_action)
	_update_selection_frame()
	_start_selected_bob()
	_pulse_selected_glow()
	selection_changed.emit(ACTIONS[selected_index])

func _update_selection_frame() -> void:
	if _selection_frame == null or _slots.is_empty():
		return
	var selected_slot := _slots[clampi(selected_index, 0, _slots.size() - 1)]
	if _selection_frame.get_parent() != selected_slot:
		_selection_frame.reparent(selected_slot, false)
	_selection_frame.position = Vector2(6.0, 4.0)
	_selection_frame.size = selected_slot.size - Vector2(12.0, 8.0)
	_selection_frame.visible = true

func _start_selected_bob() -> void:
	if _selected_bob_tween != null:
		_selected_bob_tween.kill()
	if _selected_bob_slot != null and is_instance_valid(_selected_bob_slot):
		_selected_bob_slot.position.y = _selected_bob_base_y
	_selected_bob_slot = null
	if selected_index < 0 or selected_index >= _slots.size():
		return
	if not _is_category_unlocked(ACTIONS[selected_index]):
		return
	_selected_bob_slot = _slots[selected_index]
	_selected_bob_base_y = _selected_bob_slot.position.y
	_selected_bob_tween = create_tween()
	_selected_bob_tween.set_loops()
	_selected_bob_tween.set_trans(Tween.TRANS_SINE)
	_selected_bob_tween.set_ease(Tween.EASE_IN_OUT)
	_selected_bob_tween.tween_property(_selected_bob_slot, "position:y", _selected_bob_base_y - 5.0, 0.72)
	_selected_bob_tween.tween_property(_selected_bob_slot, "position:y", _selected_bob_base_y, 0.72)

func _pulse_selected_glow() -> void:
	if _glow_tween != null:
		_glow_tween.kill()
	for material in _glow_materials:
		material.set_shader_parameter("glow_strength", 0.0)
	if selected_index < 0 or selected_index >= _glow_materials.size() or not _is_category_unlocked(ACTIONS[selected_index]):
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
		var action: StringName = entry["action"]
		var unlocked := _is_action_unlocked(action)
		option.texture_normal = load(String(entry["icon"])) as Texture2D
		option.tooltip_text = String(entry["label"])
		if label != null:
			label.text = String(entry["label"]) if unlocked else String(entry["label"]) + "\nNÍVEL " + str(_pet_skills.get_unlock_level(action) if _pet_skills != null else 1)
		var selected := index == submenu_selected_index
		option.modulate = Color.WHITE if selected and unlocked else Color(0.42, 0.48, 0.62, 0.55 if not selected else 0.72) if not unlocked else Color(1.0, 1.0, 1.0, 0.58)
		option.scale = Vector2(1.06, 1.06) if selected and unlocked else Vector2.ONE
	if _submenu_hint != null:
		if entries.is_empty():
			_submenu_hint.text = "SEM OPÇÕES DISPONÍVEIS"
		else:
			var selected_entry: Dictionary = entries[clampi(submenu_selected_index, 0, entries.size() - 1)]
			var selected_action: StringName = selected_entry["action"]
			_submenu_hint.text = "D-PAD: escolher   •   VERDE: confirmar   •   ROSA: voltar" if _is_action_unlocked(selected_action) else _unlock_message(selected_action)

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
