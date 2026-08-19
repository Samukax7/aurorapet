class_name ConsoleFrame
extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	var c := size / 2.0
	var body := Rect2(c.x - size.x * 0.46, c.y - size.y * 0.40, size.x * 0.92, size.y * 0.80)
	var radius := body.size.y * 0.38
	# sombra e corpo do console
	draw_style_box(_box(Color("#b7b7c0"), radius), Rect2(body.position + Vector2(0, 7), body.size))
	draw_style_box(_box(Color("#f1f1f3"), radius), body)
	draw_style_box(_box(Color("#dedee3"), radius), Rect2(body.position + Vector2(8, 8), body.size - Vector2(16, 16)))
	# tela central
	var screen := Rect2(c.x - size.x * 0.205, c.y - size.y * 0.255, size.x * 0.41, size.y * 0.37)
	draw_style_box(_box(Color("#15151d"), 18), screen.grow(7))
	draw_style_box(_box(Color("#51e3df"), 8), screen)
	# brilho da tela
	draw_rect(Rect2(screen.position + Vector2(4, 4), Vector2(screen.size.x - 8, screen.size.y * 0.18)), Color(1, 1, 1, 0.12))
	# D-pad
	var dpad_center := Vector2(c.x - size.x * 0.335, c.y - size.y * 0.01)
	var dpad_color := Color("#3e2b58")
	draw_style_box(_box(dpad_color, 8), Rect2(dpad_center - Vector2(13, 44), Vector2(26, 88)))
	draw_style_box(_box(dpad_color, 8), Rect2(dpad_center - Vector2(44, 13), Vector2(88, 26)))
	# botões coloridos
	draw_circle(Vector2(c.x + size.x * 0.325, c.y - size.y * 0.13), 13, Color("#d7da3e"))
	draw_circle(Vector2(c.x + size.x * 0.405, c.y - size.y * 0.13), 13, Color("#52c77d"))
	draw_circle(Vector2(c.x + size.x * 0.365, c.y + size.y * 0.075), 22, Color("#d14d8a"))
	# marca
	draw_string(ThemeDB.fallback_font, Vector2(c.x - 46, body.end.y - 18), "AuroraPet", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#299fd1"))

func _box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	var r := int(radius)
	box.corner_radius_top_left = r
	box.corner_radius_top_right = r
	box.corner_radius_bottom_left = r
	box.corner_radius_bottom_right = r
	return box
