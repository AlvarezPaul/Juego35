extends Control

const ESCENA_MENU := "res://UI/ajustes.tscn"
@onready var click: AudioStreamPlayer = _buscar_click()


func _on_volver_pressed() -> void:
	if click != null and click.is_inside_tree():
		click.play()
	get_tree().change_scene_to_file(ESCENA_MENU)


# Busca un nodo llamado "Click" en este nodo y en sus padres.
func _buscar_click() -> AudioStreamPlayer:
	var nodo := get_parent()
	while nodo != null:
		var encontrado := nodo.find_child("Click", true, false)
		if encontrado is AudioStreamPlayer:
			return encontrado
		nodo = nodo.get_parent()
	return null
