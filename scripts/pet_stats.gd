extends Node
class_name PetStats

## Sistema simples de necessidades do pet para a fase de prototipagem.
## Os valores ficam entre 0 e 100 e são alterados pelo tempo e pelas ações.

signal stats_changed(hunger: float, energy: float, mood: float, health: float)
signal action_performed(action: StringName)

@export_category("Valores iniciais")
@export_range(0.0, 100.0, 1.0) var hunger := 82.0
@export_range(0.0, 100.0, 1.0) var energy := 76.0
@export_range(0.0, 100.0, 1.0) var mood := 68.0
@export_range(0.0, 100.0, 1.0) var health := 91.0

@export_category("Decaimento por segundo")
@export var decay_enabled := true
@export_range(0.0, 10.0, 0.01) var hunger_decay := 0.15
@export_range(0.0, 10.0, 0.01) var energy_decay := 0.12
@export_range(0.0, 10.0, 0.01) var mood_decay := 0.10
@export_range(0.0, 10.0, 0.01) var health_decay := 0.03
@export_range(0.0, 5.0, 0.05) var decay_multiplier := 1.0

func _ready() -> void:
	_clamp_values()
	_emit_stats()

func _process(delta: float) -> void:
	if not decay_enabled or delta <= 0.0:
		return
	hunger -= hunger_decay * decay_multiplier * delta
	energy -= energy_decay * decay_multiplier * delta
	mood -= mood_decay * decay_multiplier * delta
	health -= health_decay * decay_multiplier * delta
	_clamp_values()
	_emit_stats()

## Aplica o efeito básico de uma ação confirmada no menu.
func perform_action(action: StringName) -> void:
	match action:
		&"comer":
			hunger += 24.0
			energy -= 2.0
			health += 1.0
		&"brincar":
			mood += 24.0
			energy -= 12.0
			hunger -= 8.0
		&"limpar":
			health += 14.0
			mood += 8.0
			energy -= 3.0
		&"treinar":
			mood += 10.0
			energy -= 18.0
			hunger -= 10.0
			health += 3.0
		&"dormir":
			energy += 36.0
			mood += 5.0
			hunger -= 7.0
			health += 2.0
		_:
			push_warning("Ação desconhecida: %s" % action)
			return
	_clamp_values()
	_emit_stats()
	action_performed.emit(action)

func set_stat(stat: StringName, value: float) -> void:
	match stat:
		&"fome": hunger = value
		&"energia": energy = value
		&"humor": mood = value
		&"saude": health = value
		_:
			push_warning("Status desconhecido: %s" % stat)
			return
	_clamp_values()
	_emit_stats()

func _clamp_values() -> void:
	hunger = clampf(hunger, 0.0, 100.0)
	energy = clampf(energy, 0.0, 100.0)
	mood = clampf(mood, 0.0, 100.0)
	health = clampf(health, 0.0, 100.0)

func _emit_stats() -> void:
	stats_changed.emit(hunger, energy, mood, health)
