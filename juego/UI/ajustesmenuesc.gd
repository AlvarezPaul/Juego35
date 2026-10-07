extends Control

@onready var aj: Control = $"."

func _on_cerrar_pressed() -> void:
	aj.visible=false
