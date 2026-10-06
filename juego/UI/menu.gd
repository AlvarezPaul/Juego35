extends Control
## Controla el menú principal: navegación a la sala de juego, a los
## créditos, y salir de la aplicación.

const ESCENA_JUGAR := "res://UI/pantalla_de_carga.tscn"
const ESCENA_CREDITOS := "res://UI/ClickCreditos.tscn"
const ESCENA_AJUSTES := "res://UI/ajustes.tscn"
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_CREDITOS)

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_JUGAR)

func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_ajustes_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_AJUSTES)
