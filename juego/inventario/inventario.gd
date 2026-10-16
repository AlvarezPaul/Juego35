extends Node2D

@onready var slots: Array = [
	$Control/HBoxContainer/Panel,
	$Control/HBoxContainer/Panel2,
	$Control/HBoxContainer/Panel3,
	$Control/HBoxContainer/Panel4,
]

var estilos: Array = []

# Guarda qué objeto hay realmente en cada slot.
# Cada posición puede ser:
# null = vacío
# Dictionary = objeto guardado
var items: Array = [null, null, null, null]

const BORDE_ANCHO = 4
const BORDE_EXPANDIDO = 4
const COLOR_ACTIVO = Color(1, 0.85, 0, 1)
const COLOR_INACTIVO = Color(0, 0, 0, 0)
const MARGEN_NUMERO = 6


func _ready() -> void:
	add_to_group("inventario")

	$Control/HBoxContainer.add_theme_constant_override(
		"separation",
		BORDE_EXPANDIDO * 2 + 6
	)

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

		# Arrancan vacíos: sacamos cualquier ícono que venga puesto desde la escena.
		var texture_rect = panel.get_node_or_null("TextureRect")
		if texture_rect:
			texture_rect.texture = null
			var label_item = texture_rect.get_node_or_null("Label")
			if label_item:
				label_item.text = ""

	call_deferred("_ubicar_numeros")


func _ubicar_numeros() -> void:
	for panel in slots:
		var label = panel.get_node_or_null("LabelNumero")

		if label:
			label.position = Vector2(
				MARGEN_NUMERO,
				panel.size.y - label.size.y - MARGEN_NUMERO
			)

func agregar_item(
	nombre_item: String,
	icono: Texture2D,
	escena_item: PackedScene = null
) -> bool:

	var slot = agregar_item_y_devolver_slot(
		nombre_item,
		icono,
		escena_item
	)

	return slot != -1


func agregar_item_y_devolver_slot(
	nombre_item: String,
	icono: Texture2D,
	escena_item: PackedScene = null
) -> int:

	for i in slots.size():

		if items[i] == null:

			# Guardamos la información real del objeto.
			items[i] = {
				"nombre": nombre_item,
				"icono": icono,
				"escena": escena_item
			}

			# Actualizamos la interfaz.
			var texture_rect: TextureRect = slots[i].get_node("TextureRect")

			texture_rect.texture = icono
			# No mostramos el nombre en el slot, solo el ícono.
			texture_rect.get_node("Label").text = ""

			return i

	return -1

func obtener_item(numero_slot: int):
	if numero_slot < 1 or numero_slot > items.size():
		return null

	return items[numero_slot - 1]

func quitar_item(numero_slot: int):
	if numero_slot < 1 or numero_slot > items.size():
		return null

	var indice := numero_slot - 1
	var item = items[indice]

	if item == null:
		return null

	items[indice] = null

	# Limpiamos la interfaz.
	var texture_rect: TextureRect = slots[indice].get_node("TextureRect")

	texture_rect.texture = null
	texture_rect.get_node("Label").text = ""

	return item

func marcar_slot_equipado(numero: int) -> void:

	for i in estilos.size():

		var estilo = estilos[i]
		var activo = (i == numero - 1)

		estilo.border_color = (
			COLOR_ACTIVO
			if activo
			else COLOR_INACTIVO
		)

		estilo.shadow_color = Color(
			1,
			0.85,
			0,
			0.6 if activo else 0.0
		)

		estilo.set_expand_margin_all(
			BORDE_EXPANDIDO if activo else 0
		)
