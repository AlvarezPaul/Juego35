extends Node3D

var partida_terminada = false
@onready var label: Label = $MensajesAlJugador/Label

func _ready():
	$escuela/SALIDAFINAL.body_entered.connect(_on_salida_final_body_entered)
	$AnimacionFadeIn/AnimacionFadeIn.play("fade_in")
	Mensajetexto.label = label
	Mensajetexto.mensaje_mostrar("Te quedaste atrapado en el baño, debes buscar algo para salir de aquí.", 7.0)

func _on_salida_final_body_entered(body):
	if body.name == "Jugador":
		$Jugador/Node2D/CanvasLayer/Control.partida_terminada = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$PantallaFinal.visible = true
		$ContadorFPS.visible = false
		$CanvasLayer.visible = false
		$Jugador/Inventario.visible = false
