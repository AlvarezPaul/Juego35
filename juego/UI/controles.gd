extends Control

@onready var contr: Control = $"."

func _on_cerrar_pressed() -> void:
	contr.visible = false
