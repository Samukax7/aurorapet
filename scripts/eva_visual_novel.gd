class_name EvaVisualNovel
extends Control

## Camada reutilizável da narrativa da EVA.
## Há dois fluxos: capítulos da Jornada e o encontro intermediário da Exploração.
## O encontro usa o mesmo controlador para trocar fundo, pose, diálogo e escolha.

signal sequence_completed(helped: bool)
signal exploration_encounter_completed(helped: bool)
signal sequence_closed

const CHAPTERS: Dictionary = {
	1: {
		"title": "CAPÍTULO 1 • O SILÊNCIO DOS ECOS",
		"region": "RUÍNAS DIGITAIS",
		"lines": [
			["EVA", "Você ouviu? Há um eco preso entre estas estrelas."],
			["EVA", "Ele não nasceu cruel. Apenas esqueceu como voltar para casa."],
			["EVA", "Se caminharmos juntos, talvez a memória encontre um caminho."],
		]
	},
	2: {
		"title": "CAPÍTULO 2 • O ESPELHO FRAGMENTADO",
		"region": "FLORESTA CRISTALINA",
		"lines": [
			["EVA", "Cada cristal devolve uma versão diferente de quem fomos."],
			["EVA", "Não confie no reflexo mais fácil. A verdade costuma piscar primeiro."],
		]
	},
	3: {
		"title": "CAPÍTULO 3 • OS ALGORITMOS ESQUECIDOS",
		"region": "ABISMO ELÉTRICO",
		"lines": [
			["EVA", "Os dados antigos ainda lembram o nome do primeiro mundo."],
			["EVA", "Vamos atravessar o ruído antes que ele apague o sinal."],
		]
	},
	4: {
		"title": "CAPÍTULO 4 • A FORJA DA SUPERNOVA",
		"region": "MAR DE PLASMA ESTELAR",
		"lines": [
			["EVA", "O calor desta região não destrói tudo. Algumas coisas renascem nele."],
			["EVA", "Fique perto. A próxima batalha vai iluminar o caminho."],
		]
	},
	5: {
		"title": "CAPÍTULO 5 • O ABISMO DA MEMÓRIA",
		"region": "VAZIO PRIMORDIAL",
		"lines": [
			["EVA", "Aqui até o silêncio guarda uma forma."],
			["EVA", "Se eu esquecer meu nome, lembre-me de que não estou sozinha."],
		]
	},
	6: {
		"title": "CAPÍTULO 6 • O RETORNO À ORIGEM",
		"region": "ORIGEM DA CRIAÇÃO",
		"lines": [
			["EVA", "Chegamos ao lugar onde todos os caminhos começaram."],
			["EVA", "O último eco não quer ser vencido. Quer ser compreendido."],
		]
	}
}

const FALL_SEQUENCE: Array[Dictionary] = [
	{"texture": "res://assets/eva/encounter/fall_sky_crop.png", "caption": "O céu se abriu..."},
	{"texture": "res://assets/eva/encounter/fall_close_crop.png", "caption": "Algo caiu do alto."},
	{"texture": "res://assets/eva/encounter/fall_impact_crop.png", "caption": ""},
]

const ENCOUNTER_BACKGROUNDS: Dictionary = {
	&"field": "res://assets/eva/encounter/encounter_field.jpg",
	&"gorgon_glitch": "res://assets/eva/encounter/boss_gorgon_cave.jpg",
	# Chaves futuras podem receber fundos próprios sem criar outra cena.
	&"prisma_guard": "res://assets/eva/encounter/encounter_field.jpg",
	&"core_overlord": "res://assets/eva/encounter/encounter_field.jpg",
	&"ignis_vectis": "res://assets/eva/encounter/encounter_field.jpg",
	&"arquiteto_do_esquecimento": "res://assets/eva/encounter/encounter_field.jpg",
	&"eco_absoluto": "res://assets/eva/encounter/encounter_field.jpg",
}

