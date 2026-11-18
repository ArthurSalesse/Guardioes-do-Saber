extends Node2D
## Layout determinístico: 60×34 tiles de 32px, três regiões sequenciais.

signal message_changed(text: String)
signal dialogue_requested(title: String, pages: Array[Resource])
signal interaction_requested(point_id: StringName)

const GRASS := 0
const PATH := 1
const WATER := 2
const TREE := 3
const ROCK := 4
const BRIDGE := 5
const GATE := 6
const BRIDGE_CELLS: Array[Vector2i] = [Vector2i(20, 16), Vector2i(21, 16), Vector2i(20, 17), Vector2i(21, 17)]
const CAVE_GATE: Array[Vector2i] = [Vector2i(40, 16), Vector2i(40, 17)]
const SPAWN := Vector2(288, 544)

@onready var ground: TileMapLayer = $Ground
@onready var obstacles: TileMapLayer = $Obstacles
@onready var progress = $Progress
var interaction_enabled := true
var active_point: Area2D
var _last_prompt := ""
var _placed_planks := 0.0


func _ready() -> void:
	var tiles := _make_tileset()
	ground.tile_set = tiles
	ground.collision_enabled = false
	obstacles.tile_set = tiles
	_build_map()
	progress.changed.connect(_apply_progress)
	_apply_progress()


func _make_tileset() -> TileSet:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32, 32)
	tiles.add_physics_layer()
	tiles.set_physics_layer_collision_layer(0, 1)
	tiles.set_physics_layer_collision_mask(0, 2)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = preload("res://assets/forest_tiles.svg")
	atlas.texture_region_size = Vector2i(32, 32)
	tiles.add_source(atlas, 0)
	for index in range(7):
		var coords := Vector2i(index, 0)
		atlas.create_tile(coords)
		if index == GRASS:
			for variant in range(1, 5):
				atlas.create_alternative_tile(coords, variant)
				atlas.get_tile_data(coords, variant).modulate = Color(1.0 - variant * 0.018, 1.0 - variant * 0.012, 1.0 - variant * 0.008)
		if index in [WATER, TREE, ROCK, GATE]:
			var data := atlas.get_tile_data(coords, 0)
			data.set_collision_polygons_count(0, 1)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]))
	return tiles


func _build_map() -> void:
	for x in range(60):
		for y in range(34):
			var cell := Vector2i(x, y)
			var path := y in [16, 17] or (x in [32, 33] and y >= 12 and y <= 17)
			ground.set_cell(cell, 0, Vector2i(PATH if path else GRASS, 0), 0 if path else (x * 7 + y * 11 + x * y) % 5)
			if x == 0 or x == 59 or y == 0 or y == 33:
				obstacles.set_cell(cell, 0, Vector2i(TREE, 0))
			elif x in [20, 21]:
				obstacles.set_cell(cell, 0, Vector2i(WATER, 0))
			elif x == 40:
				obstacles.set_cell(cell, 0, Vector2i(ROCK, 0))
	# Colisores dos edifícios; a entrada da caverna fica no caminho.
	for rect in [Rect2i(32, 9, 2, 3), Rect2i(51, 12, 4, 4)]:
		for x in range(rect.position.x, rect.end.x):
			for y in range(rect.position.y, rect.end.y):
				obstacles.set_cell(Vector2i(x, y), 0, Vector2i(ROCK, 0))
	# Bosques longe do caminho central e dos pontos de interação.
	for rect in [Rect2i(5, 6, 5, 4), Rect2i(8, 24, 7, 3), Rect2i(25, 23, 5, 4), Rect2i(46, 6, 6, 4)]:
		for x in range(rect.position.x, rect.end.x):
			for y in range(rect.position.y, rect.end.y):
				obstacles.set_cell(Vector2i(x, y), 0, Vector2i(TREE, 0))


