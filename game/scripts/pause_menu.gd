extends Control

signal resumed
signal menu_requested

@onready var resume_button: Button = $Center/Panel/Content/Resume


func _ready() -> void:
	hide()
	resume_button.pressed.connect(resume)
	var menu_button: Button = $Center/Panel/Content/Menu
	var volume_slider: HSlider = $Center/Panel/Content/Volume/Slider
	menu_button.pressed.connect(_go_to_menu)
	var controls: Array[Control] = [resume_button, volume_slider, menu_button]
	for index in range(controls.size()):
		var control := controls[index]
		control.focus_next = controls[(index + 1) % controls.size()].get_path()
		control.focus_previous = controls[posmod(index - 1, controls.size())].get_path()
		control.focus_neighbor_bottom = control.focus_next
		control.focus_neighbor_top = control.focus_previous
		control.focus_neighbor_left = control.get_path()
		control.focus_neighbor_right = control.get_path()


func open() -> void:
	if visible:
		return
	$Center/Panel/Content/Volume.refresh()
	show()
	get_tree().paused = true
	resume_button.grab_focus()


func resume() -> void:
	if not visible:
		return
	hide()
	get_tree().paused = false
	resumed.emit()


func _go_to_menu() -> void:
	resume()
	menu_requested.emit()


func _input(event: InputEvent) -> void:
	if visible and not event.is_echo() and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")):
		get_viewport().set_input_as_handled()
		resume()
