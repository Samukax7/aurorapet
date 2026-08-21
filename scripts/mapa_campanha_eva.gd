extends Control
class_name MapaCampanhaEva

signal stage_selected(stage_id: StringName)
signal map_closed

const STAGES: Array[Dictionary] = [
	{"id": &"eva_ch1_01", "title": "ECO INICIAL", "chapter": "CAPÍTULO 1", "position": Vector2(540, 1680), "boss": false, "unlocked": true},
	{"id": &"eva_ch1_02", "title": "FRAGMENTO", "chapter": "CAPÍTULO 1", "position": Vector2(430, 1510), "boss": false, "unlocked": false},
	{"id": &"eva_ch1_03", "title": "RUÍDO VIOLETA", "chapter": "CAPÍTULO 1", "position": Vector2(650, 1380), "boss": false, "unlocked": false},
	{"id": &"eva_ch1_boss", "title": "GORGON GLITCH", "chapter": "BOSS • CAPÍTULO 1", "position": Vector2(540, 1180), "boss": true, "unlocked": false},
	{"id": &"eva_ch2_01", "title": "ESPELHO", "chapter": "CAPÍTULO 2", "position": Vector2(390, 990), "boss": false, "unlocked": false},
	{"id": &"eva_ch2_02", "title": "PRISMA", "chapter": "CAPÍTULO 2", "position": Vector2(670, 840), "boss": false, "unlocked": false},
	{"id": &"eva_ch2_boss", "title": "PRISMA GUARD", "chapter": "BOSS • CAPÍTULO 2", "position": Vector2(540, 650), "boss": true, "unlocked": false},
	{"id": &"eva_ch3_01", "title": "DADOS PERDIDOS", "chapter": "CAPÍTULO 3", "position": Vector2(400, 485), "boss": false, "unlocked": false},
	{"id": &"eva_ch3_boss", "title": "CORE OVERLORD", "chapter": "BOSS • CAPÍTULO 3", "position": Vector2(680, 300), "boss": true, "unlocked": false},
	{"id": &"eva_final_boss", "title": "O ECO ABSOLUTO", "chapter": "BOSS FINAL", "position": Vector2(540, 115), "boss": true, "unlocked": false},
]

var selected_index := 0
var time := 0.0
@onready var map_content: Control = $MapScroll/MapContent
@onready var selection_label: Label = $SelectionPanel/SelectionLabel
@onready var hint_label: Label = $Hint
@onready var stage_buttons: Array[Button] = [$MapScroll/MapContent/Stage01, $MapScroll/MapContent/Stage02, $MapScroll/MapContent/Stage03, $MapScroll/MapContent/Stage04, $MapScroll/MapContent/Stage05, $MapScroll/MapContent/Stage06, $MapScroll/MapContent/Stage07, $MapScroll/MapContent/Stage08, $MapScroll/MapContent/Stage09, $MapScroll/MapContent/Stage10]

func _ready() -> void:
	visible = false
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
	selected_index = 0
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
	_update_selection()

func confirm() -> void:
	if not visible:
		return
	var stage: Dictionary = STAGES[selected_index]
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
	var target := clampf(y - 245.0, 0.0, 1400.0)
	if absf(scroll.scroll_vertical - int(target)) > 4:
		scroll.scroll_vertical = int(lerpf(float(scroll.scroll_vertical), target, 0.12))
