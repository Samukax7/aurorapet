class_name PetState
extends Resource

signal pet_changed
signal message_emitted(text: String)
signal evolved(stage_name: String)

var seed_value: int = 0
var pet_name: String = ""
var faction: String = "Neutro"
var race: String = "Guardião"
var stage: int = 0
var level: int = 1
var xp: int = 0
var last_tick_ms: int = 0

var hunger: float = 85.0
var energy: float = 85.0
var health: float = 100.0
var happiness: float = 80.0
var obedience: float = 50.0
var strength: float = 20.0
var defense: float = 20.0
var agility: float = 20.0
var intelligence: float = 20.0
var resistance: float = 20.0

var emotion: String = "neutro"
var action_cooldown: float = 0.0

const PREFIXES := {
	"Luz": ["Auri", "Lumi", "Sera", "Celes"],
	"Trevas": ["Umbr", "Noct", "Vex", "Shad"],
	"Neutro": ["Terr", "Aer", "Cosm", "Novi"]
}
const SUFFIXES := ["iel", "ara", "ion", "ys", "en"]
const RACES := {
	"Luz": ["Serafim", "Fada Estelar", "Guardião Solar"],
	"Trevas": ["Sombra", "Corvo Espectral", "Demônio Lunar"],
	"Neutro": ["Guardião", "Espírito Elemental", "Animal Cósmico"]
}
const STAGES := ["Bebê", "Criança", "Adolescente", "Jovem"]

func _init() -> void:
	last_tick_ms = Time.get_ticks_msec()

func generate_new(value: int = -1) -> void:
	seed_value = value if value >= 0 else int(Time.get_unix_time_from_system()) % 1000000000
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	strength = rng.randi_range(10, 40)
	defense = rng.randi_range(10, 40)
	agility = rng.randi_range(10, 40)
	intelligence = rng.randi_range(10, 40)
	resistance = rng.randi_range(10, 40)
	var luck := rng.randi_range(0, 100)
	var total := strength + defense + agility + intelligence + resistance + luck
	if total >= 330:
		faction = "Luz"
	elif total <= 190:
		faction = "Trevas"
	else:
		faction = "Neutro"
	var hash_value := absi(seed_value + total * 17)
	var faction_races: Array = RACES[faction]
	race = faction_races[hash_value % faction_races.size()]
	pet_name = PREFIXES[faction][hash_value % PREFIXES[faction].size()] + SUFFIXES[hash_value % SUFFIXES.size()]
	message_emitted.emit("Um novo AuroraPet nasceu: %s" % pet_name)
	pet_changed.emit()

func tick(delta: float) -> void:
	if action_cooldown > 0.0:
		action_cooldown = maxf(0.0, action_cooldown - delta)
		return
	var resistance_factor := clampf(1.0 - resistance / 200.0, 0.35, 1.0)
	hunger = maxf(0.0, hunger - delta * 0.18 * resistance_factor)
	energy = maxf(0.0, energy - delta * 0.12 * resistance_factor)
	happiness = maxf(0.0, happiness - delta * 0.07 * resistance_factor)
	if hunger < 20.0 or energy < 20.0:
		health = maxf(0.0, health - delta * 0.04)
	update_emotion()
	pet_changed.emit()

func feed(amount: float = 18.0) -> void:
	if action_cooldown > 0.0: return
	hunger = minf(100.0, hunger + amount)
	happiness = minf(100.0, happiness + 3.0)
	xp_gain(8)
	perform_action(1.0, "%s comeu e parece satisfeito." % pet_name)

func play() -> void:
	if action_cooldown > 0.0 or energy < 8.0: return
	energy = maxf(0.0, energy - 8.0)
	hunger = maxf(0.0, hunger - 5.0)
	happiness = minf(100.0, happiness + 18.0)
	xp_gain(15)
	perform_action(2.0, "%s brincou com você." % pet_name)

func rest() -> void:
	if action_cooldown > 0.0: return
	energy = minf(100.0, energy + 28.0)
	happiness = minf(100.0, happiness + 2.0)
	perform_action(2.0, "%s tirou uma soneca." % pet_name)

func praise() -> void:
	if action_cooldown > 0.0: return
	happiness = minf(100.0, happiness + 8.0)
	obedience = minf(100.0, obedience + 4.0)
	xp_gain(5)
	perform_action(1.0, "%s ficou contente com o elogio." % pet_name)

func train() -> void:
	if action_cooldown > 0.0 or energy < 12.0: return
	energy = maxf(0.0, energy - 12.0)
	hunger = maxf(0.0, hunger - 8.0)
	strength = minf(100.0, strength + 2.0)
	agility = minf(100.0, agility + 1.0)
	intelligence = maxf(0.0, intelligence - 0.5)
	xp_gain(30)
	perform_action(3.0, "%s treinou e ficou mais forte." % pet_name)

func xp_gain(amount: int) -> void:
	xp += amount
	while xp >= 100:
		xp -= 100
		level += 1
		strength = minf(100.0, strength + 1.0)
		defense = minf(100.0, defense + 1.0)
		message_emitted.emit("%s alcançou o nível %d." % [pet_name, level])
	check_evolution()

func check_evolution() -> void:
	if stage >= STAGES.size() - 1: return
	var average := (strength + defense + agility + intelligence) / 4.0
	var required_level := (stage + 1) * 3
	if level >= required_level and average >= 22.0 + stage * 8.0:
		stage += 1
		evolved.emit(STAGES[stage])
		message_emitted.emit("%s evoluiu para %s!" % [pet_name, STAGES[stage]])

func update_emotion() -> void:
	if health < 30.0:
		emotion = "doente"
	elif energy < 25.0:
		emotion = "sonolento"
	elif happiness < 25.0:
		emotion = "triste"
	elif happiness > 78.0 and health > 70.0:
		emotion = "feliz"
	else:
		emotion = "neutro"

func perform_action(cooldown: float, text: String) -> void:
	action_cooldown = cooldown
	update_emotion()
	message_emitted.emit(text)
	pet_changed.emit()
