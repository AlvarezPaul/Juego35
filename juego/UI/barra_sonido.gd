extends HSlider
## Control deslizante de volumen general del juego (bus "Master").

@onready var _bus_master: int = AudioServer.get_bus_index("Master")
@onready var _etiqueta: Label =  $"../ValorVolumen"
func _ready() -> void:
	min_value = -30.0
	max_value = 6.0
	step = 1.0

	# Ajusta la barra al volumen actual.
	value = AudioServer.get_bus_volume_db(_bus_master)

	value_changed.connect(_al_cambiar_volumen)
	_actualizar_etiqueta(value)


func _al_cambiar_volumen(nuevo_valor: float) -> void:
	if nuevo_valor <= min_value:
		# Silencia el juego al llegar al extremo izquierdo.
		AudioServer.set_bus_mute(_bus_master, true)
	else:
		AudioServer.set_bus_mute(_bus_master, false)
		AudioServer.set_bus_volume_db(_bus_master, nuevo_valor)

	_actualizar_etiqueta(nuevo_valor)


func _actualizar_etiqueta(valor_db: float) -> void:
	var porcentaje: int = roundi(
		inverse_lerp(min_value, max_value, valor_db) * 100.0
	)
	_etiqueta.text = str(porcentaje) + "%"
