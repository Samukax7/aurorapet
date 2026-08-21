extends Sprite2D

## Controla a UI da tela usando teclado ou os botões visuais do console.
## O mapeamento pode ser alterado aqui sem mexer na cena Pet ou Deepworld.

@onready var pet_ui: PetUI = $ScreenContent/PetUI
@onready var pet_stats: PetStats = $ScreenContent/Deepworld/Paisagem/Pet/PetStats
@onready var pet_skills: PetSkills = $ScreenContent/Deepworld/Paisagem/Pet/PetSkills
@onready var pet_evolution: PetEvolution = $ScreenContent/Deepworld/Paisagem/Pet/PetEvolution
@onready var pet_randomizer: PetRandomizer = $ScreenContent/Deepworld/Paisagem/Pet
@onready var pet_identity: PetIdentity = $ScreenContent/Deepworld/Paisagem/Pet/PetIdentity
@onready var deepworld_controller: DeepworldController = $ScreenContent/Deepworld
@onready var skill_tree: ArvoreDeHabilidades = $ScreenContent/ArvoreDeHabilidades
@onready var opening_flow: OpeningFlow = $ScreenContent/OpeningFlow
@onready var jogo_da_velha: JogoDaVelha = $ScreenContent/JogoDaVelha
@onready var jokenpo: Jokenpo = $ScreenContent/Jokenpo
@onready var jogo_2048: Jogo2048 = $ScreenContent/Jogo2048
@onready var batalha_exploracao: BatalhaDeExploracao = $ScreenContent/BatalhaDeExploracao
@onready var quarto_cosmico: QuartoCosmico = $ScreenContent/Deepworld/QuartoCosmico
@onready var aurora_pet_save: AuroraPetSave = $ScreenContent/AuroraPetSave

var quarto_entry_pending := false

func _ready() -> void:
	_connect_console_buttons()
	if aurora_pet_save != null:
		aurora_pet_save.configure(pet_identity, pet_stats, pet_skills, pet_evolution, pet_randomizer, quarto_cosmico, batalha_exploracao)
	if opening_flow != null:
		opening_flow.configure(pet_identity, pet_stats, pet_skills, pet_randomizer, pet_ui, $ScreenContent/Deepworld, skill_tree, aurora_pet_save)
	if pet_ui != null:
		pet_ui.set_progression_source(pet_skills)
		pet_ui.action_requested.connect(_on_action_requested)
	if pet_stats != null:
		pet_stats.stats_changed.connect(_on_stats_changed)
		pet_stats.needs_changed.connect(_on_needs_changed)
		pet_stats.attention_changed.connect(_on_attention_changed)
		pet_stats.illness_changed.connect(_on_illness_changed)
		pet_stats.reaction_requested.connect(_on_reaction_requested)
		pet_stats.action_blocked.connect(_on_action_blocked)
		pet_stats.action_refused.connect(_on_action_refused)
		pet_stats.action_info.connect(_on_action_info)
		pet_stats.behavior_event.connect(_on_behavior_event)
		pet_stats.poop_state_changed.connect(_on_poop_state_changed)
		pet_stats.special_need_changed.connect(_on_special_need_changed)

		pet_stats.sleep_state_changed.connect(_on_sleep_state_changed)
		pet_stats.newborn_tutorial_step_changed.connect(_on_newborn_tutorial_step_changed)
		pet_stats.newborn_tutorial_completed.connect(_on_newborn_tutorial_completed)
		_on_stats_changed(pet_stats.hunger, pet_stats.energy, pet_stats.mood, pet_stats.health)
		_on_needs_changed(pet_stats.get_needs_snapshot())
		_on_poop_state_changed(pet_stats.poop_visible)
		_on_sleep_state_changed(pet_stats.is_sleeping)
	if pet_skills != null:
		pet_skills.skill_unlocked.connect(_on_skill_unlocked)
		pet_skills.level_up.connect(_on_level_up)
	if skill_tree != null:
		skill_tree.set_pet_identity(pet_identity)
		skill_tree.set_pet_skills(pet_skills)
		skill_tree.training_requested.connect(_on_training_requested)
	if jogo_da_velha != null:
		jogo_da_velha.match_completed.connect(_on_tic_tac_toe_completed)
	if jokenpo != null:
		jokenpo.match_completed.connect(_on_jokenpo_completed)
	if jogo_2048 != null:
		jogo_2048.match_completed.connect(_on_2048_completed)
	if batalha_exploracao != null:
		batalha_exploracao.configure(pet_stats, pet_skills, pet_identity)
		batalha_exploracao.points_changed.connect(_on_exploration_points_changed)
		batalha_exploracao.battle_completed.connect(_on_exploration_battle_completed)
		batalha_exploracao.battle_started.connect(_on_exploration_battle_started)


	if quarto_cosmico != null:
		quarto_cosmico.exit_confirmed.connect(_on_quarto_exit_confirmed)
		if batalha_exploracao != null:
			quarto_cosmico.set_exploration_points(batalha_exploracao.get_exploration_points())
		if pet_skills != null:
			quarto_cosmico.configure_progression(pet_skills.level, pet_skills.xp, pet_skills.total_xp)
	if pet_evolution != null:
		pet_evolution.evolution_completed.connect(_on_evolution_completed)
	if pet_identity != null:
		call_deferred("_show_identity_intro")

