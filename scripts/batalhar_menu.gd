extends Control
class_name BatalharMenu

signal mode_selected(mode_id: StringName)
signal menu_closed

var selected_index := 0
@onready var selection_label: Label = $Card/SelectionLabel
@onready var exploration_button: Button = $Card/ExplorationButton
@onready var campaign_button: Button = $Card/CampaignButton

func _ready() -> void:
	visible = false
	_update_selection()

func open_menu() -> void:
	visible = true
	selected_index = 0
	_update_selection()
	grab_focus()

func close_menu() -> void:
	visible = false
	menu_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not visible or direction == Vector2i.ZERO:
		return
	selected_index = wrapi(selected_index + (1 if direction.y > 0 or direction.x > 0 else -1), 0, 2)
	_update_selection()

func confirm() -> void:
	if visible:
		mode_selected.emit(&"explorar_deepworld" if selected_index == 0 else &"campanha_eva")

func back() -> void:
	if visible:
		close_menu()

func _update_selection() -> void:
	if not visible:
		return
	exploration_button.button_pressed = selected_index == 0
	campaign_button.button_pressed = selected_index == 1
	selection_label.text = "EXPLORAR DEEPWORLD" if selected_index == 0 else "CAMPANHA DA EVA"
