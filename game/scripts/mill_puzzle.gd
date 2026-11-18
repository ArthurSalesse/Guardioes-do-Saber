extends Control

signal closed
signal solved

const MISSION := &"mill"
const BUDGET := 20
const RESERVE := 6
const ENERGY_A := 6
const ENERGY_B := 8
const HINTS := [
	"Some a energia dos dois mecanismos. Quanto sobra para a reserva?",
	"Calcule 20 − 6 − 8 para descobrir quanto fica na reserva.",
]

@onready var energy_a: SpinBox = $Center/Panel/Content/Allocation/EnergyA
@onready var energy_b: SpinBox = $Center/Panel/Content/Allocation/EnergyB
@onready var balance: Label = $Center/Panel/Content/Balance
@onready var feedback: Label = $Center/Panel/Content/Feedback
@onready var hint: Label = $Center/Panel/Content/Hint
@onready var actions: HBoxContainer = $Center/Panel/Content/Actions

var _answer_accepted := false


func _ready() -> void:
	hide()
	for field in [energy_a, energy_b]:
		field.max_value = BUDGET
		field.value_changed.connect(_update_balance)
	$Center/Panel/Content/Instructions.text = "Distribua %d unidades de energia e guarde pelo menos %d." % [BUDGET, RESERVE]
	$Center/Panel/Content/Allocation/LabelA.text = "Mecanismo A · precisa de %d" % ENERGY_A
	$Center/Panel/Content/Allocation/LabelB.text = "Mecanismo B · precisa de %d" % ENERGY_B
	actions.get_node("Confirm").pressed.connect(_confirm)
	actions.get_node("Hint").pressed.connect(_request_hint)
	actions.get_node("Back").pressed.connect(_cancel)


func open() -> void:
	_answer_accepted = false
	for field in [energy_a, energy_b]:
		field.value = 0
		field.editable = true
	for button in actions.get_children():
		button.disabled = false
	var hint_count := MissionManager.count_puzzle_hints(MISSION)
	hint.text = "" if hint_count == 0 else HINTS[mini(hint_count, HINTS.size()) - 1]
	actions.get_node("Hint").text = "Pedir dica" if hint_count == 0 else "Outra dica"
	actions.get_node("Hint").disabled = hint_count >= HINTS.size()
	_update_balance()
	show()
	energy_a.get_line_edit().grab_focus()


func _update_balance(_value: float = 0.0) -> void:
	var remaining := BUDGET - int(energy_a.value) - int(energy_b.value)
	balance.text = "Energia restante: %d de %d · Reserva mínima: %d" % [remaining, BUDGET, RESERVE]
	feedback.text = ""


func _confirm() -> void:
	if not visible or _answer_accepted:
		return
	energy_a.apply()
	energy_b.apply()
	var a := int(energy_a.value)
	var b := int(energy_b.value)
	var remaining := BUDGET - a - b
	var error := ""
	if remaining < 0:
		error = "Faltam %d unidades para essa distribuição. Você tem %d no total." % [-remaining, BUDGET]
	elif remaining < RESERVE:
		error = "Sobraram %d unidades. A reserva precisa de pelo menos %d." % [remaining, RESERVE]
	elif a != ENERGY_A or b != ENERGY_B:
		error = "A precisa receber exatamente %d unidades e B precisa receber %d." % [ENERGY_A, ENERGY_B]

	MissionManager.record_puzzle_event(&"PUZZLE_ATTEMPTED", MISSION, {
		"energy_a": a, "energy_b": b, "remaining": remaining,
	})
	MissionManager.record_puzzle_event(&"PUZZLE_CORRECT" if error.is_empty() else &"PUZZLE_INCORRECT", MISSION, {
		"remaining": remaining,
	})
	if not error.is_empty():
		feedback.text = error
		return

	_answer_accepted = true
	feedback.text = "Você acertou! O moinho voltou a funcionar e a caverna está aberta."
	for field in [energy_a, energy_b]:
		field.editable = false
	for button in actions.get_children():
		button.disabled = true
	solved.emit()
	await get_tree().create_timer(1.8, false).timeout
	hide()
	closed.emit()


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
		closed.emit()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		_cancel()
		get_viewport().set_input_as_handled()
