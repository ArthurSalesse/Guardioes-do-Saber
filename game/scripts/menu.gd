extends Control

signal navigate(route: StringName)


func _ready() -> void:
	resized.connect(queue_redraw)
	$Center/Content/Start.pressed.connect(func(): navigate.emit(&"avatar_select"))
	$Center/Content/Restart.pressed.connect(_restart)
	$Center/Content/Start.text = "Continuar aventura" if MissionManager.has_progress() else "Iniciar"
	$Center/Content/Restart.visible = MissionManager.has_progress()
	$Center/Content/Start.grab_focus()


func _restart() -> void:
	MissionManager.new_session()
	navigate.emit(&"avatar_select")


func _draw() -> void:
	var extent := size
	draw_rect(Rect2(Vector2.ZERO, extent), Color("102f31"))
	# Lua e colinas em camadas.
	var moon := Vector2(extent.x * 0.76, extent.y * 0.23)
	for ring in range(8, 0, -1):
		draw_circle(moon, 38.0 + ring * 13, Color(0.8, 0.86, 0.62, 0.014))
	draw_circle(moon, 36, Color("e6dca5"))
	for layer in range(3):
		var ridge := PackedVector2Array([Vector2(0, extent.y)])
		for x in range(0, int(extent.x) + 33, 32):
			ridge.append(Vector2(x, extent.y * (0.48 + layer * 0.15) + sin(x * 0.006 + layer * 2.0) * 48))
		ridge.append(Vector2(extent.x + 32, extent.y))
		draw_colored_polygon(ridge, [Color("214b46"), Color("193e39"), Color("112e2c")][layer])
	for i in range(22):
		var x := float(i) * extent.x / 21.0
		if x > extent.x * 0.23 and x < extent.x * 0.77:
			continue
		var base := Vector2(x, extent.y * 0.96)
		var height := 120.0 + fmod(i * 73.0, 180.0)
		draw_line(base, base - Vector2(0, height), Color("102e2c"), 13)
		for tier in range(3):
			var top := base - Vector2(0, height + 40 - tier * 48)
			draw_colored_polygon(PackedVector2Array([top, top + Vector2(-60 + tier * 7, 105), top + Vector2(60 - tier * 7, 105)]), Color("183f36"))
	for i in range(35):
		var dot := Vector2(fmod(i * 137.3, extent.x), extent.y * 0.42 + fmod(i * 71.7, extent.y * 0.56))
		draw_circle(dot, 5, Color(0.8, 0.9, 0.5, 0.05))
		draw_circle(dot, 1.4, Color(0.9, 0.88, 0.55, 0.6))
