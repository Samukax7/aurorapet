extends Control
class_name LojaCosmica

## Loja Cósmica do Quarto Cósmico.
## Os dados de ofertas ficam centralizados aqui para facilitar o balanceamento.

signal purchase_requested(item_id: StringName, price: int)
signal closed

const CATEGORY_IDS: Array[StringName] = [&"visual", &"golpes", &"especiais"]
const CATEGORY_LABELS: Array[String] = ["VISUAL", "GOLPES", "ESPECIAIS"]
const OFFERS_PER_PAGE := 3
const OFFERS: Dictionary = {
	&"visual": [
		{"id": &"cosmetico_aurora", "name": "Cosmético: Aura Aurora", "level": 1, "price": 10},
		{"id": &"efeito_cometa", "name": "Efeito: Rastro de Cometa", "level": 2, "price": 15},
		{"id": &"cenario_nebulosa", "name": "Cenário: Nebulosa Viva", "level": 3, "price": 25},
		{"id": &"animacao_orbital", "name": "Animação Especial: Órbita", "level": 4, "price": 35},
	],
	&"golpes": [
		{"id": &"ataque_forte_solar", "name": "Ataque Forte: Impacto Solar", "level": 2, "price": 20},
		{"id": &"ataque_fraco_lunar", "name": "Ataque Fraco: Pulso Lunar", "level": 1, "price": 8},
		{"id": &"ataque_status_nebular", "name": "Ataque de Status: Sinal Nebular", "level": 3, "price": 25},
		{"id": &"ataque_recuperacao", "name": "Ataque de Recuperação: Cura Estelar", "level": 4, "price": 30},
		{"id": &"suprema_colapso", "name": "Suprema: Colapso Cósmico", "level": 6, "price": 60},
	],
	&"especiais": [
		{"id": &"fundo_exclusivo", "name": "Fundo Exclusivo: Dimensão EVA", "level": 5, "price": 45},
		{"id": &"editor_pet", "name": "Editor de Pet Exclusivo", "level": 7, "price": 80},
		{"id": &"musicas_adicionais", "name": "Músicas Adicionais", "level": 4, "price": 35},
		{"id": &"editor_cenario", "name": "Editor de Cenário", "level": 8, "price": 75},
		{"id": &"plataforma_eclipse", "name": "Plataforma: Eclipse", "level": 3, "price": 25},
		{"id": &"catalogo_pets", "name": "Catálogo de Pets", "level": 5, "price": 50},
		{"id": &"hall_pets", "name": "Hall de Pets", "level": 6, "price": 65},
		{"id": &"eva_mascote", "name": "EVA: Raposa Guia", "level": 10, "price": 100},
	],
}

var selected_category := 0
var selected_offer := 0
var player_level := 1
var player_xp := 0
var player_total_xp := 0
var available_points := 0
var accumulated_value := 0
var _category_buttons: Array[Button] = []
var _item_buttons: Array[Button] = []

@onready var stats_label: Label = $Panel/Stats
@onready var page_label: Label = $Panel/Page
@onready var result_label: Label = $Panel/Result
@onready var categories: HBoxContainer = $Panel/Categories
@onready var items: GridContainer = $Panel/Items

func _ready() -> void:
	for child in categories.get_children():
		if child is Button:
			_category_buttons.append(child as Button)
	for child in items.get_children():
		if child is Button:
			_item_buttons.append(child as Button)
	for index in _category_buttons.size():
		_category_buttons[index].pressed.connect(_on_category_pressed.bind(index))
	for index in _item_buttons.size():
		_item_buttons[index].pressed.connect(_on_item_pressed.bind(index))
	visible = false
	_refresh()

func open_shop(level: int, xp: int, total_xp: int, points: int, total_value: int) -> void:
	visible = true
	player_level = maxi(level, 1)
	player_xp = maxi(xp, 0)
	player_total_xp = maxi(total_xp, 0)
	available_points = maxi(points, 0)
	accumulated_value = maxi(total_value, 0)
	selected_category = clampi(selected_category, 0, CATEGORY_IDS.size() - 1)
	selected_offer = 0
	result_label.text = "SELECIONE UMA OFERTA E PRESSIONE VERDE PARA COMPRAR"
	_refresh()

func close_shop() -> void:
	if not visible:
		return
	visible = false
	closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not visible:
		return
	if direction.x < 0:
		selected_category = wrapi(selected_category - 1, 0, CATEGORY_IDS.size())
		selected_offer = 0
	elif direction.x > 0:
		selected_category = wrapi(selected_category + 1, 0, CATEGORY_IDS.size())
		selected_offer = 0
	elif direction.y < 0:
		_move_offer(-1)
	elif direction.y > 0:
		_move_offer(1)
	_refresh()

