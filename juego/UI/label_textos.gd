extends Label

var tiempo: float = 0.0

func _ready() -> void:
	hide()

func mensaje (mensaje: String, segundos: float):
	text = mensaje
	tiempo = segundos
	show()

func _process(delta: float) -> void:
	if visible:
		tiempo -= delta
		if tiempo <= 0:
			hide()
