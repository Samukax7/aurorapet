extends Control
class_name MapaCampanhaEva

signal stage_selected(stage_id: StringName)
signal map_closed

const STAGES: Array[Dictionary] = [
	{"id": &"eva_base", "title": "PLATAFORMA INICIAL", "chapter": "INÍCIO DA JORNADA", "position": Vector2(540, 1840), "boss": false, "base": true, "unlocked": true},
	{"id": &"eva_ch1_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 1", "position": Vector2(430, 1768), "boss": false, "base": false, "unlocked": true},
	{"id": &"eva_ch1_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 1", "position": Vector2(650, 1696), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch1_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 1", "position": Vector2(540, 1624), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch1_boss", "title": "GORGON GLITCH", "chapter": "BOSS • CAPÍTULO 1", "position": Vector2(540, 1552), "boss": true, "base": false, "unlocked": false},
	{"id": &"eva_ch2_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 2", "position": Vector2(430, 1480), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch2_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 2", "position": Vector2(650, 1408), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch2_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 2", "position": Vector2(540, 1336), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch2_boss", "title": "PRISMA GUARD", "chapter": "BOSS • CAPÍTULO 2", "position": Vector2(540, 1264), "boss": true, "base": false, "unlocked": false},
	{"id": &"eva_ch3_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 3", "position": Vector2(430, 1192), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch3_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 3", "position": Vector2(650, 1120), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch3_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 3", "position": Vector2(540, 1048), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch3_boss", "title": "CORE OVERLORD", "chapter": "BOSS • CAPÍTULO 3", "position": Vector2(540, 976), "boss": true, "base": false, "unlocked": false},
	{"id": &"eva_ch4_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 4", "position": Vector2(430, 904), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch4_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 4", "position": Vector2(650, 832), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch4_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 4", "position": Vector2(540, 760), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch4_boss", "title": "IGNIS VECTIS", "chapter": "BOSS • CAPÍTULO 4", "position": Vector2(540, 688), "boss": true, "base": false, "unlocked": false},
	{"id": &"eva_ch5_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 5", "position": Vector2(430, 616), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch5_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 5", "position": Vector2(650, 544), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch5_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 5", "position": Vector2(540, 472), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch5_boss", "title": "ARQUITETO DO ESQUECIMENTO", "chapter": "BOSS • CAPÍTULO 5", "position": Vector2(540, 400), "boss": true, "base": false, "unlocked": false},
	{"id": &"eva_ch6_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 6", "position": Vector2(430, 328), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch6_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 6", "position": Vector2(650, 256), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch6_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 6", "position": Vector2(540, 184), "boss": false, "base": false, "unlocked": false},
	{"id": &"eva_ch6_boss", "title": "O ECO ABSOLUTO", "chapter": "BOSS • CAPÍTULO 6", "position": Vector2(540, 112), "boss": true, "base": false, "unlocked": false},
]

var selected_index := 0
var time := 0.0
@onready var map_content: Control = $MapScroll/MapContent
@onready var selection_label: Label = $SelectionPanel/SelectionLabel
@onready var hint_label: Label = $Hint
@onready var stage_buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	for child in map_content.get_children():
		if child is Button and child.name.begins_with("Stage"):
			stage_buttons.append(child)
	_update_selection()

func _process(delta: float) -> void:
	if not visible:
		return
	time += delta
	for i in range(stage_buttons.size()):
		var base: Dictionary = STAGES[i]
		var offset := sin(time * 4.0) * 5.0 if i == selected_index else 0.0
		stage_buttons[i].position = Vector2(base.position.x - 28.0, base.position.y - 28.0 + offset)
	if selected_index >= 0 and selected_index < STAGES.size():
		_center_on_stage(STAGES[selected_index].position.y)

func open_map() -> void:
	visible = true
	selected_index = 1
	time = 0.0
	_update_selection()
	grab_focus()

func close_map() -> void:
	visible = false
	map_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not visible or direction == Vector2i.ZERO:
		return
	var delta := 1 if direction.y > 0 or direction.x > 0 else -1
	selected_index = wrapi(selected_index + delta, 0, STAGES.size())
	if selected_index == 0:
		selected_index = STAGES.size() - 1 if delta < 0 else 1
	_update_selection()

func confirm() -> void:
	if not visible:
		return
	var stage: Dictionary = STAGES[selected_index]
	if bool(stage.get("base", false)):
		selected_index = 1
		_update_selection()
		return
	if not bool(stage.unlocked):
		selection_label.text = "%s\nFASE BLOQUEADA\nComplete a etapa anterior" % stage.title
		return
	selection_label.text = "%s\n%s\n\nFASE PRONTA" % [stage.chapter, stage.title]
	stage_selected.emit(stage.id)

func back() -> void:
	if visible:
		close_map()

func _update_selection() -> void:
	if not visible:
		return
	var stage: Dictionary = STAGES[selected_index]
	selection_label.text = "%s\n%s" % [stage.chapter, stage.title]
	hint_label.text = "D-PAD: SUBIR/DESCER   •   VERDE: ENTRAR   •   ROSA: VOLTAR"
	for i in range(stage_buttons.size()):
		var button := stage_buttons[i]
		button.text = "◆" if i == selected_index else ("★" if STAGES[i].boss else "·")
		button.disabled = not bool(STAGES[i].unlocked)

func _center_on_stage(y: float) -> void:
	var scroll := $MapScroll
	var target := clampf(y - 245.0, 0.0, 1650.0)
	if absf(scroll.scroll_vertical - int(target)) > 4:
		scroll.scroll_vertical = int(lerpf(float(scroll.scroll_vertical), target, 0.12))
