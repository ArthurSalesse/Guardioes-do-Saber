extends CharacterBody2D
## Movimento cardinal sem diagonais; animação procedural provisória.

@export var speed := 240.0
var facing := Vector2.DOWN
var walking := false
var animation_time := 0.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Quatro direções: empates priorizam o eixo horizontal.
	if absf(direction.x) >= absf(direction.y):
		direction = Vector2(signf(direction.x), 0)
	else:
		direction = Vector2(0, signf(direction.y))
	velocity = direction * speed
	if direction != Vector2.ZERO:
		facing = direction
	move_and_slide()
	walking = get_real_velocity().length() > 1.0
	animation_time = animation_time + delta if walking else 0.0
	queue_redraw()


func _draw() -> void:
	var stride := sin(animation_time * 16.0) * 5.0 if walking else 0.0
	draw_ellipse_shadow()
	draw_line(Vector2(-7, 8), Vector2(-7, 22 + stride), Color("283b55"), 8)
	draw_line(Vector2(7, 8), Vector2(7, 22 - stride), Color("283b55"), 8)
	draw_rect(Rect2(-14, -12, 28, 30), Color("4286c4"))
	draw_line(Vector2(-18, -6), Vector2(-20, 10 - stride), Color("f2c49c"), 7)
	draw_line(Vector2(18, -6), Vector2(20, 10 + stride), Color("f2c49c"), 7)
	draw_circle(Vector2(0, -23), 15, Color("f2c49c"))
	draw_arc(Vector2(0, -25), 14, PI, TAU, 16, Color("47372e"), 7)
	if facing != Vector2.UP:
		var eye_x := facing.x * 5
		draw_circle(Vector2(-5 + eye_x, -23), 2, Color("202d3d"))
		draw_circle(Vector2(5 + eye_x, -23), 2, Color("202d3d"))
	else:
		draw_circle(Vector2(0, -25), 12, Color("47372e"))


func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 23), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 22, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO)