func confirm() -> void:
	if not visible:
		return
	var offer := _current_offer()
	if offer.is_empty():
		return
	var required_level := int(offer.get("level", 1))
	var price := int(offer.get("price", 0))
	if player_level < required_level:
		result_label.text = "BLOQUEADO • DESBLOQUEIA NO NÍVEL %d" % required_level
		return
	if available_points < price:
		result_label.text = "PONTOS INSUFICIENTES • PRECISA DE %d" % price
		return
	result_label.text = "CONFIRMANDO COMPRA: %s" % String(offer.get("name", "ITEM"))
	purchase_requested.emit(StringName(offer.get("id", &"")), price)

func apply_purchase(item_id: StringName, remaining_points: int, total_value: int) -> void:
	available_points = maxi(remaining_points, 0)
	accumulated_value = maxi(total_value, 0)
	var offer := _find_offer(item_id)
	result_label.text = "COMPRADO: %s • VALOR ACUMULADO %05d" % [String(offer.get("name", item_id)).to_upper(), accumulated_value]
	_refresh()

func show_purchase_result(message: String) -> void:
	result_label.text = message

func get_current_offer() -> Dictionary:
	return _current_offer().duplicate(true)

func _current_offers() -> Array:
	return OFFERS.get(CATEGORY_IDS[selected_category], [])

func _page_start() -> int:
	return (selected_offer / OFFERS_PER_PAGE) * OFFERS_PER_PAGE

func _move_offer(step: int) -> void:
	var offers := _current_offers()
	if offers.is_empty():
		return
	var page_start := _page_start()
	var page_end := mini(page_start + OFFERS_PER_PAGE - 1, offers.size() - 1)
	if step < 0:
		if selected_offer > page_start:
			selected_offer -= 1
		elif page_start > 0:
			selected_offer = page_start - 1
		else:
			selected_offer = offers.size() - 1
	else:
		if selected_offer < page_end:
			selected_offer += 1
		elif page_end < offers.size() - 1:
			selected_offer = page_end + 1
		else:
			selected_offer = 0

func _current_offer() -> Dictionary:
	var offers := _current_offers()
	if offers.is_empty():
		return {}
	selected_offer = clampi(selected_offer, 0, offers.size() - 1)
	return offers[selected_offer]

func _find_offer(item_id: StringName) -> Dictionary:
	for category_id in CATEGORY_IDS:
		for offer in OFFERS.get(category_id, []):
			if StringName(offer.get("id", &"")) == item_id:
				return offer
	return {}

func _refresh() -> void:
	if stats_label != null:
		stats_label.text = "NÍVEL %02d  •  XP %04d  •  XP ACUMULADO %05d\nPONTOS %05d  •  VALOR ACUMULADO %05d" % [player_level, player_xp, player_total_xp, available_points, accumulated_value]
	for index in _category_buttons.size():
		_category_buttons[index].text = CATEGORY_LABELS[index]
		_category_buttons[index].add_theme_color_override("font_color", Color(0.95, 0.99, 1, 1) if index == selected_category else Color(0.62, 0.78, 0.95, 1))
	var offers := _current_offers()
	var page_start := _page_start()
	var page_count := maxi(ceili(float(offers.size()) / float(OFFERS_PER_PAGE)), 1)
	if page_label != null:
		page_label.text = "PÁGINA %d/%d  •  3 OFERTAS POR VEZ" % [page_start / OFFERS_PER_PAGE + 1, page_count]
	for index in _item_buttons.size():
		var button := _item_buttons[index]
		var absolute_index := page_start + index
		if index >= OFFERS_PER_PAGE or absolute_index >= offers.size():
			button.visible = false
			continue
		button.visible = true
		var offer: Dictionary = offers[absolute_index]
		var required_level := int(offer.get("level", 1))
		var price := int(offer.get("price", 0))
		var locked := player_level < required_level
		button.text = "%s\nNÍVEL %d  •  %d PONTOS%s" % [String(offer.get("name", "ITEM")), required_level, price, "  •  BLOQUEADO" if locked else ""]
		button.disabled = false
		button.add_theme_color_override("font_color", Color(1, 0.83, 0.4, 1) if absolute_index == selected_offer else Color(0.9, 0.95, 1, 1))
		button.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.08, 1))
		button.add_theme_constant_override("outline_size", 4)

func _on_category_pressed(index: int) -> void:
	selected_category = clampi(index, 0, CATEGORY_IDS.size() - 1)
	selected_offer = 0
	_refresh()

func _on_item_pressed(index: int) -> void:
	selected_offer = _page_start() + index
	_refresh()
