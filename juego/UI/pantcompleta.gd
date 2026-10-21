extends CheckBox

func _ready() -> void:
	# El check refleja el modo de pantalla actual sin disparar la señal.
	set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_toggled(toggled_on: bool) -> void:
	Autoloadsonido.play_click()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
