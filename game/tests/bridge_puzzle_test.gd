extends SceneTree

const SOLUTIONS := [[0, 3], [1, 2]]
var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func run() -> void:
	var manager = root.get_node("MissionManager")
	for solution in SOLUTIONS:
		manager.new_session()
		var game = load("res://scenes/game.tscn").instantiate()
		root.add_child(game)
		var world = game.get_node("World")
		var player = world.get_node("Player")
		var puzzle = game.get_node("HUD/BridgePuzzle")
		var dialogue = game.get_node("HUD/Dialogue")
		var confirm: Button = puzzle.actions.get_node("Confirm")
		var hint: Button = puzzle.actions.get_node("Hint")
		for frame in range(4):
			await physics_frame
		player.position = world.get_node("Points/Bridge").position
		for frame in range(4):
			await physics_frame
		await process_frame
		await process_frame
		check(world.interact(), "Interage com Tobi")
		dialogue.close_dialogue()
		check(not puzzle.visible and player.controls_enabled, "Fechar a conversa permite sair")
		check(world.interact(), "Tobi permite reler as instruções")
		for page in range(3):
			dialogue.advance()
		check(puzzle.visible and not player.controls_enabled and confirm.disabled, "A leitura abre o desafio sem seleção")
		hint.pressed.emit()
		check(not puzzle.hint.text.is_empty(), "Exibe dica")
		puzzle.actions.get_node("Back").pressed.emit()
		check(not puzzle.visible and player.controls_enabled, "Sair devolve o controle")
		world.interact()
		for page in range(3):
			dialogue.advance()
		check(manager.count_puzzle_hints(&"bridge") == 1 and not puzzle.hint.text.is_empty(), "Mantém a dica ao reabrir")
		hint.pressed.emit()
		check(hint.disabled, "Limita as dicas disponíveis")
		puzzle.piles.get_child(0).button_pressed = true
		confirm.pressed.emit()
		check("faltam" in puzzle.feedback.text, "Informa quando faltam tábuas")
		puzzle.piles.get_child(3).button_pressed = true
		puzzle.piles.get_child(1).button_pressed = true
		confirm.pressed.emit()
		check("passou" in puzzle.feedback.text, "Informa quando sobram tábuas")
		for index in range(puzzle.piles.get_child_count()):
			puzzle.piles.get_child(index).button_pressed = index in solution
		confirm.pressed.emit()
		check("acertou" in puzzle.feedback.text and confirm.disabled, "Confirma o acerto e bloqueia novas tentativas")
		var cell := Vector2i(20, 16)
		await create_timer(1.1).timeout
		check(not puzzle.visible and world.obstacles.get_cell_source_id(cell) != -1, "Rio permanece bloqueado durante a animação")
		await create_timer(1.3).timeout
		check(manager.is_completed(&"bridge") and player.controls_enabled, "Conclui após animar")
		check(world.obstacles.get_cell_source_id(cell) == -1, "Libera a travessia")
		var events: Array[Dictionary] = manager.get_events()
		var types := events.map(func(event: Dictionary): return event.type)
		check(types == ["MISSION_STARTED", "HINT_REQUESTED", "HINT_REQUESTED",
			"PUZZLE_ATTEMPTED", "PUZZLE_INCORRECT", "PUZZLE_ATTEMPTED",
			"PUZZLE_INCORRECT", "PUZZLE_ATTEMPTED", "PUZZLE_CORRECT",
			"MISSION_COMPLETED"], "Registra dicas, tentativas, resultados e conclusão")
		if events.size() == 10:
			check(events[7].data.total == 12 and events[7].data.elapsed_ms >= 0, "Registra total e tempo de resolução")
		game.queue_free()
		await process_frame
	print("Bridge puzzle: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
