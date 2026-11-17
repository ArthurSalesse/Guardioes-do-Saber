extends Node
## Centraliza as rotas. A troca é adiada para não remover um botão no seu sinal.

const ROUTES := {
	"menu": preload("res://scenes/menu.tscn"),
	"game": preload("res://scenes/game.tscn"),
}

var current_route: StringName = &""
var _screen: Control
var _pending := false


func go_to(route: StringName) -> void:
	if not ROUTES.has(route) or _pending or route == current_route:
		return
	_pending = true
	_show.call_deferred(route)


func _show(route: StringName) -> void:
	if is_instance_valid(_screen):
		remove_child(_screen)
		_screen.queue_free()
	_screen = ROUTES[route].instantiate()
	_screen.navigate.connect(go_to)
	add_child(_screen)
	current_route = route
	_pending = false


func _ready() -> void:
	go_to(&"menu")
