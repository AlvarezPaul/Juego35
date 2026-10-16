extends HBoxContainer

func _ready() -> void:
	$Ocultar.pressed.connect(func(): Cronometro.mostrar = false)
	$Mostrar.pressed.connect(func(): Cronometro.mostrar = true)
