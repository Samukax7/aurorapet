extends Node
class_name PetIdentity

## Identidade procedural persistente do AuroraPet.
## A identidade controla contexto e pesos; o PetRandomizer continua controlando as peças reais.

signal identity_generated(snapshot: Dictionary)

@export_category("Identidade")
@export var generate_on_ready := true
@export var identity_seed: int = 0
@export var apply_attribute_bias_on_ready := true

var faction_id: StringName = &""
var faction_label := ""
var lineage_id: StringName = &""
var lineage_label := ""
var element: StringName = &""
var gender: StringName = &""
var pet_name := ""
var traits: Array[StringName] = []
var attribute_bias: Dictionary = {}
var preferred_palette_names: Array[StringName] = []
var part_weights: Dictionary = {}
var _bias_applied := false
var _used_names: Array[String] = []
var _rng := RandomNumberGenerator.new()

const FACTION_DATA: Dictionary = {
	&"luz": {
		"label": "Aurora da Luz",
		"lineages": [&"serafim", &"fada_estelar"],
	},
	&"trevas": {
		"label": "Aurora das Trevas",
		"lineages": [&"sombra", &"corvo_espectral"],
	},
	&"neutro": {
		"label": "Aurora Neutra",
		"lineages": [&"espirito", &"guardiao_elemental"],
	},
}

