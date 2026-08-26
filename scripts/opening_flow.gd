extends Control
class_name OpeningFlow

## Fluxo inicial do AuroraPet: logo, menu, história, controles, escolha do ovo e ficha RPG.
## O fluxo vive dentro do console e entrega o controle ao ConsoleController
## somente depois que o pet nasce ou um save é continuado.

signal flow_completed

const SAVE_PATH := "user://aurorapet_save.json"
const HATCH_HITS_REQUIRED := 8
const DEVELOPMENT_CODE := "DEV"
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
var egg_selection_index := 0
var selected_faction: StringName = &"neutro"
var development_mode_active := false
var hatch_hits := 0

var pet_identity: PetIdentity
var pet_stats: PetStats
var pet_skills: PetSkills
var pet_randomizer: PetRandomizer
var pet_ui: PetUI
var deepworld: Node
var pet_node: Node2D
var skill_tree: Node
var pet_save: AuroraPetSave
var egg_base_position := Vector2(450.0, 360.0)
var egg_shake_tween: Tween
var intro_anim_time := 0.0

const INTRO_FPS := 24.0
const EVA_TRAVEL_FRAME_START := 120
const EVA_ENTRY_FRAME_COUNT := 40
const EVA_EXIT_FRAME_COUNT := 72
const EVA_IDLE_FRAME_START := 192
const EVA_IDLE_FRAME_COUNT := 48
const EVA_IDLE_PINGPONG_COUNT := EVA_IDLE_FRAME_COUNT * 2 - 2
const EVA_IDLE_BLEND_FRAMES := 18
const EVA_IDLE_START_SCALE := 1.46
const CONTROLS_EVA_Y := 342.0
const EGG_EVA_Y := 352.0
const STATUS_EVA_POSITION := Vector2(1015.0, 520.0)
const STATUS_EVA_EXIT_X := 1242.905

@onready var background: ColorRect = $Background
@onready var logo: Label = $Logo
@onready var logo_image: TextureRect = $LogoImage
@onready var logo_subtitle: Label = $LogoSubtitle
@onready var menu_panel: Panel = $MenuPanel
@onready var menu_title: Label = $MenuPanel/Title
@onready var menu_buttons: Array[Button] = [$MenuPanel/Menu/Start, $MenuPanel/Menu/Continue, $MenuPanel/Menu/Options]
@onready var menu_notice: Label = $MenuPanel/Notice
@onready var access_panel: Panel = $AccessCodePanel
@onready var access_edit: LineEdit = $AccessCodePanel/Code
@onready var access_message: Label = $AccessCodePanel/Message
@onready var story_panel: Panel = $StoryPanel
@onready var story_page_label: Label = $StoryPanel/Page
@onready var story_body: Label = $StoryPanel/Body
@onready var story_back: Button = $StoryPanel/Back
@onready var story_next: Button = $StoryPanel/Next
@onready var egg_selection_panel: Panel = $EggSelectionPanel
@onready var egg_selection_buttons: Array[Button] = [$EggSelectionPanel/Options/Luz, $EggSelectionPanel/Options/Trevas, $EggSelectionPanel/Options/Neutro]
@onready var egg_selection_hint: Label = $EggSelectionPanel/Hint
@onready var egg_panel: Panel = $EggPanel
@onready var egg_label: Label = $EggPanel/Egg
@onready var egg_image: TextureRect = $EggImage
@onready var egg_progress: ProgressBar = $EggPanel/Progress
@onready var egg_hint: Label = $EggPanel/Hint
@onready var status_panel: Panel = $PetStatusPanel
@onready var status_identity: Label = $PetStatusPanel/Identity
@onready var status_attributes: Label = $PetStatusPanel/Attributes
@onready var status_hint: Label = $PetStatusPanel/Hint
@onready var intro_backdrop: TextureRect = $IntroBackdrop
@onready var controls_panel: Panel = $ControlsPanel
@onready var controls_back: Button = $ControlsPanel/Back
@onready var controls_next: Button = $ControlsPanel/Next
@onready var controls_speech_bubble: Panel = $ControlsSpeechBubble
@onready var controls_speech_body: Label = $ControlsSpeechBubble/Body
@onready var presenter_sprite: Sprite2D = $PresenterSprite
@onready var guide_sprite: Sprite2D = $GuideSprite
@onready var status_sprite: Sprite2D = $StatusSprite
@onready var welcome_audio: AudioStreamPlayer = $WelcomeAudio
@onready var intro_eva_audio: AudioStreamPlayer = $IntroEvaAudio

