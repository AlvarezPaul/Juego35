extends CanvasLayer

@onready var fondo = $Color
@onready var animacion = $AnimacionFadeIn

func _enter_tree():
	$Color.visible = true
	$Color.color = Color.BLACK
	$Color.modulate = Color.WHITE
	$Color.mouse_filter = Control.MOUSE_FILTER_IGNORE
