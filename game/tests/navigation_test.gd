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
		check(main.current_route == &"game", "Iniciar deve abrir o jogo")
		check(main.get_child_count() == 1, "Deve existir apenas uma tela ativa")
		main.get_node("Game/Center/Content/Back").pressed.emit()
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
