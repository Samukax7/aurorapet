extends Control
class_name ScreenContentSpace

## Contrato único de coordenadas para todas as telas internas do AuroraPet.
## A janela pode escalar este espaço; as cenas não devem depender do tamanho da janela.

const LOGICAL_SIZE := Vector2(1080.0, 650.0)
const LOGICAL_CENTER := Vector2(540.0, 325.0)

func _ready() -> void:
	custom_minimum_size = LOGICAL_SIZE
	if size.x <= 0.0 or size.y <= 0.0:
		size = LOGICAL_SIZE

func get_logical_size() -> Vector2:
	return LOGICAL_SIZE

func get_logical_center() -> Vector2:
	return LOGICAL_CENTER

func center_control(control_size: Vector2) -> Vector2:
	return (LOGICAL_SIZE - control_size) * 0.5
