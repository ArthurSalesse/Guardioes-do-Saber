extends SceneTree
## Exercita os botões reais e as rotas sem exigir uma janela.

var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func run() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	check(main.current_route == &"menu", "Inicialização deve abrir o menu")
	for iteration in range(3):
		main.get_node("Menu/Center/Content/Start").pressed.emit()
		await process_frame
		await process_frame
		check(main.current_route == &"avatar_select", "Iniciar deve abrir a escolha de avatar")
		var avatar_id: StringName = &"girl" if iteration % 2 == 0 else &"boy"
		var choice := "Girl" if avatar_id == &"girl" else "Boy"
		main.get_node("AvatarSelect/Center/Content/Choices/" + choice).pressed.emit()
		main.get_node("AvatarSelect/Center/Content/Begin").pressed.emit()
		await process_frame
		await process_frame
		check(main.current_route == &"game", "Confirmar avatar deve abrir o jogo")
		check(main.get_node("Game/World/Player").avatar == avatar_id, "Personagem deve usar o avatar escolhido")
		check(main.get_child_count() == 1, "Deve existir apenas uma tela ativa")
		main.get_node("Game/HUD/Panel/Content/Pause").pressed.emit()
		main.get_node("Game/HUD/PauseMenu/Center/Panel/Content/Menu").pressed.emit()
		await process_frame
		await process_frame
		check(main.current_route == &"menu", "Voltar deve abrir o menu")
	main.go_to(&"missing")
	await process_frame
	check(main.current_route == &"menu", "Rota inválida deve preservar a tela")
	main.go_to(&"menu")
	await process_frame
	check(main.get_child_count() == 1, "Mesma rota não deve duplicar a tela")
	main.queue_free()
	await process_frame
	print("Navigation: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
