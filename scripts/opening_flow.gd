extends Control
class_name OpeningFlow

## Fluxo inicial do AuroraPet: logo, menu, história, facção, ovo e ficha RPG.
## O fluxo vive dentro do console e entrega o controle ao ConsoleController
## somente depois que o pet nasce ou um save é continuado.

signal flow_completed

const SAVE_PATH := "user://aurorapet_save.json"
const HATCH_HITS_REQUIRED := 8
const EGG_TEXTURES := {
	&"luz": "res://assets/UI/minigames/ovos/ovo_cosmico_Luz.png",
	&"trevas": "res://assets/UI/minigames/ovos/ovo_cosmico_trevas.png",
	&"neutro": "res://assets/UI/minigames/ovos/ovo_cosmico_neutro.png",
}

var active := true
var state: StringName = &"logo"
var menu_options: Array[StringName] = []
var menu_selected_index := 0
var story_page := 0
var faction_selected_index := 0
var selected_faction: StringName = &"neutro"
var hatch_hits := 0

var pet_identity: PetIdentity
var pet_skills: PetSkills
var pet_randomizer: PetRandomizer
var pet_ui: PetUI
var deepworld: Node
var pet_node: Node2D
var skill_tree: Node
var egg_base_position := Vector2(317, 405)
var egg_shake_tween: Tween

@onready var background: ColorRect = $Background
@onready var logo: Label = $Logo
@onready var logo_image: TextureRect = $LogoImage
@onready var logo_subtitle: Label = $LogoSubtitle
@onready var menu_panel: Panel = $MenuPanel
@onready var menu_title: Label = $MenuPanel/Title
@onready var menu_buttons: Array[Button] = [$MenuPanel/Menu/Start, $MenuPanel/Menu/Continue, $MenuPanel/Menu/Options]
@onready var menu_notice: Label = $MenuPanel/Notice
@onready var story_panel: Panel = $StoryPanel
@onready var story_page_label: Label = $StoryPanel/Page
@onready var story_body: Label = $StoryPanel/Body
@onready var story_back: Button = $StoryPanel/Back
@onready var story_next: Button = $StoryPanel/Next
@onready var faction_panel: Panel = $FactionPanel
@onready var faction_buttons: Array[Button] = [$FactionPanel/Options/Luz, $FactionPanel/Options/Trevas, $FactionPanel/Options/Neutro]
@onready var faction_hint: Label = $FactionPanel/Hint
@onready var egg_panel: Panel = $EggPanel
@onready var egg_label: Label = $EggPanel/Egg
@onready var egg_image: TextureRect = $EggImage
@onready var egg_progress: ProgressBar = $EggPanel/Progress
@onready var egg_hint: Label = $EggPanel/Hint
@onready var status_panel: Panel = $PetStatusPanel
@onready var status_identity: Label = $PetStatusPanel/Identity
@onready var status_attributes: Label = $PetStatusPanel/Attributes
@onready var status_hint: Label = $PetStatusPanel/Hint

func _ready() -> void:
	_connect_buttons()
	_hide_all_panels()
	_show_logo()

func configure(identity: PetIdentity, skills: PetSkills, randomizer: PetRandomizer, ui: PetUI, world: Node, tree: Node) -> void:
	pet_identity = identity
	pet_skills = skills
	pet_randomizer = randomizer
	pet_ui = ui
	deepworld = world
	pet_node = deepworld.get_node_or_null("Paisagem/Pet") as Node2D if deepworld != null else null
	skill_tree = tree
	if deepworld != null:
		deepworld.visible = false
	if pet_node != null:
		pet_node.visible = false
	if pet_ui != null:
		pet_ui.visible = false
	if skill_tree != null:
		skill_tree.visible = false

func _connect_buttons() -> void:
	for index in menu_buttons.size():
		menu_buttons[index].pressed.connect(_on_menu_button_pressed.bind(index))
	for index in faction_buttons.size():
		faction_buttons[index].pressed.connect(_on_faction_button_pressed.bind(index))
	story_back.pressed.connect(_on_story_back_pressed)
	story_next.pressed.connect(_on_story_next_pressed)
	$EggPanel/HitButton.pressed.connect(_on_egg_button_pressed)
	$PetStatusPanel/ExitButton.pressed.connect(_on_status_exit_pressed)

func handle_direction(direction: Vector2i) -> void:
	if not active:
		return
	match state:
		&"menu":
			if direction.y != 0:
				menu_selected_index = wrapi(menu_selected_index + (1 if direction.y > 0 else -1), 0, menu_options.size())
				_refresh_menu()
		&"story":
			if direction.x < 0 or direction.y < 0:
				_back_story()
			elif direction.x > 0 or direction.y > 0:
				_next_story()
		&"faction":
			if direction.x != 0 or direction.y != 0:
				var step := 1 if direction.x > 0 or direction.y > 0 else -1
				faction_selected_index = wrapi(faction_selected_index + step, 0, faction_buttons.size())
				_refresh_faction()

