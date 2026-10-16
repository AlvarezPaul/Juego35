extends HSlider
## Control deslizante de volumen general del juego (bus "Master").
## Al arrastrarlo hasta el extremo izquierdo, silencia todo el audio.

@onready var _bus_master: int = AudioServer.get_bus_index("Master")


func _ready() -> void:
	min_value = -30.0
	max_value = 6.0
	step = 1.0

	# Ajusta la barra al volumen actual del bus al cargar la escena.
	value = AudioServer.get_bus_volume_db(_bus_master)

	value_changed.connect(_al_cambiar_volumen)


func _al_cambiar_volumen(nuevo_valor: float) -> void:
	if nuevo_valor <= min_value:
		# Silencia el juego por completo al llegar al fondo a la izquierda.
		AudioServer.set_bus_mute(_bus_master, true)
	else:
		AudioServer.set_bus_mute(_bus_master, false)
		AudioServer.set_bus_volume_db(_bus_master, nuevo_valor)
