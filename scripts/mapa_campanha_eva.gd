extends Control
class_name MapaCampanhaEva

signal stage_selected(stage_id: StringName)
signal map_closed

const STAGES: Array[Dictionary] = [
		{"id": &"eva_base", "title": "PLATAFORMA INICIAL", "chapter": "INÍCIO DA JORNADA", "position": Vector2(530, 1818), "boss": false, "base": true, "unlocked": true},
		{"id": &"eva_ch1_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 1", "position": Vector2(582, 1713), "boss": false, "base": false, "unlocked": true},
		{"id": &"eva_ch1_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 1", "position": Vector2(489, 1691), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch1_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 1", "position": Vector2(476, 1672), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch1_boss", "title": "GORGON GLITCH", "chapter": "BOSS • CAPÍTULO 1", "position": Vector2(540, 1548), "boss": true, "base": false, "unlocked": false},
		{"id": &"eva_ch2_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 2", "position": Vector2(604, 1470), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch2_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 2", "position": Vector2(516, 1446), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch2_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 2", "position": Vector2(427, 1425), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch2_boss", "title": "PRISMA GUARD", "chapter": "BOSS • CAPÍTULO 2", "position": Vector2(540, 1308), "boss": true, "base": false, "unlocked": false},
		{"id": &"eva_ch3_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 3", "position": Vector2(609, 1206), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch3_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 3", "position": Vector2(521, 1184), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch3_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 3", "position": Vector2(429, 1166), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch3_boss", "title": "CORE OVERLORD", "chapter": "BOSS • CAPÍTULO 3", "position": Vector2(540, 1008), "boss": true, "base": false, "unlocked": false},
		{"id": &"eva_ch4_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 4", "position": Vector2(616, 930), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch4_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 4", "position": Vector2(528, 913), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch4_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 4", "position": Vector2(438, 892), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch4_boss", "title": "IGNIS VECTIS", "chapter": "BOSS • CAPÍTULO 4", "position": Vector2(540, 744), "boss": true, "base": false, "unlocked": false},
		{"id": &"eva_ch5_01", "title": "ENCONTRO 1", "chapter": "CAPÍTULO 5", "position": Vector2(627, 640), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch5_02", "title": "ENCONTRO 2", "chapter": "CAPÍTULO 5", "position": Vector2(540, 624), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch5_03", "title": "ENCONTRO 3", "chapter": "CAPÍTULO 5", "position": Vector2(457, 608), "boss": false, "base": false, "unlocked": false},
		{"id": &"eva_ch5_boss", "title": "ARQUITETO DO ESQUECIMENTO", "chapter": "BOSS • CAPÍTULO 5", "position": Vector2(540, 468), "boss": true, "base": false, "unlocked": false},
		{"id": &"eva_ch6_boss", "title": "O ECO ABSOLUTO", "chapter": "BOSS FINAL", "position": Vector2(540, 192), "boss": true, "base": false, "unlocked": false},
	]

var selected_index := 0
var unlocked_stage_index := 1
var time := 0.0
var _initial_scroll_pending := false
var mobile_presentation := false
@onready var map_content: Control = $MapScroll/MapContent
@onready var selection_panel: Panel = $SelectionPanel
@onready var selection_label: Label = $SelectionPanel/SelectionLabel
@onready var hint_label: Label = $Hint
@onready var stage_buttons: Array[Button] = []
@onready var map_music: AudioStreamPlayer = $MapMusic

func _ready() -> void:
	visible = false
	_configure_music_loop()
	for child in map_content.get_children():
		if child is Button and child.name.begins_with("Stage"):
			stage_buttons.append(child)
	for index in stage_buttons.size():
		stage_buttons[index].pressed.connect(_on_stage_button_pressed.bind(index))
	_update_selection()

func set_mobile_presentation(active_mobile: bool) -> void:
	mobile_presentation = active_mobile
	_update_selection()

func _on_stage_button_pressed(index: int) -> void:
	if not visible:
		return
	selected_index = clampi(index, 0, STAGES.size() - 1)
	_update_selection()
	if mobile_presentation:
		confirm()

func _process(delta: float) -> void:
	if not visible:
		return
	time += delta
	for i in range(stage_buttons.size()):
		var base: Dictionary = STAGES[i]
		var offset := sin(time * 4.0) * 5.0 if i == selected_index else 0.0
		stage_buttons[i].position = Vector2(base.position.x - 28.0, base.position.y - 28.0 + offset)
	if selected_index >= 0 and selected_index < STAGES.size():
		_center_on_stage(STAGES[selected_index].position.y, _initial_scroll_pending)
		_initial_scroll_pending = false
		_position_selection_panel(STAGES[selected_index].position)

func open_map() -> void:
	visible = true
	if map_music != null and not map_music.playing:
		map_music.play()
	# A campanha sempre recomeça visualmente na plataforma neutra inferior.
	# O jogador sobe pelos nós e o scroll acompanha a continuidade vertical.
	selected_index = 0
	time = 0.0
	_initial_scroll_pending = true
	_update_selection()
	grab_focus()

func set_progression(stage_index: int) -> void:
	unlocked_stage_index = clampi(stage_index, 1, STAGES.size() - 1)
	_update_selection()

func get_unlocked_stage_index() -> int:
	return unlocked_stage_index

func advance_to_stage(stage_id: StringName) -> void:
	for index in range(STAGES.size()):
		if STAGES[index].id == stage_id:
			unlocked_stage_index = maxi(unlocked_stage_index, clampi(index + 1, 1, STAGES.size() - 1))
			_update_selection()
			return

func close_map() -> void:
	visible = false
	if map_music != null:
		map_music.stop()
	map_closed.emit()

func _configure_music_loop() -> void:
	if map_music == null:
		return
	var wav := map_music.stream as AudioStreamWAV
	if wav != null:
		var looped := wav.duplicate() as AudioStreamWAV
		looped.loop_mode = AudioStreamWAV.LOOP_FORWARD
		map_music.stream = looped

func handle_direction(direction: Vector2i) -> void:
	if not visible or direction == Vector2i.ZERO:
		return
	var delta := 0
	if direction.y < 0:
		delta = 1
	elif direction.y > 0:
		delta = -1
	elif direction.x != 0:
		delta = 1 if direction.x > 0 else -1
	if delta == 0:
		return
	# O índice 0 é a plataforma neutra inferior; CIMA sobe para os índices seguintes.
	selected_index = clampi(selected_index + delta, 0, STAGES.size() - 1)
	_update_selection()

func confirm() -> void:
	if not visible:
		return
	var stage: Dictionary = STAGES[selected_index]
	if bool(stage.get("base", false)):
		selection_label.text = "PLATAFORMA NEUTRA\nINÍCIO DA JORNADA\n\nUse CIMA para subir"
		return
	if selected_index > unlocked_stage_index:
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
	var availability := "\nINÍCIO" if bool(stage.base) else ("\nDISPONÍVEL" if selected_index <= unlocked_stage_index else "\nBLOQUEADA")
	var display_title := "PLATAFORMA NEUTRA" if bool(stage.base) else String(stage.title)
	selection_label.text = "%s\n%s%s" % [stage.chapter, display_title, availability]
	_position_selection_panel(stage.position)
	hint_label.text = "TOQUE EM UMA FASE   •   ←: VOLTAR" if mobile_presentation else ""
	for i in range(stage_buttons.size()):
		var button := stage_buttons[i]
		button.text = "◆" if i == selected_index else ("★" if STAGES[i].boss else "·")
		button.disabled = i > unlocked_stage_index

func _position_selection_panel(stage_position: Vector2) -> void:
	if selection_panel == null:
		return
	var scroll := $MapScroll as ScrollContainer
	var visible_position := stage_position - Vector2(0.0, scroll.scroll_vertical)
	var panel_size := selection_panel.size
	var panel_x := stage_position.x + 38.0 if stage_position.x < 540.0 else stage_position.x - panel_size.x - 38.0
	var panel_y := visible_position.y - panel_size.y - 12.0
	panel_x = clampf(panel_x, 12.0, 1080.0 - panel_size.x - 12.0)
	panel_y = clampf(panel_y, 12.0, 650.0 - panel_size.y - 12.0)
	selection_panel.position = Vector2(panel_x, panel_y)
	selection_panel.visible = true

func _center_on_stage(y: float, snap: bool = false) -> void:
	var scroll := $MapScroll
	# O conteúdo é a imagem original ajustada para 1080 × 1920 (proporção 9:16).
	# O limite é calculado pela altura real do conteúdo, nunca por um valor fixo.
	var max_scroll := maxf(0.0, map_content.size.y - scroll.size.y)
	var target := clampf(y - scroll.size.y * 0.5, 0.0, max_scroll)
	if snap:
		scroll.scroll_vertical = int(target)
	elif absf(scroll.scroll_vertical - int(target)) > 4:
		scroll.scroll_vertical = int(lerpf(float(scroll.scroll_vertical), target, 0.12))
