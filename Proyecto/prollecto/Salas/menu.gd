extends Control


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Salas/ClickCreditos.tscn")


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Salas/Sala.tscn")


func _on_algomas_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit()
	
