extends Area2D

@export var point_id: StringName
@export var title := ""
@export_multiline var instruction := ""


func _ready() -> void:
	$Title.text = title


func contains_player(player: CharacterBody2D) -> bool:
	return overlaps_body(player)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 22, Color("f0cf7b"))
	draw_circle(Vector2.ZERO, 17, Color("735d41"))
	draw_line(Vector2(0, -9), Vector2(0, 3), Color.WHITE, 4)
	draw_circle(Vector2(0, 10), 2, Color.WHITE)
