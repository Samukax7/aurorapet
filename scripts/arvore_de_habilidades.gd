@tool
class_name ArvoreDeHabilidades
extends Control

## Tela de treino e árvore de habilidades do AuroraPet.
## O estado real permanece em PetSkills; esta cena apenas apresenta e navega pelos dados.

signal training_requested
signal tree_closed

const SKILL_ORDER: Array[StringName] = [
	&"golpe_fraco",
	&"golpe_forte",
	&"golpe_status",
	&"defesa",
	&"golpe_fraco_avancado",
	&"golpe_forte_avancado",
	&"status_avancado",
	&"defesa_avancada",
]

@export var selected_index := 0

var _pet_skills: PetSkills
var _train_button: Button
var _skill_buttons: Array[Button] = []
var _progress_label: Label
var _detail_label: Label
var _level_label: Label

func _ready() -> void:
	_cache_nodes()
	_connect_skill_buttons()
	_refresh_tree()

func _cache_nodes() -> void:
	_train_button = get_node_or_null(^"Panel/Margin/Content/TrainingOption") as Button
	_progress_label = get_node_or_null(^"Panel/Margin/Content/Progress") as Label
	_detail_label = get_node_or_null(^"Panel/Margin/Content/Detail") as Label
	_level_label = get_node_or_null(^"Panel/Margin/Content/Header/Level") as Label
	_skill_buttons.clear()
	var paths: Array[NodePath] = [
		^"Panel/Margin/Content/SkillColumns/ColumnLeft/GolpeFraco",
		^"Panel/Margin/Content/SkillColumns/ColumnLeft/GolpeForte",
		^"Panel/Margin/Content/SkillColumns/ColumnLeft/GolpeStatus",
		^"Panel/Margin/Content/SkillColumns/ColumnLeft/Defesa",
		^"Panel/Margin/Content/SkillColumns/ColumnRight/GolpeFracoAvancado",
		^"Panel/Margin/Content/SkillColumns/ColumnRight/GolpeForteAvancado",
		^"Panel/Margin/Content/SkillColumns/ColumnRight/StatusAvancado",
		^"Panel/Margin/Content/SkillColumns/ColumnRight/DefesaAvancada",
	]
	for path in paths:
		var button := get_node_or_null(path) as Button
		if button != null:
			_skill_buttons.append(button)

func _connect_skill_buttons() -> void:
	if _train_button != null and not _train_button.pressed.is_connected(_on_training_button_pressed):
		_train_button.pressed.connect(_on_training_button_pressed)
	for index in _skill_buttons.size():
		var button := _skill_buttons[index]
		var selection_index := index + 1
		button.pressed.connect(func():
			selected_index = selection_index
			_refresh_tree()
		)

func set_pet_skills(value: PetSkills) -> void:
	if _pet_skills != null:
		if _pet_skills.skill_tree_changed.is_connected(_on_skill_tree_changed):
			_pet_skills.skill_tree_changed.disconnect(_on_skill_tree_changed)
		if _pet_skills.progression_changed.is_connected(_on_progression_changed):
			_pet_skills.progression_changed.disconnect(_on_progression_changed)
	_pet_skills = value
	if _pet_skills != null:
		_pet_skills.skill_tree_changed.connect(_on_skill_tree_changed)
		_pet_skills.progression_changed.connect(_on_progression_changed)
	_refresh_tree()

func open_tree() -> void:
	visible = true
	selected_index = 0
	_refresh_tree()
	if _train_button != null:
		_train_button.grab_focus()

func close_tree() -> void:
	if not visible:
		return
	visible = false
	tree_closed.emit()

func move_selection(direction: Vector2i) -> void:
	var total_items := SKILL_ORDER.size() + 1
	if total_items <= 0:
		return
	var step := 1 if direction.x > 0 or direction.y > 0 else -1
	selected_index = wrapi(selected_index + step, 0, total_items)
	_refresh_tree()

func confirm_selected() -> void:
	if selected_index == 0:
		_on_training_button_pressed()
		return
	_refresh_detail()

func refresh_tree() -> void:
	_refresh_tree()