func _ready() -> void:
	_connect_buttons()
	_hide_all_panels()
	_show_logo()
	set_process(true)

func _process(delta: float) -> void:
	if not active:
		return
	intro_anim_time += delta
	var frame_tick := int(intro_anim_time * INTRO_FPS)
	var transition_progress := clampf(float(frame_tick) / float(EVA_ENTRY_FRAME_COUNT), 0.0, 1.0)
	match state:
		&"story":
			# Bloco 1: o ciclo de apresentação toca uma vez e depois entra no idle suave.
			presenter_sprite.flip_h = false
			if frame_tick < 240:
				presenter_sprite.frame = frame_tick
				presenter_sprite.scale = Vector2.ONE * (2.4 + sin(float(frame_tick) * 0.08) * 0.10)
			else:
				presenter_sprite.frame = _idle_frame(frame_tick - 240)
				presenter_sprite.scale = Vector2.ONE * 2.4
			presenter_sprite.position.x = lerpf(917.095, 223.240, transition_progress)
		&"controls":
			# A entrada termina no idle: não há voo repetindo depois do giro.
			_animate_eva_to_idle(guide_sprite, frame_tick, 953.296, 174.972, false)
			guide_sprite.position.y = CONTROLS_EVA_Y
		&"egg_select":
			# A EVA fica à esquerda, voltada para os ovos e para a descrição da aura.
			_animate_eva_to_idle(presenter_sprite, frame_tick, 953.296, 223.240, false)
		&"egg":
			# A EVA cruza a tela uma vez e termina no canto esquerdo, voltada para o ovo.
			_animate_eva_to_idle(guide_sprite, frame_tick, 953.296, 174.972, false)
			guide_sprite.position.y = EGG_EVA_Y
		&"status":
			# Bloco 3: ciclo completo espelhado; termina com voo para fora da tela.
			status_sprite.flip_h = true
			status_sprite.position.y = STATUS_EVA_POSITION.y
			if frame_tick < 240:
				status_sprite.frame = frame_tick
				status_sprite.scale = Vector2.ONE * (2.2 + sin(float(frame_tick) * 0.08) * 0.10)
				status_sprite.position.x = STATUS_EVA_POSITION.x
			else:
				var exit_tick := frame_tick - 240
				status_sprite.frame = EVA_TRAVEL_FRAME_START + (exit_tick % EVA_EXIT_FRAME_COUNT)
				status_sprite.scale = Vector2.ONE * 2.2
				status_sprite.position.x = lerpf(STATUS_EVA_POSITION.x, STATUS_EVA_EXIT_X, clampf(float(exit_tick) / float(EVA_EXIT_FRAME_COUNT), 0.0, 1.0))

func _idle_frame(elapsed_frames: int) -> int:
	var phase := posmod(elapsed_frames, EVA_IDLE_PINGPONG_COUNT)
	if phase >= EVA_IDLE_FRAME_COUNT:
		phase = EVA_IDLE_PINGPONG_COUNT - phase
	return EVA_IDLE_FRAME_START + phase

