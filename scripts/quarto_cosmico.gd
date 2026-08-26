extends Node2D
class_name QuartoCosmico

## Área global do Quarto Cósmico dentro do Deepworld.
## O acesso não pertence a nenhuma opção do menu principal.

signal points_spent(amount: int, remaining: int)
signal points_changed(total_points: int)
signal area_closed
signal shop_requested
signal wardrobe_requested
signal exit_confirmation_requested
signal exit_confirmation_cancelled
signal exit_confirmed
signal purchase_completed(item_id: StringName, price: int, remaining_points: int, accumulated_value: int)
signal cosmetic_equipped(item_id: StringName)

var exploration_points := 0
var shop_total_value := 0
var owned_items: Array[StringName] = []
var selected_index := 0
var player_level := 1
var player_xp := 0
var player_total_xp := 0
var exit_confirmation_pending := false
var _background_visibility: Dictionary = {}

@onready var standard_background: Sprite2D = $FundoPadrao
@onready var room: Control = $Room
@onready var points_label: Label = $Room/Points
@onready var status_label: Label = $Room/Status
@onready var result_label: Label = $Room/Result
@onready var system_panel: Panel = $Room/SystemMessage
@onready var system_label: Label = $Room/SystemMessage/Label
@onready var shop: LojaCosmica = $LojaCosmica
@onready var wardrobe: GuardaRoupasCosmico = $GuardaRoupasCosmico

func _ready() -> void:
	visible = false
	standard_background.visible = false
	system_panel.visible = false
	if shop != null:
		shop.purchase_requested.connect(_on_purchase_requested)
	if wardrobe != null:
		wardrobe.wardrobe_closed.connect(_on_wardrobe_closed)
		wardrobe.cosmetic_equipped.connect(_on_cosmetic_equipped)
	_update_points()

func configure_progression(level: int, xp: int, total_xp: int) -> void:
	player_level = maxi(level, 1)
	player_xp = maxi(xp, 0)
	player_total_xp = maxi(total_xp, 0)

func open_area() -> void:
	visible = true
	selected_index = 0
	exit_confirmation_pending = false
	system_panel.visible = false
	_set_standard_background(true)
	room.visible = true
	if shop != null:
		shop.visible = false
	if wardrobe != null:
		wardrobe.close_wardrobe()
	_update_selection_message()
	_update_points()

func close_area() -> void:
	if shop != null and shop.visible:
		shop.close_shop()
		system_panel.visible = false
		room.visible = true
		return
	if wardrobe != null and wardrobe.visible:
		wardrobe.close_wardrobe()
		room.visible = true
		return
	exit_confirmation_pending = false
	system_panel.visible = false
	_set_standard_background(false)
	visible = false
	area_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if shop != null and shop.visible:
		shop.handle_direction(direction)
		return
	if wardrobe != null and wardrobe.visible:
		wardrobe.handle_direction(direction)
		return
	if not visible or direction == Vector2i.ZERO or exit_confirmation_pending:
		return
	if direction.x < 0 or direction.y < 0:
		selected_index = 0
	else:
		selected_index = 1
	_update_selection_message()

func confirm() -> void:
	if wardrobe != null and wardrobe.visible:
		wardrobe.confirm()
		return
	if exit_confirmation_pending:
		exit_confirmation_pending = false
		system_panel.visible = false
		exit_confirmed.emit()
		return
	if shop != null and shop.visible:
		shop.confirm()
		return
	if not visible:
		return
	if selected_index == 0:
		_open_shop()
	else:
		status_label.text = "GUARDA-ROUPAS"
		result_label.text = "SELECIONE UM ACESSÓRIO PARA EQUIPAR"
		_open_wardrobe()

func back() -> void:
	if shop != null and shop.visible:
		shop.close_shop()
		room.visible = true
		_update_selection_message()
		return
	if wardrobe != null and wardrobe.visible:
		wardrobe.back()
		return
	request_exit()

func request_exit() -> void:
	if not visible or exit_confirmation_pending:
		return
	exit_confirmation_pending = true
	system_label.text = "SISTEMA: SAIR DO QUARTO CÓSMICO?\nVERDE: CONFIRMAR   •   ROSA: CANCELAR"
	system_panel.visible = true
	exit_confirmation_requested.emit()

