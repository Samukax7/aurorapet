extends Control

var pet: PetState
var pet_visual: PetVisual
var name_label: Label
var meta_label: Label
var emotion_label: Label
var message_label: Label
var level_label: Label
var progress: ProgressBar
var bars: Dictionary = {}

var palette := {
	"bg": Color("#17152a"),
	"screen": Color("#51e3df"),
	"screen_dark": Color("#1c8fa1"),
	"text": Color("#142d44"),
	"accent": Color("#fff15a"),
	"good": Color("#217b70")
}

func _ready() -> void:
	pet = PetState.new()
	pet.generate_new(20260818)
	pet.pet_changed.connect(_refresh)
	pet.message_emitted.connect(_show_message)
	pet.evolved.connect(_on_evolved)
	_build_ui()
	_refresh()

func _process(delta: float) -> void:
	if pet:
		pet.tick(delta)

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = palette.bg
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var console := ConsoleFrame.new()
	console.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(console)

	# Área jogável posicionada sobre a tela do console.
	var screen := PanelContainer.new()
	screen.position = Vector2(300, 143)
	screen.size = Vector2(360, 178)
	screen.add_theme_stylebox_override("panel", _style(palette.screen, 8))
	add_child(screen)
	var screen_root := VBoxContainer.new()
	screen_root.add_theme_constant_override("separation", 2)
	screen.add_child(screen_root)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 18
	screen_root.add_child(header)
	name_label = _label("AURORAPET", 14, palette.text)
	header.add_child(name_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	level_label = _label("LV 1", 12, palette.text)
	header.add_child(level_label)

	var info := HBoxContainer.new()
	screen_root.add_child(info)
	meta_label = _label("", 9, palette.text)
	info.add_child(meta_label)
	var info_spacer := Control.new()
	info_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(info_spacer)
	emotion_label = _label("", 9, palette.text)
	info.add_child(emotion_label)

	var pet_area := PanelContainer.new()
	pet_area.custom_minimum_size.y = 88
	pet_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pet_area.add_theme_stylebox_override("panel", _style(Color(0.2, 0.85, 0.82, 0.22), 5))
	screen_root.add_child(pet_area)
	pet_visual = PetVisual.new()
	pet_visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pet_area.add_child(pet_visual)

	var stats := GridContainer.new()
	stats.columns = 4
	stats.add_theme_constant_override("h_separation", 4)
	screen_root.add_child(stats)
	for key in ["fome", "energia", "saúde", "felicidade"]:
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(78, 10)
		bar.max_value = 100
		bar.show_percentage = false
		bar.tooltip_text = key
		bar.add_theme_stylebox_override("background", _style(Color("#247c85"), 3))
		bar.add_theme_stylebox_override("fill", _style(palette.good, 3))
		stats.add_child(bar)
		bars[key] = bar

	message_label = _label("", 9, palette.text)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.custom_minimum_size.y = 14
	screen_root.add_child(message_label)

	# Botões grandes sobre os botões físicos do console.
	_add_action("COMER", "feed", Vector2(748, 125), Vector2(58, 38))
	_add_action("BRINCAR", "play", Vector2(812, 125), Vector2(58, 38))
	_add_action("DORMIR", "rest", Vector2(780, 181), Vector2(72, 42))
	_add_action("ELOGIAR", "praise", Vector2(690, 360), Vector2(80, 28))
	_add_action("TREINAR", "train", Vector2(780, 360), Vector2(80, 28))

	var hint := _label("TECLAS: 1 COMER  2 BRINCAR  3 DORMIR  4 ELOGIAR  5 TREINAR", 12, Color("#d8d4eb"))
	hint.position = Vector2(270, 475)
	hint.size = Vector2(420, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)

func _add_action(caption: String, method_name: String, position_value: Vector2, button_size: Vector2) -> void:
	var button := Button.new()
	button.text = caption
	button.position = position_value
	button.size = button_size
	button.add_theme_font_size_override("font_size", 9)
	button.pressed.connect(Callable(pet, method_name))
	add_child(button)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1: pet.feed()
		KEY_2: pet.play()
		KEY_3: pet.rest()
		KEY_4: pet.praise()
		KEY_5: pet.train()
		KEY_ENTER, KEY_SPACE: pet.play()

func _refresh() -> void:
	if not pet_visual: return
	name_label.text = pet.pet_name.to_upper()
	meta_label.text = "%s  %s" % [pet.faction, PetState.STAGES[pet.stage]]
	emotion_label.text = pet.emotion.to_upper()
	level_label.text = "LV %d" % pet.level
	bars["fome"].value = pet.hunger
	bars["energia"].value = pet.energy
	bars["saúde"].value = pet.health
	bars["felicidade"].value = pet.happiness
	pet_visual.set_pet(pet)

func _show_message(text: String) -> void:
	if message_label:
		message_label.text = text

func _on_evolved(stage_name: String) -> void:
	_show_message("EVOLUIU: %s" % stage_name.to_upper())

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _style(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = 5
	box.content_margin_right = 5
	box.content_margin_top = 3
	box.content_margin_bottom = 3
	return box
