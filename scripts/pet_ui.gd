@tool
class_name PetUI
extends Control

## UI do pet com menu principal de cinco categorias e submenus contextuais.
## O estado das ações continua sendo encaminhado pelo ConsoleController.

signal action_requested(action: StringName)
signal selection_changed(action: StringName)
signal status_visibility_changed(visible: bool)
signal menu_visibility_changed(visible: bool)
signal submenu_visibility_changed(visible: bool, category: StringName)

@export_category("Menu principal")
@export var menu_visible := true
@export_range(0, 4, 1) var selected_index := 0

@export_category("Submenu")
@export var submenu_visible := false
@export var active_category: StringName = &""
@export_range(0, 2, 1) var submenu_selected_index := 0

@export_category("Status")
@export var status_visible := false
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
		{"action": &"sala_treinos", "label": "Sala de Treinos", "icon": "res://assets/UI/submenus/sala_de_treinos.png"},
		{"action": &"explorar_deepworld", "label": "Explorar Deepworld", "icon": "res://assets/UI/submenus/explorar_deepworld.png"},
		{"action": &"aventura_eva", "label": "Aventura com EVA", "icon": "res://assets/UI/submenus/jornada_eva.png"},
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
var _poop_count := 0
var _special_need_indicator: Control
var _special_need_icon: Label
var _special_need_wish_icon: Label
var _sleep_indicator: Label
var _system_message_tween: Tween
var _pet_message_tween: Tween
var _system_message_token := 0
var _pet_message_token := 0
var _sleeping := false
var _special_need_active := false
var _attention_active := false
var _attention_reason: StringName = &""
var _glow_materials: Array[ShaderMaterial] = []
var _glow_tween: Tween
var _selected_bob_tween: Tween
var _selected_bob_slot: Control
var _selected_bob_base_y := 0.0
var _selection_frame: Panel
var _pet_skills: PetSkills
var _world_progression: AuroraPetSave
var _status_page: Panel
var _status_page_title: Label
var _status_page_identity: Label
var _status_page_body: Label
var _status_page_stats: Label
var _status_page_level: Label
var _status_page_weight: Label
var _identity_snapshot: Dictionary = {}
var _needs_snapshot: Dictionary = {}
var _status_page_bars: Array[ProgressBar] = []
var _status_page_progress: Label

func _ready() -> void:
	_cache_menu_nodes()
	_connect_menu_buttons()
	_setup_menu_glows()
	_refresh_selection()
	call_deferred("_update_selection_frame")
	_refresh_status_bars()
	_create_status_page()
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
	_refresh_status_page()

func set_identity_snapshot(identity: Dictionary) -> void:
	_identity_snapshot = identity.duplicate(true)
	if _status_page_identity == null:
		return
	_status_page_identity.text = "NOME: %s\nCÓDIGO: %s\nFACÇÃO: %s  •  LINHAGEM: %s  •  ELEMENTO: %s" % [str(identity.get("name", "—")).to_upper(), str(identity.get("access_code", "—")), str(identity.get("faction_label", "—")).to_upper(), str(identity.get("lineage_label", "—")).to_upper(), str(identity.get("element", "—")).to_upper()]
	_refresh_status_page()

func set_world_progression(world: AuroraPetSave) -> void:
	_world_progression = world
	refresh_progression_locks()

func refresh_progression_locks() -> void:
	_refresh_selection()
	_refresh_submenu()

func _is_category_unlocked(action: StringName) -> bool:
	return _pet_skills == null or _pet_skills.is_category_unlocked(action)

func _is_action_unlocked(action: StringName) -> bool:
	if action == &"aventura_eva":
		return _world_progression == null or _world_progression.eva_adventure_unlocked
	return _pet_skills == null or _pet_skills.is_action_unlocked(action)

func _unlock_message(action: StringName) -> String:
	if action == &"aventura_eva" and _world_progression != null and not _world_progression.eva_adventure_unlocked:
		return "ENCONTRE EVA E ACEITE AJUDÁ-LA"
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