const EVA_POSES: Dictionary = {
	&"cry": "res://assets/eva/encounter/restored/eva_cry_restored.png",
	&"suspicious": "res://assets/eva/encounter/restored/eva_suspicious_restored.png",
	&"confident": "res://assets/eva/encounter/restored/eva_confident_restored.png",
	&"happy": "res://assets/eva/encounter/restored/eva_happy_restored.png",
	&"neutral": "res://assets/eva/encounter/restored/eva_neutral_restored.png",
	&"angry": "res://assets/eva/encounter/restored/eva_angry_restored.png",
}

const ENCOUNTER_LINES: Array[Dictionary] = [
	{"pose": &"cry", "speaker": "EVA", "text": "Eu caí aqui... não me lembro quem sou ou de onde venho."},
	{"pose": &"suspicious", "speaker": "EVA", "text": "Só sei que me chamo Eva. E não sei se posso confiar neste lugar."},
	{"pose": &"neutral", "speaker": "EVA", "text": "Você pode me ajudar a descobrir por que eu vim parar no Deepworld?"},
]

const REFUSAL_LINES: Array[Dictionary] = [
	{"pose": &"cry", "speaker": "EVA", "text": "Eu entendo... mas não vá embora ainda. Eu realmente não sei para onde ir."},
	{"pose": &"confident", "speaker": "EVA", "text": "Talvez você mude de ideia. Eu vou esperar por você aqui."},
]

const MODE_CHAPTER: StringName = &"chapter"
const MODE_EXPLORATION_ENCOUNTER: StringName = &"exploration_encounter"
const PHASE_NONE: StringName = &"none"
const PHASE_BLACKOUT: StringName = &"blackout"
const PHASE_FALL: StringName = &"fall"
const PHASE_DIALOGUE: StringName = &"dialogue"
const PHASE_CHOICE: StringName = &"choice"

var active := false
var presentation_mode: StringName = MODE_CHAPTER
var encounter_phase: StringName = PHASE_NONE
var encounter_background_id: StringName = &"field"
var encounter_frame_index := 0
var encounter_elapsed := 0.0
var glitch_elapsed := 0.0
var fall_waiting_for_confirmation := false
var choice_emphasis_elapsed := 0.0
var choice_emphasis_complete := false
var encounter_line_index := 0
var encounter_choice_index := 0
var encounter_refusal_count := 0
var chapter := 1
var line_index := 0
var choice_index := 0
var awaiting_choice := false
var allow_choice := true
var elapsed := 0.0
var _chapter_frame_style: StyleBox

@onready var eva_sprite: Sprite2D = $EvaSprite
@onready var chapter_label: Label = $DialogueFrame/Chapter
@onready var region_label: Label = $DialogueFrame/Region
@onready var speaker_label: Label = $DialogueFrame/Speaker
@onready var dialogue_label: Label = $DialogueFrame/Dialogue
@onready var choice_panel: Panel = $DialogueFrame/ChoicePanel
@onready var choice_help: Button = $DialogueFrame/ChoicePanel/Help
@onready var choice_wait: Button = $DialogueFrame/ChoicePanel/Wait
@onready var hint_label: Label = $Hint
@onready var progress_label: Label = $DialogueFrame/Progress
@onready var campaign_music: AudioStreamPlayer = $CampaignMusic
@onready var dialogue_music: AudioStreamPlayer = $DialogueMusic
@onready var choice_audio: AudioStreamPlayer = $ChoiceAudio
@onready var encounter_background: TextureRect = $EncounterBackground
@onready var encounter_frame: TextureRect = $EncounterFrame
@onready var encounter_eva: TextureRect = $EncounterEva
@onready var dialogue_box_artwork: TextureRect = $DialogueBoxArtwork
@onready var choice_art: TextureRect = $ChoiceArt
@onready var blackout: ColorRect = $Blackout
@onready var glitch_overlay: ColorRect = $GlitchOverlay
@onready var glitch_title: Label = $GlitchTitle
@onready var fall_caption: Label = $FallCaption