func _unhandled_input(event: InputEvent) -> void:
	if opening_flow != null and opening_flow.active:
		if event.is_action_pressed("ui_left"):
			opening_flow.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			opening_flow.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			opening_flow.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			opening_flow.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			opening_flow.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			opening_flow.back()
			get_viewport().set_input_as_handled()
		return
	if jogo_da_velha != null and jogo_da_velha.visible:
		if event.is_action_pressed("ui_left"):
			jogo_da_velha.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			jogo_da_velha.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			jogo_da_velha.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			jogo_da_velha.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			jogo_da_velha.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_close_tic_tac_toe()
			get_viewport().set_input_as_handled()
		return
	if jokenpo != null and jokenpo.visible:
		if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
			jokenpo.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
			jokenpo.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			jokenpo.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_close_jokenpo()
			get_viewport().set_input_as_handled()
		return
	if batalha_exploracao != null and batalha_exploracao.visible:
		if event.is_action_pressed("ui_left"):
			batalha_exploracao.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			batalha_exploracao.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			batalha_exploracao.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			batalha_exploracao.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			batalha_exploracao.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			if batalha_exploracao.is_in_submenu():
				batalha_exploracao.back()
			else:
				_close_exploration()
			get_viewport().set_input_as_handled()
		return
	if jogo_2048 != null and jogo_2048.visible:

		if event.is_action_pressed("ui_left"):
			jogo_2048.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			jogo_2048.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			jogo_2048.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			jogo_2048.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			jogo_2048.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_close_2048()
			get_viewport().set_input_as_handled()
		return
	if quarto_cosmico != null and quarto_cosmico.visible:
		if event.is_action_pressed("ui_left"):
			quarto_cosmico.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			quarto_cosmico.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			quarto_cosmico.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			quarto_cosmico.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			quarto_cosmico.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			if quarto_cosmico.is_shop_open():
				quarto_cosmico.back()
			else:
				quarto_cosmico.request_exit()
			get_viewport().set_input_as_handled()
		return
	if quarto_entry_pending:
		if event.is_action_pressed("ui_accept"):
			_open_quarto()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_cancel_quarto_entry()
			get_viewport().set_input_as_handled()
		return
	if _is_quarto_global_access_request(event):
		_request_quarto_global_access()
		get_viewport().set_input_as_handled()
		return
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
	if quarto_entry_pending:
		_open_quarto()
		return
	if quarto_cosmico != null and quarto_cosmico.visible:
		quarto_cosmico.confirm()
		return
	if opening_flow != null and opening_flow.active:
		opening_flow.confirm()
		return
	if jogo_da_velha != null and jogo_da_velha.visible:
		jogo_da_velha.confirm()
		return
	if jokenpo != null and jokenpo.visible:
		jokenpo.confirm()
		return
	if jogo_2048 != null and jogo_2048.visible:
		jogo_2048.confirm()
		return
	if batalha_exploracao != null and batalha_exploracao.visible:
		batalha_exploracao.confirm()
		return
	_confirm_active_selection()

func _on_yellow_pressed() -> void:
	if opening_flow != null and opening_flow.active:
		return
	if jogo_da_velha != null and jogo_da_velha.visible:
		return
	if quarto_entry_pending:
		return
	if quarto_cosmico != null and quarto_cosmico.visible:
		if quarto_cosmico.is_shop_open():
			quarto_cosmico.back()
		return
	pet_ui.toggle_status()

