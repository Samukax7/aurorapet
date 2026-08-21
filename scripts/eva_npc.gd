extends Node2D
class_name EvaNPC

## Presença visual da EVA narrativa. O estado da campanha fica no EvaJourneyManager.

@export var idle_frame_start := 192
@export var idle_frame_count := 48
@export var frames_per_second := 12.0

@onready var sprite: Sprite2D = $Sprite

var active := false
var elapsed := 0.0

func _ready() -> void:
	visible = false
	sprite.frame = idle_frame_start

func activate() -> void:
	active = true
	visible = true
	elapsed = 0.0

func deactivate() -> void:
	active = false
	visible = false

func set_facing_left(facing_left: bool) -> void:
	sprite.flip_h = facing_left

func play_reaction(frame_start: int, frame_count: int = 24) -> void:
	active = true
	visible = true
	elapsed = 0.0
	idle_frame_start = clampi(frame_start, 0, 239)
	idle_frame_count = maxi(1, mini(frame_count, 240 - idle_frame_start))

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	sprite.frame = idle_frame_start + (int(elapsed * frames_per_second) % idle_frame_count)
