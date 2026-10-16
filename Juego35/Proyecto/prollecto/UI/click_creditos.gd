extends Control
## Pantalla de créditos: solo permite volver al menú principal.

const ESCENA_MENU := "res://UI/Menu.tscn"

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)
