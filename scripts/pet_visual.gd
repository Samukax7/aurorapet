class_name PetVisual
extends Control

var pet: PetState
var pulse: float = 0.0

func set_pet(value: PetState) -> void:
	pet = value
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _draw() -> void:
	if pet == null: return
	var center := size / 2.0
	var bob := sin(pulse * 2.0) * 3.0
	center.y += bob
	var main_color := Color("#f6d78a")
	var accent := Color("#ffd95a")
	if pet.faction == "Luz":
		main_color = Color("#fff1bf")
		accent = Color("#8be7ff")
	elif pet.faction == "Trevas":
		main_color = Color("#59466f")
		accent = Color("#d26cff")
	else:
		main_color = Color("#8ac7b1")
		accent = Color("#5fe4d0")
	var scale_factor := 1.0 + pet.stage * 0.05
	var body_radius := 48.0 * scale_factor
	var head_radius := 56.0 * scale_factor
	# aura
	if pet.emotion == "feliz":
		draw_circle(center, head_radius + 12.0, Color(accent, 0.12 + sin(pulse * 4.0) * 0.04))
	# ears
	var ear_left := PackedVector2Array([center + Vector2(-38, -35), center + Vector2(-58, -82), center + Vector2(-12, -50)])
	var ear_right := PackedVector2Array([center + Vector2(38, -35), center + Vector2(58, -82), center + Vector2(12, -50)])
	draw_colored_polygon(ear_left, main_color)
	draw_colored_polygon(ear_right, main_color)
	# body and head
	draw_circle(center + Vector2(0, 47), body_radius, main_color)
	draw_circle(center, head_radius, main_color)
	draw_arc(center, head_radius, 0, TAU, 48, Color("#3b3048"), 3.0)
	# eyes
	var eye_color := Color("#3b3048")
	if pet.emotion == "sonolento":
		draw_line(center + Vector2(-24, 0), center + Vector2(-9, 0), eye_color, 4.0)
		draw_line(center + Vector2(9, 0), center + Vector2(24, 0), eye_color, 4.0)
	else:
		draw_circle(center + Vector2(-17, 0), 6.0, eye_color)
		draw_circle(center + Vector2(17, 0), 6.0, eye_color)
	# muzzle and expression
	draw_circle(center + Vector2(0, 18), 15.0, Color("#fff7e8", 0.8))
	if pet.emotion == "triste":
		draw_arc(center + Vector2(0, 22), 8.0, PI, TAU, 16, eye_color, 3.0)
	elif pet.emotion == "irritado":
		draw_line(center + Vector2(-27, -12), center + Vector2(-9, -7), eye_color, 3.0)
		draw_line(center + Vector2(9, -7), center + Vector2(27, -12), eye_color, 3.0)
	else:
		draw_arc(center + Vector2(0, 12), 8.0, 0, PI, 16, eye_color, 3.0)
	# faction mark
	draw_circle(center + Vector2(0, -62), 9.0, accent)
	# emotion particles
	if pet.emotion == "feliz":
		draw_string(ThemeDB.fallback_font, center + Vector2(72, -45), "✦", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, accent)
		draw_string(ThemeDB.fallback_font, center + Vector2(-84, -28), "✦", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, accent)
	elif pet.emotion == "sonolento":
		draw_string(ThemeDB.fallback_font, center + Vector2(62, -50), "Z", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b8a8e8"))
		draw_string(ThemeDB.fallback_font, center + Vector2(78, -70), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#b8a8e8"))
	elif pet.emotion == "doente":
		draw_circle(center + Vector2(-68, -42), 5.0, Color("#98d99a"))
		draw_circle(center + Vector2(70, -32), 4.0, Color("#98d99a"))
