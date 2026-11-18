extends Node2D

const TREE := 3
var _obstacles: TileMapLayer
var _trees: Array[Vector2] = []


func configure(obstacles: TileMapLayer) -> void:
	_obstacles = obstacles
	for cell in obstacles.get_used_cells():
		if obstacles.get_cell_atlas_coords(cell).x == TREE:
			_trees.append(Vector2(cell * 32) + Vector2(16, 26))
	_trees.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.y < b.y)
	queue_redraw()


func _draw() -> void:
	if _obstacles == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 17081
	_draw_path_edges()
	# Manchas e vegetação distribuídas pelo chão.
	for i in range(1450):
		var p := Vector2(rng.randf_range(24, 1896), rng.randf_range(24, 1056))
		var cell := Vector2i(p / 32.0)
		if cell.y in [16, 17] or (cell.x in [32, 33] and cell.y in range(12, 16)):
			if _obstacles.get_cell_source_id(cell) == -1 and cell.x not in [20, 21]:
				_ellipse(p, Vector2(rng.randf_range(1, 4), 1.2), Color("9d81574d"))
			continue
		if _obstacles.get_cell_source_id(cell) != -1:
			continue
		_ellipse(p, Vector2(rng.randf_range(5, 19), rng.randf_range(2, 7)), Color("9dbf7020"))
		if i % 3 == 0:
			_draw_plant(p, i)
	# Margens irregulares emolduram a água.
	for side in [-1, 1]:
		for span in [Vector2i(16, 512), Vector2i(576, 1080)]:
			var bank := PackedVector2Array()
			for y in range(span.x, span.y + 1, 4):
				var edge := sin(y * 0.08) * 2.5 + sin(y * 0.27) * 1.2
				bank.append(Vector2(672.0 + side * (32.0 + edge), y))
			draw_polyline(bank, Color("294d42"), 5.0, true)
			for i in range(0, bank.size(), 4):
				draw_circle(bank[i], 2.4, Color("91ae79"), true, -1.0, true)
	for p in _trees:
		_ellipse(p + Vector2(4, 2), Vector2(23, 7), Color("142f2b65"))
	for p in _trees:
		_draw_tree(p, rng)


func _draw_path_edges() -> void:
	for y in [512.0, 576.0]:
		var side := -1.0 if y == 512.0 else 1.0
		var spans := [Vector2i(0, 640), Vector2i(704, 1280), Vector2i(1312, 1920)]
		if y == 512.0:
			spans[1] = Vector2i(704, 1024)
			spans.append(Vector2i(1088, 1280))
		for span in spans:
			var edge := PackedVector2Array()
			for x in range(span.x, span.y + 1, 4):
				var roughness := 0.7 * sin(x * 0.11) + 1.2 * sin(x * 0.061)
				edge.append(Vector2(x, y + side * roughness))
			draw_polyline(edge, Color("9c9164"), 5.0, true)


func _draw_plant(p: Vector2, index: int) -> void:
	var leaf := Color("8ead6b") if index % 2 == 0 else Color("245445")
	for side in [-1, 1]:
		draw_line(p, p + Vector2(5 * side, -7), Color("416b4c"), 1.1, true)
		draw_circle(p + Vector2(4 * side, -6), 2.3, leaf, true, -1.0, true)
	if index % 4 == 0:
		draw_line(p, p - Vector2(0, 11), leaf, 1.2, true)
		draw_circle(p - Vector2(0, 11), 2.8, Color("eccb83") if index % 8 == 0 else Color("df9d9a"), true, -1.0, true)
		draw_circle(p - Vector2(0, 11), 0.9, Color("fff0bd"), true, -1.0, true)


func _draw_tree(p: Vector2, rng: RandomNumberGenerator) -> void:
	var crown := p + Vector2(rng.randf_range(-5, 5), rng.randf_range(-30, -23))
	var radius := rng.randf_range(15, 24)
	var green := Color("477a52").lerp(Color("72954c"), rng.randf())
	draw_line(p + Vector2(-2, 1), crown, Color("493b32"), 8, true)
	draw_line(p + Vector2(-4, -1), crown, Color("876449"), 2, true)
	for offset in [Vector2(-0.55, 0.1), Vector2(0.53, 0.12), Vector2(0.04, 0.38), Vector2(-0.1, -0.42)]:
		var center: Vector2 = crown + offset * radius
		draw_circle(center, radius * 0.69, Color("254a3c"), true, -1.0, true)
		draw_circle(center - Vector2(1, 3), radius * 0.63, green.darkened(0.13 + offset.y * 0.35), true, -1.0, true)
		draw_arc(center - Vector2(1, 3), radius * 0.48, 3.55, 5.0, 10, green.lightened(0.15), 1.5, true)
	for i in range(7):
		var speck := crown + Vector2(rng.randf_range(-0.7, 0.7), rng.randf_range(-0.75, 0.25)) * radius
		draw_line(speck, speck + Vector2(3, -1), green.lightened(0.22), 1.1, true)


func _ellipse(p: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(p, 0.0, Vector2(1.0, radii.y / radii.x))
	draw_circle(Vector2.ZERO, radii.x, color, true, -1.0, true)
	draw_set_transform(Vector2.ZERO)
