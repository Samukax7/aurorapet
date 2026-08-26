extends Control
class_name EvaVisualNovel

## Camada de apresentação da campanha da EVA.
## A cena não resolve batalha nem salva estado: entrega a escolha ao controlador.

signal sequence_completed(helped: bool)
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

var active := false
var chapter := 1
var line_index := 0
var choice_index := 0
var awaiting_choice := false
var allow_choice := true
var elapsed := 0.0

@onready var eva_sprite: Sprite2D = $EvaSprite
@onready var chapter_label: Label = $DialogueFrame/Chapter
@onready var region_label: Label = $DialogueFrame/Region
@onready var speaker_label: Label = $DialogueFrame/Speaker
@onready var dialogue_label: Label = $DialogueFrame/Dialogue
@onready var choice_panel: Panel = $ChoicePanel
@onready var choice_help: Button = $ChoicePanel/Help
@onready var choice_wait: Button = $ChoicePanel/Wait
@onready var hint_label: Label = $Hint
@onready var progress_label: Label = $DialogueFrame/Progress
@onready var campaign_music: AudioStreamPlayer = $CampaignMusic
@onready var choice_audio: AudioStreamPlayer = $ChoiceAudio

func _ready() -> void:
	visible = false
	choice_help.pressed.connect(func(): _choose(true))
	choice_wait.pressed.connect(func(): _choose(false))
	_render()

func open_chapter(chapter_id: int = 1, include_choice: bool = true) -> void:
	chapter = clampi(chapter_id, 1, CHAPTERS.size())
	allow_choice = include_choice
	line_index = 0
	choice_index = 0
	awaiting_choice = false
	elapsed = 0.0
	active = true
	visible = true
	if campaign_music != null and not campaign_music.playing:
		campaign_music.play()
	eva_sprite.frame = 0
	_render()
	grab_focus()

func close_novel() -> void:
	if not active:
		return
	active = false
	visible = false
	if campaign_music != null:
		campaign_music.stop()
	sequence_closed.emit()

func handle_direction(direction: Vector2i) -> void:
	if not active or direction == Vector2i.ZERO:
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
	if awaiting_choice:
		_choose(choice_index == 0)
		return
	if line_index < _current_lines().size() - 1:
		line_index += 1
	elif allow_choice:
		awaiting_choice = true
	else:
		active = false
		visible = false
		if campaign_music != null:
			campaign_music.stop()
		sequence_completed.emit(true)
		return
	_render()

func back() -> void:
	close_novel()

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	# A EVA alterna dois frames da folha de apresentação para não ficar estática.
	if not awaiting_choice:
		eva_sprite.frame = 0 if int(elapsed * 3.0) % 2 == 0 else 1
	else:
		eva_sprite.frame = 2 if int(elapsed * 2.0) % 2 == 0 else 3

func _current_data() -> Dictionary:
	return CHAPTERS.get(chapter, CHAPTERS[1])

func _current_lines() -> Array:
	return _current_data().get("lines", []) as Array

func _choose(helped: bool) -> void:
	if not active or not awaiting_choice:
		return
	active = false
	visible = false
	if campaign_music != null:
		campaign_music.stop()
	if choice_audio != null:
		choice_audio.play()
	sequence_completed.emit(helped)

func _render() -> void:
	if not is_node_ready():
		return
	var data := _current_data()
	var lines := _current_lines()
	chapter_label.text = String(data.get("title", "CAMPANHA DA EVA"))
	region_label.text = "REGIÃO: " + String(data.get("region", "DEEPWORLD"))
	progress_label.text = "%02d / %02d" % [mini(line_index + 1, lines.size()), lines.size()]
	if awaiting_choice:
		speaker_label.text = "EVA"
		dialogue_label.text = "O sinal está à frente. Você vem comigo?"
		choice_panel.visible = true
		choice_help.button_pressed = choice_index == 0
		choice_wait.button_pressed = choice_index == 1
		hint_label.text = "D-PAD: ESCOLHER   •   VERDE: CONFIRMAR   •   ROSA: VOLTAR"
	else:
		var line: Array = lines[clampi(line_index, 0, maxi(0, lines.size() - 1))]
		speaker_label.text = String(line[0])
		dialogue_label.text = String(line[1])
		choice_panel.visible = false
		hint_label.text = "VERDE: AVANÇAR   •   D-PAD: NAVEGAR   •   ROSA: SAIR" if line_index < lines.size() - 1 or allow_choice else "VERDE: IR PARA A BATALHA   •   ROSA: SAIR"