func _ready() -> void:
	visible = false
	_chapter_frame_style = $DialogueFrame.get_theme_stylebox("panel").duplicate()
	_configure_dialogue_music_loop()
	choice_help.pressed.connect(func(): _choose(true))
	choice_wait.pressed.connect(func(): _choose(false))
	_render()

func open_chapter(chapter_id: int = 1, include_choice: bool = true) -> void:
	presentation_mode = MODE_CHAPTER
	encounter_phase = PHASE_NONE
	chapter = clampi(chapter_id, 1, CHAPTERS.size())
	allow_choice = include_choice
	line_index = 0
	choice_index = 0
	awaiting_choice = false
	elapsed = 0.0
	active = true
	visible = true
	_stop_all_narrative_music()
	if campaign_music != null:
		campaign_music.play()
	eva_sprite.visible = true
	eva_sprite.frame = 0
	_hide_encounter_layers()
	_render()
	grab_focus()

func open_exploration_encounter(background_id: StringName = &"field") -> void:
	presentation_mode = MODE_EXPLORATION_ENCOUNTER
	encounter_background_id = background_id if ENCOUNTER_BACKGROUNDS.has(background_id) else &"field"
	encounter_phase = PHASE_BLACKOUT
	encounter_frame_index = 0
	encounter_elapsed = 0.0
	glitch_elapsed = 0.0
	encounter_line_index = 0
	encounter_choice_index = 0
	encounter_refusal_count = 0
	fall_waiting_for_confirmation = false
	choice_emphasis_elapsed = 0.0
	choice_emphasis_complete = false
	active = true
	visible = true
	_stop_all_narrative_music()
	if campaign_music != null:
		campaign_music.play()
	eva_sprite.visible = false
	_render()
	grab_focus()

func set_encounter_background(background_id: StringName) -> void:
	if ENCOUNTER_BACKGROUNDS.has(background_id):
		encounter_background_id = background_id
		if active and presentation_mode == MODE_EXPLORATION_ENCOUNTER:
			_render()

func close_novel() -> void:
	if not active:
		return
	active = false
	visible = false
	_stop_all_narrative_music()
	_hide_encounter_layers()
	sequence_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not active or direction == Vector2i.ZERO:
		return
	if presentation_mode == MODE_EXPLORATION_ENCOUNTER:
		_handle_encounter_direction(direction)
		return
	if awaiting_choice:
		if direction.y != 0 or direction.x != 0:
			choice_index = 1 - choice_index
			_render()
		return
	if direction.x < 0 or direction.y < 0:
		line_index = maxi(0, line_index - 1)
	else:
		line_index = mini(_current_lines().size(), line_index + 1)
	_render()

func confirm() -> void:
	if not active:
		return
	if presentation_mode == MODE_EXPLORATION_ENCOUNTER:
		_confirm_encounter()
		return
	if awaiting_choice:
		_choose(choice_index == 0)
		return
	if line_index < _current_lines().size() - 1:
		line_index += 1
	elif allow_choice:
		awaiting_choice = true
	else:
		_finish_chapter(true)
	_render()

func back() -> void:
	close_novel()

func _process(delta: float) -> void:
	if not active:
		return
	if presentation_mode == MODE_EXPLORATION_ENCOUNTER:
		_process_encounter(delta)
		return
	elapsed += delta
	if not awaiting_choice:
		eva_sprite.frame = 0 if int(elapsed * 3.0) % 2 == 0 else 1
	else:
		eva_sprite.frame = 2 if int(elapsed * 2.0) % 2 == 0 else 3

