extends Area2D

@export var point_id: StringName
@export var dialogue_pages: Array[Resource] = []
var selected := false
var _marker_time := 0.0
var _highlight := 0.0

@export var title := ""
@export_multiline var instruction := ""


func _ready() -> void:
	$Title.text = title


func contains_player(player: CharacterBody2D) -> bool:
	return overlaps_body(player)


func set_selected(value: bool) -> void:
	if selected != value:
		selected = value
		queue_redraw()


func _process(delta: float) -> void:
	_marker_time += delta
	_highlight = move_toward(_highlight, 1.0 if selected else 0.0, delta * 6.0)
	queue_redraw()


func _draw() -> void:
	var bob := sin(_marker_time * 2.7 + position.x * 0.02) * 2.0
	draw_set_transform(Vector2(0, bob))
	draw_circle(Vector2(0, 2), 23, Color("233d35b3"), true, -1.0, true)
	if _highlight > 0.0:
		draw_arc(Vector2.ZERO, 25 + _highlight * 4, 0, TAU, 48, Color(1, 0.92, 0.69, _highlight), 2, true)
	draw_circle(Vector2.ZERO, 20, Color("f0cf7b"), true, -1.0, true)
	draw_circle(Vector2.ZERO, 16, Color("5d4435"), true, -1.0, true)
	draw_arc(Vector2.ZERO, 17.5, 3.4, 5.4, 20, Color("fff0bc"), 1.1, true)
	draw_line(Vector2(0, -8), Vector2(0, 3), Color("fff0bc"), 4, true)
	draw_circle(Vector2(0, 9), 2, Color("fff0bc"), true, -1.0, true)