## Restaura o submenu de origem depois de uma tela modal, sem reaplicar
## bloqueios de progressão a uma opção que já estava acessível ao jogador.
func restore_submenu(category: StringName) -> void:
	if not SUBMENU_DEFINITIONS.has(category):
		return
	menu_visible = true
	active_category = category
	submenu_selected_index = 0
	_set_menu_visibility(true)
	_set_submenu_visibility(true)
	_refresh_submenu()
	if not _submenu_options.is_empty():
		_submenu_options[0].grab_focus()

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

func toggle_menu() -> void:
	menu_visible = not menu_visible
	_set_menu_visibility(menu_visible)

func set_menu_visibility(value: bool) -> void:
	menu_visible = value
	_set_menu_visibility(value)

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
	_needs_snapshot = snapshot.duplicate(true)
	if _needs_summary_label == null:
		return
	var hygiene_value := roundi(float(snapshot.get("hygiene", 0.0)))
	var discipline_value := roundi(float(snapshot.get("discipline", 0.0)))
	var obedience_value := roundi(float(snapshot.get("obedience", 0.0)))
	var audacity_value := roundi(float(snapshot.get("audacity", 0.0)))
	var weight_value := roundi(float(snapshot.get("weight", 0.0)))
	var illness := "  •  DOENTE" if bool(snapshot.get("is_sick", false)) else ""
	var sleeping := "  •  DORMINDO" if bool(snapshot.get("is_sleeping", false)) else ""
	_needs_summary_label.text = "HIGIENE %d%%  •  DISCIPLINA %d%%  •  PESO %d\nOBEDIÊNCIA %d%%  •  OUSADIA %d%%%s%s" % [hygiene_value, discipline_value, weight_value, obedience_value, audacity_value, illness, sleeping]
	_refresh_status_page()

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
	_refresh_status_page()

func set_status_values(new_hunger: float, new_energy: float, new_mood: float, new_health: float) -> void:
	hunger = clampf(new_hunger, 0.0, 100.0)
	energy = clampf(new_energy, 0.0, 100.0)
	mood = clampf(new_mood, 0.0, 100.0)
	health = clampf(new_health, 0.0, 100.0)
	_refresh_status_bars()
	_refresh_status_page()

func show_progression_message(message: String) -> void:
	show_system_message(message)

func show_system_message(message: String) -> void:
	if _system_message_panel == null or _system_message_label == null:
		return
	_system_message_token += 1
	var token := _system_message_token
	_system_message_label.text = message
	_system_message_panel.visible = true
	if _system_message_tween != null:
		_system_message_tween.kill()
	_system_message_tween = create_tween()
	_system_message_panel.modulate.a = 0.0
	_system_message_tween.tween_property(_system_message_panel, "modulate:a", 1.0, 0.18)
	if not Engine.is_editor_hint() and is_inside_tree():
		get_tree().create_timer(3.2).timeout.connect(func() -> void:
			if token == _system_message_token:
				_hide_system_message())

func show_pet_message(message: String) -> void:
	if _pet_message_bubble == null or _pet_message_label == null:
		return
	_pet_message_token += 1
	var token := _pet_message_token
	_pet_message_label.text = message
	_pet_message_bubble.visible = true
	if _pet_message_tween != null:
		_pet_message_tween.kill()
	_pet_message_tween = create_tween()
	_pet_message_bubble.modulate.a = 0.0
	_pet_message_tween.tween_property(_pet_message_bubble, "modulate:a", 1.0, 0.16)
	if not Engine.is_editor_hint() and is_inside_tree():
		get_tree().create_timer(2.6).timeout.connect(func() -> void:
			if token == _pet_message_token:
				_hide_pet_message())