func _process_encounter(delta: float) -> void:
	match encounter_phase:
		PHASE_BLACKOUT:
			glitch_elapsed += delta
			_update_glitch_visuals()
			if glitch_elapsed >= 3.0:
				_start_fall_sequence()
		PHASE_FALL:
			# Cada quadro aguarda confirmação para deixar o ritmo nas mãos do jogador.
			return
		PHASE_DIALOGUE:
			encounter_elapsed += delta
			if encounter_eva != null and encounter_eva.visible:
				encounter_eva.position = Vector2(350.0, 50.0 + sin(encounter_elapsed * 2.2) * 2.0)
		PHASE_CHOICE:
			encounter_elapsed += delta
			if not choice_emphasis_complete:
				choice_emphasis_elapsed += delta
				var intro_t := clampf(choice_emphasis_elapsed / 2.0, 0.0, 1.0)
				var intro_scale := 1.0 + sin(intro_t * PI) * 0.035
				choice_art.pivot_offset = Vector2(540.0, 325.0)
				choice_art.scale = Vector2.ONE * intro_scale
				if choice_emphasis_elapsed >= 2.0:
					choice_emphasis_complete = true
					choice_panel.visible = true
					choice_panel.modulate.a = 1.0
					_render()
			else:
				choice_art.scale = Vector2.ONE * (1.0 + sin(encounter_elapsed * 1.5) * 0.008)

func _start_fall_sequence() -> void:
	encounter_phase = PHASE_FALL
	encounter_frame_index = 0
	encounter_elapsed = 0.0
	fall_waiting_for_confirmation = true
	_render()

func _start_encounter_dialogue(after_refusal: bool) -> void:
	encounter_phase = PHASE_DIALOGUE
	encounter_line_index = 0
	encounter_elapsed = 0.0
	_stop_all_narrative_music()
	if dialogue_music != null:
		dialogue_music.play()
	if after_refusal:
		encounter_line_index = 0
	_render()

func _handle_encounter_direction(direction: Vector2i) -> void:
	if encounter_phase == PHASE_BLACKOUT or encounter_phase == PHASE_FALL:
		return
	if encounter_phase == PHASE_CHOICE:
		encounter_choice_index = 1 - encounter_choice_index
		_render()
		return
	var lines: Array[Dictionary] = REFUSAL_LINES if encounter_refusal_count > 0 else ENCOUNTER_LINES
	if direction.x < 0 or direction.y < 0:
		encounter_line_index = maxi(0, encounter_line_index - 1)
	else:
		encounter_line_index = mini(lines.size(), encounter_line_index + 1)
	_render()

func _confirm_encounter() -> void:
	if encounter_phase == PHASE_BLACKOUT:
		return
	if encounter_phase == PHASE_FALL:
		encounter_frame_index += 1
		if encounter_frame_index >= FALL_SEQUENCE.size():
			_start_encounter_dialogue(false)
		else:
			_render()
		return
	if encounter_phase == PHASE_CHOICE:
		if not choice_emphasis_complete:
			return
		_choose(encounter_choice_index == 0)
		return
	var lines: Array[Dictionary] = REFUSAL_LINES if encounter_refusal_count > 0 else ENCOUNTER_LINES
	if encounter_line_index < lines.size() - 1:
		encounter_line_index += 1
	else:
		encounter_phase = PHASE_CHOICE
		encounter_choice_index = 0
	_render()

func _choose(helped: bool) -> void:
	if not active:
		return
	if presentation_mode == MODE_EXPLORATION_ENCOUNTER:
		if helped:
			_finish_exploration_encounter(true)
		else:
			# A primeira recusa troca a introdução pela conversa curta e retorna à escolha.
			# Uma segunda recusa encerra o encontro atual; o save poderá reabrir após três batalhas.
			if encounter_refusal_count == 0:
				encounter_refusal_count = 1
				_start_encounter_dialogue(true)
			else:
				_finish_exploration_encounter(false)
			return
		return
	if not awaiting_choice:
		return
	_finish_chapter(helped)

func _finish_exploration_encounter(helped: bool) -> void:
	active = false
	visible = false
	_stop_all_narrative_music()
	_hide_encounter_layers()
	if choice_audio != null:
		choice_audio.play()
	exploration_encounter_completed.emit(helped)

func _finish_chapter(helped: bool) -> void:
	active = false
	visible = false
	_stop_all_narrative_music()
	if choice_audio != null:
		choice_audio.play()
	sequence_completed.emit(helped)

