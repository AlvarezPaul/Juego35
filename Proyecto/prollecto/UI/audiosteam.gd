extends AudioStreamPlayer

func _ready() -> void:
	# Evita que la música se pause si el juego entra en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Asegura que suene siempre
	if not playing:
		play()