func _apply_progress() -> void:
	for cell in BRIDGE_CELLS:
		if progress.is_completed(&"bridge"):
			ground.set_cell(cell, 0, Vector2i(BRIDGE, 0))
			obstacles.erase_cell(cell)
		else:
			ground.set_cell(cell, 0, Vector2i(PATH, 0))
			obstacles.set_cell(cell, 0, Vector2i(WATER, 0))
	for cell in CAVE_GATE:
		if progress.is_completed(&"mill"):
			obstacles.erase_cell(cell)
		else:
			obstacles.set_cell(cell, 0, Vector2i(GATE, 0))
	queue_redraw()


func rebuild_bridge() -> void:
	var animation := create_tween()
	animation.tween_method(_show_planks, 0.0, 12.0, 1.2)
	await animation.finished


func _show_planks(amount: float) -> void:
	_placed_planks = amount
	queue_redraw()


func _process(_delta: float) -> void:
	if not interaction_enabled:
		return
	var player := get_node_or_null("Player") as CharacterBody2D
	active_point = null
	var nearest := INF
	if player:
		for point in $Points.get_children():
			var distance := player.global_position.distance_squared_to(point.global_position)
			if point.contains_player(player) and distance < nearest:
				active_point = point
				nearest = distance
	for point in $Points.get_children():
		point.set_selected(point == active_point)
	var prompt := "Explore com WASD ou setas. Procure os sinais de !."
	if active_point:
		prompt = "[E] " + active_point.title + " · Ler orientação"
	if prompt != _last_prompt:
		_last_prompt = prompt
		message_changed.emit(prompt)


func _unhandled_input(event: InputEvent) -> void:
	if interaction_enabled and event.is_action_pressed("interact") and not event.is_echo():
		interact()
		get_viewport().set_input_as_handled()


func interact() -> bool:
	if not interaction_enabled or not is_instance_valid(active_point):
		return false
	var player := get_node_or_null("Player") as CharacterBody2D
	if not player or not active_point.contains_player(player):
		return false
	# A leitura inicia a missão disponível, sem concluir seu desafio.
	progress.start_mission(active_point.point_id)
	interaction_requested.emit(active_point.point_id)
	var pages: Array[Resource] = active_point.dialogue_pages.duplicate()
	var text := ""
	if active_point.point_id == &"crystal" and not progress.is_completed(&"mill"):
		text = "Restaure a ponte e o moinho para chegar à caverna."
	elif active_point.point_id in [&"bridge", &"mill", &"crystal"] and progress.is_completed(active_point.point_id):
		text = "Esta missão já foi concluída. Continue sua aventura!"
	if not text.is_empty() or pages.is_empty():
		var page = preload("res://scripts/instruction_page.gd").new()
		page.text = text if not text.is_empty() else active_point.instruction
		pages = [page]
	dialogue_requested.emit(active_point.title, pages)
	return true