func get_pet_reaction_message(reaction_id: StringName) -> String:
	match reaction_id:
		&"comer", &"fruta_estelar", &"nectar_cosmico", &"banquete_nebulosa": return "NHAM! ISSO ESTAVA BOM!"
		&"brincar", &"jokenpo", &"jogo_da_velha", &"2048": return "QUE LEGAL!"
		&"limpar", &"limpar_sujeira": return "AHH... MELHOROU!"
		&"remedio", &"dar_remedio": return "VOU FICAR BEM!"
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
	set_poop_count(maxi(1, _poop_count) if value else 0)

func set_poop_count(value: int) -> void:
	_poop_count = clampi(value, 0, 6)
	if _poop_marker == null:
		return
	_poop_marker.visible = _poop_count > 0
	for index in _poop_marker.get_child_count():
		var icon := _poop_marker.get_child(index) as CanvasItem
		if icon != null:
			icon.visible = index < _poop_count

func set_special_need(need: StringName, wish: StringName, active: bool) -> void:
	_special_need_active = active
	if _special_need_icon != null:
		_special_need_icon.text = "!"
	if _special_need_wish_icon != null:
		if active:
			_special_need_wish_icon.text = "✦" if wish == &"jogo_da_velha" else "▲"
		else:
			_special_need_wish_icon.text = _attention_short_label(_attention_reason) if _attention_active else ""
	_refresh_special_need_visibility()

func set_attention_need(reason: StringName, active: bool) -> void:
	_attention_active = active
	_attention_reason = reason if active else &""
	if _special_need_icon != null:
		_special_need_icon.text = "!"
	if _special_need_wish_icon != null and not _special_need_active:
		_special_need_wish_icon.text = _attention_short_label(reason) if active else ""
	_refresh_special_need_visibility()
	_refresh_selection()

func _attention_short_label(reason: StringName) -> String:
	match reason:
		&"fome": return "FO"
		&"sono": return "EN"
		&"humor": return "HU"
		&"saude", &"doenca": return "SA"
		&"higiene": return "HI"
	return "!"

func _refresh_special_need_visibility() -> void:
	if _special_need_indicator != null:
		_special_need_indicator.visible = (_special_need_active or _attention_active) and not submenu_visible

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
			if _attention_active and action == _attention_menu_category(_attention_reason):
				label.text += "  !"
		if _selection_label != null:
			var selected_action := ACTIONS[selected_index]
			_selection_label.text = String(selected_action).to_upper() if _is_category_unlocked(selected_action) else _unlock_message(selected_action)
	_update_selection_frame()
	_start_selected_bob()
	_pulse_selected_glow()
	selection_changed.emit(ACTIONS[selected_index])

func _attention_menu_category(reason: StringName) -> StringName:
	match reason:
		&"fome": return &"comer"
		&"humor": return &"jogar"
		&"sono", &"saude", &"doenca", &"higiene": return &"cuidar"
	return &""

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
	menu_visibility_changed.emit(value)

func _set_status_visibility(value: bool) -> void:
	var status_bar := get_node_or_null(^"StatusBar") as Control
	if status_bar != null:
		status_bar.visible = false
	var action_bar := get_node_or_null(^"ActionBar") as Control
	if action_bar != null:
		action_bar.visible = false if value else menu_visible
	var submenu := get_node_or_null(^"SubmenuOverlay") as Control
	if submenu != null:
		submenu.visible = false if value else submenu_visible
	if _special_need_indicator != null:
		_special_need_indicator.visible = false if value else _special_need_active
	if _status_page != null:
		_status_page.visible = value
	if value:
		_refresh_status_page()

