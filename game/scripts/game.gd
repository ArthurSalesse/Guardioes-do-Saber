extends Control

signal navigate(route: StringName)


func _ready() -> void:
	$Center/Content/Back.pressed.connect(func(): navigate.emit(&"menu"))
	$Center/Content/Back.grab_focus()