func _animate_eva_to_idle(sprite: Sprite2D, frame_tick: int, start_x: float, end_x: float, face_left: bool) -> void:
	sprite.flip_h = face_left
	if frame_tick < EVA_ENTRY_FRAME_COUNT:
		sprite.frame = EVA_TRAVEL_FRAME_START + frame_tick
		sprite.scale = Vector2.ONE * 2.2
		sprite.position.x = lerpf(start_x, end_x, clampf(float(frame_tick) / float(EVA_ENTRY_FRAME_COUNT), 0.0, 1.0))
	else:
		var idle_tick := frame_tick - EVA_ENTRY_FRAME_COUNT
		sprite.frame = _idle_frame(idle_tick)
		# O último frame de pouso é menor que o primeiro idle. Uma breve
		# interpolação de escala evita o salto que denunciava a troca de bloco.
		var idle_blend := clampf(float(idle_tick) / float(EVA_IDLE_BLEND_FRAMES), 0.0, 1.0)
		sprite.scale = Vector2.ONE * lerpf(EVA_IDLE_START_SCALE, 2.2, idle_blend)
		sprite.position.x = end_x

func configure(identity: PetIdentity, stats: PetStats, skills: PetSkills, randomizer: PetRandomizer, ui: PetUI, world: Node, tree: Node, save_manager: AuroraPetSave = null) -> void:

	pet_identity = identity
	pet_stats = stats
	pet_skills = skills
	pet_randomizer = randomizer
	pet_ui = ui
	deepworld = world
	pet_node = deepworld.get_node_or_null("Paisagem/Pet") as Node2D if deepworld != null else null
	skill_tree = tree
	pet_save = save_manager
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
	for index in egg_selection_buttons.size():
		egg_selection_buttons[index].pressed.connect(_on_egg_selection_button_pressed.bind(index))
	story_back.pressed.connect(_on_story_back_pressed)
	story_next.pressed.connect(_on_story_next_pressed)
	$EggPanel/HitButton.pressed.connect(_on_egg_button_pressed)
	$PetStatusPanel/ExitButton.pressed.connect(_on_status_exit_pressed)
	controls_back.pressed.connect(_on_controls_back_pressed)
	controls_next.pressed.connect(_on_controls_next_pressed)
	$AccessCodePanel/Load.pressed.connect(_on_access_load_pressed)
	$AccessCodePanel/Cancel.pressed.connect(_on_access_cancel_pressed)

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
		&"controls":
			if direction.x < 0 or direction.y < 0:
				_show_story(0)
			elif direction.x > 0 or direction.y > 0:
				_show_egg_selection()
		&"egg_select":
			if direction.x != 0 or direction.y != 0:
				var egg_step := 1 if direction.x > 0 or direction.y > 0 else -1
				egg_selection_index = wrapi(egg_selection_index + egg_step, 0, egg_selection_buttons.size())
				_refresh_egg_selection()

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
		&"controls":
			_show_egg_selection()
		&"egg_select":
			_confirm_egg_selection()
		&"access_code":
			_load_access_code()
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
		&"controls":
			_show_story(0)
		&"egg_select":
			_show_story(1)
		&"access_code":
			_show_menu()
		&"egg":
			_show_egg_selection()
		&"status":
			_finish_flow()

