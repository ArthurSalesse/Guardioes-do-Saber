extends SceneTree

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func key(code: Key, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.shift_pressed = shift
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
	await process_frame


func run() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var menu = main.get_node("Menu/Center/Content")
	check(root.gui_get_focus_owner() == menu.get_node("Start"), "Menu começa com Iniciar focalizado")
	await key(KEY_TAB)
	var main_slider: HSlider = menu.get_node("Volume/Slider")
	check(root.gui_get_focus_owner() == main_slider, "Tab alcança o volume")
	await key(KEY_LEFT)
	check(main_slider.value == 95, "Seta ajusta o volume")
	await key(KEY_TAB)
	await key(KEY_ENTER)
	check(main.current_route == &"avatar_select", "Enter inicia pelo menu")
	var avatar = main.get_node("AvatarSelect")
	avatar.get_node("Center/Content/Begin").grab_focus()
	await key(KEY_ENTER)
	check(main.current_route == &"game", "Enter confirma o avatar")

	var game = main.get_node("Game")
	var manager = root.get_node("MissionManager")
	var objective: Label = game.get_node("HUD/MissionStatus/Content/Objective")
	var player = game.get_node("World/Player")
	var pause_menu = game.get_node("HUD/PauseMenu")
	var pause_slider: HSlider = pause_menu.get_node("Center/Panel/Content/Volume/Slider")
	check("Encontre Tobi" in objective.text, "Mostra o objetivo atual")
	manager.start_mission(&"bridge")
	check("12 tábuas" in objective.text, "Atualiza o objetivo quando a missão inicia")
	manager.complete_mission(&"bridge")
	check("Flora" in objective.text, "Mostra a próxima missão")
	await key(KEY_E)
	var dialogue = game.get_node("HUD/Dialogue")
	check(dialogue.visible and not dialogue.body.text.is_empty(), "E abre as instruções por escrito")
	await key(KEY_ENTER)
	check(dialogue.page_index == 1, "Enter avança a leitura")
	await key(KEY_TAB, true)
	check(root.gui_get_focus_owner() == dialogue.previous_button, "Shift+Tab alcança a página anterior")
	await key(KEY_ENTER)
	check(dialogue.page_index == 0 and dialogue.previous_button.disabled, "Permite reler a página anterior")
	await key(KEY_P)
	check(paused and pause_menu.visible and dialogue.visible, "P pausa sem perder a página")
	check(root.gui_get_focus_owner() == pause_menu.resume_button, "O foco vai para Continuar")
	check(pause_slider.value == 95, "Volume do menu inicial é reaproveitado na pausa")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == pause_slider, "Tab alcança o volume na pausa")
	await key(KEY_HOME)
	check(AudioServer.is_bus_mute(0) and pause_slider.value == 0, "Volume zero silencia o áudio")
	await key(KEY_RIGHT)
	check(not AudioServer.is_bus_mute(0) and pause_slider.value == 5, "Aumentar volume reativa o áudio")
	await key(KEY_TAB)
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == pause_menu.resume_button, "Tab mantém o foco no menu de pausa")
	await key(KEY_ESCAPE)
	check(not paused and not pause_menu.visible and dialogue.page_index == 0, "Esc retoma a página")
	check(root.gui_get_focus_owner() == dialogue.next_button, "Retoma o foco do diálogo")
	await key(KEY_ESCAPE)
	check(not dialogue.visible, "Esc fecha as instruções")
	await key(KEY_ESCAPE)
	check(paused and pause_menu.visible, "Esc pausa durante a exploração")
	var start: Vector2 = player.position
	Input.action_press("move_right")
	await process_frame
	await process_frame
	Input.action_release("move_right")
	check(player.position.is_equal_approx(start), "O personagem fica parado durante a pausa")
	pause_menu.get_node("Center/Panel/Content/Menu").grab_focus()
	await key(KEY_ENTER)
	check(not paused and main.current_route == &"menu", "Voltar ao menu encerra a pausa")
	check(main.get_node("Menu/Center/Content/Volume/Slider").value == 5, "Volume é mantido ao voltar ao menu")
	AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, 0)
	main.queue_free()
	await process_frame
	print("Accessibility: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
