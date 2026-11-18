extends SceneTree

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func run() -> void:
	var manager = root.get_node("MissionManager")
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	var world = game.get_node("World")
	var player = world.get_node("Player")
	var puzzle = game.get_node("HUD/MillPuzzle")
	var dialogue = game.get_node("HUD/Dialogue")
	var confirm: Button = puzzle.actions.get_node("Confirm")
	for frame in range(4):
		await physics_frame
	player.position = world.get_node("Points/Mill").position
	for frame in range(4):
		await physics_frame
	await process_frame
	await process_frame

	check(world.interact(), "Interage com Flora")
	for page in range(3):
		dialogue.advance()
	check(not puzzle.visible, "Mantém o desafio indisponível antes da ponte")
	manager.start_mission(&"bridge")
	manager.complete_mission(&"bridge")
	check(world.interact(), "Conversa após reconstruir a ponte")
	for page in range(3):
		dialogue.advance()
	check(puzzle.visible and not player.controls_enabled, "Abre o desafio e bloqueia movimento")
	puzzle.actions.get_node("Hint").pressed.emit()
	check(not puzzle.hint.text.is_empty(), "Exibe uma dica")
	puzzle.actions.get_node("Back").pressed.emit()
	check(not puzzle.visible and player.controls_enabled, "Sair devolve o controle")
	world.interact()
	for page in range(3):
		dialogue.advance()
	check(not puzzle.hint.text.is_empty(), "Mantém a dica ao reabrir")

	puzzle.energy_a.get_line_edit().text = "20"
	puzzle.energy_b.get_line_edit().text = "8"
	confirm.pressed.emit()
	check("Faltam 8" in puzzle.feedback.text, "Explica o excesso no orçamento")
	puzzle.energy_a.get_line_edit().text = "10"
	confirm.pressed.emit()
	check("Sobraram 2" in puzzle.feedback.text, "Explica a reserva insuficiente")
	puzzle.energy_a.get_line_edit().text = "8"
	puzzle.energy_b.get_line_edit().text = "6"
	confirm.pressed.emit()
	check("exatamente 6" in puzzle.feedback.text, "Valida cada mecanismo mesmo quando a reserva está correta")
	var gate := Vector2i(40, 16)
	check(world.obstacles.get_cell_source_id(gate) != -1, "A caverna continua fechada após erros")
	puzzle.energy_a.get_line_edit().text = "6"
	puzzle.energy_b.get_line_edit().text = "8"
	confirm.pressed.emit()
	check("acertou" in puzzle.feedback.text and confirm.disabled, "Aceita 6 e 8 digitados com reserva de 6")
	check(manager.is_completed(&"mill") and world.obstacles.get_cell_source_id(gate) == -1, "Ativa o moinho e abre a passagem")
	await process_frame
	await process_frame
	check(not is_zero_approx(world.mill_sails.rotation), "Gira as pás do moinho ativado")
	await create_timer(1.9).timeout
	check(not puzzle.visible and player.controls_enabled, "Devolve o controle após o feedback")
	var events: Array[Dictionary] = manager.get_events().filter(func(event: Dictionary): return event.mission_id == "mill")
	check(events.map(func(event: Dictionary): return event.type) == [
		"MISSION_STARTED", "HINT_REQUESTED", "PUZZLE_ATTEMPTED", "PUZZLE_INCORRECT",
		"PUZZLE_ATTEMPTED", "PUZZLE_INCORRECT", "PUZZLE_ATTEMPTED", "PUZZLE_INCORRECT",
		"PUZZLE_ATTEMPTED", "PUZZLE_CORRECT", "MISSION_COMPLETED",
	], "Registra tentativas, dica, resultados e conclusão")
	if events.size() == 11:
		check(events[8].data.remaining == 6 and events[8].data.elapsed_ms >= 0, "Registra reserva e tempo")
	game.queue_free()
	await process_frame
	print("Mill puzzle: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
