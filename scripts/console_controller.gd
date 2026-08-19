extends Sprite2D

## Controla a UI da tela usando teclado ou os botões visuais do console.
## O mapeamento pode ser alterado aqui sem mexer na cena Pet ou Deepworld.

@onready var pet_ui: PetUI = $ScreenContent/PetUI
@onready var pet_stats: PetStats = $ScreenContent/Deepworld/Paisagem/Pet/PetStats
@onready var pet_skills: PetSkills = $ScreenContent/Deepworld/Paisagem/Pet/PetSkills
@onready var pet_evolution: PetEvolution = $ScreenContent/Deepworld/Paisagem/Pet/PetEvolution
@onready var pet_randomizer: PetRandomizer = $ScreenContent/Deepworld/Paisagem/Pet
@onready var skill_tree: ArvoreDeHabilidades = $ScreenContent/ArvoreDeHabilidades

func _ready() -> void:
	_connect_console_buttons()
	if pet_ui != null:
		pet_ui.action_requested.connect(_on_action_requested)
	if pet_stats != null:
		pet_stats.stats_changed.connect(_on_stats_changed)
		pet_stats.needs_changed.connect(_on_needs_changed)
		pet_stats.attention_changed.connect(_on_attention_changed)
		pet_stats.illness_changed.connect(_on_illness_changed)
		_on_stats_changed(pet_stats.hunger, pet_stats.energy, pet_stats.mood, pet_stats.health)
		_on_needs_changed(pet_stats.get_needs_snapshot())
	if pet_skills != null:
		pet_skills.skill_unlocked.connect(_on_skill_unlocked)
		pet_skills.level_up.connect(_on_level_up)
	if skill_tree != null:
		skill_tree.set_pet_skills(pet_skills)
		skill_tree.training_requested.connect(_on_training_requested)
	if pet_evolution != null:
		pet_evolution.evolution_completed.connect(_on_evolution_completed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		if pet_randomizer != null:
			pet_randomizer.reroll()
			if pet_ui != null:
				pet_ui.show_progression_message("PET REDESENHADO")
			get_viewport().set_input_as_handled()
			return
	if pet_ui == null:
		return
	if skill_tree != null and skill_tree.visible:
		if event.is_action_pressed("ui_left"):
			skill_tree.move_selection(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			skill_tree.move_selection(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			skill_tree.move_selection(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			skill_tree.move_selection(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			skill_tree.confirm_selected()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			skill_tree.close_tree()
			get_viewport().set_input_as_handled()
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
	$DPadUp.pressed.connect(func(): _move_active_selection(Vector2i.UP))
	$DPadDown.pressed.connect(func(): _move_active_selection(Vector2i.DOWN))
	$DPadLeft.pressed.connect(func(): _move_active_selection(Vector2i.LEFT))
	$DPadRight.pressed.connect(func(): _move_active_selection(Vector2i.RIGHT))

func _on_green_pressed() -> void:
	_confirm_active_selection()

func _on_yellow_pressed() -> void:
	pet_ui.toggle_status()

func _on_pink_pressed() -> void:
	if skill_tree != null and skill_tree.visible:
		skill_tree.close_tree()
	elif pet_ui != null and pet_ui.submenu_visible:
		pet_ui.close_submenu()
	else:
		pet_ui.toggle_menu()

func _move_active_selection(direction: Vector2i) -> void:
	if skill_tree != null and skill_tree.visible:
		skill_tree.move_selection(direction)
	elif pet_ui != null:
		pet_ui.move_selection(direction)

func _confirm_active_selection() -> void:
	if skill_tree != null and skill_tree.visible:
		skill_tree.confirm_selected()
	elif pet_ui != null:
		pet_ui.confirm_selected()

func _open_skill_tree() -> void:
	if skill_tree == null:
		return
	skill_tree.set_pet_skills(pet_skills)
	skill_tree.open_tree()

func _on_training_requested() -> void:
	if pet_stats != null:
		pet_stats.perform_action(&"treinar")
	if pet_skills != null:
		pet_skills.add_xp(25)
		pet_skills.train_attribute(&"forca", 1)
	if skill_tree != null:
		skill_tree.refresh_tree()
	if pet_ui != null:
		pet_ui.show_progression_message("TREINO CONCLUÍDO: +25 XP")
	print("Treino confirmado")

func _on_action_requested(action: StringName) -> void:
	if action == &"treinar":
		_open_skill_tree()
		return
	if action == &"batalhar":
		if pet_ui != null:
			pet_ui.show_progression_message("EM BREVE: BATALHAS")
		return
	if pet_stats != null:
		pet_stats.perform_action(action)
	if pet_skills != null:
		match action:
			&"fruta_estelar", &"nectar_cosmico", &"banquete_nebulosa", &"dar_remedio", &"limpar_sujeira", &"dormir":
				pet_skills.add_xp(5)
			&"jokenpo":
				pet_skills.add_xp(15)
			&"jogo_da_velha":
				pet_skills.add_xp(18)
			&"2048":
				pet_skills.add_xp(20)

	if pet_ui != null:
		pet_ui.show_progression_message(_action_feedback(action))
	print("Ação selecionada: ", action)

func _action_feedback(action: StringName) -> String:
	match action:
		&"fruta_estelar": return "FRUTA ESTELAR: +FOME"
		&"nectar_cosmico": return "NECTAR CÓSMICO: +FOME"
		&"banquete_nebulosa": return "BANQUETE NEBULOSA: +FOME"
		&"dar_remedio": return "REMÉDIO APLICADO: +SAÚDE"
		&"limpar_sujeira": return "SUJEIRA LIMPA: +SAÚDE"
		&"dormir": return "SONO RECUPERADO: +ENERGIA"
		&"jokenpo": return "JOKENPÔ: +15 XP"
		&"jogo_da_velha": return "JOGO DA VELHA: +18 XP"
		&"2048": return "2048: +20 XP"
	return "AÇÃO: " + String(action).to_upper()

func _on_skill_unlocked(skill_id: StringName) -> void:
	print("Habilidade desbloqueada: ", skill_id)
	if pet_ui != null and pet_skills != null:
		var skill: Dictionary = pet_skills.get_skill(skill_id)
		pet_ui.show_progression_message("NOVA HABILIDADE: " + String(skill.get("name", skill_id)).to_upper())

func _on_level_up(new_level: int) -> void:
	print("Nível aumentado: ", new_level)
	if pet_ui != null:
		pet_ui.show_progression_message("NÍVEL " + str(new_level))

func _on_evolution_completed(new_stage: int, stage_name: StringName, visual_scale: float) -> void:
	print("Evolução concluída: ", stage_name, " escala=", visual_scale)
	if pet_ui != null:
		pet_ui.show_progression_message("EVOLUÇÃO: " + String(stage_name).to_upper())

func _on_stats_changed(hunger: float, energy: float, mood: float, health: float) -> void:
	if pet_ui != null:
		pet_ui.set_status_values(hunger, energy, mood, health)

func _on_needs_changed(snapshot: Dictionary) -> void:
	if pet_ui != null:
		pet_ui.set_needs_summary(snapshot)

func _on_attention_changed(active: bool, reason: StringName) -> void:
	if pet_ui == null:
		return
	if active and pet_stats != null:
		pet_ui.show_progression_message(pet_stats.get_attention_message())
	elif not active:
		pet_ui.show_progression_message("NECESSIDADES ESTÁVEIS")

func _on_illness_changed(is_sick: bool) -> void:
	if pet_ui == null:
		return
	pet_ui.show_progression_message("O PET ADOECEU" if is_sick else "DOENÇA TRATADA")
