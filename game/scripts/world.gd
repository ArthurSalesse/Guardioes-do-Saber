extends Node2D
## Área provisória; retângulos visuais e colisores compartilham a mesma geometria.

const SIZE := Vector2(1920, 1080)
const WALLS: Array[Rect2] = [
	Rect2(0, 0, 1920, 32), Rect2(0, 1048, 1920, 32),
	Rect2(0, 32, 32, 1016), Rect2(1888, 32, 32, 1016),
]
const OBSTACLES: Array[Rect2] = [
	Rect2(1160, 440, 160, 200), Rect2(480, 280, 160, 160),
	Rect2(600, 800, 220, 100), Rect2(1480, 760, 160, 160),
]


func _ready() -> void:
	for rect in WALLS + OBSTACLES:
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 2
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collider.shape = shape
		body.position = rect.get_center()
		body.add_child(collider)
		add_child(body)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("345b44"))
	draw_rect(Rect2(32, 480, 1856, 120), Color("a08b63"))
	draw_rect(Rect2(900, 32, 120, 1016), Color("a08b63"))
	for x in range(80, 1880, 80):
		for y in range(80, 1040, 80):
			draw_line(Vector2(x, y), Vector2(x + 5, y - 8), Color("527955"), 2)
	for rect in WALLS:
		draw_rect(rect, Color("233e32"))
	for rect in OBSTACLES:
		draw_rect(rect, Color("243e35"))
		draw_rect(rect.grow(-8), Color("54765a"))
		draw_rect(rect.grow(-24), Color("668966"))