func _create_status_page() -> void:
	if _status_page != null:
		return
	_status_page = Panel.new()
	_status_page.name = "StatusPage"
	_status_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_status_page.z_index = 20
	_status_page.mouse_filter = Control.MOUSE_FILTER_STOP
	_status_page.add_theme_stylebox_override("panel", _make_box(Color("#06142b"), Color("#2dbde5"), 3, 12))
	add_child(_status_page)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 10)
	_status_page.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(column)
	_status_page_title = Label.new()
	_status_page_title.text = "AURIEL — #06L"
	_status_page_title.add_theme_color_override("font_color", Color("#ffffff"))
	_status_page_title.add_theme_font_size_override("font_size", 44)
	column.add_child(_status_page_title)
	_status_page_identity = Label.new()
	_status_page_identity.add_theme_color_override("font_color", Color("#b8c9dc"))
	_status_page_identity.add_theme_font_size_override("font_size", 27)
	column.add_child(_status_page_identity)
	var progression_row := HBoxContainer.new()
	progression_row.add_theme_constant_override("separation", 8)
	column.add_child(progression_row)
	var level_card := _make_status_card("NÍVEL", "1", 175.0)
	_status_page_level = level_card.get_node(^"Content/Value") as Label
	progression_row.add_child(level_card)
	_status_page_progress = Label.new()
	_status_page_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_page_progress.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_page_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_page_progress.custom_minimum_size = Vector2(0, 96)
	_status_page_progress.add_theme_color_override("font_color", Color("#071329"))
	_status_page_progress.add_theme_font_size_override("font_size", 38)
	_status_page_progress.add_theme_stylebox_override("normal", _make_box(Color("#f4f1df"), Color.WHITE, 2, 4))
	progression_row.add_child(_status_page_progress)
	var weight_card := _make_status_card("PESO", "— kg", 210.0, Color("#14254a"))
	_status_page_weight = weight_card.get_node(^"Content/Value") as Label
	progression_row.add_child(weight_card)
	_status_page_stats = Label.new()
	_status_page_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_page_stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_page_stats.custom_minimum_size = Vector2(0, 92)
	_status_page_stats.add_theme_color_override("font_color", Color("#071329"))
	_status_page_stats.add_theme_font_size_override("font_size", 27)
	_status_page_stats.add_theme_stylebox_override("normal", _make_box(Color("#f4f1df"), Color.WHITE, 2, 3))
	column.add_child(_status_page_stats)
	var bars := GridContainer.new()
	bars.columns = 2
	bars.add_theme_constant_override("h_separation", 8)
	bars.add_theme_constant_override("v_separation", 9)
	bars.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(bars)
	var status_colors: Array[Color] = [Color("#ffd166"), Color("#4dd9ff"), Color("#ff78b7"), Color("#69e68a"), Color("#b8794a"), Color("#ff9f43"), Color("#ff4fc3"), Color("#b47cff")]
	_status_page_bars.clear()
	for status_index in 8:
		var status_name: String = ["FOME", "ENERGIA", "HUMOR", "SAÚDE", "HIGIENE", "DISCIPLINA", "OBEDIÊNCIA", "OUSADIA"][status_index]
		var row := Control.new()
		row.custom_minimum_size = Vector2(0, 60)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var bar := ProgressBar.new()
		bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", _make_box(Color("#111b31"), Color("#f4f1df"), 2, 3))
		bar.add_theme_stylebox_override("fill", _make_box(status_colors[status_index], status_colors[status_index], 0, 2))
		row.add_child(bar)
		var overlay := HBoxContainer.new()
		overlay.name = "Overlay"
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 7)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var label := Label.new()
		label.text = status_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_shadow_color", Color("#071329"))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		label.add_theme_font_size_override("font_size", 27)
		overlay.add_child(label)
		var value_label := Label.new()
		value_label.name = "Value"
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		value_label.add_theme_color_override("font_color", Color.WHITE)
		value_label.add_theme_color_override("font_shadow_color", Color("#071329"))
		value_label.add_theme_font_size_override("font_size", 27)
		overlay.add_child(value_label)
		row.add_child(overlay)
		bars.add_child(row)
		_status_page_bars.append(bar)
	_status_page_body = Label.new()
	_status_page_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_page_body.add_theme_color_override("font_color", Color("#ffd166"))
	_status_page_body.add_theme_font_size_override("font_size", 27)
	column.add_child(_status_page_body)
	var hint := Label.new()
	hint.text = "AMARELO: FECHAR STATUS"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("#ffffff"))
	hint.add_theme_font_size_override("font_size", 27)
	column.add_child(hint)
	_status_page.visible = status_visible

