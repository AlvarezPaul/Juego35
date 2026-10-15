extends Node

# Declaro el label que se encarga de mostrar los mensajes.
var label: Label
var mensaje_ganzua = false

#Función para utilizar en todo el juego como una global.
func mensaje_mostrar(mensaje: String, segundos: float = 4.0):
	if label != null:
		label.mensaje(mensaje, segundos)

func reset_mensajes():
	mensaje_ganzua = false
