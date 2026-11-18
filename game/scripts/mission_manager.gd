extends Node
## Estado da aventura atual. Sobrevive a trocas de cena, não ao fechar o jogo.

signal changed
signal mission_started(mission: StringName)
signal mission_completed(mission: StringName)
signal event_recorded(event: Dictionary)

enum State { NOT_STARTED, ACTIVE, COMPLETED }
const ORDER: Array[StringName] = [&"bridge", &"mill", &"crystal"]
const TITLES := {
	&"bridge": "A Ponte Quebrada",
	&"mill": "O Moinho Encantado",
	&"crystal": "O Cristal Perdido",
}
var avatar: StringName = &"boy"
var session_id := ""
var _states: Dictionary = {}
var _started_at: Dictionary = {}
var _events: Array[Dictionary] = []


func _ready() -> void:
	new_session()


func new_session() -> void:
	avatar = &"boy"
	session_id = Crypto.new().generate_random_bytes(16).hex_encode()
	_states.clear()
	_events.clear()
	_started_at.clear()
	for mission in ORDER:
		_states[mission] = State.NOT_STARTED
	changed.emit()


func get_state(mission: StringName) -> int:
	return _states.get(mission, -1)


func is_completed(mission: StringName) -> bool:
	return get_state(mission) == State.COMPLETED


func has_progress() -> bool:
	for mission in ORDER:
		if get_state(mission) != State.NOT_STARTED:
			return true
	return false


func can_start(mission: StringName) -> bool:
	var index := ORDER.find(mission)
	if index < 0 or get_state(mission) != State.NOT_STARTED:
		return false
	return index == 0 or is_completed(ORDER[index - 1])


func start_mission(mission: StringName) -> bool:
	if not can_start(mission):
		return false
	_states[mission] = State.ACTIVE
	_started_at[mission] = Time.get_ticks_msec()
	_record(&"MISSION_STARTED", mission)
	mission_started.emit(mission)
	changed.emit()
	return true


func complete_mission(mission: StringName) -> bool:
	if get_state(mission) != State.ACTIVE:
		return false
	_states[mission] = State.COMPLETED
	_record(&"MISSION_COMPLETED", mission)
	mission_completed.emit(mission)
	changed.emit()
	return true


func get_events() -> Array[Dictionary]:
	return _events.duplicate(true)


func count_puzzle_hints(mission: StringName) -> int:
	var count := 0
	for event in _events:
		if event.type == "HINT_REQUESTED" and event.mission_id == String(mission):
			count += 1
	return count


func record_puzzle_event(type: StringName, mission: StringName, details: Dictionary) -> void:
	if mission != &"bridge" or get_state(mission) != State.ACTIVE:
		return
	var data := details.duplicate(true)
	data.puzzle_id = "bridge"
	data.skill = "addition"
	data.elapsed_ms = Time.get_ticks_msec() - _started_at[mission]
	_record(type, mission, data)


func _record(type: StringName, mission: StringName, data: Dictionary = {}) -> void:
	var event := {
		"id": "%s:%d" % [session_id, _events.size() + 1],
		"session_id": session_id,
		"type": String(type),
		"mission_id": String(mission),
		"occurred_at": Time.get_datetime_string_from_system(true) + "Z",
	}
	if not data.is_empty():
		event.data = data
	_events.append(event)
	event_recorded.emit(event.duplicate(true))
