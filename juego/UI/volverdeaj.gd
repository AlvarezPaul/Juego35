extends Button

const ESCENA_MENU := "res://UI/Menu.tscn"

func _on_pressed() -> void:
	Autoloadsonido.play_click()
	get_tree().change_scene_to_file(ESCENA_MENU)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file(ESCENA_MENU)
