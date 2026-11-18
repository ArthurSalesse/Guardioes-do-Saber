extends Control

signal navigate(route: StringName)

var _dialogue_mission: StringName


func _ready() -> void:
	var art_theme := preload("res://scripts/art_theme.gd").create()
	for control in $HUD.get_children():
		if control is Control:
			control.theme = art_theme
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := $HUD/Panel/Content/Back.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 5
		style.content_margin_bottom = 5
		style.shadow_size = 0
		$HUD/Panel/Content/Back.add_theme_stylebox_override(state, style)
	MissionManager.changed.connect(_update_mission_status)
	_update_mission_status()
	$World.dialogue_requested.connect($HUD/Dialogue.show_dialogue)
	$HUD/Dialogue.opened.connect(func(): _set_modal_active(true))
	$HUD/Dialogue.closed.connect(func():
		_dialogue_mission = &""
		_set_modal_active($HUD/BridgePuzzle.visible or $HUD/MillPuzzle.visible))
	$World.interaction_requested.connect(func(point_id: StringName):
		_dialogue_mission = point_id)
	$HUD/Dialogue.finished.connect(_open_mission_puzzle)
	$HUD/BridgePuzzle.cancelled.connect(func(): _set_modal_active(false))
	$HUD/BridgePuzzle.solved.connect(_rebuild_bridge)
	$HUD/MillPuzzle.closed.connect(func(): _set_modal_active(false))
	$HUD/MillPuzzle.solved.connect(func(): MissionManager.complete_mission(&"mill"))
	$World.message_changed.connect(func(text: String): $HUD/Message.text = text)
	$HUD/Panel/Content/Back.pressed.connect(func(): navigate.emit(&"menu"))
	# Setas controlam o personagem; Tab ainda permite selecionar o botão.
	$HUD/Panel/Content/Back.focus_neighbor_left = $HUD/Panel/Content/Back.get_path()
	$HUD/Panel/Content/Back.focus_neighbor_right = $HUD/Panel/Content/Back.get_path()
	$HUD/Panel/Content/Back.focus_neighbor_top = $HUD/Panel/Content/Back.get_path()
	$HUD/Panel/Content/Back.focus_neighbor_bottom = $HUD/Panel/Content/Back.get_path()


func _open_mission_puzzle() -> void:
	if MissionManager.get_state(_dialogue_mission) != MissionManager.State.ACTIVE:
		return
	match _dialogue_mission:
		&"bridge":
			$HUD/BridgePuzzle.open()
		&"mill":
			$HUD/MillPuzzle.open()


func _rebuild_bridge() -> void:
	await $World.rebuild_bridge()
	MissionManager.complete_mission(&"bridge")
	_set_modal_active(false)


func _set_modal_active(active: bool) -> void:
	$World.interaction_enabled = not active
	$World/Player.controls_enabled = not active
	$HUD/Panel/Content/Back.disabled = active
	$HUD/Message.visible = not active


func _update_mission_status() -> void:
	var lines: PackedStringArray = ["Suas missões"]
	var labels := ["Não iniciada", "Ativa", "Concluída"]
	for mission in MissionManager.ORDER:
		lines.append("%s · %s" % [MissionManager.TITLES[mission], labels[MissionManager.get_state(mission)]])
	$HUD/MissionStatus/Text.text = "\n".join(lines)
