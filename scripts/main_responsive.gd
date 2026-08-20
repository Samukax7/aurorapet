extends Node2D

const DESIGN_VIEWPORT := Vector2(1080.0, 650.0)
const CONSOLE_BASE_POSITION := Vector2(540.0, 325.0)
const CONSOLE_BASE_SCALE := 0.3

@onready var console_base: Node2D = $"Console Base"

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
	if not is_instance_valid(console_base):
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale: float = minf(viewport_size.x / DESIGN_VIEWPORT.x, viewport_size.y / DESIGN_VIEWPORT.y)
	console_base.position = viewport_size * 0.5
	console_base.scale = Vector2.ONE * CONSOLE_BASE_SCALE * fit_scale