func _show_logo() -> void:
	state = &"logo"
	if welcome_audio != null:
		welcome_audio.play()
	background.color = Color("#FFFFFF")
	_hide_all_panels()
	logo.visible = false
	logo_image.visible = false
	logo_subtitle.visible = false
	logo_image.visible = true
	var logo_centered_position := Vector2(
		(size.x - logo_image.size.x) * 0.5,
		(size.y - logo_image.size.y) * 0.5
	)
	var logo_start_position := Vector2(-logo_image.size.x - 80.0, logo_centered_position.y)
	logo_image.position = logo_start_position
	logo_image.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(logo_image, "position", logo_centered_position, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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
	menu_notice.text = "V 0.1 • PROTÓTIPO EM DESENVOLVIMENTO • ÁUDIO ATIVO\nD-PAD: NAVEGAR   •   VERDE: CONFIRMAR"
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
			_start_intro_eva_loop()
			_show_story(0)
		&"continue":
			_continue_saved_pet()
		&"options":
			_show_access_code()

func _show_access_code() -> void:
	state = &"access_code"
	background.color = Color("#071332")
	_hide_all_panels()
	access_panel.visible = true
	access_edit.text = ""
	access_message.text = "DIGITE 3 CARACTERES PARA GERAR O PET • DEV: EVA DE TESTE"
	access_edit.grab_focus()

func _load_access_code() -> void:
	var code := access_edit.text.to_upper().strip_edges()
	if code.length() != 3:
		access_message.text = "ERRO: USE EXATAMENTE 3 LETRAS OU NÚMEROS"
		return
	if pet_identity == null:
		access_message.text = "ERRO: IDENTIDADE INDISPONÍVEL"
		return
	if code == DEVELOPMENT_CODE:
		_start_development_pet()
		return
	development_mode_active = false
	if pet_save != null:
		pet_save.set_development_session(false)
	var seed := pet_identity.access_code_to_seed(code)
	pet_identity.generate_new_identity(seed)
	selected_faction = pet_identity.faction_id
	if pet_skills != null:
		pet_skills.reset_for_new_pet()
	if pet_stats != null:
		pet_stats.begin_newborn_tutorial()
	if pet_randomizer != null:
		pet_randomizer.reroll()
	_show_egg()

func _start_development_pet() -> void:
	development_mode_active = true
	if pet_save != null:
		pet_save.set_development_session(true)
	if pet_identity != null:
		var dev_seed := pet_identity.access_code_to_seed(DEVELOPMENT_CODE)
		pet_identity.generate_new_identity_for_faction(&"neutro", dev_seed)
		pet_identity.pet_name = "EVA"
		pet_identity.identity_generated.emit(pet_identity.get_identity_snapshot())
	selected_faction = &"neutro"
	if pet_skills != null:
		pet_skills.prepare_development_state()
	if pet_stats != null:
		pet_stats.prepare_development_state()
	if pet_randomizer != null:
		pet_randomizer.prepare_development_appearance()
	_finish_flow()
	if pet_ui != null:
		pet_ui.show_system_message("MODO DEV ATIVO • EVA • NÍVEL 100 • TUDO DESBLOQUEADO")

func _show_story(page: int) -> void:
	_start_intro_eva_loop()
	story_page = clampi(page, 0, 1)
	intro_anim_time = 0.0
	presenter_sprite.position.x = 917.095
	guide_sprite.position.x = 953.296
	background.color = Color("#071332")
	_hide_all_panels()
	intro_backdrop.visible = true
	if story_page == 1:
		state = &"controls"
		controls_panel.visible = true
		controls_speech_bubble.visible = true
		guide_sprite.position.y = CONTROLS_EVA_Y

		controls_speech_body.text = "Olá!\n\nUse os controles para explorar o Deepworld.\n\nEscolha uma opção e confirme quando estiver pronto."
		guide_sprite.visible = true
		guide_sprite.frame = 1
		controls_next.text = "PRÓXIMA"
		return

	state = &"story"
	story_panel.visible = true
	presenter_sprite.visible = true
	story_page_label.text = "DEEPWORLD"
	story_body.text = "BEM-VINDO AO DEEPWORLD\n\nUm espelho digital do mundo real, onde vivem os Deepmons.\n\nEles crescem com cuidado, escolhas e descobertas.\n\nEu sou EVA, uma guia nascida entre as estrelas.\n\nVamos explorar juntos."
	story_next.text = "PRÓXIMA"
	story_back.visible = false

func _next_story() -> void:
	if state == &"story":
		_show_story(1)
	else:
		_show_egg_selection()

func _back_story() -> void:
	if story_page > 0:
		_show_story(story_page - 1)
	else:
		_show_menu()

func _show_egg_selection() -> void:
	_start_intro_eva_loop()
	state = &"egg_select"
	intro_anim_time = 0.0
	presenter_sprite.position.x = 953.296
	background.color = Color("#071332")
	_hide_all_panels()
	intro_backdrop.visible = true
	egg_selection_panel.visible = true
	presenter_sprite.visible = true
	egg_selection_index = 0
	_refresh_egg_selection()

func _refresh_egg_selection() -> void:
	var labels := ["LUZ", "TREVAS", "NEUTRO"]
	var factions: Array[StringName] = [&"luz", &"trevas", &"neutro"]
	var aura_descriptions := [
		"Harmonia, cura e defesa. Uma aura ligada à proteção.",
		"Caos, força e dano bruto. Uma aura ligada à intensidade.",
		"Equilíbrio, adaptação e versatilidade. Uma aura flexível."
	]
	for index in egg_selection_buttons.size():
		egg_selection_buttons[index].modulate = Color.WHITE if index == egg_selection_index else Color(0.5, 0.58, 0.75, 1.0)
		egg_selection_buttons[index].scale = Vector2(1.08, 1.08) if index == egg_selection_index else Vector2.ONE
	selected_faction = factions[egg_selection_index]
	egg_selection_hint.text = "AURA %s\n%s\n\nVERDE: ESCOLHER   •   ROSA: VOLTAR" % [labels[egg_selection_index], aura_descriptions[egg_selection_index]]

func _confirm_egg_selection() -> void:
	var factions: Array[StringName] = [&"luz", &"trevas", &"neutro"]
	selected_faction = factions[egg_selection_index]
	if pet_skills != null:
		pet_skills.reset_for_new_pet()
	if pet_stats != null:
		pet_stats.begin_newborn_tutorial()
	if pet_identity != null:
		pet_identity.generate_new_identity_for_faction(selected_faction)
	if pet_randomizer != null:
		pet_randomizer.reroll()
	_show_egg()

func _show_egg() -> void:
	_start_intro_eva_loop()
	state = &"egg"
	intro_anim_time = 0.0
	guide_sprite.position = Vector2(953.296, EGG_EVA_Y)
	background.color = Color(0, 0, 0, 0)
	_hide_all_panels()
	if deepworld != null:
		deepworld.visible = true
	if pet_node != null:
		pet_node.visible = false
	egg_panel.visible = true
	controls_speech_bubble.visible = true
	controls_speech_body.text = "Agora é sua vez!\n\nPressione o botão verde para ajudar o ovo a chocar.\n\nCada toque aproxima o nascimento do seu Deepmon."
	guide_sprite.visible = true
	guide_sprite.frame = 2
	egg_image.visible = true
	egg_image.position = egg_base_position
	egg_image.texture = load(String(EGG_TEXTURES.get(selected_faction, EGG_TEXTURES[&"neutro"]))) as Texture2D
	hatch_hits = 0
	egg_label.text = ""
	egg_progress.value = 0.0
	egg_hint.text = "AJUDE O OVO A CHOCAR\nPRESSIONE VERDE  •  0 / %d" % HATCH_HITS_REQUIRED

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
	_start_intro_eva_loop()
	state = &"status"
	intro_anim_time = 0.0
	background.color = Color("#FFFFFF")
	_hide_all_panels()
	status_panel.visible = true
	status_sprite.visible = true
	status_sprite.position = STATUS_EVA_POSITION
	status_sprite.frame = 0
	if pet_identity == null or pet_skills == null:
		status_identity.text = "IDENTIDADE AINDA NÃO DISPONÍVEL"
		status_attributes.text = "FORÇA --   DEFESA --\nAGILIDADE --   INTELIGÊNCIA --"
	else:
		status_identity.text = "%s\nCHAVE: %s\nFACÇÃO: %s\nLINHAGEM: %s\nELEMENTO: %s" % [pet_identity.pet_name.to_upper(), pet_identity.get_access_code(), pet_identity.faction_label.to_upper(), pet_identity.lineage_label.to_upper(), String(pet_identity.element).to_upper()]
		status_attributes.text = "NÍVEL %d   XP %d\nFORÇA %d   DEFESA %d\nAGILIDADE %d   INTELIGÊNCIA %d" % [pet_skills.level, pet_skills.total_xp, pet_skills.strength, pet_skills.defense, pet_skills.agility, pet_skills.intelligence]
	status_hint.text = "VERMELHO: FECHAR FICHA E ENTRAR NO CONSOLE"

func _start_intro_eva_loop() -> void:
	if intro_eva_audio != null and not intro_eva_audio.playing:
		intro_eva_audio.play()

func _stop_intro_eva_loop() -> void:
	if intro_eva_audio != null and intro_eva_audio.playing:
		intro_eva_audio.stop()

func _continue_saved_pet() -> void:
	development_mode_active = false
	if pet_save != null:
		pet_save.set_development_session(false)
	if pet_save != null and pet_save.load_now():
		_finish_flow()
		return
	## Compatibilidade com o formato de identidade da primeira versão.
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
	if pet_save != null and pet_save.save_now():
		return
	if pet_identity == null:
		return
	var data := {
		"version": 1,
		"has_pet": true,
		"identity_seed": pet_identity.identity_seed,
		"access_code": pet_identity.get_access_code(),
		"faction": String(pet_identity.faction_id),
		"name": pet_identity.pet_name,
		"lineage": String(pet_identity.lineage_id),
		"created_at": Time.get_datetime_string_from_system(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _finish_flow() -> void:
	_stop_intro_eva_loop()
	active = false
	visible = false
	if deepworld != null:
		if development_mode_active and deepworld.has_method("activate_default_background"):
			deepworld.call("activate_default_background")
		elif pet_identity != null and deepworld.has_method("activate_faction_background"):
			deepworld.call("activate_faction_background", pet_identity.faction_id)
	if deepworld != null:
		deepworld.visible = true
	if pet_node != null:
		pet_node.visible = true
	if pet_ui != null:
		pet_ui.visible = true
		if pet_stats != null and pet_stats.is_newborn_tutorial_active():
			pet_ui.show_progression_message(pet_stats.get_newborn_tutorial_message())
	if skill_tree != null:
		skill_tree.visible = false
	flow_completed.emit()

func _has_save() -> bool:
	return pet_save != null and pet_save.has_save() or FileAccess.file_exists(SAVE_PATH)

func _hide_all_panels() -> void:
	logo.visible = false
	logo_image.visible = false
	logo_subtitle.visible = false
	menu_panel.visible = false
	story_panel.visible = false
	
	egg_selection_panel.visible = false
	controls_panel.visible = false
	controls_speech_bubble.visible = false
	egg_panel.visible = false
	egg_image.visible = false
	status_panel.visible = false
	access_panel.visible = false
	intro_backdrop.visible = false
	presenter_sprite.visible = false
	guide_sprite.visible = false
	status_sprite.visible = false

func _on_access_load_pressed() -> void:
	_load_access_code()

func _on_access_cancel_pressed() -> void:
	_show_menu()

func _on_menu_button_pressed(index: int) -> void:
	if index >= 0 and index < menu_options.size():
		menu_selected_index = index
		_confirm_menu()

func _on_egg_selection_button_pressed(index: int) -> void:
	egg_selection_index = clampi(index, 0, egg_selection_buttons.size() - 1)
	_refresh_egg_selection()

func _on_story_back_pressed() -> void:
	_back_story()

func _on_story_next_pressed() -> void:
	_next_story()

func _on_egg_button_pressed() -> void:
	_hatch_step()

func _on_status_exit_pressed() -> void:
	_finish_flow()


func _on_controls_back_pressed() -> void:
	_show_story(0)

func _on_controls_next_pressed() -> void:
	_show_egg_selection()
