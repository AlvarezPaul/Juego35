extends Node3D

var partida_terminada := false
@onready var label: Label = $MensajesAlJugador/Label

func _ready() -> void:
	# Busca la zona de salida sin depender de que esté directamente dentro de escuela.
	var escuela: Node = get_node_or_null("escuela")
	var salida_encontrada: Node = null

	if escuela != null:
		salida_encontrada = escuela.find_child("SALIDAFINAL", true, false)

	if salida_encontrada == null:
		push_error("No se encontró el nodo SALIDAFINAL dentro de escuela. Revisá el nombre en el árbol de nodos.")
	elif salida_encontrada is Area3D:
		var salida_final: Area3D = salida_encontrada as Area3D
		if not salida_final.body_entered.is_connected(_on_salida_final_body_entered):
			salida_final.body_entered.connect(_on_salida_final_body_entered)
	else:
		push_error("El nodo SALIDAFINAL existe, pero no es un Area3D.")

	$AnimacionFadeIn/AnimacionFadeIn.play("fade_in")
	Mensajetexto.label = label
	Mensajetexto.mensaje_mostrar("Te quedaste atrapado en el baño, debes buscar algo para salir de aquí.", 7.0)

func _on_salida_final_body_entered(body: Node3D) -> void:
	if body.name != "Jugador" or partida_terminada:
		return

	partida_terminada = true
	Cronometro.detener()
	$PantallaFinal/TiempoValor.text = Cronometro.formato()
	$Jugador/Node2D/CanvasLayer/Control.partida_terminada = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$PantallaFinal.visible = true
	$ContadorFPS.visible = false
	$CanvasLayer.visible = false
	$Jugador/Inventario.visible = false
	get_tree().paused = true
