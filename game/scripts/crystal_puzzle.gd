extends Control

signal closed
signal restored

const MISSION := &"crystal"
const PEDESTALS := [
	{
		"id": &"crystal_addition", "title": "Adição",
		"question": "Você tem 7 cristais e encontra mais 5. Quantos cristais tem agora?",
		"choices": [10, 11, 12, 13], "target": 12,
		"hint": "Comece no 7 e conte mais cinco.",
	},
	{
		"id": &"crystal_subtraction", "title": "Subtração",
		"question": "Um mecanismo tem 18 unidades de energia e usa 9. Quantas restam?",
		"choices": [7, 8, 9, 10], "target": 9,
		"hint": "Conte de 9 até 18. Quantas unidades você acrescentou?",
	},
	{
		"id": &"crystal_combination", "title": "Combinação",
		"question": "Escolha cristais de valores diferentes que somem 15.",
		"choices": [2, 4, 6, 7, 9], "target": 15,
		"hint": "Escolha um cristal e calcule quanto falta para 15.",
	},
]

@onready var content: VBoxContainer = $Center/Panel/Content
@onready var choices: HBoxContainer = content.get_node("Choices")
@onready var preview: Control = $Center/Panel/Restoration
@onready var finish: Button = preview.get_node("Finish")
@onready var heading: Label = content.get_node("Pedestal")
@onready var question: Label = content.get_node("Question")
@onready var total: Label = content.get_node("Total")
@onready var feedback: Label = content.get_node("Feedback")
@onready var hint: Label = content.get_node("Hint")
@onready var actions: HBoxContainer = content.get_node("Actions")
@onready var confirm: Button = actions.get_node("Confirm")
@onready var hint_button: Button = actions.get_node("Hint")

var _index := 0
var _accepted := false
var _restoring := false
var _restoration := 0.0


func _ready() -> void:
	hide()
	preview.hide()
	preview.draw.connect(_draw_restoration)
	finish.pressed.connect(_finish)
	confirm.pressed.connect(_confirm)
	hint_button.pressed.connect(_request_hint)
	actions.get_node("Back").pressed.connect(_close)


func open() -> void:
	_index = 0
	while _index < PEDESTALS.size() and MissionManager.is_puzzle_solved(MISSION, PEDESTALS[_index].id):
		_index += 1
	show()
	if _index == PEDESTALS.size():
		_restore()
	else:
		_show_pedestal()


func _show_pedestal() -> void:
	_accepted = false
	var pedestal: Dictionary = PEDESTALS[_index]
	var multiple := _index == PEDESTALS.size() - 1
	heading.text = "Pedestal %d de %d · %s" % [_index + 1, PEDESTALS.size(), pedestal.title]
	question.text = pedestal.question
	hint_button.disabled = MissionManager.count_puzzle_hints(MISSION, pedestal.id) > 0
	hint.text = pedestal.hint if hint_button.disabled else ""
	confirm.text = "Confirmar"
	total.visible = multiple
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	var group := ButtonGroup.new()
	for value in pedestal.choices:
		var button := Button.new()
		button.text = str(value)
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not multiple:
			button.button_group = group
		button.toggled.connect(func(_pressed: bool): _update_selection())
		choices.add_child(button)
	_update_selection()
	choices.get_child(0).grab_focus()


func _selection() -> Array[int]:
	var values: Array[int] = []
	for button in choices.get_children():
		if button.button_pressed:
			values.append(int(button.text))
	return values


func _sum(values: Array[int]) -> int:
	return values.reduce(func(sum: int, value: int): return sum + value, 0)


func _update_selection() -> void:
	var selected := _selection()
	confirm.disabled = selected.is_empty()
	total.text = "Soma dos cristais: %d" % _sum(selected)
	feedback.text = ""


func _confirm() -> void:
	if not visible or _restoring or confirm.disabled:
		return
	if _accepted:
		_index += 1
		if _index == PEDESTALS.size():
			_restore()
		else:
			_show_pedestal()
		return

	var pedestal: Dictionary = PEDESTALS[_index]
	var selected := _selection()
	var answer := _sum(selected)
	var correct: bool = answer == pedestal.target
	var details := {"selected": selected, "answer": answer, "target": pedestal.target}
	MissionManager.record_puzzle_event(&"PUZZLE_ATTEMPTED", MISSION, details, pedestal.id)
	MissionManager.record_puzzle_event(&"PUZZLE_CORRECT" if correct else &"PUZZLE_INCORRECT", MISSION, details, pedestal.id)
	if not correct:
		if total.visible:
			feedback.text = "Faltam %d para chegar a %d." % [pedestal.target - answer, pedestal.target] if answer < pedestal.target else "A soma passou de %d. Reduza o valor escolhido." % pedestal.target
		else:
			feedback.text = "Ainda não. Confira a operação e tente outra resposta."
		return

	_accepted = true
	feedback.text = "Resposta certa! Pedestal ativado."
	for button in choices.get_children():
		button.disabled = true
	hint_button.disabled = true
	confirm.text = "Restaurar cristal" if _index == PEDESTALS.size() - 1 else "Próximo pedestal"
	confirm.grab_focus()


func _request_hint() -> void:
	if not visible or _restoring or hint_button.disabled:
		return
	var pedestal: Dictionary = PEDESTALS[_index]
	MissionManager.record_puzzle_event(&"HINT_REQUESTED", MISSION, {"hint_index": 1}, pedestal.id)
	hint.text = pedestal.hint
	hint_button.disabled = true


func _restore() -> void:
	_restoring = true
	content.hide()
	preview.show()
	var animation := create_tween()
	animation.tween_method(_set_restoration, 0.0, 1.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await animation.finished
	preview.get_node("Status").text = "Cristal restaurado! Aventura concluída."
	finish.show()
	finish.grab_focus()
	restored.emit()


func _set_restoration(amount: float) -> void:
	_restoration = amount
	preview.queue_redraw()


func _draw_restoration() -> void:
	var center := Vector2(preview.size.x / 2, 112)
	var glow := Color(0.47, 0.94, 0.86, 0.08 + _restoration * 0.18)
	preview.draw_circle(center, 52.0 + _restoration * 41.0, glow, true, -1.0, true)
	var colors := [Color("a4eddb"), Color("67c7bf"), Color("439eaa")]
	var points := [Vector2(0, -76), Vector2(46, 8), Vector2(0, 68), Vector2(-46, 8)]
	for index in range(colors.size()):
		var direction := Vector2.from_angle(TAU * index / 3.0 - PI / 2.0)
		var offset := direction * Vector2(84, 34) * (1.0 - _restoration)
		var facet := PackedVector2Array([center + offset, center + offset + points[index],
			center + offset + points[index + 1]])
		if index == 2:
			facet.append(center + offset + points[0])
		preview.draw_colored_polygon(facet, colors[index])


func _close() -> void:
	if visible and (not _restoring or finish.visible):
		_finish()


func _finish() -> void:
	hide()
	closed.emit()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		_close()
		get_viewport().set_input_as_handled()
