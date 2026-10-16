extends Label

func _ready() -> void:
	add_to_group("cronometro_label")
	add_theme_font_size_override("font_size", 48)
	add_theme_constant_override("outline_size", 8)
	add_theme_color_override("font_outline_color", Color.BLACK)
	Cronometro.iniciar()
	visible = Cronometro.mostrar
	text = Cronometro.formato()

func _process(delta: float) -> void:
	if Cronometro.corriendo:
		Cronometro.sumar(delta)
		visible = Cronometro.mostrar
		text = Cronometro.formato()

# Se llama al terminar el juego: muestra el tiempo final aunque el check esté apagado
func terminar_juego() -> void:
	Cronometro.detener()
	visible = true
	text = "Tiempo: " + Cronometro.formato()