func _stop_all_narrative_music() -> void:
	if campaign_music != null:
		campaign_music.stop()
	if dialogue_music != null:
		dialogue_music.stop()

func _configure_dialogue_music_loop() -> void:
	if dialogue_music == null:
		return
	var wav := dialogue_music.stream as AudioStreamWAV
	if wav != null:
		var looped := wav.duplicate() as AudioStreamWAV
		looped.loop_mode = AudioStreamWAV.LOOP_FORWARD
		dialogue_music.stream = looped

func _current_data() -> Dictionary:
	return CHAPTERS.get(chapter, CHAPTERS[1])

func _current_lines() -> Array:
	return _current_data().get("lines", []) as Array

func _render() -> void:
	if not is_node_ready():
		return
	if presentation_mode == MODE_EXPLORATION_ENCOUNTER:
		_render_encounter()
	else:
		_render_chapter()

func _render_chapter() -> void:
	_hide_encounter_layers()
	$Dimmer.visible = true
	dialogue_frame_for_chapter()
	if _chapter_frame_style != null:
		$DialogueFrame.add_theme_stylebox_override("panel", _chapter_frame_style)
	$DialogueFrame.visible = true
	var data := _current_data()
	var lines := _current_lines()
	eva_sprite.visible = true
	chapter_label.text = String(data.get("title", "CAMPANHA DA EVA"))
	region_label.text = "REGIÃO: " + String(data.get("region", "DEEPWORLD"))
	progress_label.text = "%02d / %02d" % [mini(line_index + 1, lines.size()), lines.size()]
	if awaiting_choice:
		speaker_label.text = "EVA"
		dialogue_label.text = "O sinal está à frente. Você vem comigo?"
		choice_panel.visible = true
		choice_frame_for_chapter()
		choice_help.button_pressed = choice_index == 0
		choice_wait.button_pressed = choice_index == 1
		hint_label.text = "D-PAD: ESCOLHER   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR"
	else:
		var line: Array = lines[clampi(line_index, 0, maxi(0, lines.size() - 1))]
		speaker_label.text = String(line[0])
		dialogue_label.text = String(line[1])
		choice_panel.visible = false
		hint_label.text = "VERDE: AVANÇAR   •   D-PAD: NAVEGAR   •   ROSA: SAIR" if line_index < lines.size() - 1 or allow_choice else "VERDE: IR PARA A BATALHA   •   ROSA: SAIR"

