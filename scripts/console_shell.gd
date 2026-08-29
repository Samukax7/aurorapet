extends Sprite2D
class_name AuroraPetConsoleShell

## Casca principal do AuroraPet: traduz os controles físicos para o mesmo
## gameplay usado pela apresentação mobile.

@onready var gameplay_root: Node = $GameplayRoot

func _ready() -> void:
	$ButtonGreen.pressed.connect(func(): gameplay_root.call("input_confirm"))
	$ButtonYellow.pressed.connect(func(): gameplay_root.call("input_status"))
	$ButtonPink.pressed.connect(func(): gameplay_root.call("input_back"))
	$DPadUp.pressed.connect(func(): gameplay_root.call("input_navigate", Vector2i.UP))
	$DPadDown.pressed.connect(func(): gameplay_root.call("input_navigate", Vector2i.DOWN))
	$DPadLeft.pressed.connect(func(): gameplay_root.call("input_navigate", Vector2i.LEFT))
	$DPadRight.pressed.connect(func(): gameplay_root.call("input_navigate", Vector2i.RIGHT))

func get_gameplay_root() -> Node:
	return gameplay_root