const LINEAGE_DATA: Dictionary = {
	&"serafim": {
		"faction": &"luz",
		"label": "Serafim",
		"elements": [&"fogo_sagrado", &"vento_celestial", &"cristal"],
		"traits": [&"protetor", &"sereno", &"luminoso", &"leal"],
		"names": {"prefix": ["Auri", "Soli", "Eli", "Lumi"], "suffix": ["el", "ia", "on", "is"]},
		"attribute_bias": {"forca": 0, "defesa": 2, "agilidade": 1, "inteligencia": 1},
		"palettes": [&"dourado_estelar", &"azul_eletrico", &"rosa_quasar"],
		"part_weights": {
			&"eyes": {1: 1.0, 2: 3.0, 3: 1.0, 4: 1.0, 5: 1.0},
			&"ears": {1: 3.0, 2: 2.0, 3: 1.0, 4: 1.0, 5: 1.0},
			&"wings": {1: 4.0, 2: 3.0, 3: 1.0, 4: 1.0, 5: 1.0},
			&"tail": {1: 3.0, 2: 1.0, 3: 1.0, 4: 1.0, 5: 1.0},
		},
	},
	&"fada_estelar": {
		"faction": &"luz",
		"label": "Fada Estelar",
		"elements": [&"cristal", &"vento_celestial", &"planta"],
		"traits": [&"curioso", &"brilhante", &"brincalhao", &"sensivel"],
		"names": {"prefix": ["Lira", "Astra", "Mira", "Nebu"], "suffix": ["ia", "elle", "ix", "ara"]},
		"attribute_bias": {"forca": 0, "defesa": 1, "agilidade": 2, "inteligencia": 2},
		"palettes": [&"magenta_galactico", &"ciano_cometa", &"rosa_quasar"],
		"part_weights": {
			&"eyes": {1: 1.0, 2: 2.0, 3: 3.0, 4: 1.0, 5: 1.0},
			&"ears": {1: 1.0, 2: 1.0, 3: 3.0, 4: 2.0, 5: 1.0},
			&"wings": {1: 1.0, 2: 3.0, 3: 2.0, 4: 1.0, 5: 1.0},
			&"tail": {1: 1.0, 2: 2.0, 3: 2.0, 4: 2.0, 5: 1.0},
		},
	},
	&"sombra": {
		"faction": &"trevas",
		"label": "Sombra",
		"elements": [&"chamas_negras", &"sombras", &"veneno"],
		"traits": [&"intenso", &"astuto", &"reservado", &"resiliente"],
		"names": {"prefix": ["Nox", "Umbra", "Vey", "Nyx"], "suffix": ["is", "ra", "on", "eth"]},
		"attribute_bias": {"forca": 2, "defesa": 1, "agilidade": 1, "inteligencia": 0},
		"palettes": [&"violeta_cosmico", &"magenta_galactico", &"coral_nebulosa"],
		"part_weights": {
			&"eyes": {1: 1.0, 2: 1.0, 3: 1.0, 4: 3.0, 5: 2.0},
			&"ears": {1: 1.0, 2: 1.0, 3: 1.0, 4: 2.0, 5: 3.0},
			&"wings": {1: 1.0, 2: 1.0, 3: 1.0, 4: 2.0, 5: 3.0},
			&"tail": {1: 1.0, 2: 1.0, 3: 1.0, 4: 2.0, 5: 3.0},
		},
	},
	&"corvo_espectral": {
		"faction": &"trevas",
		"label": "Corvo Espectral",
		"elements": [&"sombras", &"vento", &"metal"],
		"traits": [&"observador", &"independente", &"silencioso", &"vigilante"],
		"names": {"prefix": ["Raven", "Noct", "Vesper", "Karo"], "suffix": ["is", "en", "or", "a"]},
		"attribute_bias": {"forca": 1, "defesa": 1, "agilidade": 2, "inteligencia": 1},
		"palettes": [&"violeta_cosmico", &"azul_eletrico", &"ciano_cometa"],
		"part_weights": {
			&"eyes": {1: 1.0, 2: 1.0, 3: 2.0, 4: 2.0, 5: 2.0},
			&"ears": {1: 1.0, 2: 2.0, 3: 1.0, 4: 2.0, 5: 2.0},
			&"wings": {1: 1.0, 2: 1.0, 3: 2.0, 4: 3.0, 5: 1.0},
			&"tail": {1: 2.0, 2: 1.0, 3: 1.0, 4: 2.0, 5: 2.0},
		},
	},
	&"espirito": {
		"faction": &"neutro",
		"label": "Espírito",
		"elements": [&"agua", &"planta", &"vento"],
		"traits": [&"adaptavel", &"empatico", &"tranquilo", &"curioso"],
		"names": {"prefix": ["Eon", "Nubi", "Aera", "Omi"], "suffix": ["a", "en", "i", "um"]},
		"attribute_bias": {"forca": 1, "defesa": 1, "agilidade": 1, "inteligencia": 1},
		"palettes": [&"verde_plasma", &"esmeralda_aurora", &"azul_eletrico"],
		"part_weights": {
			&"eyes": {1: 2.0, 2: 2.0, 3: 2.0, 4: 1.0, 5: 1.0},
			&"ears": {1: 2.0, 2: 2.0, 3: 2.0, 4: 1.0, 5: 1.0},
			&"wings": {1: 2.0, 2: 2.0, 3: 1.0, 4: 1.0, 5: 1.0},
			&"tail": {1: 2.0, 2: 2.0, 3: 2.0, 4: 1.0, 5: 1.0},
		},
	},
	&"guardiao_elemental": {
		"faction": &"neutro",
		"label": "Guardião Elemental",
		"elements": [&"terra", &"pedra", &"metal"],
		"traits": [&"firme", &"leal", &"pratico", &"protetor"],
		"names": {"prefix": ["Gala", "Tera", "Orbi", "Kora"], "suffix": ["dor", "on", "ia", "um"]},
		"attribute_bias": {"forca": 2, "defesa": 2, "agilidade": 0, "inteligencia": 0},
		"palettes": [&"laranja_solar", &"dourado_estelar", &"ciano_cometa"],
		"part_weights": {
			&"eyes": {1: 2.0, 2: 1.0, 3: 2.0, 4: 1.0, 5: 2.0},
			&"ears": {1: 2.0, 2: 1.0, 3: 2.0, 4: 2.0, 5: 1.0},
			&"wings": {1: 1.0, 2: 2.0, 3: 1.0, 4: 2.0, 5: 1.0},
			&"tail": {1: 2.0, 2: 1.0, 3: 2.0, 4: 1.0, 5: 2.0},
		},
	},
}

func _ready() -> void:
	if generate_on_ready:
		generate_new_identity()

func ensure_generated() -> void:
	if pet_name.is_empty() or faction_id.is_empty() or lineage_id.is_empty():
		generate_new_identity()

