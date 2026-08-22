extends Node2D
class_name AuroraPetMobileMain

const LOGICAL_SIZE := Vector2(1080.0, 650.0)
const LOGICAL_CENTER := Vector2(540.0, 325.0)

@onready var console_base: Node2D = $"Console Base"
@onready var screen_content: Control = $"Console Base/ScreenContent"
@onready var background: ColorRect = $MobileBackground
@onready var touch_controls: Control = $MobileTouchControls

func _ready() -> void:
	_remove_desktop_shell()
	if touch_controls.has_method("set_controller"):
		touch_controls.set_controller(console_base)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func _remove_desktop_shell() -> void:
	# Remove somente a apresentação física; o Console Base continua existindo
	# como controlador e hospedeiro da cascata ScreenContent.
	if console_base is Sprite2D:
		(console_base as Sprite2D).texture = null
	for node_name in [
		"Tela", "DPadSprite", "GreenButtonSprite", "YellowButtonSprite", "PinkButtonSprite",
		"ButtonGreen", "ButtonYellow", "ButtonPink", "DPadUp", "DPadDown", "DPadLeft", "DPadRight",
	]:
		var shell_node := console_base.get_node_or_null(node_name) as CanvasItem
		if shell_node != null:
			shell_node.visible = false

func _on_viewport_size_changed() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	background.position = Vector2.ZERO
	background.size = viewport_size
	if touch_controls != null:
		touch_controls.position = Vector2.ZERO
		touch_controls.size = viewport_size
	var fit_scale := minf(viewport_size.x / LOGICAL_SIZE.x, viewport_size.y / LOGICAL_SIZE.y)
	console_base.position = viewport_size * 0.5
	console_base.scale = Vector2.ONE * fit_scale
	screen_content.position = -LOGICAL_CENTER
	screen_content.scale = Vector2.ONE
