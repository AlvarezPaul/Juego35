extends CanvasLayer

func _on_intentar_de_nuevo_pressed() -> void:
	Mensajetexto.reset_mensajes()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/pantalla_de_carga.tscn")

func _on_volver_al_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Menu.tscn")
