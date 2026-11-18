extends Control

signal navigate(route: StringName)

const OBJECTIVES := {
	&"bridge": ["Encontre Tobi perto do rio.", "Escolha pilhas que somem 12 tábuas para reconstruir a ponte."],
	&"mill": ["Atravesse a ponte e encontre Flora.", "Distribua a energia do moinho e guarde pelo menos 6 unidades."],
	&"crystal": ["Entre na caverna depois do moinho.", "Resolva os três pedestais para restaurar o cristal."],
}

@onready var pause_button: Button = $HUD/Panel/Content/Pause
@onready var pause_menu: Control = $HUD/PauseMenu

var _dialogue_mission: StringName
var _focus_before_pause: Control


func _ready() -> void:
	var art_theme := preload("res://scripts/art_theme.gd").create()
	for control in $HUD.get_children():
		if control is Control:
			control.theme = art_theme
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := pause_button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 5
		style.content_margin_bottom = 5
		style.shadow_size = 0
		pause_button.add_theme_stylebox_override(state, style)
	MissionManager.changed.connect(_update_mission_status)
	_update_mission_status()
	$World.dialogue_requested.connect($HUD/Dialogue.show_dialogue)
	$HUD/Dialogue.opened.connect(func(): _set_modal_active(true))
	$HUD/Dialogue.closed.connect(func():
		_dialogue_mission = &""
		_set_modal_active($HUD/BridgePuzzle.visible or $HUD/MillPuzzle.visible or $HUD/CrystalPuzzle.visible))
	$World.interaction_requested.connect(func(point_id: StringName):
		_dialogue_mission = point_id)
	$HUD/Dialogue.finished.connect(_open_mission_puzzle)
	$HUD/BridgePuzzle.cancelled.connect(func(): _set_modal_active(false))
	$HUD/BridgePuzzle.solved.connect(_rebuild_bridge)
	$HUD/MillPuzzle.closed.connect(func(): _set_modal_active(false))
	$HUD/MillPuzzle.solved.connect(func(): MissionManager.complete_mission(&"mill"))
	$HUD/CrystalPuzzle.closed.connect(func(): _set_modal_active(false))
	$HUD/CrystalPuzzle.restored.connect(func(): MissionManager.complete_mission(&"crystal"))
	$World.message_changed.connect(func(text: String): $HUD/Message.text = text)
	pause_button.pressed.connect(_open_pause)
	pause_menu.resumed.connect(_restore_focus)
	pause_menu.menu_requested.connect(func(): navigate.emit(&"menu"))
	# Setas controlam o personagem; Tab ainda permite selecionar o botão.
	pause_button.focus_neighbor_left = pause_button.get_path()
	pause_button.focus_neighbor_right = pause_button.get_path()
	pause_button.focus_neighbor_top = pause_button.get_path()
	pause_button.focus_neighbor_bottom = pause_button.get_path()


func _input(event: InputEvent) -> void:
	if not event.is_echo() and event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_open_pause()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_echo() and event.is_action_pressed("ui_cancel") and not pause_button.disabled:
		get_viewport().set_input_as_handled()
		_open_pause()


func _open_pause() -> void:
	_focus_before_pause = get_viewport().gui_get_focus_owner()
	pause_menu.open()


func _restore_focus() -> void:
	if is_instance_valid(_focus_before_pause) and _focus_before_pause.is_visible_in_tree():
		_focus_before_pause.grab_focus()
	_focus_before_pause = null


func _open_mission_puzzle() -> void:
	if MissionManager.get_state(_dialogue_mission) != MissionManager.State.ACTIVE:
		return
	match _dialogue_mission:
		&"bridge":
			$HUD/BridgePuzzle.open()
		&"mill":
			$HUD/MillPuzzle.open()
		&"crystal":
			$HUD/CrystalPuzzle.open()


func _rebuild_bridge() -> void:
	await $World.rebuild_bridge()
	MissionManager.complete_mission(&"bridge")
	_set_modal_active(false)


func _set_modal_active(active: bool) -> void:
	$World.interaction_enabled = not active
	$World/Player.controls_enabled = not active
	pause_button.disabled = active
	$HUD/Message.visible = not active


func _update_mission_status() -> void:
	var lines: PackedStringArray = []
	var objective := ""
	var labels := ["Não iniciada", "Ativa", "Concluída"]
	for mission in MissionManager.ORDER:
		var state := MissionManager.get_state(mission)
		lines.append("%s · %s" % [MissionManager.TITLES[mission], labels[state]])
		if objective.is_empty() and state != MissionManager.State.COMPLETED:
			objective = "Objetivo atual · " + OBJECTIVES[mission][state]
	$HUD/MissionStatus/Content/Objective.text = objective if not objective.is_empty() else "Aventura concluída!"
	$HUD/MissionStatus/Content/Text.text = "\n".join(lines)
