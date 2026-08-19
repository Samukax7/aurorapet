@tool
extends Node2D

const DESIGN_SIZE := Vector2(960, 540)

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()

func _on_viewport_resized() -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, DESIGN_SIZE), Color("#17152a"))
	# brilho ambiente atrás do console
	draw_circle(Vector2(480, 270), 280, Color(0.15, 0.22, 0.42, 0.16))
	draw_circle(Vector2(480, 270), 210, Color(0.30, 0.42, 0.72, 0.08))