func _render_encounter() -> void:
	$Dimmer.visible = false
	$DialogueFrame.visible = false
	chapter_label.text = "ENCONTRO NO DEEPWORLD"
	region_label.text = "SINAL DESCONHECIDO"
	progress_label.text = ""
	chapter_label.visible = encounter_phase == PHASE_DIALOGUE or encounter_phase == PHASE_CHOICE
	region_label.visible = encounter_phase == PHASE_DIALOGUE or encounter_phase == PHASE_CHOICE
	progress_label.visible = false
	choice_panel.visible = false
	dialogue_box_artwork.visible = false
	choice_art.visible = false
	encounter_background.visible = false
	encounter_frame.visible = false
	encounter_eva.visible = false
	dialogue_label.text = ""
	speaker_label.text = ""
	hint_label.text = ""
	blackout.visible = false
	glitch_overlay.visible = false
	glitch_title.visible = false
	fall_caption.visible = false
	if encounter_phase == PHASE_BLACKOUT:
		blackout.visible = true
		glitch_overlay.visible = true
		glitch_title.visible = true
		glitch_title.text = "O QUE FOI ISSO?"
		return
	if encounter_phase == PHASE_FALL:
		blackout.visible = true
		encounter_frame.texture = load(String(FALL_SEQUENCE[encounter_frame_index].get("texture", ""))) as Texture2D
		encounter_frame.visible = encounter_frame.texture != null
		fall_caption.text = String(FALL_SEQUENCE[encounter_frame_index].get("caption", ""))
		fall_caption.visible = not fall_caption.text.is_empty()
		hint_label.text = "VERDE: AVANÇAR PARA A PRÓXIMA CENA"
		return
	encounter_background.texture = _load_encounter_background()
	encounter_background.visible = encounter_background.texture != null
	if encounter_phase == PHASE_DIALOGUE:
		$DialogueFrame.visible = true
		dialogue_box_artwork.texture = load("res://assets/eva/encounter/dialogue_box_crop.png") as Texture2D
		var lines: Array[Dictionary] = REFUSAL_LINES if encounter_refusal_count > 0 else ENCOUNTER_LINES
		var line: Dictionary = lines[clampi(encounter_line_index, 0, maxi(0, lines.size() - 1))]
		encounter_eva.texture = load(String(EVA_POSES.get(line.get("pose", &"neutral"), EVA_POSES[&"neutral"]))) as Texture2D
		encounter_eva.visible = encounter_eva.texture != null
		dialogue_box_artwork.visible = true
		dialogue_frame_for_encounter()
		speaker_label.text = String(line.get("speaker", "EVA"))
		dialogue_label.text = String(line.get("text", ""))
		hint_label.text = "VERDE: AVANÇAR   •   D-PAD: NAVEGAR   •   ROSA: SAIR"
		return
	if encounter_phase == PHASE_CHOICE:
		choice_art.texture = load("res://assets/eva/encounter/eva_choice_background.jpg") as Texture2D
		choice_art.visible = choice_art.texture != null
		choice_art.pivot_offset = Vector2(540.0, 325.0)
		choice_art.scale = Vector2.ONE if choice_emphasis_complete else Vector2.ONE * 0.985
		dialogue_box_artwork.texture = load("res://assets/eva/encounter/dialogue_box_crop.png") as Texture2D
		dialogue_box_artwork.visible = dialogue_box_artwork.texture != null
		$DialogueFrame.visible = true
		choice_frame_for_encounter()
		choice_panel.visible = choice_emphasis_complete
		choice_panel.modulate.a = 1.0
		choice_help.button_pressed = encounter_choice_index == 0
		choice_wait.button_pressed = encounter_choice_index == 1
		$DialogueFrame/ChoicePanel/Title.text = "VOCÊ VAI ME AJUDAR?"
		hint_label.text = "D-PAD: ESCOLHER   •   VERDE: CONFIRMAR   •   ROSA: SAIR" if choice_emphasis_complete else ""

func dialogue_frame_for_chapter() -> void:
	$DialogueFrame.position = Vector2(190, 76)
	$DialogueFrame.size = Vector2(842, 354)
	chapter_label.visible = true
	region_label.visible = true
	speaker_label.visible = true
	dialogue_label.visible = true
	progress_label.visible = true
	choice_panel.position = Vector2(24, 190)
	choice_panel.size = Vector2(794, 142)

func dialogue_frame_for_encounter() -> void:
	var encounter_style := StyleBoxFlat.new()
	encounter_style.bg_color = Color(0.01, 0.02, 0.08, 0.18)
	encounter_style.border_width_left = 0
	encounter_style.border_width_top = 0
	encounter_style.border_width_right = 0
	encounter_style.border_width_bottom = 0
	$DialogueFrame.add_theme_stylebox_override("panel", encounter_style)
	$DialogueFrame.position = Vector2(52, 420)
	$DialogueFrame.size = Vector2(976, 190)
	encounter_eva.position = Vector2(350.0, 50.0)
	chapter_label.visible = true
	region_label.visible = false
	speaker_label.visible = true
	dialogue_label.visible = true
	progress_label.visible = false
	choice_panel.visible = false
	chapter_label.position = Vector2(26, 10)
	chapter_label.size = Vector2(924, 25)
	speaker_label.position = Vector2(28, 43)
	speaker_label.size = Vector2(200, 30)
	dialogue_label.position = Vector2(28, 76)
	dialogue_label.size = Vector2(920, 76)

