extends Control

signal navigate(route: StringName)


func _ready() -> void:
	$Center/Content/Start.pressed.connect(func(): navigate.emit(&"game"))
	$Center/Content/Restart.pressed.connect(_restart)
	$Center/Content/Start.text = "Continuar aventura" if MissionManager.has_progress() else "Iniciar"
	$Center/Content/Restart.visible = MissionManager.has_progress()
	$Center/Content/Start.grab_focus()


func _restart() -> void:
	MissionManager.new_session()
	navigate.emit(&"game")
