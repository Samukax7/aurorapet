extends Node2D

## Ator visual exclusivo de Boss em batalha.
## Cada Boss pode registrar seu próprio pacote de spritesheets. O Gorgon Glitch
## é o primeiro pacote; Bosses ainda não animados usam o sprite estático de fallback.

@export var battle_animation_state: StringName = &"idle"

signal action_animation_finished(animation_name: StringName)

@onready var animated_sprite: AnimatedSprite2D = $BossAnimatedSprite
@onready var static_sprite: Sprite2D = $BossStaticSprite

func _ready() -> void:
	if animated_sprite != null and not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if animated_sprite == null:
		return
	var finished_animation := animated_sprite.animation
	if finished_animation in [&"idle", &"defeat"]:
		return
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(&"idle"):
		return
	animated_sprite.animation = &"idle"
	animated_sprite.frame = 0
	animated_sprite.frame_progress = 0.0
	animated_sprite.speed_scale = 1.0
	animated_sprite.play()
	battle_animation_state = &"idle"
	action_animation_finished.emit(finished_animation)

func get_battle_animation_duration(animation_name: StringName) -> float:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return 0.0
	var frames := animated_sprite.sprite_frames
	if not frames.has_animation(animation_name):
		return 0.0
	var frame_count := frames.get_frame_count(animation_name)
	var frames_per_second := frames.get_animation_speed(animation_name)
	return float(frame_count) / maxf(frames_per_second, 0.1)

const BOSS_ANIMATION_PACKAGES: Dictionary = {
	"gorgon glitch": {
		"idle": {"path": "res://assets/bosses/gorgon_glitch/gorgon_glitch_idle_spritesheet.png", "columns": 3, "rows": 1, "speed": 4.0, "loop": true},
		"attack_basic": {"path": "res://assets/bosses/gorgon_glitch/gorgon_glitch_attack_basic_spritesheet.png", "columns": 6, "rows": 1, "speed": 9.0, "loop": false},
		"attack_charged": {"path": "res://assets/bosses/gorgon_glitch/gorgon_glitch_attack_charged_spritesheet.png", "columns": 6, "rows": 2, "speed": 8.0, "loop": false},
		"defend": {"path": "res://assets/bosses/gorgon_glitch/gorgon_glitch_defend_spritesheet.png", "columns": 4, "rows": 1, "speed": 8.0, "loop": false},
		"hurt": {"path": "res://assets/bosses/gorgon_glitch/gorgon_glitch_hurt_spritesheet.png", "columns": 3, "rows": 1, "speed": 7.0, "loop": false},
		"defeat": {"path": "res://assets/bosses/gorgon_glitch/gorgon_glitch_defeat_spritesheet.png", "columns": 8, "rows": 4, "speed": 8.0, "loop": false},
	}
}

func set_boss_texture(texture: Texture2D) -> void:
	static_sprite.texture = texture
	# O fallback não pode aparecer durante o carregamento dos frames do Boss.
	# Ele só volta a ser visível se o perfil não possuir spritesheet animado.
	static_sprite.visible = false
	if animated_sprite.sprite_frames == null or animated_sprite.sprite_frames.get_animation_names().is_empty():
		animated_sprite.visible = false

func configure_boss_profile(boss_name: String) -> bool:
	var profile: Dictionary = BOSS_ANIMATION_PACKAGES.get(boss_name.strip_edges().to_lower(), {})
	if profile.is_empty():
		set_boss_sprite_frames(null)
		return false
	var frames := SpriteFrames.new()
	for existing_animation in frames.get_animation_names():
		frames.remove_animation(existing_animation)
	for animation_name in profile.keys():
		var definition: Dictionary = profile[animation_name]
		var texture := load(String(definition["path"])) as Texture2D
		if texture == null:
			continue
		var columns: int = maxi(1, int(definition["columns"]))
		var rows: int = maxi(1, int(definition["rows"]))
		var frame_width := float(texture.get_width()) / float(columns)
		var frame_height := float(texture.get_height()) / float(rows)
		frames.add_animation(StringName(animation_name))
		frames.set_animation_speed(StringName(animation_name), float(definition["speed"]))
		frames.set_animation_loop(StringName(animation_name), bool(definition["loop"]))
		for frame_index in columns * rows:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				float(frame_index % columns) * frame_width,
				float(frame_index / columns) * frame_height,
				frame_width,
				frame_height
			)
			frames.add_frame(StringName(animation_name), atlas)
	set_boss_sprite_frames(frames, &"idle")
	return not frames.get_animation_names().is_empty()

func set_boss_sprite_frames(sprite_frames: SpriteFrames, default_animation: StringName = &"idle") -> void:
	animated_sprite.sprite_frames = sprite_frames
	if sprite_frames == null or sprite_frames.get_animation_names().is_empty():
		animated_sprite.visible = false
		static_sprite.visible = static_sprite.texture != null
		return
	var animation_name: StringName = default_animation
	if not sprite_frames.has_animation(default_animation):
		animation_name = StringName(sprite_frames.get_animation_names()[0])
	animated_sprite.animation = animation_name
	animated_sprite.frame = 0
	animated_sprite.frame_progress = 0.0
	animated_sprite.speed_scale = 1.0
	animated_sprite.visible = true
	static_sprite.visible = false
	animated_sprite.play()

func play_battle_animation(animation_name: StringName = &"idle") -> void:
	battle_animation_state = animation_name
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.animation = animation_name
		animated_sprite.frame = 0
		animated_sprite.frame_progress = 0.0
		animated_sprite.speed_scale = 1.0
		animated_sprite.play()

func stop_battle_animation() -> void:
	if animated_sprite != null:
		animated_sprite.stop()

func set_battle_transform(target_position: Vector2, uniform_scale: float) -> void:
	position = target_position
	scale = Vector2(absf(uniform_scale), absf(uniform_scale))
