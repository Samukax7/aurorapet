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
var _world_progression: AuroraPetSave
@onready var selection_label: Label = $SelectionPanel/SelectionLabel
@onready var hint_label: Label = $Hint
@onready var area_buttons: Array[Button] = [$AreaButtons/CrystalRuins, $AreaButtons/ElectricAbysm, $AreaButtons/VolcanicCore, $AreaButtons/CrystalForest, $AreaButtons/DataCity]

func _ready() -> void:
	visible = false
	_update_selection()

func set_world_progression(world: AuroraPetSave) -> void:
	_world_progression = world
	_update_selection()

func open_map() -> void:
	visible = true
	selected_index = 4
	_update_selection()
	grab_focus()

func close_map() -> void:
	visible = false
	map_closed.emit()

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
	hint_label.text = "D-PAD: NAVEGAR   •   VERDE: EXPLORAR   •   ROSA: VOLTAR"
	for i in range(area_buttons.size()):
		var button := area_buttons[i]
		var unlocked := _is_area_unlocked(AREAS[i].id)
		button.button_pressed = i == selected_index
		button.disabled = not unlocked
		button.text = "✦" if i == selected_index else "·"
		button.modulate = Color.WHITE if unlocked else Color(0.35, 0.4, 0.55, 0.55)

func _is_area_unlocked(area_id: StringName) -> bool:
	return _world_progression == null or _world_progression.is_exploration_island_unlocked(area_id)
