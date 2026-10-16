extends CanvasLayer

@onready var jugador: CharacterBody3D = get_tree().get_first_node_in_group("jugador")
@onready var barra_stamina: ProgressBar = $BarraStamina


func _ready() -> void:
	barra_stamina.show_percentage = false
	jugador.stamina_cambiada.connect(_on_stamina_cambiada)
	barra_stamina.max_value = jugador.stamina_maxima
	barra_stamina.value = jugador.stamina


func _on_stamina_cambiada(actual: float, maxima: float) -> void:
	barra_stamina.max_value = maxima
	barra_stamina.value = actual
