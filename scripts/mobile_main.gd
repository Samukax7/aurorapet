extends Node2D
class_name AuroraPetMobileMain

const LOGICAL_SIZE := Vector2(1080.0, 650.0)
const LOGICAL_CENTER := Vector2(540.0, 325.0)

@onready var gameplay_root: Node2D = $GameplayRoot
@onready var screen_content: Control = $GameplayRoot/ScreenContent
@onready var background: ColorRect = $MobileBackground
@onready var touch_controls: Control = $MobileTouchControls

func _ready() -> void:
	if gameplay_root.has_method("set_mobile_presentation"):
		gameplay_root.call("set_mobile_presentation", true)
	if touch_controls.has_method("set_controller"):
		touch_controls.set_controller(gameplay_root)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

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
	gameplay_root.position = viewport_size * 0.5
	gameplay_root.scale = Vector2.ONE * fit_scale
	screen_content.position = -LOGICAL_CENTER
	screen_content.scale = Vector2.ONE
