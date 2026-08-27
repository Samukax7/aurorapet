extends PetRandomizer
## Ator visual independente para a batalha.
## Herda apenas o contrato das peças modulares, sem PetStats, PetSkills ou UI do lobby.
## A inversão horizontal representa o adversário olhando para o pet sem virar o sprite de cabeça para baixo.

@export var mirror_horizontal := false
@export var mirror_vertical := false
@export var battle_animation_state: StringName = &"idle"

@onready var battle_animation_player: AnimationPlayer = get_node_or_null(^"AnimationPlayer") as AnimationPlayer
@onready var battle_sprite: AnimatedSprite2D = get_node_or_null(^"BattleAnimatedSprite") as AnimatedSprite2D

func _ready() -> void:
	super._ready()
	_apply_battle_direction()

func set_battle_transform(target_position: Vector2, uniform_scale: float, should_mirror: bool) -> void:
	position = target_position
	mirror_horizontal = should_mirror
	scale = Vector2(absf(uniform_scale), absf(uniform_scale))
	_apply_battle_direction()
	# Mantém reações futuras presas à escala e posição do ator, não às do lobby.
	_reaction_origin = position
	_reaction_scale = scale

func set_battle_mirror(value: bool) -> void:
	mirror_horizontal = value
	_apply_battle_direction()
	_reaction_scale = scale

func set_battle_flip(horizontal: bool, vertical: bool = false) -> void:
	mirror_horizontal = horizontal
	mirror_vertical = vertical
	_apply_battle_direction()
	_reaction_scale = scale

func set_battle_sprite_frames(sprite_frames: SpriteFrames, default_animation: StringName = &"idle") -> void:
	if battle_sprite == null:
		return
	battle_sprite.sprite_frames = sprite_frames
	if sprite_frames != null and sprite_frames.has_animation(default_animation):
		battle_sprite.animation = default_animation
		battle_sprite.visible = true

func play_battle_animation(animation_name: StringName = &"idle") -> void:
	battle_animation_state = animation_name
	if battle_sprite != null and battle_sprite.sprite_frames != null and battle_sprite.sprite_frames.has_animation(animation_name):
		battle_sprite.animation = animation_name
		battle_sprite.play()
		return
	if battle_animation_player != null and battle_animation_player.has_animation(animation_name):
		battle_animation_player.play(animation_name)

func _apply_battle_direction() -> void:
	var magnitude_x := absf(scale.x)
	var magnitude_y := absf(scale.y)
	if is_zero_approx(magnitude_x):
		magnitude_x = 1.0
	if is_zero_approx(magnitude_y):
		magnitude_y = 1.0
	scale = Vector2(-magnitude_x if mirror_horizontal else magnitude_x, -magnitude_y if mirror_vertical else magnitude_y)