func confirm() -> void:
	if not active:
		return
	match state:
		&"logo":
			_show_menu()
		&"menu":
			_confirm_menu()
		&"story":
			_next_story()
		&"faction":
			_confirm_faction()
		&"egg":
			_hatch_step()
		&"status":
			_finish_flow()

func back() -> void:
	if not active:
		return
	match state:
		&"logo":
			_show_menu()
		&"story":
			_back_story()
		&"faction":
			_show_story(1)
		&"egg":
			_show_faction()
		&"status":
			_finish_flow()

func _show_logo() -> void:
	state = &"logo"
	background.color = Color("#FFFFFF")
	_hide_all_panels()
	logo.visible = false
	logo_image.visible = false
	logo_subtitle.visible = false
	logo_image.visible = true
	logo_image.position = Vector2(-760, 130)
	logo_image.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(logo_image, "position", Vector2(0, 130), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(logo_image, "modulate:a", 1.0, 0.55)
	tween.set_parallel(false)
	tween.tween_interval(0.65)
	tween.tween_property(logo_image, "modulate:a", 0.0, 0.35)
	tween.tween_callback(_show_menu)

func _show_menu() -> void:
	state = &"menu"
	background.color = Color("#FFFFFF")
	_hide_all_panels()
	menu_panel.visible = true
	menu_notice.text = "D-PAD: NAVEGAR   •   VERDE: CONFIRMAR"
	menu_options = [&"start", &"options"]
	if _has_save():
		menu_options = [&"start", &"continue", &"options"]
	menu_selected_index = 0
	_refresh_menu()

func _refresh_menu() -> void:
	var labels := {
		&"start": "START",
		&"continue": "CONTINUE",
		&"options": "OPTIONS",
	}
	for index in menu_buttons.size():
		var button := menu_buttons[index]
		var available := index < menu_options.size()
		button.visible = available
		if not available:
			continue
		var action: StringName = menu_options[index]
		button.text = String(labels[action])
		button.modulate = Color.WHITE if index == menu_selected_index else Color(0.65, 0.7, 0.8, 1.0)
		button.scale = Vector2(1.04, 1.04) if index == menu_selected_index else Vector2.ONE

func _confirm_menu() -> void:
	if menu_options.is_empty():
		return
	var action: StringName = menu_options[menu_selected_index]
	match action:
		&"start":
			_show_story(0)
		&"continue":
			_continue_saved_pet()
		&"options":
			menu_notice.text = "OPTIONS: CONFIGURAÇÕES EM BREVE"

func _show_story(page: int) -> void:
	state = &"story"
	story_page = clampi(page, 0, 1)
	background.color = Color("#FFFFFF")
	_hide_all_panels()
	story_panel.visible = true
	story_page_label.text = "DEEPWORLD  %d / 2" % (story_page + 1)
	if story_page == 0:
		story_body.text = "HISTÓRIA AQUI\n\nOs Deepmons nasceram entre estrelas, sonhos e forças antigas.\n\nEste espaço receberá a introdução oficial do universo."
	else:
		story_body.text = "HISTÓRIA AQUI\n\nA Deepworld é formada por caminhos de Luz, Trevas e equilíbrio Neutro.\n\nEste espaço receberá a explicação detalhada das facções."
	story_back.visible = story_page > 0
	story_next.text = "ESCOLHER FACÇÃO" if story_page == 1 else "PRÓXIMA"

func _next_story() -> void:
	if story_page < 1:
		_show_story(story_page + 1)
	else:
		_show_faction()

func _back_story() -> void:
	if story_page > 0:
		_show_story(story_page - 1)
	else:
		_show_menu()

func _show_faction() -> void:
	state = &"faction"
	background.color = Color("#071332")
	_hide_all_panels()
	faction_panel.visible = true
	faction_selected_index = 0
	_refresh_faction()

func _refresh_faction() -> void:
	var labels := ["LUZ", "TREVAS", "NEUTRO"]
	var factions: Array[StringName] = [&"luz", &"trevas", &"neutro"]
	for index in faction_buttons.size():
		faction_buttons[index].text = labels[index]
		faction_buttons[index].modulate = Color.WHITE if index == faction_selected_index else Color(0.5, 0.58, 0.75, 1.0)
		faction_buttons[index].scale = Vector2(1.08, 1.08) if index == faction_selected_index else Vector2.ONE
	selected_faction = factions[faction_selected_index]
	faction_hint.text = "FACÇÃO: %s   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR" % labels[faction_selected_index]

func _confirm_faction() -> void:
	var factions: Array[StringName] = [&"luz", &"trevas", &"neutro"]
	selected_faction = factions[faction_selected_index]
	if pet_skills != null:
		pet_skills.reset_for_new_pet()
	if pet_identity != null:
		pet_identity.generate_new_identity_for_faction(selected_faction)
	if pet_randomizer != null:
		pet_randomizer.reroll()
	_show_egg()

func _show_egg() -> void:
	state = &"egg"
	background.color = Color(0, 0, 0, 0)
	_hide_all_panels()
	if deepworld != null:
		deepworld.visible = true
	if pet_node != null:
		pet_node.visible = false
	egg_panel.visible = true
	egg_image.visible = true
	egg_image.position = egg_base_position
	egg_image.texture = load(String(EGG_TEXTURES.get(selected_faction, EGG_TEXTURES[&"neutro"]))) as Texture2D
	hatch_hits = 0
	egg_label.text = ""
	egg_progress.value = 0.0
	egg_hint.text = "APERTE VERDE PARA AJUDAR O OVO A CHOCAR\n0 / %d" % HATCH_HITS_REQUIRED

func _hatch_step() -> void:
	if hatch_hits >= HATCH_HITS_REQUIRED:
		return
	hatch_hits = mini(hatch_hits + 1, HATCH_HITS_REQUIRED)
	egg_progress.value = float(hatch_hits) / float(HATCH_HITS_REQUIRED) * 100.0
	egg_hint.text = "O OVO ESTÁ REAGINDO...\n%d / %d" % [hatch_hits, HATCH_HITS_REQUIRED]
	_shake_egg()
	if hatch_hits >= HATCH_HITS_REQUIRED:
		if egg_shake_tween != null:
			egg_shake_tween.kill()
		egg_image.position = egg_base_position
		egg_image.visible = false
		if pet_node != null:
			pet_node.visible = true
		_save_new_pet()
		_show_pet_status()

func _shake_egg() -> void:
	if egg_shake_tween != null:
		egg_shake_tween.kill()
	egg_image.position = egg_base_position
	egg_shake_tween = create_tween()
	egg_shake_tween.tween_property(egg_image, "position", egg_base_position + Vector2(-9, 0), 0.045)
	egg_shake_tween.tween_property(egg_image, "position", egg_base_position + Vector2(9, 0), 0.09)
	egg_shake_tween.tween_property(egg_image, "position", egg_base_position + Vector2(-5, 0), 0.07)
	egg_shake_tween.tween_property(egg_image, "position", egg_base_position, 0.06)

func _show_pet_status() -> void:
	state = &"status"
	background.color = Color("#FFFFFF")
	_hide_all_panels()
	status_panel.visible = true
	if pet_identity == null or pet_skills == null:
		status_identity.text = "IDENTIDADE AINDA NÃO DISPONÍVEL"
		status_attributes.text = "FORÇA --   DEFESA --\nAGILIDADE --   INTELIGÊNCIA --"
	else:
		status_identity.text = "%s\nFACÇÃO: %s\nLINHAGEM: %s\nELEMENTO: %s" % [pet_identity.pet_name.to_upper(), pet_identity.faction_label.to_upper(), pet_identity.lineage_label.to_upper(), String(pet_identity.element).to_upper()]
		status_attributes.text = "NÍVEL %d   XP %d\nFORÇA %d   DEFESA %d\nAGILIDADE %d   INTELIGÊNCIA %d" % [pet_skills.level, pet_skills.total_xp, pet_skills.strength, pet_skills.defense, pet_skills.agility, pet_skills.intelligence]
	status_hint.text = "VERMELHO: FECHAR FICHA E ENTRAR NO CONSOLE"

func _continue_saved_pet() -> void:
	if pet_skills != null:
		pet_skills.reset_for_new_pet()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_show_story(0)
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		_show_story(0)
		return
	if pet_identity != null:
		var saved_faction := StringName(String(data.get("faction", "neutro")))
		var saved_seed := int(data.get("identity_seed", 0))
		pet_identity.generate_new_identity_for_faction(saved_faction, saved_seed)
	if pet_randomizer != null:
		pet_randomizer.reroll()
	_finish_flow()

func _save_new_pet() -> void:
	if pet_identity == null:
		return
	var data := {
		"version": 1,
		"has_pet": true,
		"identity_seed": pet_identity.identity_seed,
		"faction": String(pet_identity.faction_id),
		"name": pet_identity.pet_name,
		"lineage": String(pet_identity.lineage_id),
		"created_at": Time.get_datetime_string_from_system(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _finish_flow() -> void:
	active = false
	visible = false
	if deepworld != null:
		deepworld.visible = true
	if pet_node != null:
		pet_node.visible = true
	if pet_ui != null:
		pet_ui.visible = true
	if skill_tree != null:
		skill_tree.visible = false
	flow_completed.emit()

func _has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func _hide_all_panels() -> void:
	logo.visible = false
	logo_image.visible = false
	logo_subtitle.visible = false
	menu_panel.visible = false
	story_panel.visible = false
	faction_panel.visible = false
	egg_panel.visible = false
	egg_image.visible = false
	status_panel.visible = false

func _on_menu_button_pressed(index: int) -> void:
	if index >= 0 and index < menu_options.size():
		menu_selected_index = index
		_confirm_menu()

func _on_faction_button_pressed(index: int) -> void:
	faction_selected_index = clampi(index, 0, faction_buttons.size() - 1)
	_refresh_faction()

func _on_story_back_pressed() -> void:
	_back_story()

func _on_story_next_pressed() -> void:
	_next_story()

func _on_egg_button_pressed() -> void:
	_hatch_step()

func _on_status_exit_pressed() -> void:
	_finish_flow()
