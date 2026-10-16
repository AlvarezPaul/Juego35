extends Control

const ESCENA_MENU := "res://UI/ajustes.tscn"

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)


func _on_pressed() -> void:
	pass # Replace with function body.
