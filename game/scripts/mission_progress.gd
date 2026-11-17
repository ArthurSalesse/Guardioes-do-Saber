extends Node
## Integração para os futuros controladores de missões; somente nesta sessão.

signal changed
const ORDER: Array[StringName] = [&"bridge", &"mill", &"crystal"]
var _completed: Array[StringName] = []


func is_completed(mission: StringName) -> bool:
	return mission in _completed


func complete_mission(mission: StringName) -> bool:
	if mission not in ORDER or mission in _completed:
		return false
	var index := ORDER.find(mission)
	if index > 0 and not is_completed(ORDER[index - 1]):
		return false
	_completed.append(mission)
	changed.emit()
	return true
