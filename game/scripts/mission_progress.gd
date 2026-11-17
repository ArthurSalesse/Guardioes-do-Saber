extends Node
## Adaptador do mapa para o gerenciador que persiste durante a sessão.

signal changed


func _ready() -> void:
	MissionManager.changed.connect(_on_changed)


func _on_changed() -> void:
	changed.emit()


func is_completed(mission: StringName) -> bool:
	return MissionManager.is_completed(mission)


func start_mission(mission: StringName) -> bool:
	return MissionManager.start_mission(mission)


func complete_mission(mission: StringName) -> bool:
	return MissionManager.complete_mission(mission)
