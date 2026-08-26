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
@onready var mapa_exploracao: MapaExploracao = $ScreenContent/MapaExploracao
@onready var mapa_campanha_eva: MapaCampanhaEva = $ScreenContent/MapaCampanhaEva
@onready var batalhar_menu: BatalharMenu = $ScreenContent/BatalharMenu
@onready var eva_visual_novel: EvaVisualNovel = $ScreenContent/EvaVisualNovel
@onready var quarto_cosmico: QuartoCosmico = $ScreenContent/Deepworld/QuartoCosmico
@onready var aurora_pet_save: AuroraPetSave = $ScreenContent/AuroraPetSave
@onready var eva_journey_manager: EvaJourneyManager = $ScreenContent/EvaJourneyManager
@onready var confirm_audio: AudioStreamPlayer = get_node_or_null(^"ConfirmAudio") as AudioStreamPlayer
@onready var lobby_music: AudioStreamPlayer = get_node_or_null(^"LobbyMusic") as AudioStreamPlayer
@onready var dpad_audio: AudioStreamPlayer = get_node_or_null(^"DPadAudio") as AudioStreamPlayer
@onready var positive_audio: AudioStreamPlayer = get_node_or_null(^"PositiveAudio") as AudioStreamPlayer
@onready var refusal_audio: AudioStreamPlayer = get_node_or_null(^"RefusalAudio") as AudioStreamPlayer
@onready var open_options_audio: AudioStreamPlayer = get_node_or_null(^"OpenOptionsAudio") as AudioStreamPlayer
@onready var level_up_audio: AudioStreamPlayer = get_node_or_null(^"LevelUpAudio") as AudioStreamPlayer
@onready var poop_audio: AudioStreamPlayer = get_node_or_null(^"PoopAudio") as AudioStreamPlayer

var quarto_entry_pending := false
var current_eva_stage_id: StringName = &""
var eva_novel_pending_stage_id: StringName = &""
var eva_exploration_encounter_active := false

