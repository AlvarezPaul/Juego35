extends Control

@onready var aj: Control = $"."

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		$".".visible = false
func _on_cerrar_pressed() -> void:
	aj.visible=false

func _on_ocultar_pressed() -> void:
	$"../../../../ContadorFPS".visible = false

func _on_mostrar_pressed() -> void:
	$"../../../../ContadorFPS".visible = true

func _on_ocultar_2_pressed() -> void:
	Cronometro.mostrar = false

func _on_mostrar_2_pressed() -> void:
	Cronometro.mostrar = true
