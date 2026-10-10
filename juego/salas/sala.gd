extends Node3D

var partida_terminada = false

func _ready():
	$escuela/SALIDAFINAL.body_entered.connect(_on_salida_final_body_entered)

func _on_salida_final_body_entered(body):
	if body.name == "Jugador":
		$Jugador/Node2D/CanvasLayer/Control.partida_terminada = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$PantallaFinal.visible = true
		$ContadorFPS.visible = false
		$CanvasLayer.visible = false
		$Jugador/Inventario.visible = false
