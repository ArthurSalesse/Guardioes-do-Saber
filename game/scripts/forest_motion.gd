extends Node2D

var bridge_open := false
var crystals: Array[Vector2] = []
var _time := 0.0
var _motes := PackedVector2Array()


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 725
	for i in range(75):
		_motes.append(Vector2(rng.randf_range(32, 1888), rng.randf_range(40, 1040)))


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for i in range(58):
		var y := fposmod(i * 19.0 + _time * (16.0 + i % 3 * 3.0), 1080.0)
		if bridge_open and y > 508 and y < 579:
			continue
		var x := 646.0 + (i * 17) % 39 + sin(_time * 1.3 + i) * 3.0
		var width := 6.0 + i % 4 * 3.0
		var alpha := 0.17 + 0.13 * sin(_time * 2.0 + i)
		draw_line(Vector2(x, y), Vector2(minf(x + width, 700), y - 1.2), Color(0.67, 0.97, 0.87, alpha), 1.4, true)

	for i in range(_motes.size()):
		var phase := _time * (0.6 + i % 5 * 0.14) + i
		var p := _motes[i] + Vector2(cos(phase) * 22.0, sin(phase * 0.7) * 12.0)
		var glow := 0.5 + 0.5 * sin(phase * 1.8)
		var color := Color("f9da85") if p.x < 1280 else Color("a9ffe2")
		draw_circle(p, 5.0 + glow * 3.0, Color(color, glow * 0.10), true, -1.0, true)
		draw_circle(p, 1.0 + glow, Color(color, glow * 0.74), true, -1.0, true)

	for crystal in crystals:
		var point := crystal - Vector2(0, 4)
		var pulse := 0.5 + 0.5 * sin(_time * 1.8 + point.y * 0.08)
		draw_circle(point, 18.0 + pulse * 6.0, Color(0.43, 0.96, 0.85, 0.03 + pulse * 0.04), true, -1.0, true)
		var sparkle := point + Vector2(7, -13 + sin(_time * 1.8 + point.x) * 3.0)
		draw_line(sparkle - Vector2(0, 3), sparkle + Vector2(0, 3), Color(0.72, 1.0, 0.88, pulse * 0.8), 1.0, true)
		draw_line(sparkle - Vector2(3, 0), sparkle + Vector2(3, 0), Color(0.72, 1.0, 0.88, pulse * 0.8), 1.0, true)