func _on_training_button_pressed() -> void:
	training_requested.emit()

func _on_skill_tree_changed(_all_skills: Array[StringName], _unlocked_skills: Array[StringName]) -> void:
	_refresh_tree()

func _on_progression_changed(_level: int, _xp: int) -> void:
	_refresh_tree()

func _refresh_tree() -> void:
	if _pet_skills == null:
		if _level_label != null:
			_level_label.text = "NÍVEL --  |  XP --"
		for button in _skill_buttons:
			button.text = "CARREGANDO..."
		return

	if _level_label != null:
		_level_label.text = "NÍVEL %d  |  XP %d / %d" % [
			_pet_skills.level,
			_pet_skills.xp,
			_pet_skills.xp_required_for_next_level(),
		]
	if _progress_label != null:
		_progress_label.text = "TREINO: +25 XP  |  +1 FORÇA  |  confirme com o botão verde"
	for index in _skill_buttons.size():
		var button := _skill_buttons[index]
		var skill_id := SKILL_ORDER[index]
		var skill := _pet_skills.get_skill(skill_id)
		var unlocked := _pet_skills.is_unlocked(skill_id)
		var state := "DESBLOQUEADA" if unlocked else "BLOQUEADA"
		var requirement := "ATIVA" if unlocked else "NÍVEL %d  |  XP %d" % [int(skill.get("level", 1)), int(skill.get("xp", 0))]
		button.text = "%s\n%s  •  %s" % [String(skill.get("name", skill_id)), state, requirement]
		_apply_skill_style(button, unlocked, index + 1 == selected_index)
	_apply_training_style()
	_refresh_detail()

func _refresh_detail() -> void:
	if _detail_label == null:
		return
	if _pet_skills == null:
		_detail_label.text = "Selecione uma opção."
		return
	if selected_index == 0:
		_detail_label.text = "TREINO selecionado: pratique para ganhar XP e fortalecer o pet."
		return
	var skill_id := SKILL_ORDER[clampi(selected_index - 1, 0, SKILL_ORDER.size() - 1)]
	var skill := _pet_skills.get_skill(skill_id)
	var unlocked := _pet_skills.is_unlocked(skill_id)
	var state := "HABILIDADE ATIVA" if unlocked else "AINDA NÃO ALCANÇADA"
	_detail_label.text = "%s — %s | %s" % [String(skill.get("description", "")), state, String(skill.get("slot", "")).to_upper()]

func _apply_training_style() -> void:
	if _train_button == null:
		return
	_train_button.add_theme_stylebox_override("normal", _make_style(Color("#54345F"), Color("#FFD166"), 3))
	_train_button.add_theme_stylebox_override("hover", _make_style(Color("#71447A"), Color("#FFF0A8"), 3))
	_train_button.add_theme_stylebox_override("pressed", _make_style(Color("#3B2446"), Color("#FFFFFF"), 3))
	_train_button.add_theme_color_override("font_color", Color("#FFF4C2"))
	_train_button.add_theme_color_override("font_hover_color", Color.WHITE)
	_train_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	_train_button.modulate = Color.WHITE if selected_index == 0 else Color(1.0, 1.0, 1.0, 0.72)

func _apply_skill_style(button: Button, unlocked: bool, selected: bool) -> void:
	var background := Color("#123C52") if unlocked else Color("#172039")
	var border := Color("#59F0D4") if unlocked else Color("#53617A")
	var text_color := Color("#E9FFFA") if unlocked else Color("#8E9AB0")
	if selected:
		border = Color("#FFD166")
		background = Color("#23566B") if unlocked else Color("#28334D")
	button.add_theme_stylebox_override("normal", _make_style(background, border, 3 if selected else 2))
	button.add_theme_stylebox_override("hover", _make_style(background.lightened(0.12), Color("#FFF0A8"), 3))
	button.add_theme_stylebox_override("pressed", _make_style(background.darkened(0.12), Color.WHITE, 3))
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.modulate = Color.WHITE if selected else Color(1.0, 1.0, 1.0, 0.86 if unlocked else 0.55)

func _make_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