func choice_frame_for_chapter() -> void:
	$DialogueFrame.position = Vector2(190, 76)
	$DialogueFrame.size = Vector2(842, 354)
	choice_panel.remove_theme_stylebox_override("panel")
	choice_panel.position = Vector2(24, 190)
	choice_panel.size = Vector2(794, 142)

func choice_frame_for_encounter() -> void:
	var choice_style := StyleBoxFlat.new()
	choice_style.bg_color = Color(0.01, 0.02, 0.08, 0.16)
	choice_style.border_width_left = 0
	choice_style.border_width_top = 0
	choice_style.border_width_right = 0
	choice_style.border_width_bottom = 0
	$DialogueFrame.add_theme_stylebox_override("panel", choice_style)
	$DialogueFrame.position = Vector2(52, 420)
	$DialogueFrame.size = Vector2(976, 190)
	chapter_label.visible = false
	region_label.visible = false
	speaker_label.visible = false
	dialogue_label.visible = false
	progress_label.visible = false
	var transparent_choice_style := StyleBoxFlat.new()
	transparent_choice_style.bg_color = Color(0, 0, 0, 0)
	transparent_choice_style.border_width_left = 0
	transparent_choice_style.border_width_top = 0
	transparent_choice_style.border_width_right = 0
	transparent_choice_style.border_width_bottom = 0
	choice_panel.add_theme_stylebox_override("panel", transparent_choice_style)
	choice_panel.position = Vector2(0, 0)
	choice_panel.size = Vector2(976, 190)
	$DialogueFrame/ChoicePanel/Title.position = Vector2(28, 12)
	$DialogueFrame/ChoicePanel/Title.size = Vector2(920, 26)
	$DialogueFrame/ChoicePanel/Help.position = Vector2(42, 76)
	$DialogueFrame/ChoicePanel/Help.size = Vector2(400, 72)
	$DialogueFrame/ChoicePanel/Wait.position = Vector2(534, 76)
	$DialogueFrame/ChoicePanel/Wait.size = Vector2(400, 72)

func _load_encounter_background() -> Texture2D:
	var texture := load(String(ENCOUNTER_BACKGROUNDS.get(encounter_background_id, ENCOUNTER_BACKGROUNDS[&"field"]))) as Texture2D
	if texture != null:
		return texture
	return load("res://assets/fundo/faccoes/deepworld_neutro.png") as Texture2D

func _update_glitch_visuals() -> void:
	if glitch_overlay == null or glitch_title == null:
		return
	var pulse := 0.5 + 0.5 * sin(glitch_elapsed * 35.0)
	glitch_overlay.color = Color(0.12 + pulse * 0.20, 0.01, 0.25 + pulse * 0.32, 0.28 + pulse * 0.45)
	glitch_title.modulate.a = 0.52 + pulse * 0.48
	var offset := -7.0 if int(glitch_elapsed * 17.0) % 3 == 0 else 0.0
	glitch_title.position = Vector2(80.0 + offset, 275.0 if int(glitch_elapsed * 11.0) % 4 != 0 else 278.0)

func _hide_encounter_layers() -> void:
	if encounter_background != null:
		encounter_background.visible = false
	if encounter_frame != null:
		encounter_frame.visible = false
	if encounter_eva != null:
		encounter_eva.visible = false
	if dialogue_box_artwork != null:
		dialogue_box_artwork.visible = false
	if choice_art != null:
		choice_art.visible = false
	if blackout != null:
		blackout.visible = false
	if glitch_overlay != null:
		glitch_overlay.visible = false
	if glitch_title != null:
		glitch_title.visible = false
	if fall_caption != null:
		fall_caption.visible = false
	if chapter_label != null:
		chapter_label.visible = true
	if region_label != null:
		region_label.visible = true
	if progress_label != null:
		progress_label.visible = true
	if choice_panel != null:
		choice_panel.visible = false
	eva_sprite.visible = presentation_mode == MODE_CHAPTER