func _ready() -> void:
	_connect_console_buttons()
	if aurora_pet_save != null:
		aurora_pet_save.configure(pet_identity, pet_stats, pet_skills, pet_evolution, pet_randomizer, quarto_cosmico, batalha_exploracao, eva_journey_manager)
		if mapa_exploracao != null:
			mapa_exploracao.set_world_progression(aurora_pet_save)
		if mapa_campanha_eva != null:
			mapa_campanha_eva.set_progression(aurora_pet_save.eva_progress_stage_index)
		if not aurora_pet_save.world_progression_changed.is_connected(_on_world_progression_changed):
			aurora_pet_save.world_progression_changed.connect(_on_world_progression_changed)
		if not aurora_pet_save.save_loaded.is_connected(_on_save_loaded):
			aurora_pet_save.save_loaded.connect(_on_save_loaded)
	if eva_journey_manager != null:
		eva_journey_manager.eva_stage_changed.connect(_on_eva_stage_changed)
		eva_journey_manager.memory_unlocked.connect(_on_eva_memory_unlocked)
		eva_journey_manager.journey_choice_made.connect(_on_eva_journey_choice)
	if opening_flow != null:
		opening_flow.configure(pet_identity, pet_stats, pet_skills, pet_randomizer, pet_ui, $ScreenContent/Deepworld, skill_tree, aurora_pet_save)
	if pet_ui != null:
		pet_ui.set_progression_source(pet_skills)
		pet_ui.set_world_progression(aurora_pet_save)
		pet_ui.action_requested.connect(_on_action_requested)
		if not pet_ui.menu_visibility_changed.is_connected(_on_menu_visibility_changed):
			pet_ui.menu_visibility_changed.connect(_on_menu_visibility_changed)
		if not pet_ui.submenu_visibility_changed.is_connected(_on_submenu_visibility_changed):
			pet_ui.submenu_visibility_changed.connect(_on_submenu_visibility_changed)
		if not pet_ui.status_visibility_changed.is_connected(_on_status_visibility_changed):
			pet_ui.status_visibility_changed.connect(_on_status_visibility_changed)
	if pet_stats != null:
		pet_stats.stats_changed.connect(_on_stats_changed)
		pet_stats.needs_changed.connect(_on_needs_changed)
		pet_stats.attention_changed.connect(_on_attention_changed)
		pet_stats.illness_changed.connect(_on_illness_changed)
		pet_stats.reaction_requested.connect(_on_reaction_requested)
		pet_stats.action_performed.connect(_on_action_performed)
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
		batalha_exploracao.configure(pet_stats, pet_skills, pet_identity, pet_randomizer)
		_sync_battle_development_mode()
		batalha_exploracao.points_changed.connect(_on_exploration_points_changed)
		batalha_exploracao.battle_completed.connect(_on_exploration_battle_completed)
		batalha_exploracao.battle_started.connect(_on_exploration_battle_started)
	if batalhar_menu != null:
		batalhar_menu.mode_selected.connect(_on_battle_mode_selected)
	if eva_visual_novel != null:
		if not eva_visual_novel.sequence_completed.is_connected(_on_eva_novel_completed):
			eva_visual_novel.sequence_completed.connect(_on_eva_novel_completed)
		if not eva_visual_novel.exploration_encounter_completed.is_connected(_on_exploration_eva_encounter_completed):
			eva_visual_novel.exploration_encounter_completed.connect(_on_exploration_eva_encounter_completed)
		if not eva_visual_novel.sequence_closed.is_connected(_on_eva_novel_closed):
			eva_visual_novel.sequence_closed.connect(_on_eva_novel_closed)
	if mapa_exploracao != null:
		mapa_exploracao.area_selected.connect(_on_exploration_area_selected)
	if mapa_campanha_eva != null:
		mapa_campanha_eva.stage_selected.connect(_on_eva_stage_selected)


	if quarto_cosmico != null:
		quarto_cosmico.exit_confirmed.connect(_on_quarto_exit_confirmed)
		quarto_cosmico.cosmetic_equipped.connect(_on_cosmetic_equipped)
		if batalha_exploracao != null:
			quarto_cosmico.set_exploration_points(batalha_exploracao.get_exploration_points())
		if pet_skills != null:
			quarto_cosmico.configure_progression(pet_skills.level, pet_skills.xp, pet_skills.total_xp)
	if pet_evolution != null:
		pet_evolution.evolution_completed.connect(_on_evolution_completed)
	if pet_identity != null:
		call_deferred("_show_identity_intro")