func _make_box(background: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	return box

func _make_status_card(caption: String, value: String, minimum_width: float, background := Color("#f4f1df")) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(minimum_width, 96)
	card.add_theme_stylebox_override("panel", _make_box(background, Color.WHITE, 2, 4))
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 0)
	card.add_child(content)
	var text_color := Color("#071329") if background.get_luminance() > 0.5 else Color.WHITE
	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_label.add_theme_color_override("font_color", text_color)
	caption_label.add_theme_font_size_override("font_size", 27)
	content.add_child(caption_label)
	var value_label := Label.new()
	value_label.name = "Value"
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	value_label.add_theme_color_override("font_color", text_color)
	value_label.add_theme_font_size_override("font_size", 38)
	content.add_child(value_label)
	return card

func _refresh_status_page() -> void:
	if _status_page == null:
		return
	_status_page_identity.text = "RAÇA: —  |  FACÇÃO: —  |  ELEMENTO: —"
	if not _identity_snapshot.is_empty():
		_status_page_title.text = "%s — #%s" % [str(_identity_snapshot.get("name", "AURIEL")).to_upper(), str(_identity_snapshot.get("access_code", "06L")).to_upper()]
		_status_page_identity.text = "RAÇA: %s  |  FACÇÃO: %s  |  ELEMENTO: %s" % [str(_identity_snapshot.get("lineage_label", "—")).to_upper(), str(_identity_snapshot.get("faction_label", "—")).to_upper(), str(_identity_snapshot.get("element", "—")).to_upper()]
	if not _needs_snapshot.is_empty():
		_status_page_body.text = "%s%s" % ["DOENTE   " if bool(_needs_snapshot.get("is_sick", false)) else "", "DORMINDO" if bool(_needs_snapshot.get("is_sleeping", false)) else ""]
	if _status_page_stats != null and _pet_skills != null:
		var physical_multiplier := float(_needs_snapshot.get("physical_multiplier", 1.0))
		var mental_multiplier := float(_needs_snapshot.get("mental_multiplier", 1.0))
		_status_page_stats.text = "FOR %d%s   DEF %d%s   AGI %d%s   INT %d%s" % [roundi(_pet_skills.strength * physical_multiplier), _modifier_marker(physical_multiplier), roundi(_pet_skills.defense * physical_multiplier), _modifier_marker(physical_multiplier), roundi(_pet_skills.agility * mental_multiplier), _modifier_marker(mental_multiplier), roundi(_pet_skills.intelligence * mental_multiplier), _modifier_marker(mental_multiplier)]
	var values: Array[float] = [hunger, energy, mood, health, float(_needs_snapshot.get("hygiene", 0.0)), float(_needs_snapshot.get("discipline", 0.0)), float(_needs_snapshot.get("obedience", 0.0)), float(_needs_snapshot.get("audacity", 0.0))]
	for index in mini(values.size(), _status_page_bars.size()):
		_status_page_bars[index].value = values[index]
		var value_label := _status_page_bars[index].get_parent().get_node_or_null(^"Overlay/Value") as Label
		if value_label != null:
			value_label.text = "%d%%" % roundi(values[index])
	if _status_page_progress != null and _pet_skills != null:
		_status_page_progress.text = "XP  %04d" % _pet_skills.total_xp
		if _status_page_level != null:
			_status_page_level.text = str(_pet_skills.level)
		if _status_page_weight != null:
			_status_page_weight.text = "%.1f kg" % float(_needs_snapshot.get("weight", 0.0))

func _modifier_marker(multiplier: float) -> String:
	if multiplier > 1.01:
		return "↑"
	if multiplier < 0.99:
		return "↓"
	return ""

func _set_submenu_visibility(value: bool) -> void:
	submenu_visible = value
	var overlay := get_node_or_null(^"SubmenuOverlay") as Control
	if overlay != null:
		overlay.visible = value
	_refresh_special_need_visibility()
	submenu_visibility_changed.emit(value, active_category)