func _on_pink_pressed() -> void:
	if quarto_entry_pending:
		_cancel_quarto_entry()
		return
	if quarto_cosmico != null and quarto_cosmico.visible:
		if quarto_cosmico.is_shop_open():
			quarto_cosmico.back()
		else:
			quarto_cosmico.request_exit()
		return
	if opening_flow != null and opening_flow.active:
		opening_flow.back()
		return
	if jogo_da_velha != null and jogo_da_velha.visible:
		_close_tic_tac_toe()
		return
	if jokenpo != null and jokenpo.visible:
		_close_jokenpo()
		return
	if jogo_2048 != null and jogo_2048.visible:
		_close_2048()
		return
	if batalha_exploracao != null and batalha_exploracao.visible:
		if batalha_exploracao.is_in_submenu():
			batalha_exploracao.back()
		else:
			_close_exploration()
		return
	if skill_tree != null and skill_tree.visible:
		skill_tree.close_tree()

	elif pet_ui != null and pet_ui.submenu_visible:
		pet_ui.close_submenu()
	else:
		pet_ui.toggle_menu()

func _move_active_selection(direction: Vector2i) -> void:
	if quarto_entry_pending:
		return
	if direction == Vector2i.UP and _is_quarto_global_access_available():
		_request_quarto_global_access()
		return
	if opening_flow != null and opening_flow.active:
		opening_flow.handle_direction(direction)
		return
	if jogo_da_velha != null and jogo_da_velha.visible:
		jogo_da_velha.handle_direction(direction)
	elif jokenpo != null and jokenpo.visible:
		jokenpo.handle_direction(direction)
	elif jogo_2048 != null and jogo_2048.visible:
		jogo_2048.handle_direction(direction)
	elif batalha_exploracao != null and batalha_exploracao.visible:
		batalha_exploracao.handle_direction(direction)
	elif quarto_cosmico != null and quarto_cosmico.visible:
		quarto_cosmico.handle_direction(direction)
	elif skill_tree != null and skill_tree.visible:
		skill_tree.move_selection(direction)
	elif pet_ui != null:
		pet_ui.move_selection(direction)

func _confirm_active_selection() -> void:
	if jogo_da_velha != null and jogo_da_velha.visible:
		jogo_da_velha.confirm()
	elif jokenpo != null and jokenpo.visible:
		jokenpo.confirm()
	elif jogo_2048 != null and jogo_2048.visible:
		jogo_2048.confirm()
	elif batalha_exploracao != null and batalha_exploracao.visible:
		batalha_exploracao.confirm()
	elif quarto_cosmico != null and quarto_cosmico.visible:
		quarto_cosmico.confirm()
	elif skill_tree != null and skill_tree.visible:
		skill_tree.confirm_selected()
	elif pet_ui != null:
		pet_ui.confirm_selected()

func _open_skill_tree() -> void:
	if skill_tree == null:
		return
	skill_tree.set_pet_skills(pet_skills)
	skill_tree.open_tree()

func _on_training_requested() -> void:
	if pet_stats != null and not pet_stats.perform_action(&"treinar"):
		return
	if pet_skills != null:
		pet_skills.add_xp(25)
		pet_skills.train_attribute(&"forca", 1)
	if skill_tree != null:
		skill_tree.refresh_tree()
	if pet_ui != null:
		pet_ui.show_progression_message("TREINO CONCLUÍDO: +25 XP")
	print("Treino confirmado")

func _show_identity_intro() -> void:
	if pet_ui == null or pet_identity == null:
		return
	pet_identity.ensure_generated()
	if pet_identity.pet_name.is_empty():
		return
	pet_ui.show_progression_message("NASCEU: %s • %s" % [pet_identity.pet_name.to_upper(), pet_identity.lineage_label.to_upper()])

func _on_action_requested(action: StringName) -> void:
	if pet_stats != null and pet_stats.is_sleeping:
		pet_stats.perform_action(action)
		return
	if action == &"treinar":
		_open_skill_tree()
		return
	if action == &"batalhar":
		if pet_ui != null and pet_stats != null:
			pet_ui.show_progression_message(pet_stats.get_action_feedback(action))
		return
	if action == &"jogo_da_velha":
		_open_tic_tac_toe()
		return
	if action == &"jokenpo":
		_open_jokenpo()
		return
	if action == &"2048":
		_open_2048()
		return
	if action == &"batalha_exploracao":
		_open_exploration()
		return
	if pet_stats != null and not pet_stats.perform_action(action):
		return
	if pet_skills != null and pet_stats != null:
		var action_xp := pet_stats.get_action_xp(action)
		if action_xp > 0:
			pet_skills.add_xp(action_xp)

	if pet_ui != null and pet_stats != null:
		pet_ui.show_progression_message(pet_stats.get_action_feedback(action))
	print("Ação selecionada: ", action)

