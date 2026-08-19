@tool
class_name ConsoleStage
extends Node2D

@export var viewport_size := Vector2(960, 540)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var c := viewport_size / 2.0
	var body := Rect2(c.x - 410, c.y - 190, 820, 380)
	var screen := Rect2(c.x - 185, c.y - 118, 370, 185)
	# Camada 1: sombra projetada
	draw_style_box(_box(Color(0, 0, 0, 0.40), 74), Rect2(body.position + Vector2(0, 16), body.size))
	# Camada 2: corpo externo
	draw_style_box(_box(Color("#c4c4cc"), 74), body)
	# Camada 3: corpo iluminado
	draw_style_box(_box(Color("#f2f2f4"), 70), Rect2(body.position + Vector2(0, -5), body.size))
	# Camada 4: rebaixo interno
	draw_style_box(_box(Color("#d9d9df"), 60), Rect2(body.position + Vector2(15, 15), body.size - Vector2(30, 30)))
	# Camada 5: tela e moldura
	draw_style_box(_box(Color("#11131b"), 18), screen.grow(10))
	draw_style_box(_box(Color("#49e1dc"), 9), screen)
	# Camada 6: brilho e linha de leitura da tela
	draw_rect(Rect2(screen.position + Vector2(5, 5), Vector2(screen.size.x - 10, 34)), Color(1, 1, 1, 0.12))
	draw_line(screen.position + Vector2(5, 42), screen.position + Vector2(screen.size.x - 5, 42), Color(0.15, 0.55, 0.65, 0.35), 2)
	# Camada 7: D-pad com sombra e volume
	var d := Vector2(c.x - 300, c.y)
	draw_style_box(_box(Color("#292035"), 8), Rect2(d - Vector2(48, 12) + Vector2(0, 7), Vector2(96, 27)))
	draw_style_box(_box(Color("#292035"), 8), Rect2(d - Vector2(14, 48) + Vector2(0, 7), Vector2(28, 96)))
	draw_style_box(_box(Color("#4d3569"), 8), Rect2(d - Vector2(48, 12), Vector2(96, 27)))
	draw_style_box(_box(Color("#4d3569"), 8), Rect2(d - Vector2(14, 48), Vector2(28, 96)))
	# Camada 8: botões com volume
	_draw_button(Vector2(c.x + 298, c.y - 46), 15, Color("#e0df4a"))
	_draw_button(Vector2(c.x + 360, c.y - 46), 15, Color("#58c982"))
	_draw_button(Vector2(c.x + 330, c.y + 55), 25, Color("#d4528e"))
	# Camada 9: marca no corpo
	draw_string(ThemeDB.fallback_font, Vector2(c.x - 49, body.end.y - 22), "AuroraPet", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#2c9dc8"))

func _draw_button(position: Vector2, radius: float, color: Color) -> void:
	draw_circle(position + Vector2(0, 5), radius, Color(0, 0, 0, 0.25))
	draw_circle(position, radius, color)
	draw_arc(position, radius - 2, PI + 0.2, TAU - 0.2, 20, Color(1, 1, 1, 0.35), 2.0)

func _box(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	return box
