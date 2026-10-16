extends Node2D

@onready var slots: Array = [
	$HBoxContainer/Panel,
	$HBoxContainer/Panel2,
	$HBoxContainer/Panel3,
	$HBoxContainer/Panel4,
]

var estilos: Array = []

const BORDE_ANCHO = 4
const BORDE_EXPANDIDO = 4
const COLOR_ACTIVO = Color(1, 0.85, 0, 1)
const COLOR_INACTIVO = Color(0, 0, 0, 0)
const MARGEN_NUMERO = 6

func _ready() -> void:
	add_to_group("inventario")
	$HBoxContainer.add_theme_constant_override("separation", BORDE_EXPANDIDO * 2 + 6)

	for i in slots.size():
		var panel = slots[i]

		var label = panel.get_node_or_null("LabelNumero")
		if label:
			label.text = str(i + 1)

		var estilo = StyleBoxFlat.new()
		estilo.bg_color = Color(0.15, 0.15, 0.15, 1)
		estilo.set_corner_radius_all(6)
		estilo.set_border_width_all(BORDE_ANCHO)
		estilo.border_color = COLOR_INACTIVO
		estilo.shadow_size = 6

		panel.add_theme_stylebox_override("panel", estilo)
		estilos.append(estilo)

	call_deferred("_ubicar_numeros")

func _ubicar_numeros() -> void:
	for panel in slots:
		var label = panel.get_node_or_null("LabelNumero")
		if label:
			label.position = Vector2(
				MARGEN_NUMERO,
				panel.size.y - label.size.y - MARGEN_NUMERO
			)

func agregar_item(nombre_item: String, icono: Texture2D) -> bool:
	for panel in slots:
		var texture_rect: TextureRect = panel.get_node("TextureRect")
		if texture_rect.texture == null:
			texture_rect.texture = icono
			texture_rect.get_node("Label").text = nombre_item
			return true
	return false

func marcar_slot_equipado(numero: int) -> void:
	for i in estilos.size():
		var estilo = estilos[i]
		var activo = (i == numero - 1)

		estilo.border_color = COLOR_ACTIVO if activo else COLOR_INACTIVO
		estilo.shadow_color = Color(1, 0.85, 0, 0.6 if activo else 0)
		estilo.set_expand_margin_all(BORDE_EXPANDIDO if activo else 0)
