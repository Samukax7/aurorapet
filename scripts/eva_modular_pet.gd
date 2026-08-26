extends Node2D
class_name EvaModularPet

## EVA jogável/recompensa visual, separada da EVA narrativa e da EVA DEV.
## Os seis primeiros estágios usam a folha idle evolutiva; o sétimo usa a forma cósmica.

signal stage_changed(stage_index: int, stage_name: StringName)

const STAGE_NAMES: Array[StringName] = [
	&"bebê",
	&"criança",
	&"adolescente",
	&"jovem_adulta",
	&"anciã",
	&"lendária",
	&"deusa_cosmica",
]
const IDLE_FRAMES_PER_STAGE := 3
const GODDESS_IDLE_START := 192
const GODDESS_IDLE_COUNT := 48

@export_range(0, 6, 1) var stage_index := 0
@export var idle_fps := 5.0
@export var goddess_fps := 10.0
@export var pixel_scale := 3.0

@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var goddess_sprite: Sprite2D = $GoddessSprite
@onready var aura: CPUParticles2D = $Aura

var elapsed := 0.0
var _last_stage := -1

func _ready() -> void:
	_apply_stage()

func set_stage(value: int) -> void:
	stage_index = clampi(value, 0, STAGE_NAMES.size() - 1)
	_apply_stage()

func get_stage_name() -> StringName:
	return STAGE_NAMES[clampi(stage_index, 0, STAGE_NAMES.size() - 1)]

func play_reaction(reaction: StringName = &"idle") -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	match reaction:
		&"happy", &"victory", &"helped":
			tween.tween_property(self, "position:y", position.y - 10.0, 0.14)
			tween.tween_property(self, "position:y", position.y, 0.18)
		&"hurt", &"refusal":
			tween.tween_property(self, "rotation", deg_to_rad(-5.0), 0.08)
			tween.tween_property(self, "rotation", deg_to_rad(5.0), 0.12)
			tween.tween_property(self, "rotation", 0.0, 0.10)
		_:
			tween.tween_property(self, "scale", Vector2(1.05, 0.96), 0.12)
			tween.tween_property(self, "scale", Vector2.ONE, 0.16)

func _process(delta: float) -> void:
	elapsed += delta
	if stage_index >= 6:
		goddess_sprite.frame = GODDESS_IDLE_START + posmod(int(elapsed * goddess_fps), GODDESS_IDLE_COUNT)
	else:
		var local_frame := posmod(int(elapsed * idle_fps), IDLE_FRAMES_PER_STAGE)
		idle_sprite.frame = stage_index * IDLE_FRAMES_PER_STAGE + local_frame
	if stage_index != _last_stage:
		_apply_stage()

func _apply_stage() -> void:
	if not is_node_ready():
		return
	stage_index = clampi(stage_index, 0, STAGE_NAMES.size() - 1)
	var goddess := stage_index >= 6
	idle_sprite.visible = not goddess
	goddess_sprite.visible = goddess
	aura.emitting = stage_index >= 4
	aura.amount = 8 + stage_index * 3
	aura.color = Color(0.42, 0.92, 1.0, 0.42) if goddess else Color(0.74, 0.54, 1.0, 0.30)
	idle_sprite.scale = Vector2.ONE * pixel_scale
	goddess_sprite.scale = Vector2.ONE * (pixel_scale * 0.72)
	_last_stage = stage_index
	stage_changed.emit(stage_index, get_stage_name())
