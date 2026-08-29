extends Control
class_name MapaExploracao

signal area_selected(area_id: StringName)
signal map_closed

const AREAS: Array[Dictionary] = [
	{"id": &"crystal_ruins", "title": "RUÍNAS CRISTALINAS", "subtitle": "Itens raros e Ecos corrompidos", "position": Vector2(165, 128)},
	{"id": &"electric_abysm", "title": "ABISMO ELÉTRICO", "subtitle": "Ecos velozes e XP elevado", "position": Vector2(850, 128)},
	{"id": &"volcanic_core", "title": "NÚCLEO VULCÂNICO", "subtitle": "Área central de alto risco", "position": Vector2(535, 305)},
	{"id": &"crystal_forest", "title": "FLORESTA DE CRISTAL", "subtitle": "Recursos de recuperação", "position": Vector2(170, 520)},
	{"id": &"data_city", "title": "CIDADE DOS DADOS", "subtitle": "Itens tecnológicos e Ecos", "position": Vector2(850, 520)},
]

var selected_index := 4
var mobile_presentation := false
var _world_progression: AuroraPetSave
@onready var selection_label: Label = $SelectionPanel/SelectionLabel
@onready var hint_label: Label = $Hint
@onready var area_buttons: Array[Button] = [$AreaButtons/CrystalRuins, $AreaButtons/ElectricAbysm, $AreaButtons/VolcanicCore, $AreaButtons/CrystalForest, $AreaButtons/DataCity]
@onready var map_music: AudioStreamPlayer = $MapMusic

func _ready() -> void:
	visible = false
	for index in area_buttons.size():
		area_buttons[index].pressed.connect(_on_area_button_pressed.bind(index))
	_configure_music_loop()
	_update_selection()

func set_mobile_presentation(active_mobile: bool) -> void:
	mobile_presentation = active_mobile
	_update_selection()

func _on_area_button_pressed(index: int) -> void:
	if not visible:
		return
	selected_index = clampi(index, 0, AREAS.size() - 1)
	_update_selection()
	if mobile_presentation:
		confirm()

func set_world_progression(world: AuroraPetSave) -> void:
	_world_progression = world
	_update_selection()

func open_map() -> void:
	visible = true
	if map_music != null and not map_music.playing:
		map_music.play()
	selected_index = 4
	_update_selection()
	grab_focus()

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
	var delta := 1 if direction.x > 0 or direction.y > 0 else -1
	selected_index = wrapi(selected_index + delta, 0, AREAS.size())
	_update_selection()

func confirm() -> void:
	if not visible:
		return
	var area: Dictionary = AREAS[selected_index]
	if not _is_area_unlocked(area.id):
		selection_label.text = "%s\nÁREA BLOQUEADA\nEncontre EVA para avançar" % area.title
		return
	selection_label.text = "%s\n%s\n\nÁREA PRONTA PARA EXPLORAÇÃO" % [area.title, area.subtitle]
	area_selected.emit(area.id)

func back() -> void:
	if visible:
		close_map()

func _update_selection() -> void:
	if not visible:
		return
	var area: Dictionary = AREAS[selected_index]
	selection_label.text = "%s\n%s" % [area.title, area.subtitle] if _is_area_unlocked(area.id) else "%s\nÁREA BLOQUEADA" % area.title
	hint_label.text = ("TOQUE EM UMA ILHA PARA EXPLORAR   •   ←: VOLTAR" if mobile_presentation
		else "D-PAD: NAVEGAR   •   VERDE: EXPLORAR   •   ROSA: VOLTAR")
	for i in range(area_buttons.size()):
		var button := area_buttons[i]
		var unlocked := _is_area_unlocked(AREAS[i].id)
		button.button_pressed = i == selected_index
		button.disabled = not unlocked
		button.text = "✦" if i == selected_index else "·"
		button.modulate = Color.WHITE if unlocked else Color(0.35, 0.4, 0.55, 0.55)

func _is_area_unlocked(area_id: StringName) -> bool:
	return _world_progression == null or _world_progression.is_exploration_island_unlocked(area_id)
