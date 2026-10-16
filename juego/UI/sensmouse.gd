extends HSlider

@onready var label: Label = $"../Label"

func _ready() -> void:
	min_value = 0.0
	max_value = 10.0
	step = 0.1
	value = AjusteSensmouse.sensibilidad_mouse
	value_changed.connect(_cambiar_sensibilidad)
	_actualizar_etiqueta(value)

func _cambiar_sensibilidad(valor: float) -> void:
	AjusteSensmouse.sensibilidad_mouse = valor
	_actualizar_etiqueta(valor)

func _actualizar_etiqueta(valor: float) -> void:
	label.text = str(snappedf(valor, 0.1))
