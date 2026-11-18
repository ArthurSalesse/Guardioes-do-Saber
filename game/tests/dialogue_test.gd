extends SceneTree

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func ticks(count: int = 3) -> void:
	for i in range(count):
		await physics_frame
	await process_frame
	await process_frame


func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await ticks()
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await ticks()


func run() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	var world = game.get_node("World")
	var player = world.get_node("Player")
	var dialogue = game.get_node("HUD/Dialogue")
	await ticks()
	check(world.active_point.point_id == &"welcome", "Seleciona ponto próximo")
	check(world.active_point.selected, "Indicador visual do ponto ativo")
	await key(KEY_E)
	check(dialogue.visible and dialogue.page_index == 0, "E abre sem pular primeira página")
	check(dialogue.pages.size() == 3, "Texto da clareira tem três páginas")
	check(not world.interaction_enabled and not player.controls_enabled, "Bloqueia novas interações e movimento")
	check(dialogue.replay_button.disabled, "Sem áudio, ouvir de novo fica desativado")
	var start: Vector2 = player.position
	Input.action_press("move_right")
	await ticks(12)
	Input.action_release("move_right")
	check(player.position.is_equal_approx(start), "Personagem permanece parado ao ler")
	check(not world.interact(), "Não abre diálogos sobrepostos")
	await key(KEY_E)
	check(dialogue.page_index == 1, "E avança uma página")
	await key(KEY_ESCAPE)
	check(not dialogue.visible and player.controls_enabled, "Esc fecha e restaura controles")
	check(world.interact(), "Permite repetir orientação")
	check(dialogue.page_index == 0, "Repetição começa na primeira página")
	dialogue.next_button.pressed.emit()
	check(dialogue.page_index == 1, "Botão próximo avança")
	dialogue.advance()
	check(dialogue.next_button.text == "Concluir", "Última página indica conclusão da leitura")
	dialogue.advance()
	check(not dialogue.visible, "Avançar no fim encerra")
	check(not world.progress.is_completed(&"bridge"), "Ler não conclui missões")
	var empty: Array[Resource] = []
	check(not dialogue.show_dialogue("Vazio", empty), "Não abre diálogo vazio")
	# Exercita o suporte real a AudioStream sem depender de uma gravação externa.
	var page = load("res://scripts/instruction_page.gd").new()
	page.text = "Instrução com áudio opcional."
	var recording := AudioStreamWAV.new()
	recording.mix_rate = 8000
	var samples := PackedByteArray()
	samples.resize(8000)
	recording.data = samples
	page.audio = recording
	var pages: Array[Resource] = [page]
	check(dialogue.show_dialogue("Áudio", pages), "Aceita página com AudioStream")
	check(dialogue.audio.stream == recording and dialogue.audio.playing, "Inicia narração")
	check(not dialogue.replay_button.disabled, "Habilita repetição de áudio")
	dialogue.audio.stop()
	dialogue.replay_button.pressed.emit()
	check(dialogue.audio.playing, "Botão repete áudio")
	dialogue.get_node("Panel/Margin/Content/Buttons/Close").pressed.emit()
	check(not dialogue.audio.playing and dialogue.audio.stream == null, "Encerrar para e libera áudio")
	player.position = Vector2(160, 800)
	await ticks()
	check(world.active_point == null and not world.interact(), "Sem interação distante")
	check(not world.get_node("Points/Welcome").selected, "Remove destaque ao sair do alcance")
	pages.clear()
	page = null
	recording = null
	game.queue_free()
	await process_frame
	await process_frame
	# O mixer libera playbacks de AudioStream de forma assíncrona.
	await create_timer(0.1).timeout
	print("Dialogue: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
