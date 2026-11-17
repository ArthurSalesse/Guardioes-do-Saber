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


func run() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	var player = game.get_node("World/Player")
	var camera: Camera2D = player.get_node("Camera2D")
	await ticks(3)
	check(player is CharacterBody2D, "Player deve usar CharacterBody2D")
	for binding in [["move_left", KEY_LEFT, KEY_A], ["move_right", KEY_RIGHT, KEY_D],
		["move_up", KEY_UP, KEY_W], ["move_down", KEY_DOWN, KEY_S]]:
		var keys: Array[int] = []
		for event in InputMap.action_get_events(binding[0]):
			if event is InputEventKey:
				keys.append(event.physical_keycode)
		check(binding[1] in keys and binding[2] in keys, "Atalhos físicos: " + binding[0])
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		player.position = Vector2(960, 540)
		var start: Vector2 = player.position
		Input.action_press(action)
		await ticks(12)
		var distance: Vector2 = player.position - start
		check(distance.length() > 20, "Movimento: " + action)
		check(is_zero_approx(distance.x) or is_zero_approx(distance.y), "Movimento cardinal")
		check(player.walking and player.animation_time > 0, "Animação ao caminhar")
		Input.action_release(action)
		await ticks(2)
		check(player.velocity == Vector2.ZERO and not player.walking, "Parada ao soltar")
		check(player.animation_time == 0, "Animação ociosa")
	player.position = Vector2(960, 540)
	Input.action_press("move_right")
	Input.action_press("move_down")
	await ticks(12)
	check(is_equal_approx(player.position.y, 540), "Duas teclas não geram diagonal")
	check(is_equal_approx(player.velocity.length(), player.speed), "Sem ganho de velocidade")
	Input.action_release("move_down")
	# O obstáculo à direita começa em x=1160; o raio do jogador é 14.
	await ticks(80)
	check(player.position.x <= 1146.1, "Colisão com obstáculo")
	check(not player.walking, "Parado contra parede não anima caminhada")
	Input.action_release("move_right")
	for sample in [
		[Vector2(100, 200), "move_left", 0],
		[Vector2(1800, 200), "move_right", 1],
		[Vector2(300, 100), "move_up", 2],
		[Vector2(300, 980), "move_down", 3],
	]:
		player.position = sample[0]
		Input.action_press(sample[1])
		await ticks(60)
		Input.action_release(sample[1])
		check(player.position.x >= 45.9 and player.position.x <= 1874.1, "Limites horizontais")
		check(player.position.y >= 35.9 and player.position.y <= 1024.1, "Limites verticais")
		camera.force_update_scroll()
		var center := camera.get_screen_center_position()
		var half := root.get_visible_rect().size / 2
		check(center.x >= half.x - 1 and center.x <= 1920 - half.x + 1, "Limites da câmera X")
		check(center.y >= half.y - 1 and center.y <= 1080 - half.y + 1, "Limites da câmera Y")
	game.queue_free()
	await process_frame
	print("Movement: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
