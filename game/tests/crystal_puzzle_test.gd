extends SceneTree

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func read_dialogue(dialogue: Control) -> void:
	while dialogue.visible:
		dialogue.advance()


func run() -> void:
	var manager = root.get_node("MissionManager")
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	var world = game.get_node("World")
	var player = world.get_node("Player")
	var puzzle = game.get_node("HUD/CrystalPuzzle")
	var dialogue = game.get_node("HUD/Dialogue")
	for frame in range(4):
		await physics_frame
	player.position = world.get_node("Points/Cave").position
	for frame in range(4):
		await physics_frame
	await process_frame
	await process_frame
	check(world.interact(), "Interage com a entrada da caverna")
	read_dialogue(dialogue)
	check(not puzzle.visible, "Moinho é pré-requisito")
	for mission in [&"bridge", &"mill"]:
		manager.start_mission(mission)
		manager.complete_mission(mission)

	check(world.interact(), "Acessa as instruções após restaurar o moinho")
	read_dialogue(dialogue)
	check(puzzle.visible and not player.controls_enabled and puzzle.confirm.disabled, "Abre o primeiro pedestal sem seleção")
	puzzle.hint_button.pressed.emit()
	var first_hint: String = puzzle.hint.text
	check(not puzzle.hint_button.disabled and not first_hint.is_empty(), "Primeira dica deixa disponível uma ajuda mais direta")
	puzzle.hint_button.pressed.emit()
	check(puzzle.hint_button.disabled and puzzle.hint.text != first_hint, "Segunda dica aprofunda a orientação")
	puzzle.choices.get_child(0).button_pressed = true
	puzzle.confirm.pressed.emit()
	check("Confira" in puzzle.feedback.text, "Rejeita resposta de adição incorreta")
	puzzle.choices.get_child(2).button_pressed = true
	check(not puzzle.choices.get_child(0).button_pressed, "Adição permite uma única escolha")
	puzzle.confirm.pressed.emit()
	check("Pedestal ativado" in puzzle.feedback.text, "Aceita o total 12")

	puzzle.actions.get_node("Back").pressed.emit()
	check(not puzzle.visible and player.controls_enabled, "Permite voltar à floresta entre pedestais")
	world.interact()
	read_dialogue(dialogue)
	check("Subtração" in puzzle.heading.text and not puzzle.hint_button.disabled, "Retoma no segundo pedestal com sua própria dica")
	puzzle.hint_button.pressed.emit()
	puzzle.choices.get_child(2).button_pressed = true
	puzzle.confirm.pressed.emit()
	puzzle.confirm.pressed.emit()
	check("Combinação" in puzzle.heading.text and puzzle.total.visible, "Avança ao terceiro pedestal")
	puzzle.choices.get_child(0).button_pressed = true
	puzzle.confirm.pressed.emit()
	check("Faltam 13" in puzzle.feedback.text, "Explica a soma abaixo da meta")
	puzzle.choices.get_child(3).button_pressed = true
	puzzle.choices.get_child(4).button_pressed = true
	check("18" in puzzle.total.text, "Soma várias escolhas")
	puzzle.confirm.pressed.emit()
	check("passou" in puzzle.feedback.text, "Explica a soma acima da meta")
	puzzle.choices.get_child(3).button_pressed = false
	puzzle.choices.get_child(1).button_pressed = true
	puzzle.confirm.pressed.emit()
	check(puzzle.confirm.text == "Restaurar cristal", "Aceita a combinação 2 + 4 + 9")
	puzzle.confirm.pressed.emit()
	check(puzzle.preview.visible and not manager.is_completed(&"crystal"), "Anima antes de concluir a aventura")
	await puzzle.restored
	check(manager.is_completed(&"crystal") and puzzle.finish.visible, "Conclui a missão depois da animação")
	puzzle.finish.pressed.emit()
	check(not puzzle.visible and player.controls_enabled, "Devolve o controle ao fechar o resultado")
	world.interact()
	read_dialogue(dialogue)
	check(not puzzle.visible, "O desafio concluído não reabre")

	var events: Array[Dictionary] = manager.get_events()
	check(events[-2].type == "MISSION_COMPLETED" and events[-1].type == "SESSION_COMPLETED",
		"Registra a conclusão da missão seguida da conclusão da aventura")
	check(not manager.complete_mission(&"crystal") and manager.get_events().size() == events.size(),
		"A conclusão é registrada uma só vez")
	var solved := events.filter(func(event: Dictionary): return event.type == "PUZZLE_CORRECT")
	check(solved.map(func(event: Dictionary): return event.data.puzzle_id) ==
		["crystal_addition", "crystal_subtraction", "crystal_combination"], "Identifica cada pedestal no histórico")
	check(manager.count_puzzle_hints(&"crystal", &"crystal_addition") == 2
		and manager.count_puzzle_hints(&"crystal", &"crystal_subtraction") == 1, "Registra dicas por pedestal")
	game.queue_free()
	await process_frame
	print("Crystal puzzle: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
