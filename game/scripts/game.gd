extends Control

signal navigate(route: StringName)


func _ready() -> void:
	$World.message_changed.connect(func(text: String): $HUD/Message.text = text)
	$HUD/Panel/Content/Back.pressed.connect(func(): navigate.emit(&"menu"))
	# Setas controlam o personagem; Tab ainda permite selecionar o botão.
	$HUD/Panel/Content/Back.focus_neighbor_left = $HUD/Panel/Content/Back.get_path()
	$HUD/Panel/Content/Back.focus_neighbor_right = $HUD/Panel/Content/Back.get_path()
	$HUD/Panel/Content/Back.focus_neighbor_top = $HUD/Panel/Content/Back.get_path()
	$HUD/Panel/Content/Back.focus_neighbor_bottom = $HUD/Panel/Content/Back.get_path()
