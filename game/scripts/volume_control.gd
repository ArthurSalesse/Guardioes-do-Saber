extends HBoxContainer

@onready var slider: HSlider = $Slider
@onready var percent: Label = $Percent


func _ready() -> void:
	refresh()
	slider.value_changed.connect(_set_volume)


func refresh() -> void:
	var volume := 0.0 if AudioServer.is_bus_mute(0) else db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	slider.set_value_no_signal(volume)
	_update_label(slider.value)


func _set_volume(value: float) -> void:
	AudioServer.set_bus_mute(0, value == 0.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value / 100.0, 0.001)))
	_update_label(value)


func _update_label(value: float) -> void:
	percent.text = "%d%%" % value
