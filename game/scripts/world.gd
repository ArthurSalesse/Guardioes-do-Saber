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
			ground.set_cell(cell, 0, Vector2i(PATH if path else GRASS, 0))
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
		ground.set_cell(cell, 0, Vector2i(BRIDGE, 0))
		if progress.is_completed(&"bridge"):
			obstacles.erase_cell(cell)
		else:
			obstacles.set_cell(cell, 0, Vector2i(GATE, 0))
	for cell in CAVE_GATE:
		if progress.is_completed(&"mill"):
			obstacles.erase_cell(cell)
		else:
			obstacles.set_cell(cell, 0, Vector2i(GATE, 0))
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
	# Marcos visuais originais: moinho, caverna e portal de passagem.
	draw_rect(Rect2(1008, 288, 96, 96), Color("d6ba8a"))
	draw_colored_polygon(PackedVector2Array([Vector2(992, 288), Vector2(1056, 240), Vector2(1120, 288)]), Color("835644"))
	for offset in [Vector2(50, 50), Vector2(-50, 50)]:
		draw_line(Vector2(1056, 304) - offset, Vector2(1056, 304) + offset, Color("f2e5bd"), 10)
	draw_circle(Vector2(1056, 304), 10, Color("705744"))
	draw_circle(Vector2(1696, 448), 76, Color("7d8b91"))
	draw_rect(Rect2(1620, 448, 152, 64), Color("7d8b91"))
	draw_circle(Vector2(1696, 466), 42, Color("26343b"))
	draw_rect(Rect2(1654, 466, 84, 46), Color("26343b"))