func _open_tic_tac_toe() -> void:
	if pet_stats != null and not pet_stats.report_action_check(&"jogo_da_velha"):
		return
	if jogo_da_velha == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = false
	jogo_da_velha.open_game()

func _close_tic_tac_toe() -> void:
	if jogo_da_velha != null:
		jogo_da_velha.close_game()
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = true
	if pet_ui != null:
		pet_ui.visible = true

func _on_tic_tac_toe_completed(result: StringName, reward: int) -> void:
	if pet_stats != null:
		pet_stats.perform_action(&"jogo_da_velha")
	if pet_skills != null:
		pet_skills.add_xp(reward)

func _open_jokenpo() -> void:
	if pet_stats != null and not pet_stats.report_action_check(&"jokenpo"):
		return
	if jokenpo == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = false
	jokenpo.open_game()

func _close_jokenpo() -> void:
	if jokenpo != null:
		jokenpo.close_game()
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = true
	if pet_ui != null:
		pet_ui.visible = true

func _on_jokenpo_completed(result: StringName, reward: int) -> void:
	if pet_stats != null:
		pet_stats.perform_action(&"jokenpo")
	if pet_skills != null:
		pet_skills.add_xp(reward)

func _open_2048() -> void:
	if pet_stats != null and not pet_stats.report_action_check(&"2048"):
		return
	if jogo_2048 == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = false
	jogo_2048.open_game()

func _close_2048() -> void:
	if jogo_2048 != null:
		jogo_2048.close_game()
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = true
	if pet_ui != null:
		pet_ui.visible = true

func _on_2048_completed(_result: StringName, reward: int) -> void:
	if pet_stats != null:
		pet_stats.perform_action(&"2048")
	if pet_skills != null:
		pet_skills.add_xp(reward)
	if pet_ui != null:
		pet_ui.show_progression_message("2048 CONCLUÍDO: +%d XP" % reward)

func _is_quarto_global_access_available() -> bool:
	if opening_flow != null and opening_flow.active:
		return false
	if pet_ui == null or pet_ui.menu_visible or pet_ui.submenu_visible:
		return false
	return quarto_cosmico != null and not quarto_cosmico.visible

func _is_quarto_global_access_request(event: InputEvent) -> bool:
	return _is_quarto_global_access_available() and event.is_action_pressed("ui_up")

func _request_quarto_global_access() -> void:
	quarto_entry_pending = true
	if pet_ui != null:
		pet_ui.show_system_message("SISTEMA: ENTRAR NO QUARTO CÓSMICO?\nVERDE: CONFIRMAR   •   ROSA: CANCELAR")

func _cancel_quarto_entry() -> void:
	quarto_entry_pending = false
	if pet_ui != null:
		pet_ui.show_system_message("SISTEMA: ENTRADA NO QUARTO CANCELADA")

func _open_quarto() -> void:
	if quarto_cosmico == null:
		return
	quarto_entry_pending = false
	if pet_ui != null:
		pet_ui.visible = false
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = true
	quarto_cosmico.open_area()

func _close_quarto() -> void:
	if quarto_cosmico != null:
		quarto_cosmico.close_area()
	var deepworld := $ScreenContent/Deepworld as Node2D
	if deepworld != null:
		deepworld.visible = true
	if pet_ui != null:
		pet_ui.visible = true
	quarto_entry_pending = false

func _on_quarto_exit_confirmed() -> void:
	_close_quarto()

func _open_exploration() -> void:
	if pet_stats != null and not pet_stats.report_action_check(&"batalha_exploracao"):
		return
	if batalha_exploracao == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.show_battle_stage()
	batalha_exploracao.open_area()

func _close_exploration() -> void:
	if batalha_exploracao != null:
		batalha_exploracao.close_area()
	if deepworld_controller != null:
		deepworld_controller.hide_battle_stage()
		deepworld_controller.visible = true
	if pet_ui != null:
		pet_ui.visible = true

func _on_exploration_battle_started(enemy_name: String, enemy_faction: StringName) -> void:
	if deepworld_controller != null:
		deepworld_controller.show_battle_stage(enemy_name, enemy_faction)

func _on_exploration_points_changed(total_points: int) -> void:
	if quarto_cosmico != null:
		quarto_cosmico.set_exploration_points(total_points)

