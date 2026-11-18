extends CharacterBody2D
## Movimento cardinal e animação do pequeno guardião.

@export var avatar: StringName = &"boy"


func _ready() -> void:
	avatar = MissionManager.avatar
	_tunic_style = _make_tunic()
	_hair_style = _make_hair()
	queue_redraw()


@export var speed := 240.0
var controls_enabled := true
var facing := Vector2.DOWN
var walking := false
var animation_time := 0.0
var _idle_time := 0.0
var _gait := 0.0
var _step_phase := 0.0
var _tunic_style: StyleBoxFlat
var _hair_style: StyleBoxFlat


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not controls_enabled:
		direction = Vector2.ZERO
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
	_gait = move_toward(_gait, 1.0 if walking else 0.0, delta * 9.0)
	_idle_time += delta
	animation_time = animation_time + delta if walking else 0.0
	if _gait > 0.0:
		_step_phase += delta * 16.0
	else:
		_step_phase = 0.0
	queue_redraw()


func _draw() -> void:
	if _tunic_style == null:
		return
	var stride := sin(_step_phase) * _gait
	var lift := absf(stride) * 3.2
	var breathing := sin(_idle_time * 3.0) * (1.0 - _gait)
	var sway := facing.x * stride * 1.5
	draw_ellipse_shadow()
	for side in [-1, 1]:
		var foot := Vector2(side * 7.0, 22.0 + side * stride * 5.0)
		draw_line(Vector2(side * 7, 9 - lift), foot, Color("283b55"), 8, true)
		draw_line(foot, foot + Vector2(facing.x * 3.0, 1), Color("453638"), 8, true)
	draw_set_transform(Vector2(sway, breathing - lift), facing.x * _gait * 0.045)
	if avatar == &"girl":
		draw_style_box(_hair_style, Rect2(-17, -37, 34, 40))
		draw_circle(Vector2(18, -25 + stride * 0.3), 10, Color("49312f"))
		draw_circle(Vector2(16, -32), 4, Color("dfbb69"))
	# Capa, túnica, cinto e mochila compõem a silhueta do guardião.
	draw_colored_polygon(PackedVector2Array([Vector2(-13, -12), Vector2(13, -12), Vector2(19 + stride * 3, 19), Vector2(stride * 4, 15), Vector2(-19 + stride * 3, 19)]), Color("163f43"))
	draw_style_box(_tunic_style, Rect2(-13, -12, 26, 29))
	draw_line(Vector2(-11, 10), Vector2(11, 10), Color("75533b"), 5)
	draw_rect(Rect2(-3, 7, 6, 6), Color("dfc477"))
	draw_line(Vector2(-16, -5), Vector2(-19, 9 - stride * 5.0), Color("e4b78b"), 6, true)
	draw_line(Vector2(16, -5), Vector2(19, 9 + stride * 5.0), Color("e4b78b"), 6, true)
	draw_circle(Vector2(0, -23), 15.5, Color("553e32"))
	draw_circle(Vector2(0, -22), 13.5, Color("edc69a"))
	draw_arc(Vector2(0, -25), 13, PI, TAU, 20, _hair_color(), 8, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-14,-27), Vector2(-8,-39), Vector2(5,-40), Vector2(14,-29), Vector2(4,-31), Vector2(-3,-27)]), _hair_color())
	if facing != Vector2.UP:
		var eye_x := facing.x * 4
		draw_circle(Vector2(-5 + eye_x, -23), 2, Color("253b39"))
		draw_circle(Vector2(5 + eye_x, -23), 2, Color("253b39"))
		draw_circle(Vector2(-5.5 + eye_x, -23.5), 0.7, Color.WHITE)
		draw_arc(Vector2(eye_x, -19), 3, 0.2, PI - 0.2, 10, Color("a96d51"), 1, true)
	else:
		draw_circle(Vector2(0, -25), 12, _hair_color())
		draw_style_box(_tunic_style, Rect2(-10, -8, 20, 23))
		draw_rect(Rect2(-7, -4, 14, 15), Color("a08050"))
	draw_colored_polygon(PackedVector2Array([Vector2(-13,-11), Vector2(0,-6), Vector2(13,-11), Vector2(8,-2), Vector2(-7,-2)]), Color("dfbb69"))
	draw_set_transform(Vector2.ZERO)


func _make_tunic() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("9365a0") if avatar == &"girl" else Color("4d8a78")
	box.border_color = Color("62466f") if avatar == &"girl" else Color("296057")
	box.set_border_width_all(2)
	box.set_corner_radius_all(5)
	return box


func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 23), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 22, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO)


func _hair_color() -> Color:
	return Color("49312f") if avatar == &"girl" else Color("604332")


func _make_hair() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = _hair_color()
	box.set_corner_radius_all(14)
	return box
