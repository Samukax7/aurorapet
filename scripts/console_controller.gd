extends Sprite2D

## Controla a UI da tela usando teclado ou os botões visuais do console.
## O mapeamento pode ser alterado aqui sem mexer na cena Pet ou Deepworld.

@onready var pet_ui: PetUI = $ScreenContent/PetUI
@onready var pet_stats: PetStats = $ScreenContent/Deepworld/Paisagem/Pet/PetStats
@onready var pet_skills: PetSkills = $ScreenContent/Deepworld/Paisagem/Pet/PetSkills

func _ready() -> void:
	_connect_console_buttons()
	if pet_ui != null:
		pet_ui.action_requested.connect(_on_action_requested)
	if pet_stats != null:
		pet_stats.stats_changed.connect(_on_stats_changed)
		_on_stats_changed(pet_stats.hunger, pet_stats.energy, pet_stats.mood, pet_stats.health)
	if pet_skills != null:
		pet_skills.skill_unlocked.connect(_on_skill_unlocked)

func _unhandled_input(event: InputEvent) -> void:
	if pet_ui == null:
		return
	if event.is_action_pressed("ui_left"):
		pet_ui.move_selection(Vector2i.LEFT)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		pet_ui.move_selection(Vector2i.RIGHT)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		pet_ui.move_selection(Vector2i.UP)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		pet_ui.move_selection(Vector2i.DOWN)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		pet_ui.confirm_selected()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		pet_ui.toggle_menu()
		get_viewport().set_input_as_handled()

func _connect_console_buttons() -> void:
	$ButtonGreen.pressed.connect(_on_green_pressed)
	$ButtonYellow.pressed.connect(_on_yellow_pressed)
	$ButtonPink.pressed.connect(_on_pink_pressed)
	$DPadUp.pressed.connect(func(): pet_ui.move_selection(Vector2i.UP))
	$DPadDown.pressed.connect(func(): pet_ui.move_selection(Vector2i.DOWN))
	$DPadLeft.pressed.connect(func(): pet_ui.move_selection(Vector2i.LEFT))
	$DPadRight.pressed.connect(func(): pet_ui.move_selection(Vector2i.RIGHT))

func _on_green_pressed() -> void:
	pet_ui.confirm_selected()

func _on_yellow_pressed() -> void:
	pet_ui.toggle_status()

func _on_pink_pressed() -> void:
	pet_ui.toggle_menu()

func _on_action_requested(action: StringName) -> void:
	if pet_stats != null:
		pet_stats.perform_action(action)
	if pet_skills != null:
		match action:
			&"comer", &"limpar", &"dormir":
				pet_skills.add_xp(5)
			&"brincar":
				pet_skills.add_xp(15)
			&"treinar":
				pet_skills.add_xp(25)
				pet_skills.train_attribute(&"forca", 1)
	print("Ação selecionada: ", action)

func _on_skill_unlocked(skill_id: StringName) -> void:
	print("Habilidade desbloqueada: ", skill_id)

func _on_stats_changed(hunger: float, energy: float, mood: float, health: float) -> void:
	if pet_ui != null:
		pet_ui.set_status_values(hunger, energy, mood, health)