func _on_exploration_battle_completed(victory: bool, xp_reward: int, _point_reward: int, _log_text: String) -> void:
	if pet_skills != null and xp_reward > 0:
		pet_skills.add_xp(xp_reward)
	if pet_stats != null and victory:
		pet_stats.perform_action(&"batalhar")
	if pet_ui != null:
		pet_ui.show_progression_message("BATALHA %s: +%d XP" % ["VENCIDA" if victory else "ENCERRADA", xp_reward])

func _on_skill_unlocked(skill_id: StringName) -> void:
	print("Habilidade desbloqueada: ", skill_id)
	if pet_ui != null and pet_skills != null:
		var skill: Dictionary = pet_skills.get_skill(skill_id)
		pet_ui.show_progression_message("NOVA HABILIDADE: " + String(skill.get("name", skill_id)).to_upper())

func _on_level_up(new_level: int) -> void:
	print("Nível aumentado: ", new_level)
	if quarto_cosmico != null and pet_skills != null:
		quarto_cosmico.configure_progression(pet_skills.level, pet_skills.xp, pet_skills.total_xp)
	if pet_ui != null:
		pet_ui.refresh_progression_locks()
		pet_ui.show_progression_message("NÍVEL %d • NOVO CONTEÚDO DISPONÍVEL" % new_level)

func _on_newborn_tutorial_step_changed(_step: StringName, message: String) -> void:
	if pet_ui != null:
		pet_ui.show_progression_message(message)

func _on_newborn_tutorial_completed() -> void:
	if pet_skills == null:
		return
	if pet_skills.level < 2:
		pet_skills.add_xp(pet_skills.xp_required_for_next_level() - pet_skills.xp)
	if pet_ui != null:
		pet_ui.refresh_progression_locks()
		pet_ui.show_progression_message("TUTORIAL CONCLUÍDO! NÍVEL 2 • JOGO DA VELHA LIBERADO")

func _on_evolution_completed(new_stage: int, stage_name: StringName, visual_scale: float) -> void:
	if aurora_pet_save != null:
		aurora_pet_save.mark_dirty()
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
		pet_ui.show_system_message(pet_stats.get_attention_message())
	elif not active:
		pet_ui.show_system_message("NECESSIDADES ESTÁVEIS")

func _on_illness_changed(is_sick: bool) -> void:
	if pet_ui == null:
		return
	pet_ui.show_system_message("O PET ADOECEU" if is_sick else "DOENÇA TRATADA")

func _on_reaction_requested(action: StringName, reaction_id: StringName) -> void:
	if pet_randomizer != null:
		pet_randomizer.play_reaction(action, reaction_id)
	if pet_ui != null:
		pet_ui.show_pet_message(pet_ui.get_pet_reaction_message(reaction_id))

func _on_action_blocked(_action: StringName, message: String) -> void:
	if pet_ui != null:
		pet_ui.show_system_message(message)

func _on_action_refused(_action: StringName, system_message: String, pet_message: String) -> void:
	if pet_ui == null:
		return
	pet_ui.show_system_message(system_message)
	if not pet_message.is_empty():
		pet_ui.show_pet_message(pet_message)

func _on_action_info(_action: StringName, system_message: String, pet_message: String) -> void:
	if pet_ui == null:
		return
	pet_ui.show_system_message(system_message)
	if not pet_message.is_empty():
		pet_ui.show_pet_message(pet_message)

func _on_behavior_event(_event_id: StringName, system_message: String, pet_message: String) -> void:
	if pet_ui == null:
		return
	pet_ui.show_system_message(system_message)
	if not pet_message.is_empty():
		pet_ui.show_pet_message(pet_message)

func _on_poop_state_changed(visible: bool) -> void:
	if pet_ui != null:
		pet_ui.set_poop_visible(visible)
		if visible:
			pet_ui.show_system_message("O PET FEZ COCÔ • LIMPE A SUJEIRA")

func _on_special_need_changed(need: StringName, wish: StringName, active: bool) -> void:
	if pet_ui != null:
		pet_ui.set_special_need(need, wish, active)
		if active:
			pet_ui.show_pet_message(pet_ui.get_special_need_message(need, wish))

func _on_sleep_state_changed(sleeping: bool) -> void:
	if pet_randomizer != null:
		pet_randomizer.set_sleeping_visual(sleeping)
	if pet_ui != null:
		pet_ui.set_sleeping(sleeping)
		if sleeping:
			pet_ui.show_system_message("SONO ATIVO • FUNÇÕES BLOQUEADAS ATÉ ENERGIA 100%")
		else:
			pet_ui.show_system_message("PET ACORDOU • FUNÇÕES LIBERADAS")
