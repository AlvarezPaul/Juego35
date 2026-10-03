extends CheckBox

@onready var click = $"../../../click"

func _on_toggled(toggled_on: bool) -> void:
	click.playing = true
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
