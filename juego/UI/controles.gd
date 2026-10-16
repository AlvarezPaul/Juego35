extends Control

@onready var contr: Control = $"."

func _on_cerrar_pressed() -> void:
	contr.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		contr.visible = false