func cancel_exit() -> void:
	if not exit_confirmation_pending:
		return
	exit_confirmation_pending = false
	system_panel.visible = false
	result_label.text = "SAÍDA CANCELADA • CONTINUE NO QUARTO CÓSMICO"
	exit_confirmation_cancelled.emit()

func is_shop_open() -> bool:
	return shop != null and shop.visible

func is_wardrobe_open() -> bool:
	return wardrobe != null and wardrobe.visible

func is_exit_confirmation_pending() -> bool:
	return exit_confirmation_pending

func set_exploration_points(value: int) -> void:
	exploration_points = maxi(value, 0)
	_update_points()
	if shop != null and shop.visible:
		shop.open_shop(player_level, player_xp, player_total_xp, exploration_points, shop_total_value)

func add_exploration_points(amount: int) -> void:
	if amount <= 0:
		return
	exploration_points += amount
	_update_points()
	points_changed.emit(exploration_points)

func can_spend_points(amount: int) -> bool:
	return amount >= 0 and exploration_points >= amount

func spend_points(amount: int) -> bool:
	if not can_spend_points(amount):
		return false
	exploration_points -= amount
	_update_points()
	points_spent.emit(amount, exploration_points)
	points_changed.emit(exploration_points)
	return true

func get_exploration_points() -> int:
	return exploration_points

func get_shop_total_value() -> int:
	return shop_total_value

func get_owned_items() -> Array[StringName]:
	return owned_items.duplicate()

func set_owned_items(items: Array) -> void:
	owned_items.clear()
	for item_id in items:
		var normalized := StringName(String(item_id))
		if not normalized.is_empty() and not owned_items.has(normalized):
			owned_items.append(normalized)

func has_owned_item(item_id: StringName) -> bool:
	return owned_items.has(item_id)

func _open_wardrobe() -> void:
	if wardrobe == null:
		return
	system_panel.visible = false
	room.visible = false
	wardrobe.open_wardrobe()
	wardrobe_requested.emit()

func _on_wardrobe_closed() -> void:
	room.visible = true
	_update_selection_message()

func _on_cosmetic_equipped(item_id: StringName) -> void:
	result_label.text = "EQUIPADO: " + String(item_id).to_upper()
	cosmetic_equipped.emit(item_id)

func _open_shop() -> void:
	if shop == null:
		return
	system_panel.visible = false
	room.visible = false
	shop.open_shop(player_level, player_xp, player_total_xp, exploration_points, shop_total_value)
	shop_requested.emit()

func _on_purchase_requested(item_id: StringName, price: int) -> void:
	if has_owned_item(item_id):
		shop.show_purchase_result("ITEM JÁ ADQUIRIDO • USE-O NO GUARDA-ROUPAS")
		return
	if not spend_points(price):
		shop.show_purchase_result("PONTOS INSUFICIENTES • PRECISA DE %d" % price)
		return
	owned_items.append(item_id)
	shop_total_value += price
	shop.apply_purchase(item_id, exploration_points, shop_total_value)
	purchase_completed.emit(item_id, price, exploration_points, shop_total_value)

func _update_selection_message() -> void:
	var options := ["LOJA CÓSMICA", "GUARDA-ROUPAS"]
	status_label.text = options[selected_index]
	result_label.text = "PRESSIONE VERDE PARA CONFIRMAR"

func _update_points() -> void:
	if points_label != null:
		points_label.text = "PONTOS DE EXPLORAÇÃO: %05d" % exploration_points

func _set_standard_background(active: bool) -> void:
	if active:
		_background_visibility.clear()
		var cenario := get_parent().get_node_or_null(^"Cenario")
		if cenario != null:
			for child in cenario.get_children():
				_background_visibility[child] = child.visible
				child.visible = false
		standard_background.visible = true
	else:
		standard_background.visible = false
		var cenario := get_parent().get_node_or_null(^"Cenario")
		if cenario != null:
			for child in cenario.get_children():
				if _background_visibility.has(child):
					child.visible = bool(_background_visibility[child])
		_background_visibility.clear()
