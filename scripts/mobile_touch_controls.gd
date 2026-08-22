extends Control
class_name AuroraPetMobileTouchControls

var controller: Node
var _buttons: Dictionary = {}
var _base_style: StyleBoxFlat
var _pressed_styles: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_styles()
	_build_controls()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func set_controller(value: Node) -> void:
	controller = value

func _build_styles() -> void:
	_base_style = StyleBoxFlat.new()
	_base_style.bg_color = Color(0.025, 0.075, 0.16, 0.72)
	_base_style.border_width_left = 2
	_base_style.border_width_top = 2
	_base_style.border_width_right = 2
	_base_style.border_width_bottom = 2
	_base_style.border_color = Color(0.35, 0.85, 1.0, 0.75)
	_base_style.corner_radius_top_left = 14
	_base_style.corner_radius_top_right = 14
	_base_style.corner_radius_bottom_left = 14
	_base_style.corner_radius_bottom_right = 14
	_base_style.shadow_color = Color(0.05, 0.45, 0.8, 0.35)
	_base_style.shadow_size = 4
	for key in [&"green", &"pink", &"yellow"]:
		var style := _base_style.duplicate() as StyleBoxFlat
		style.bg_color = {
			&"green": Color(0.14, 0.72, 0.36, 0.78),
			&"pink": Color(0.86, 0.24, 0.52, 0.78),
			&"yellow": Color(0.88, 0.66, 0.18, 0.78),
		}[key]
		style.border_color = Color(1, 1, 1, 0.85)
		_pressed_styles[key] = style

func _make_button(key: StringName, label: String, action: StringName) -> Button:
	var button := Button.new()
	button.name = String(key).capitalize()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 24 if key in [&"up", &"down", &"left", &"right"] else 16)
	button.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0, 0.96))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _base_style)
	button.add_theme_stylebox_override("hover", _base_style)
	button.add_theme_stylebox_override("pressed", _pressed_styles.get(key, _base_style))
	button.pressed.connect(_on_touch_pressed.bind(action))
	add_child(button)
	_buttons[key] = button
	return button

func _build_controls() -> void:
	_make_button(&"up", "▲", &"up")
	_make_button(&"down", "▼", &"down")
	_make_button(&"left", "◀", &"left")
	_make_button(&"right", "▶", &"right")
	_make_button(&"green", "VERDE", &"green")
	_make_button(&"pink", "ROSA", &"pink")
	_make_button(&"yellow", "AMARELO", &"yellow")

func _on_viewport_size_changed() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or _buttons.is_empty():
		return
	var unit := clampf(minf(viewport_size.x, viewport_size.y) * 0.115, 42.0, 82.0)
	var gap := unit * 0.84
	var dpad_origin := Vector2(unit * 0.55, viewport_size.y - unit * 2.72)
	_buttons[&"up"].position = dpad_origin + Vector2(gap, 0.0)
	_buttons[&"down"].position = dpad_origin + Vector2(gap, gap * 2.0)
	_buttons[&"left"].position = dpad_origin + Vector2(0.0, gap)
	_buttons[&"right"].position = dpad_origin + Vector2(gap * 2.0, gap)
	for key in [&"up", &"down", &"left", &"right"]:
		_buttons[key].size = Vector2(unit, unit)
	var action_width := clampf(viewport_size.x * 0.13, 92.0, 148.0)
	var action_height := clampf(unit * 0.78, 48.0, 68.0)
	var action_gap := clampf(unit * 0.22, 10.0, 18.0)
	var action_x := viewport_size.x - action_width - unit * 0.55
	var action_y := viewport_size.y - action_height * 3.0 - action_gap * 2.0 - unit * 0.35
	_buttons[&"green"].position = Vector2(action_x, action_y)
	_buttons[&"pink"].position = Vector2(action_x, action_y + action_height + action_gap)
	_buttons[&"yellow"].position = Vector2(action_x, action_y + (action_height + action_gap) * 2.0)
	for key in [&"green", &"pink", &"yellow"]:
		_buttons[key].size = Vector2(action_width, action_height)

func _on_touch_pressed(action: StringName) -> void:
	if controller == null or not is_instance_valid(controller):
		return
	match action:
		&"up": controller.call("_move_active_selection", Vector2i.UP)
		&"down": controller.call("_move_active_selection", Vector2i.DOWN)
		&"left": controller.call("_move_active_selection", Vector2i.LEFT)
		&"right": controller.call("_move_active_selection", Vector2i.RIGHT)
		&"green": controller.call("_on_green_pressed")
		&"pink": controller.call("_on_pink_pressed")
		&"yellow": controller.call("_on_yellow_pressed")