func _process(_delta: float) -> void:
	if lobby_music == null:
		return
	if _is_lobby_active():
		if not lobby_music.playing:
			lobby_music.play()
	elif lobby_music.playing:
		lobby_music.stop()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		_play_dpad_sound()
	if event.is_action_pressed("ui_accept"):
		_play_confirm_sound()
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
	if batalhar_menu != null and batalhar_menu.visible:
		if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
			batalhar_menu.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
			batalhar_menu.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			batalhar_menu.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_close_battle_modes()
			get_viewport().set_input_as_handled()
		return
	if mapa_exploracao != null and mapa_exploracao.visible:
		if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
			mapa_exploracao.handle_direction(Vector2i.LEFT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
			mapa_exploracao.handle_direction(Vector2i.RIGHT)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			mapa_exploracao.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_close_exploration_map()
			get_viewport().set_input_as_handled()
		return
	if eva_visual_novel != null and eva_visual_novel.visible:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
			eva_visual_novel.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
			eva_visual_novel.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			eva_visual_novel.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			eva_visual_novel.back()
			get_viewport().set_input_as_handled()
		return
	if mapa_campanha_eva != null and mapa_campanha_eva.visible:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
			mapa_campanha_eva.handle_direction(Vector2i.UP)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
			mapa_campanha_eva.handle_direction(Vector2i.DOWN)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			mapa_campanha_eva.confirm()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_close_eva_campaign_map()
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
			if pet_ui != null:
				pet_ui.set_menu_visibility(true)
			get_viewport().set_input_as_handled()
		return
	if not _is_lobby_active():
		return
	if event.is_action_pressed("ui_left"):
		if pet_ui.menu_visible or pet_ui.submenu_visible:
			pet_ui.move_selection(Vector2i.LEFT)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		if pet_ui.menu_visible or pet_ui.submenu_visible:
			pet_ui.move_selection(Vector2i.RIGHT)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		if pet_ui.menu_visible or pet_ui.submenu_visible:
			pet_ui.move_selection(Vector2i.UP)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		if pet_ui.menu_visible or pet_ui.submenu_visible:
			pet_ui.move_selection(Vector2i.DOWN)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		if pet_ui.menu_visible or pet_ui.submenu_visible:
			pet_ui.confirm_selected()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		if pet_ui.submenu_visible:
			pet_ui.close_submenu()
		else:
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
	_play_confirm_sound()
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
	if batalhar_menu != null and batalhar_menu.visible:
		batalhar_menu.confirm()
		return
	if eva_visual_novel != null and eva_visual_novel.visible:
		eva_visual_novel.confirm()
		return
	if mapa_exploracao != null and mapa_exploracao.visible:
		mapa_exploracao.confirm()
		return

	if mapa_campanha_eva != null and mapa_campanha_eva.visible:
		mapa_campanha_eva.confirm()
		return
	if batalha_exploracao != null and batalha_exploracao.visible:
		batalha_exploracao.confirm()
		return
	_confirm_active_selection()

func _stop_lobby_music() -> void:
	if lobby_music != null:
		lobby_music.stop()

func _play_confirm_sound() -> void:
	if confirm_audio != null:
		confirm_audio.play()

func _play_dpad_sound() -> void:
	if dpad_audio != null:
		dpad_audio.play()

func _play_positive_sound() -> void:
	if positive_audio != null:
		positive_audio.play()

func _play_refusal_sound() -> void:
	if refusal_audio != null:
		refusal_audio.play()

func _play_open_options_sound() -> void:
	if open_options_audio != null:
		open_options_audio.play()

func _play_level_up_sound() -> void:
	if level_up_audio != null:
		level_up_audio.play()

func _play_poop_sound() -> void:
	if poop_audio != null:
		poop_audio.play()

func _on_yellow_pressed() -> void:
	if opening_flow != null and opening_flow.active:
		return
	if jogo_da_velha != null and jogo_da_velha.visible:
		return
	if quarto_entry_pending:
		return
	if quarto_cosmico != null and quarto_cosmico.visible:
		if quarto_cosmico.is_shop_open() or quarto_cosmico.is_wardrobe_open():
			quarto_cosmico.back()
		return
	if not _is_lobby_active():
		return
	pet_ui.toggle_status()

func _on_pink_pressed() -> void:
	if quarto_entry_pending:
		_cancel_quarto_entry()
		return
	if quarto_cosmico != null and quarto_cosmico.visible:
		if quarto_cosmico.is_shop_open() or quarto_cosmico.is_wardrobe_open():
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
	if batalhar_menu != null and batalhar_menu.visible:
		_close_battle_modes()
		return
	if eva_visual_novel != null and eva_visual_novel.visible:
		eva_visual_novel.back()
		return
	if mapa_exploracao != null and mapa_exploracao.visible:
		_close_exploration_map()
		return

	if mapa_campanha_eva != null and mapa_campanha_eva.visible:
		_close_eva_campaign_map()
		return
	if batalha_exploracao != null and batalha_exploracao.visible:
		if batalha_exploracao.is_in_submenu():
			batalha_exploracao.back()
		else:
			_close_exploration()
		return
	if skill_tree != null and skill_tree.visible:
		skill_tree.close_tree()
		if pet_ui != null:
			pet_ui.set_menu_visibility(true)

	elif pet_ui != null and pet_ui.submenu_visible:
		pet_ui.close_submenu()
	else:
		pet_ui.toggle_menu()

func _move_active_selection(direction: Vector2i) -> void:
	if quarto_entry_pending:
		return
	_play_dpad_sound()
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
	elif batalhar_menu != null and batalhar_menu.visible:
		batalhar_menu.handle_direction(direction)
	elif eva_visual_novel != null and eva_visual_novel.visible:
		eva_visual_novel.handle_direction(direction)
	elif mapa_exploracao != null and mapa_exploracao.visible:
		mapa_exploracao.handle_direction(direction)
	elif mapa_campanha_eva != null and mapa_campanha_eva.visible:
		mapa_campanha_eva.handle_direction(direction)
	elif batalha_exploracao != null and batalha_exploracao.visible:
		batalha_exploracao.handle_direction(direction)
	elif quarto_cosmico != null and quarto_cosmico.visible:
		quarto_cosmico.handle_direction(direction)
	elif skill_tree != null and skill_tree.visible:
		skill_tree.move_selection(direction)
	elif pet_ui != null and _is_lobby_active() and (pet_ui.menu_visible or pet_ui.submenu_visible):
		pet_ui.move_selection(direction)

func _confirm_active_selection() -> void:
	if jogo_da_velha != null and jogo_da_velha.visible:
		jogo_da_velha.confirm()
	elif jokenpo != null and jokenpo.visible:
		jokenpo.confirm()
	elif jogo_2048 != null and jogo_2048.visible:
		jogo_2048.confirm()
	elif eva_visual_novel != null and eva_visual_novel.visible:
		eva_visual_novel.confirm()
	elif batalha_exploracao != null and batalha_exploracao.visible:
		batalha_exploracao.confirm()
	elif quarto_cosmico != null and quarto_cosmico.visible:
		quarto_cosmico.confirm()
	elif skill_tree != null and skill_tree.visible:
		skill_tree.confirm_selected()
	elif pet_ui != null and _is_lobby_active() and (pet_ui.menu_visible or pet_ui.submenu_visible):
		pet_ui.confirm_selected()

func _open_skill_tree() -> void:
	if skill_tree == null:
		return
	if pet_ui != null:
		pet_ui.set_menu_visibility(false)
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

func _show_identity_intro() -> void:
	if pet_ui == null or pet_identity == null:
		return
	pet_identity.ensure_generated()
	if pet_identity.pet_name.is_empty():
		return
	pet_ui.show_progression_message("NASCEU: %s • %s" % [pet_identity.pet_name.to_upper(), pet_identity.lineage_label.to_upper()])

func _on_action_requested(action: StringName) -> void:
	if action == &"sala_treinos":
		if batalha_exploracao != null:
			batalha_exploracao.configure_mode(&"training")
		_open_exploration()
		return
	if action == &"explorar_deepworld":
		_open_exploration_map()
		return
	if action == &"aventura_eva":
		_open_eva_campaign_map()
		return
	if pet_stats != null and pet_stats.is_sleeping:
		pet_stats.perform_action(action)
		return
	if action == &"treinar":
		_open_skill_tree()
		return
	if action == &"batalhar":
		if pet_stats != null and not pet_stats.report_action_check(&"batalhar"):
			return
		_open_battle_modes()
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
		_open_exploration_map()
		return
	if action == &"campanha_eva":
		_open_eva_campaign_map()
		return

	if pet_stats != null and not pet_stats.perform_action(action):
		return
	if pet_skills != null and pet_stats != null:
		var action_xp := pet_stats.get_action_xp(action)
		if action_xp > 0:
			pet_skills.add_xp(action_xp)

	if pet_ui != null and pet_stats != null:
		pet_ui.show_progression_message(pet_stats.get_action_feedback(action))

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

func _on_tic_tac_toe_completed(_result: StringName, reward: int) -> void:
	if pet_stats != null:
		pet_stats.perform_action(&"jogo_da_velha", true)
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

func _on_jokenpo_completed(_result: StringName, reward: int) -> void:
	if pet_stats != null:
		pet_stats.perform_action(&"jokenpo", true)
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
		pet_stats.perform_action(&"2048", true)
	if pet_skills != null:
		pet_skills.add_xp(reward)
	if pet_ui != null:
		pet_ui.show_progression_message("2048 CONCLUÍDO: +%d XP" % reward)

func _is_lobby_active() -> bool:
	# Lobby = Deepworld normal visível, PetUI visível e nenhum modo externo ativo.
	# Essa guarda central impede que ↑ abra o quarto durante mapas, batalha ou minijogos.
	if opening_flow != null and opening_flow.active:
		return false
	if pet_ui == null or not pet_ui.visible:
		return false
	if deepworld_controller == null or not deepworld_controller.visible:
		return false
	if quarto_entry_pending:
		return false
	if quarto_cosmico != null and quarto_cosmico.visible:
		return false
	if skill_tree != null and skill_tree.visible:
		return false
	if jogo_da_velha != null and jogo_da_velha.visible:
		return false
	if jokenpo != null and jokenpo.visible:
		return false
	if jogo_2048 != null and jogo_2048.visible:
		return false
	if batalhar_menu != null and batalhar_menu.visible:
		return false
	if mapa_exploracao != null and mapa_exploracao.visible:
		return false
	if mapa_campanha_eva != null and mapa_campanha_eva.visible:
		return false
	if batalha_exploracao != null and batalha_exploracao.visible:
		return false
	var battle_stage := deepworld_controller.get_battle_stage()
	if battle_stage != null and battle_stage.visible:
		return false
	return true

func _is_quarto_global_access_available() -> bool:
	if not _is_lobby_active():
		return false
	# O quarto só é acessível com o menu principal e os submenus fechados.
	if pet_ui.menu_visible or pet_ui.submenu_visible:
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

func _open_battle_modes() -> void:
	_stop_lobby_music()
	if batalhar_menu == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.hide_battle_stage()
	batalhar_menu.open_menu()

func _close_battle_modes() -> void:
	if batalhar_menu != null:
		batalhar_menu.close_menu()
	if pet_ui != null:
		pet_ui.visible = true
	if deepworld_controller != null:
		deepworld_controller.visible = true

func _on_battle_mode_selected(mode_id: StringName) -> void:
	if batalhar_menu != null:
		batalhar_menu.close_menu()
	if mode_id == &"explorar_deepworld":
		_open_exploration_map()
	else:
		_open_eva_campaign_map()

func _open_exploration_map() -> void:
	_stop_lobby_music()
	if mapa_exploracao == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.hide_battle_stage()
	mapa_exploracao.open_map()

func _close_exploration_map() -> void:
	if mapa_exploracao != null:
		mapa_exploracao.close_map()
	if pet_ui != null:
		pet_ui.visible = true
	if deepworld_controller != null:
		deepworld_controller.visible = true

func _open_eva_campaign_map() -> void:
	_stop_lobby_music()
	if mapa_campanha_eva == null:
		return
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.hide_battle_stage()
	if eva_journey_manager != null and not eva_journey_manager.journey_started:
		_open_eva_visual_novel(1, true)
	else:
		mapa_campanha_eva.open_map()

func _close_eva_campaign_map() -> void:
	if mapa_campanha_eva != null:
		mapa_campanha_eva.close_map()
	if pet_ui != null:
		pet_ui.visible = true
	if deepworld_controller != null:
		deepworld_controller.visible = true

func _on_exploration_area_selected(area_id: StringName) -> void:
	var outcome := _roll_exploration_outcome(area_id)
	if outcome == &"coin":
		if aurora_pet_save != null:
			aurora_pet_save.add_stellar_coins(3)
		if pet_ui != null:
			pet_ui.show_progression_message("ACHADO: +3 MOEDAS ESTELARES")
		return
	if outcome == &"xp":
		if pet_skills != null:
			pet_skills.add_xp(35)
		if pet_ui != null:
			pet_ui.show_progression_message("SINAL DE XP: +35 EXPERIÊNCIA")
		return
	if batalha_exploracao != null:
		batalha_exploracao.configure_mode(&"exploration")
		batalha_exploracao.configure_exploration_area(area_id)
	if pet_ui != null:
		pet_ui.show_progression_message("ECO DETECTADO: %s" % String(area_id).to_upper())
	_open_exploration()

func _roll_exploration_outcome(area_id: StringName) -> StringName:
	var rng := RandomNumberGenerator.new()
	var seed_base := int(Time.get_unix_time_from_system()) + String(area_id).hash() + (aurora_pet_save.exploration_battles_completed if aurora_pet_save != null else 0)
	rng.seed = seed_base
	var roll := rng.randf()
	if roll < 0.15:
		return &"coin"
	if roll < 0.30:
		return &"xp"
	return &"deepmon"

func _on_eva_stage_selected(stage_id: StringName) -> void:
	current_eva_stage_id = stage_id
	eva_novel_pending_stage_id = stage_id
	if batalha_exploracao != null:
		batalha_exploracao.configure_mode(&"eva")
		_sync_battle_development_mode()
	var encounters: Dictionary = {
		&"eva_ch1_01": ["ECO INICIAL", 0, false],
		&"eva_ch1_02": ["FRAGMENTO INSTÁVEL", 1, false],
		&"eva_ch1_03": ["RUÍDO VIOLETA", 1, false],
		&"eva_ch1_boss": ["GORGON GLITCH", 2, true],
		&"eva_ch2_01": ["ECO ESPELHADO", 2, false],
		&"eva_ch2_02": ["PRISMA VIGILANTE", 3, false],
		&"eva_ch2_boss": ["PRISMA GUARD", 3, true],
		&"eva_ch3_01": ["DADOS PERDIDOS", 4, false],
		&"eva_ch3_02": ["NÓ CORROMPIDO", 4, false],
		&"eva_ch3_03": ["ECO DE MEMÓRIA", 5, false],
		&"eva_ch3_boss": ["CORE OVERLORD", 5, true],
		&"eva_ch4_01": ["FRAGMENTO ÍGNEO", 6, false],
		&"eva_ch4_02": ["VETOR ARDENTE", 6, false],
		&"eva_ch4_03": ["NÚCLEO VULCÂNICO", 7, false],
		&"eva_ch4_boss": ["IGNIS VECTIS", 8, true],
		&"eva_ch5_01": ["PÁGINA AUSENTE", 8, false],
		&"eva_ch5_02": ["MEMÓRIA FRATURADA", 9, false],
		&"eva_ch5_03": ["SALA SEM NOME", 9, false],
		&"eva_ch5_boss": ["ARQUITETO DO ESQUECIMENTO", 10, true],
		&"eva_ch6_01": ["ÚLTIMO SINAL", 10, false],
		&"eva_ch6_02": ["RESSONÂNCIA", 11, false],
		&"eva_ch6_03": ["SILÊNCIO ABSOLUTO", 11, false],
		&"eva_ch6_boss": ["O ECO ABSOLUTO", 12, true],
	}
	var encounter: Array = encounters.get(stage_id, [String(stage_id).to_upper(), 0, false])
	if pet_ui != null:
		pet_ui.show_progression_message("FASE DA EVA: %s" % String(stage_id).to_upper())
	if mapa_campanha_eva != null:
		mapa_campanha_eva.close_map()
	if batalha_exploracao != null:
		batalha_exploracao.configure_encounter(String(encounter[0]), int(encounter[1]), bool(encounter[2]))
	_open_eva_visual_novel(_eva_chapter_for_stage(stage_id), false)

func _eva_chapter_for_stage(stage_id: StringName) -> int:
	var parts := String(stage_id).split("_")
	if parts.size() < 2:
		return 1
	return clampi(int(String(parts[1]).trim_prefix("ch")), 1, 6)

func _open_eva_visual_novel(chapter_id: int, include_choice: bool) -> void:
	_stop_lobby_music()
	if eva_visual_novel == null:
		return
	if mapa_campanha_eva != null:
		mapa_campanha_eva.close_map()
	if mapa_exploracao != null:
		mapa_exploracao.close_map()
	if batalhar_menu != null:
		batalhar_menu.close_menu()
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.hide_battle_stage()
	eva_visual_novel.open_chapter(chapter_id, include_choice)

func _open_exploration_eva_encounter() -> void:
	_stop_lobby_music()
	if eva_visual_novel == null:
		return
	eva_exploration_encounter_active = true
	if batalha_exploracao != null:
		batalha_exploracao.close_area()
	if mapa_exploracao != null:
		mapa_exploracao.close_map()
	if mapa_campanha_eva != null:
		mapa_campanha_eva.close_map()
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.hide_battle_stage()
	# O fundo é um ponto de extensão: futuros bosses podem passar outra chave.
	eva_visual_novel.open_exploration_encounter(&"field")

func _on_exploration_eva_encounter_completed(helped: bool) -> void:
	eva_exploration_encounter_active = false
	if aurora_pet_save != null:
		if helped:
			aurora_pet_save.mark_eva_encounter_seen()
			aurora_pet_save.unlock_eva_adventure()
		else:
			aurora_pet_save.reset_eva_encounter_after_refusal()
	if eva_journey_manager != null:
		eva_journey_manager.choose_help_eva(helped)
	if helped:
		if mapa_campanha_eva != null:
			mapa_campanha_eva.open_map()
		if pet_ui != null:
			pet_ui.visible = false
	else:
		if mapa_exploracao != null:
			mapa_exploracao.open_map()
		if pet_ui != null:
			pet_ui.visible = false

func _on_eva_novel_completed(helped: bool) -> void:
	if not eva_novel_pending_stage_id.is_empty():
		eva_novel_pending_stage_id = &""
		if helped:
			_open_exploration()
		else:
			if mapa_campanha_eva != null:
				mapa_campanha_eva.open_map()
			if pet_ui != null:
				pet_ui.visible = false
		return
	if eva_journey_manager != null:
		eva_journey_manager.choose_help_eva(helped)
	if helped:
		if mapa_campanha_eva != null:
			mapa_campanha_eva.open_map()
		if pet_ui != null:
			pet_ui.visible = false
	else:
		_close_eva_campaign_map()

func _on_eva_novel_closed() -> void:
	if eva_exploration_encounter_active:
		eva_exploration_encounter_active = false
		if aurora_pet_save != null:
			aurora_pet_save.reset_eva_encounter_after_refusal()
		if mapa_exploracao != null:
			mapa_exploracao.open_map()
		if pet_ui != null:
			pet_ui.visible = false
		return
	if not eva_novel_pending_stage_id.is_empty():
		eva_novel_pending_stage_id = &""
		if mapa_campanha_eva != null:
			mapa_campanha_eva.open_map()
		if pet_ui != null:
			pet_ui.visible = false
	else:
		_close_eva_campaign_map()

func _open_exploration() -> void:
	_stop_lobby_music()
	if mapa_exploracao != null and mapa_exploracao.visible:
		mapa_exploracao.close_map()
	if mapa_campanha_eva != null and mapa_campanha_eva.visible:
		mapa_campanha_eva.close_map()
	if pet_stats != null and not pet_stats.report_action_check(&"batalhar"):
		return
	if batalha_exploracao == null:
		return
	_sync_battle_development_mode()
	if pet_ui != null:
		pet_ui.visible = false
	if deepworld_controller != null:
		deepworld_controller.show_battle_stage()
	batalha_exploracao.open_area()

func _sync_battle_development_mode() -> void:
	if batalha_exploracao == null:
		return
	var dev_active := aurora_pet_save != null and aurora_pet_save.is_development_session()
	batalha_exploracao.set_development_mode(dev_active)

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
	var battle_mode := batalha_exploracao.get_mode_context() if batalha_exploracao != null else &"training"
	var launch_eva_encounter := false
	if aurora_pet_save != null and battle_mode == &"exploration":
		aurora_pet_save.register_exploration_battle(victory)
		if victory:
			aurora_pet_save.unlock_next_exploration_island()
			launch_eva_encounter = aurora_pet_save.consume_eva_encounter_trigger()
	if pet_skills != null and xp_reward > 0:
		pet_skills.add_xp(xp_reward)
	if pet_stats != null and victory:
		pet_stats.perform_action(&"batalhar", true)
	if launch_eva_encounter:
		_open_exploration_eva_encounter()
		return
	if battle_mode == &"eva" and batalha_exploracao != null:
		if victory:
			if mapa_campanha_eva != null and not current_eva_stage_id.is_empty():
				mapa_campanha_eva.advance_to_stage(current_eva_stage_id)
				if aurora_pet_save != null:
					aurora_pet_save.eva_progress_stage_index = mapa_campanha_eva.get_unlocked_stage_index()
					aurora_pet_save.mark_dirty()
			if batalha_exploracao.is_boss_encounter():
				if eva_journey_manager != null:
					eva_journey_manager.complete_current_chapter()
				_close_exploration()
		elif not victory:
			_close_exploration()
			if pet_ui != null:
				pet_ui.show_system_message("EVA TROUXE VOCÊ DE VOLTA AO LOBBY")
	if pet_ui != null:
		pet_ui.show_progression_message("BATALHA %s: +%d XP" % ["VENCIDA" if victory else "ENCERRADA", xp_reward])

func _on_skill_unlocked(skill_id: StringName) -> void:
	if pet_ui != null and pet_skills != null:
		var skill: Dictionary = pet_skills.get_skill(skill_id)
		pet_ui.show_progression_message("NOVA HABILIDADE: " + String(skill.get("name", skill_id)).to_upper())

func _on_save_loaded() -> void:
	_on_world_progression_changed()
	if mapa_campanha_eva != null and aurora_pet_save != null:
		mapa_campanha_eva.set_progression(aurora_pet_save.eva_progress_stage_index)

func _on_world_progression_changed() -> void:
	if pet_ui != null:
		pet_ui.refresh_progression_locks()
	if mapa_exploracao != null:
		mapa_exploracao.set_world_progression(aurora_pet_save)
	if mapa_campanha_eva != null and aurora_pet_save != null:
		mapa_campanha_eva.set_progression(aurora_pet_save.eva_progress_stage_index)

func _on_level_up(new_level: int) -> void:
	_play_level_up_sound()
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

func _on_eva_stage_changed(stage_name: StringName) -> void:
	if pet_ui != null:
		pet_ui.show_progression_message("EVA DESPERTOU: " + String(stage_name).to_upper())

func _on_eva_memory_unlocked(fragment_id: int, text: String) -> void:
	if pet_ui != null:
		pet_ui.show_pet_message("MEMÓRIA %d: %s" % [fragment_id, text])



func _on_eva_journey_choice(helped: bool) -> void:
	if pet_ui != null:
		pet_ui.show_pet_message("EVA: Obrigada por aceitar a jornada." if helped else "EVA: Tudo bem. Estarei aqui quando você estiver pronto.")

func _on_evolution_completed(new_stage: int, stage_name: StringName, visual_scale: float) -> void:
	if aurora_pet_save != null:
		aurora_pet_save.mark_dirty()
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

func _on_cosmetic_equipped(item_id: StringName) -> void:
	if pet_randomizer != null:
		pet_randomizer.equip_cosmetic(item_id)
	if pet_ui != null:
		pet_ui.show_progression_message("COSMÉTICO EQUIPADO: " + String(item_id).to_upper())

func _on_action_performed(_action: StringName) -> void:
	_play_positive_sound()

func _on_action_blocked(_action: StringName, message: String) -> void:
	if pet_ui != null:
		pet_ui.show_system_message(message)

func _on_action_refused(_action: StringName, system_message: String, pet_message: String) -> void:
	_play_refusal_sound()
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
	if visible:
		_play_poop_sound()
	if pet_ui != null:
		pet_ui.set_poop_visible(visible)
		if visible:
			pet_ui.show_system_message("O PET FEZ COCÔ • LIMPE A SUJEIRA")

func _on_menu_visibility_changed(visible: bool) -> void:
	_play_open_options_sound()

func _on_submenu_visibility_changed(visible: bool, _category: StringName) -> void:
	_play_open_options_sound()

func _on_status_visibility_changed(_visible: bool) -> void:
	_play_open_options_sound()

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
