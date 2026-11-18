extends RefCounted
## Paleta compartilhada entre menu, HUD e desafios.

static func panel(color: Color, border: Color, radius: int = 16) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 22
	box.content_margin_right = 22
	box.content_margin_top = 16
	box.content_margin_bottom = 16
	box.shadow_color = Color(0.015, 0.04, 0.035, 0.3)
	box.shadow_size = 8
	box.shadow_offset = Vector2(0, 4)
	return box

static func create() -> Theme:
	var result := Theme.new()
	result.default_font_size = 22
	result.set_color("font_color", "Label", Color("f3e9cd"))
	result.set_color("font_shadow_color", "Label", Color(0.02, 0.08, 0.07, 0.65))
	result.set_constant("shadow_offset_y", "Label", 2)
	result.set_stylebox("panel", "PanelContainer", panel(Color("183d38"), Color("6f8860")))
	result.set_stylebox("normal", "Button", panel(Color("28594b"), Color("a6b47a"), 12))
	result.set_stylebox("hover", "Button", panel(Color("39745b"), Color("e4ca86"), 12))
	result.set_stylebox("pressed", "Button", panel(Color("163e36"), Color("e4ca86"), 12))
	var focus := panel(Color(0, 0, 0, 0), Color("ffe4a0"), 12)
	focus.shadow_size = 0
	result.set_stylebox("focus", "Button", focus)
	result.set_color("font_color", "Button", Color("fff0cc"))
	result.set_color("font_hover_color", "Button", Color.WHITE)
	return result