func _draw() -> void:
	if not progress.is_completed(&"bridge"):
		for index in range(ceili(_placed_planks)):
			var drop := (1.0 - clampf(_placed_planks - index, 0.0, 1.0)) * 22.0
			var plank := Rect2(640 + index * 64.0 / 12.0, 512 - drop, 64.0 / 12.0, 64)
			draw_rect(plank, Color("ac794f"))
			draw_line(plank.position, plank.position + Vector2(0, 64), Color("64452f"))
	# Pequenos detalhes determinísticos: não alteram colisões ou objetivos.
	for i in range(320):
		var cell := Vector2i(2 + (i * 17) % 56, 2 + (i * 11) % 30)
		if cell.y in [15, 16, 17, 18] or cell.x in [20, 21, 40] or obstacles.get_cell_source_id(cell) != -1:
			continue
		var pos := Vector2(cell * 32) + Vector2(8 + i % 15, 10 + i % 12)
		if i % 4 == 0:
			draw_line(pos, pos + Vector2(0, -6), Color("80a666"), 1, true)
			draw_circle(pos + Vector2(0, -7), 2.1, Color("e6cb84") if i % 8 == 0 else Color("c9a7ae"))
		else:
			draw_arc(pos, 4, PI, TAU, 6, Color("58845a"), 1, true)
	# Moinho de pedra e madeira com telhado, janelas e velas.
	draw_set_transform(Vector2(1056, 375), 0, Vector2(1, 0.3))
	draw_circle(Vector2.ZERO, 73, Color(0.04, 0.12, 0.1, 0.3))
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(1011, 284, 90, 100), Color("bda57b"))
	draw_rect(Rect2(1017, 290, 15, 90), Color("d9c79b"))
	for row in range(5):
		draw_line(Vector2(1011, 300 + row * 17), Vector2(1101, 300 + row * 17), Color("a78d68"), 1)
	draw_colored_polygon(PackedVector2Array([Vector2(996, 287), Vector2(1056, 234), Vector2(1116, 287)]), Color("643f37"))
	for row in range(4):
		var y := 252.0 + row * 9
		var half := (y - 234) * 1.13
		draw_line(Vector2(1056 - half, y), Vector2(1056 + half, y), Color("a1694a"), 3, true)
	draw_style_box(preload("res://scripts/art_theme.gd").panel(Color("304d49"), Color("e0c38b"), 12), Rect2(1044, 343, 24, 41))
	for x in [1026, 1078]:
		draw_rect(Rect2(x, 307, 13, 20), Color("304d49"))
		draw_line(Vector2(x + 6, 307), Vector2(x + 6, 327), Color("dfc38a"), 2)
	for angle in [PI / 4, PI * 3 / 4, PI * 5 / 4, PI * 7 / 4]:
		var arm := Vector2.from_angle(angle)
		var side := arm.orthogonal()
		draw_line(Vector2(1056, 304), Vector2(1056, 304) + arm * 68, Color("684e39"), 5, true)
		var sail := PackedVector2Array([Vector2(1056,304) + arm * 18, Vector2(1056,304) + arm * 64, Vector2(1056,304) + arm * 64 + side * 15, Vector2(1056,304) + arm * 18 + side * 10])
		draw_colored_polygon(sail, Color("eee1b5"))
		draw_polyline(sail, Color("bda578"), 1, true)
	draw_circle(Vector2(1056, 304), 9, Color("73563e"))
	draw_circle(Vector2(1056, 304), 4, Color("d9bb77"))
	# Entrada rochosa e cristais luminosos.
	draw_set_transform(Vector2(1696, 509), 0, Vector2(1, 0.25))
	draw_circle(Vector2.ZERO, 90, Color(0.04, 0.12, 0.1, 0.35))
	draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(PackedVector2Array([Vector2(1616,512),Vector2(1622,427),Vector2(1656,380),Vector2(1707,366),Vector2(1758,405),Vector2(1776,512)]), Color("637b76"))
	draw_colored_polygon(PackedVector2Array([Vector2(1622,427),Vector2(1656,380),Vector2(1707,366),Vector2(1681,422),Vector2(1640,451)]), Color("91a395"))
	draw_colored_polygon(PackedVector2Array([Vector2(1707,366),Vector2(1758,405),Vector2(1776,512),Vector2(1730,486),Vector2(1716,415)]), Color("455f60"))
	draw_circle(Vector2(1696, 463), 44, Color("112f36"))
	draw_rect(Rect2(1652, 463, 88, 49), Color("112f36"))
	for pos in [Vector2(1640, 466), Vector2(1748, 481), Vector2(1728, 420)]:
		draw_circle(pos, 18, Color(0.35, 0.85, 0.8, 0.08))
		draw_colored_polygon(PackedVector2Array([pos + Vector2(0,-17),pos + Vector2(7,-5),pos + Vector2(4,9),pos + Vector2(-5,7),pos + Vector2(-7,-5)]), Color("70c9bd"))
		draw_line(pos + Vector2(0,-14), pos + Vector2(0,6), Color("c0eed7"), 2, true)
