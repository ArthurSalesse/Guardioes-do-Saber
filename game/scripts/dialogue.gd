extends Control

signal opened
signal closed
signal page_changed(index: int)

var pages: Array[Resource] = []
var page_index := 0

@onready var speaker: Label = $Panel/Margin/Content/Header/Speaker
@onready var counter: Label = $Panel/Margin/Content/Header/Counter
@onready var body: Label = $Panel/Margin/Content/Text
@onready var next_button: Button = $Panel/Margin/Content/Buttons/Next
@onready var replay_button: Button = $Panel/Margin/Content/Buttons/Replay
@onready var audio: AudioStreamPlayer = $Audio


func _ready() -> void:
	hide()
	next_button.pressed.connect(advance)
	$Panel/Margin/Content/Buttons/Close.pressed.connect(close_dialogue)
	replay_button.pressed.connect(replay_audio)


func show_dialogue(title: String, content: Array[Resource]) -> bool:
	if visible:
		return false
	pages.clear()
	for page in content:
		if page != null and not page.text.strip_edges().is_empty():
			pages.append(page)
	if pages.is_empty():
		return false
	speaker.text = title
	page_index = 0
	show()
	opened.emit()
	_show_page()
	return true


func _show_page() -> void:
	audio.stop()
	body.text = pages[page_index].text
	counter.text = "%d / %d" % [page_index + 1, pages.size()]
	next_button.text = "Concluir" if page_index == pages.size() - 1 else "Próximo"
	audio.stream = pages[page_index].audio
	replay_button.disabled = audio.stream == null
	if audio.stream != null:
		audio.play()
	next_button.grab_focus()
	page_changed.emit(page_index)


func advance() -> void:
	if not visible:
		return
	if page_index + 1 >= pages.size():
		close_dialogue()
	else:
		page_index += 1
		_show_page()


func replay_audio() -> void:
	if visible and audio.stream != null:
		audio.play()


func close_dialogue() -> void:
	if not visible:
		return
	audio.stop()
	audio.stream = null
	hide()
	pages.clear()
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible or event.is_echo():
		return
	if event.is_action_pressed("interact"):
		advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		close_dialogue()
		get_viewport().set_input_as_handled()
