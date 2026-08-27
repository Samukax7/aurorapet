extends Control

## Apresentação de entrada exclusiva do Boss.
## O runtime usa um spritesheet PNG porque o Godot não importa GIF animado diretamente;
## o GIF original permanece no pacote como referência e fallback de distribuição.

signal presentation_finished

@onready var backdrop: TextureRect = $Backdrop
@onready var tint: ColorRect = $Tint
@onready var boss_sprite: AnimatedSprite2D = $BossSprite
@onready var intro_audio: AudioStreamPlayer = $IntroAudio

const BOSS_INTRO_PACKAGES: Dictionary = {
	"gorgon glitch": {
		"sheet": "res://assets/bosses/gorgon_glitch/gorgon_glitch_intro_spritesheet.png",
		"columns": 13,
		"rows": 6,
		"speed": 12.0,
		"background": "res://assets/bosses/gorgon_glitch/gorgon_glitch_battle_background.jpg",
		"audio": "res://assets/bosses/gorgon_glitch/gorgon_glitch_intro_audio.ogg",
	}
}

var _presentation_active := false

func _ready() -> void:
	visible = false
	boss_sprite.animation_finished.connect(_on_sprite_animation_finished)

func has_package(boss_name: String) -> bool:
	return not BOSS_INTRO_PACKAGES.get(boss_name.strip_edges().to_lower(), {}).is_empty()

func play_for_boss(boss_name: String) -> bool:
	var package: Dictionary = BOSS_INTRO_PACKAGES.get(boss_name.strip_edges().to_lower(), {})
	if package.is_empty():
		return false
	var sheet := load(String(package["sheet"])) as Texture2D
	var background := load(String(package["background"])) as Texture2D
	var audio_stream := load(String(package["audio"])) as AudioStream
	if sheet == null or background == null:
		return false
	var columns: int = maxi(1, int(package["columns"]))
	var rows: int = maxi(1, int(package["rows"]))
	var frames := SpriteFrames.new()
	frames.add_animation(&"intro")
	frames.set_animation_speed(&"intro", float(package["speed"]))
	frames.set_animation_loop(&"intro", false)
	var frame_width := float(sheet.get_width()) / float(columns)
	var frame_height := float(sheet.get_height()) / float(rows)
	for frame_index in columns * rows:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(
			float(frame_index % columns) * frame_width,
			float(frame_index / columns) * frame_height,
			frame_width,
			frame_height
		)
		frames.add_frame(&"intro", atlas)
	boss_sprite.sprite_frames = frames
	boss_sprite.animation = &"intro"
	boss_sprite.frame = 0
	backdrop.texture = background
	intro_audio.stream = audio_stream
	visible = true
	_presentation_active = true
	boss_sprite.play()
	if intro_audio.stream != null:
		intro_audio.play()
	return true

func skip() -> void:
	_finish_presentation()

func _on_sprite_animation_finished() -> void:
	_finish_presentation()

func _finish_presentation() -> void:
	if not _presentation_active:
		return
	_presentation_active = false
	boss_sprite.stop()
	if intro_audio != null:
		intro_audio.stop()
	visible = false
	presentation_finished.emit()
