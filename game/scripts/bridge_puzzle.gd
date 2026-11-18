extends Control

signal cancelled
signal solved

const MISSION := &"bridge"
const TARGET := 12
const PILES := [4, 5, 7, 8]
const HINTS := [
	"Escolha uma pilha. Quanto falta para chegar a 12?",
	"Se você escolher a pilha de 5, procure a que tem 7 tábuas.",
]

@onready var piles: HBoxContainer = $Center/Panel/Content/Piles
@onready var total_label: Label = $Center/Panel/Content/Total
@onready var feedback: Label = $Center/Panel/Content/Feedback
@onready var hint: Label = $Center/Panel/Content/Hint
@onready var actions: HBoxContainer = $Center/Panel/Content/Actions

var _answer_accepted := false


func _ready() -> void:
	hide()
	for amount in PILES:
		var button := Button.new()
		button.text = "%d tábuas" % amount
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggled.connect(func(_pressed: bool): _update_total())
		piles.add_child(button)
	actions.get_node("Confirm").pressed.connect(_confirm)
	actions.get_node("Hint").pressed.connect(_request_hint)
	actions.get_node("Back").pressed.connect(_cancel)


func open() -> void:
	_answer_accepted = false
	for button in piles.get_children():
		button.set_pressed_no_signal(false)
		button.disabled = false
	for button in actions.get_children():
		button.disabled = false
	feedback.text = ""
	var hint_count := MissionManager.count_puzzle_hints(MISSION)
	hint.text = "" if hint_count == 0 else HINTS[mini(hint_count, HINTS.size()) - 1]
	actions.get_node("Hint").text = "Pedir dica" if hint_count == 0 else "Outra dica"
	actions.get_node("Hint").disabled = hint_count >= HINTS.size()
	_update_total()
	show()
	piles.get_child(0).grab_focus()


func _selected_piles() -> Array[int]:
	var selected: Array[int] = []
	for index in range(PILES.size()):
		if piles.get_child(index).button_pressed:
			selected.append(PILES[index])
	return selected


func _update_total() -> void:
	var selected := _selected_piles()
	var total: int = selected.reduce(func(sum: int, amount: int): return sum + amount, 0)
	total_label.text = "%d / %d tábuas" % [total, TARGET]
	actions.get_node("Confirm").disabled = selected.is_empty()
	feedback.text = ""


func _confirm() -> void:
	var selected := _selected_piles()
	if not visible or _answer_accepted or selected.is_empty():
		return
	var total: int = selected.reduce(func(sum: int, amount: int): return sum + amount, 0)
	var correct := total == TARGET
	MissionManager.record_puzzle_event(&"PUZZLE_ATTEMPTED", MISSION, {
		"selected_piles": selected, "total": total, "target": TARGET,
	})
	MissionManager.record_puzzle_event(&"PUZZLE_CORRECT" if correct else &"PUZZLE_INCORRECT", MISSION, {
		"total": total,
	})
	if not correct:
		feedback.text = "Ainda faltam %d para chegar a 12." % (TARGET - total) if total < TARGET else "Você passou de 12. Retire tábuas e tente de novo."
		return
	_answer_accepted = true
	feedback.text = "Você acertou! Vamos reconstruir a ponte."
	for button in piles.get_children() + actions.get_children():
		button.disabled = true
	await get_tree().create_timer(1.0, false).timeout
	hide()
	solved.emit()


func _request_hint() -> void:
	var index := MissionManager.count_puzzle_hints(MISSION)
	if not visible or _answer_accepted or index >= HINTS.size():
		return
	MissionManager.record_puzzle_event(&"HINT_REQUESTED", MISSION, {"hint_index": index + 1})
	hint.text = HINTS[index]
	actions.get_node("Hint").text = "Outra dica"
	actions.get_node("Hint").disabled = index + 1 == HINTS.size()


func _cancel() -> void:
	if visible and not _answer_accepted:
		hide()
		cancelled.emit()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		_cancel()
		get_viewport().set_input_as_handled()
