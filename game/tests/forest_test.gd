extends SceneTree

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame


func reachable(world: Node, target: Vector2i) -> bool:
	var visited := {}
	var pending: Array[Vector2i] = [Vector2i(9, 17)]
	while not pending.is_empty():
		var cell: Vector2i = pending.pop_back()
		if cell == target:
			return true
		if visited.has(cell) or cell.x < 0 or cell.x >= 60 or cell.y < 0 or cell.y >= 34:
			continue
		visited[cell] = true
		var data: TileData = world.obstacles.get_cell_tile_data(cell)
		if data and data.get_collision_polygons_count(0) > 0:
			continue
		for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			pending.append(cell + step)
	return false


func run() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	var world = game.get_node("World")
	var player = world.get_node("Player")
	var progress = world.get_node("Progress")
	await ticks(4)
	check(world.ground is TileMapLayer and world.obstacles is TileMapLayer, "Camadas de tiles")
	check(world.ground.get_used_cells().size() == 2040, "Mapa 60×34 completo")
	check(reachable(world, Vector2i(17, 17)), "Tobi acessível da clareira")
	check(not reachable(world, Vector2i(33, 13)), "Moinho bloqueado pela ponte")
	check(not reachable(world, Vector2i(51, 17)), "Caverna bloqueada")
	check(not progress.complete_mission(&"mill"), "Não permite missão fora de ordem")
	check(not progress.complete_mission(&"unknown"), "Não aceita missão desconhecida")
	var events: Array[StringName] = []
	world.interaction_requested.connect(func(id: StringName): events.append(id))
	player.position = Vector2(544, 544)
	await ticks(4)
	check(world.interact() and events == [&"bridge"], "Interação próxima emite ID da missão")
	check(not progress.is_completed(&"bridge"), "Interagir não conclui missão")
	game.get_node("HUD/Dialogue").close_dialogue()
	player.position = Vector2(160, 800)
	await ticks(4)
	check(not world.interact(), "Não interage fora do alcance")
	check(progress.complete_mission(&"bridge"), "Conclui ponte")
	check(not progress.complete_mission(&"bridge"), "Conclusão idempotente")
	await ticks(4)
	check(reachable(world, Vector2i(33, 13)), "Moinho acessível após a ponte")
	check(not reachable(world, Vector2i(51, 17)), "Caverna continua bloqueada")
	player.position = Vector2(600, 544)
	Input.action_press("move_right")
	await ticks(40)
	Input.action_release("move_right")
	check(player.position.x > 704, "Passagem física pela ponte liberada")
	player.position = Vector2(1216, 544)
	Input.action_press("move_right")
	await ticks(35)
	Input.action_release("move_right")
	check(player.position.x <= 1266.1, "Portão da caverna tem colisão antes do moinho")
	check(progress.complete_mission(&"mill"), "Conclui moinho")
	await ticks(4)
	check(reachable(world, Vector2i(51, 17)), "Caverna acessível após moinho")
	Input.action_press("move_right")
	await ticks(30)
	Input.action_release("move_right")
	check(player.position.x > 1312, "Colisão do portão removida")
	check(progress.complete_mission(&"crystal"), "Conclui sequência")
	game.queue_free()
	await process_frame
	var fresh = load("res://scenes/forest.tscn").instantiate()
	root.add_child(fresh)
	check(not fresh.progress.is_completed(&"bridge"), "Nova aventura começa bloqueada")
	fresh.queue_free()
	await process_frame
	print("Forest: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
