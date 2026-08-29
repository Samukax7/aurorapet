extends Control
class_name AuroraPetMobileTouchControls

const SWIPE_MIN_DISTANCE := 54.0

var controller: Node
var _buttons: Dictionary = {}
var _base_style: StyleBoxFlat
var _accent_styles: Dictionary = {}
var _touch_start := Vector2.ZERO
var _tracking_touch := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_styles()
	_build_controls()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()
	set_process(true)

func set_controller(value: Node) -> void:
	controller = value
	_refresh_context()

func _process(_delta: float) -> void:
	_refresh_context()

func _build_styles() -> void:
	_base_style = StyleBoxFlat.new()
	_base_style.bg_color = Color(0.025, 0.075, 0.16, 0.88)
	_base_style.set_border_width_all(2)
	_base_style.border_color = Color(0.35, 0.85, 1.0, 0.88)
	_base_style.set_corner_radius_all(14)
	_base_style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	_base_style.shadow_size = 6
	for key in [&"status", &"room", &"back", &"confirm"]:
		var style := _base_style.duplicate() as StyleBoxFlat
		style.bg_color = {
			&"status": Color(0.88, 0.20, 0.46, 0.92),
			&"room": Color(0.35, 0.20, 0.62, 0.92),
			&"back": Color(0.08, 0.16, 0.30, 0.92),
			&"confirm": Color(0.12, 0.65, 0.32, 0.92),
		}[key]
		style.border_color = Color(1, 1, 1, 0.90)
		_accent_styles[key] = style

func _make_icon_button(key: StringName, glyph: String, tooltip: String) -> Button:
	var button := Button.new()
	button.name = String(key).capitalize()
	button.text = glyph
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _base_style)
	button.add_theme_stylebox_override("hover", _accent_styles[key])
	button.add_theme_stylebox_override("pressed", _accent_styles[key])
	button.pressed.connect(_on_icon_pressed.bind(key))
	add_child(button)
	_buttons[key] = button
	return button

func _build_controls() -> void:
	_make_icon_button(&"status", "♥", "Status")
	_make_icon_button(&"room", "⌂", "Quarto Cósmico")
	_make_icon_button(&"back", "←", "Voltar")
	_make_icon_button(&"confirm", "✓", "Confirmar")

func _on_viewport_size_changed() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or _buttons.is_empty():
		return
	position = Vector2.ZERO
	size = viewport_size
	var safe_margin := clampf(minf(viewport_size.x, viewport_size.y) * 0.035, 14.0, 28.0)
	var icon_size := clampf(minf(viewport_size.x, viewport_size.y) * 0.105, 52.0, 76.0)
	var button_size := Vector2(icon_size, icon_size)
	_buttons[&"status"].position = Vector2(viewport_size.x - icon_size - safe_margin, safe_margin)
	_buttons[&"room"].position = Vector2(safe_margin, (viewport_size.y - icon_size) * 0.5)
	_buttons[&"back"].position = Vector2(safe_margin, safe_margin)
	_buttons[&"confirm"].position = Vector2(viewport_size.x - icon_size - safe_margin, viewport_size.y - icon_size - safe_margin)
	for button in _buttons.values():
		(button as Button).size = button_size

func _refresh_context() -> void:
	if controller == null or not is_instance_valid(controller) or not controller.has_method("get_mobile_ui_state"):
		return
	var state: Dictionary = controller.call("get_mobile_ui_state")
	_buttons[&"status"].visible = bool(state.get("show_status", false))
	_buttons[&"room"].visible = bool(state.get("show_room", false))
	_buttons[&"back"].visible = bool(state.get("show_back", false))
	_buttons[&"confirm"].visible = bool(state.get("show_confirm", false))

func _on_icon_pressed(action: StringName) -> void:
	if controller == null or not is_instance_valid(controller):
		return
	match action:
		&"status": controller.call("mobile_toggle_status")
		&"room": controller.call("mobile_open_quarto")
		&"back": controller.call("mobile_back")
		&"confirm": controller.call("mobile_confirm")

func _input(event: InputEvent) -> void:
	if controller == null or not is_instance_valid(controller):
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_start = touch.position
			_tracking_touch = true
		elif _tracking_touch:
			_tracking_touch = false
			_handle_swipe(touch.position - _touch_start)

func _handle_swipe(delta: Vector2) -> void:
	if delta.length() < SWIPE_MIN_DISTANCE or not controller.has_method("get_mobile_ui_state"):
		return
	var state: Dictionary = controller.call("get_mobile_ui_state")
	if not bool(state.get("allow_swipe_navigation", false)):
		return
	var direction := Vector2i.ZERO
	if absf(delta.x) > absf(delta.y):
		direction = Vector2i.RIGHT if delta.x > 0.0 else Vector2i.LEFT
	else:
		direction = Vector2i.DOWN if delta.y > 0.0 else Vector2i.UP
	controller.call("mobile_navigate", direction)
