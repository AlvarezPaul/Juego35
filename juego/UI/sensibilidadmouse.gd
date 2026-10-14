extends HSlider

@onready var slider: HSlider = $"."
@onready var texto: Label = $"../ValorSensMouse"

func _ready() -> void:
	slider.min_value = 0.0
	slider.max_value = 10.0
	slider.step = 0.1

	slider.value = Sensmouseglobal.sensibilidad_mouse
	slider.value_changed.connect(_cambiar_sensibilidad)
	slider.value_changed.connect(_actualizar_valor)
	_actualizar_valor(slider.value)


func _cambiar_sensibilidad(valor: float) -> void:
	Sensmouseglobal.sensibilidad_mouse = valor

func _actualizar_valor(valor: float) -> void:
	texto.text = str(snappedf(valor, 0.1))