func generate_new_identity(new_seed: int = 0) -> void:
	if new_seed != 0:
		identity_seed = new_seed
	elif identity_seed == 0:
		_rng.randomize()
		identity_seed = int(_rng.randi())
	else:
		_rng.seed = identity_seed
	_rng.seed = identity_seed

	var faction_ids: Array = FACTION_DATA.keys()
	faction_id = faction_ids[_rng.randi_range(0, faction_ids.size() - 1)]
	var faction: Dictionary = FACTION_DATA[faction_id]
	faction_label = String(faction["label"])
	var lineage_options: Array = faction["lineages"]
	lineage_id = lineage_options[_rng.randi_range(0, lineage_options.size() - 1)]
	var lineage: Dictionary = LINEAGE_DATA[lineage_id]
	lineage_label = String(lineage["label"])
	var elements: Array = lineage["elements"]
	element = elements[_rng.randi_range(0, elements.size() - 1)]
	gender = [&"feminino", &"masculino", &"neutro"][_rng.randi_range(0, 2)]
	traits = _pick_unique_traits(lineage["traits"], 2)
	attribute_bias = lineage["attribute_bias"].duplicate(true)
	preferred_palette_names.clear()
	for palette_name in lineage["palettes"]:
		preferred_palette_names.append(palette_name)
	part_weights = lineage["part_weights"].duplicate(true)
	pet_name = _generate_name(lineage["names"])
	if apply_attribute_bias_on_ready and not _bias_applied:
		call_deferred("_apply_attribute_bias_once")
	identity_generated.emit(get_identity_snapshot())

func choose_part_variant(part: StringName, rng: RandomNumberGenerator) -> int:
	var weights: Dictionary = part_weights.get(part, {})
	if weights.is_empty():
		return rng.randi_range(1, 5)
	var total := 0.0
	for variant in range(1, 6):
		total += maxf(0.0, float(weights.get(variant, 1.0)))
	if total <= 0.0:
		return rng.randi_range(1, 5)
	var roll := rng.randf_range(0.0, total)
	for variant in range(1, 6):
		roll -= maxf(0.0, float(weights.get(variant, 1.0)))
		if roll <= 0.0:
			return variant
	return 5

func get_identity_snapshot() -> Dictionary:
	return {
		"identity_seed": identity_seed,
		"name": pet_name,
		"gender": gender,
		"faction": faction_id,
		"faction_label": faction_label,
		"lineage": lineage_id,
		"lineage_label": lineage_label,
		"element": element,
		"traits": traits.duplicate(),
		"attribute_bias": attribute_bias.duplicate(true),
		"preferred_palette_names": preferred_palette_names.duplicate(),
	}

func get_preferred_palette_names() -> Array[StringName]:
	return preferred_palette_names.duplicate()

func get_attribute_bias() -> Dictionary:
	return attribute_bias.duplicate(true)

func _generate_name(name_data: Dictionary) -> String:
	var prefixes: Array = name_data.get("prefix", [])
	var suffixes: Array = name_data.get("suffix", [])
	if prefixes.is_empty() or suffixes.is_empty():
		return "Aurora"
	var candidate := ""
	for attempt in range(12):
		candidate = String(prefixes[_rng.randi_range(0, prefixes.size() - 1)]) + String(suffixes[_rng.randi_range(0, suffixes.size() - 1)])
		if not _used_names.has(candidate):
			_used_names.append(candidate)
			return candidate
	return candidate

func _pick_unique_traits(pool: Array, count: int) -> Array[StringName]:
	var available: Array = pool.duplicate()
	var result: Array[StringName] = []
	while not available.is_empty() and result.size() < count:
		var index := _rng.randi_range(0, available.size() - 1)
		result.append(available[index])
		available.remove_at(index)
	return result

func _apply_attribute_bias_once() -> void:
	if _bias_applied:
		return
	var skills := get_parent().get_node_or_null(^"PetSkills") as PetSkills
	if skills != null:
		skills.apply_identity_bias(attribute_bias)
		_bias_applied = true
