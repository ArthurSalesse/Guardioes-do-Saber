extends "res://scripts/menu.gd"
## A prévia usa o mesmo desenho do personagem dentro da aventura.

var selected: StringName = &"boy"
var choices: Array[Button] = []


func _ready() -> void:
	resized.connect(queue_redraw)
	var content := $Center/Content
	var group := ButtonGroup.new()
	for avatar_id in [&"boy", &"girl"]:
		var button := Button.new()
		button.name = "Boy" if avatar_id == &"boy" else "Girl"
		button.custom_minimum_size = Vector2(210, 240)
		button.toggle_mode = true
		button.button_group = group
		button.text = "Menino" if avatar_id == &"boy" else "Menina"
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("outline_size", 0)
		for state in ["normal", "hover", "pressed", "focus"]:
			var style := button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			style.content_margin_top = 180
			button.add_theme_stylebox_override(state, style)
		content.get_node("Choices").add_child(button)
		var preview = preload("res://scenes/player.tscn").instantiate()
		button.add_child(preview)
		preview.set_physics_process(false)
		preview.get_node("Camera2D").enabled = false
		preview.avatar = avatar_id
		preview.scale = Vector2(2.4, 2.4)
		button.resized.connect(func(): preview.position = Vector2(button.size.x / 2, 119))
		preview.position = Vector2(105, 119)
		preview.queue_redraw()
		button.pressed.connect(func(): _select(avatar_id))
		choices.append(button)
	_select(MissionManager.avatar)
	content.get_node("Begin").pressed.connect(_begin)
	content.get_node("Back").pressed.connect(func(): navigate.emit(&"menu"))
	choices[0 if selected == &"boy" else 1].grab_focus()


func _select(avatar_id: StringName) -> void:
	selected = avatar_id
	choices[0].set_pressed_no_signal(selected == &"boy")
	choices[1].set_pressed_no_signal(selected == &"girl")
	$Center/Content/Selection.text = "Avatar escolhido: %s" % ("menino" if selected == &"boy" else "menina")


func _begin() -> void:
	MissionManager.avatar = selected
	navigate.emit(&"game")
