extends Control

signal navigate(route: StringName)


func _ready() -> void:
	$Center/Content/Start.pressed.connect(func(): navigate.emit(&"game"))
	$Center/Content/Start.grab_focus()
