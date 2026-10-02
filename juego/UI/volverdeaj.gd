extends Button

const ESCENA_MENU := "res://UI/Menu.tscn"
@onready var click: AudioStreamPlayer = _buscar_click()


func _on_pressed() -> void:
	# Primero suena el click y recién después se cambia de escena.
	if click != null and click.is_inside_tree():
		click.play()
		await click.finished
	get_tree().change_scene_to_file(ESCENA_MENU)


func _buscar_click() -> AudioStreamPlayer:
	var nodo := get_parent()
	while nodo != null:
		var encontrado := nodo.find_child("Click", true, false)
		if encontrado is AudioStreamPlayer:
			return encontrado
		nodo = nodo.get_parent()
	return null
