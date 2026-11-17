extends SceneTree

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func frames() -> void:
	await process_frame
	await process_frame


func run() -> void:
	var manager = root.get_node("MissionManager")
	manager.new_session()
	var first_session: String = manager.session_id
	var observed: Array[Dictionary] = []
	var starts: Array[StringName] = []
	var ends: Array[StringName] = []
	manager.event_recorded.connect(func(event: Dictionary): observed.append(event))
	manager.mission_started.connect(func(id: StringName): starts.append(id))
	manager.mission_completed.connect(func(id: StringName): ends.append(id))
	for mission in manager.ORDER:
		check(manager.get_state(mission) == manager.State.NOT_STARTED, "Estado inicial: " + mission)
	check(manager.get_state(&"unknown") == -1, "ID desconhecido não vira missão")
	check(not manager.start_mission(&"unknown"), "Início desconhecido recusado")
	check(not manager.complete_mission(&"bridge"), "Não conclui sem iniciar")
	check(not manager.start_mission(&"mill"), "Pré-requisito impede início fora de ordem")
	for mission in manager.ORDER:
		check(manager.start_mission(mission), "Inicia missão: " + mission)
		check(manager.get_state(mission) == manager.State.ACTIVE, "Estado ativo")
		check(not manager.start_mission(mission), "Repetir início não emite outro evento")
		check(manager.complete_mission(mission), "Conclui missão: " + mission)
		check(manager.get_state(mission) == manager.State.COMPLETED, "Estado concluído")
		check(not manager.complete_mission(mission), "Repetir conclusão não emite outro evento")
	check(starts == manager.ORDER and ends == manager.ORDER, "Sinais uma vez por transição")
	var events: Array[Dictionary] = manager.get_events()
	check(events.size() == 6 and observed.size() == 6, "Dois eventos por missão")
	var identifiers := {}
	for index in range(events.size()):
		var event := events[index]
		check(event.session_id == first_session, "Evento vinculado à sessão")
		check(not identifiers.has(event.id), "Identificador de evento único")
		identifiers[event.id] = true
		check(event.occurred_at.ends_with("Z"), "Momento de ocorrência em UTC")
		check(event.type == ("MISSION_STARTED" if index % 2 == 0 else "MISSION_COMPLETED"), "Ordem dos eventos")
	events[0]["type"] = "mutated"
	observed[0]["type"] = "mutated"
	check(manager.get_events()[0].type == "MISSION_STARTED", "Consumidores não alteram histórico interno")
	manager.new_session()
	check(manager.session_id != first_session and manager.get_events().is_empty(), "Nova sessão renova ID e histórico")
	# Exercita o fluxo real: interação inicia, desafio conclui, menu permite continuar.
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames()
	main.get_node("Menu/Center/Content/Start").pressed.emit()
	await frames()
	var game = main.get_node("Game")
	game.get_node("World/Player").position = Vector2(544, 544)
	for tick in range(5):
		await physics_frame
	await frames()
	check(game.get_node("World").interact(), "Interação com Tobi aceita")
	check(manager.get_state(&"bridge") == manager.State.ACTIVE, "Interação inicia missão disponível")
	game.get_node("HUD/Dialogue").close_dialogue()
	check(manager.complete_mission(&"bridge"), "Controlador de desafio pode concluir missão ativa")
	game.get_node("HUD/Panel/Content/Back").pressed.emit()
	await frames()
	check(main.get_node("Menu/Center/Content/Start").text == "Continuar aventura", "Menu mostra continuar")
	main.get_node("Menu/Center/Content/Start").pressed.emit()
	await frames()
	game = main.get_node("Game")
	check(manager.is_completed(&"bridge"), "Troca de cena preserva progresso")
	check(game.get_node("World/Obstacles").get_cell_source_id(Vector2i(20, 16)) == -1, "Mapa recriado restaura passagem aberta")
	check(game.get_node("HUD/MissionStatus/Text").text.contains("Concluída"), "HUD restaura status")
	game.get_node("HUD/Panel/Content/Back").pressed.emit()
	await frames()
	main.get_node("Menu/Center/Content/Restart").pressed.emit()
	await frames()
	check(not manager.has_progress() and manager.get_events().is_empty(), "Recomeçar limpa progresso e eventos")
	check(main.get_node("Game/World/Obstacles").get_cell_source_id(Vector2i(20, 16)) == 0, "Recomeçar fecha ponte")
	main.queue_free()
	await frames()
	print("Missions: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
