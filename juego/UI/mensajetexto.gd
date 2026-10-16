extends Node

# Label que se encarga de mostrar los mensajes (lo asigna la sala al cargarse).
var label: Label
var mensaje_ganzua := false

# Función para utilizar en todo el juego como una global.
func mensaje_mostrar(texto: String, segundos: float = 4.0) -> void:
	# is_instance_valid: el label se libera al salir de la sala.
	if is_instance_valid(label):
		label.mensaje(texto, segundos)

func reset_mensajes() -> void:
	mensaje_ganzua = false
