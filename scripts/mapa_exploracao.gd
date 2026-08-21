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

var selected_index := 0
@onready var selection_label: Label = $SelectionPanel/SelectionLabel
@onready var hint_label: Label = $Hint
@onready var area_buttons: Array[Button] = [$AreaButtons/CrystalRuins, $AreaButtons/ElectricAbysm, $AreaButtons/VolcanicCore, $AreaButtons/CrystalForest, $AreaButtons/DataCity]

func _ready() -> void:
	visible = false
	_update_selection()

func open_map() -> void:
	visible = true
	selected_index = 0
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
	selection_label.text = "%s\n%s\n\nÁREA PRONTA PARA EXPLORAÇÃO" % [area.title, area.subtitle]
	area_selected.emit(area.id)

func back() -> void:
	if visible:
		close_map()

func _update_selection() -> void:
	if not visible:
		return
	var area: Dictionary = AREAS[selected_index]
	selection_label.text = "%s\n%s" % [area.title, area.subtitle]
	hint_label.text = "D-PAD: NAVEGAR   •   VERDE: EXPLORAR   •   ROSA: VOLTAR"
	for i in range(area_buttons.size()):
		var button := area_buttons[i]
		button.button_pressed = i == selected_index
		button.text = "✦" if i == selected_index else "·"
