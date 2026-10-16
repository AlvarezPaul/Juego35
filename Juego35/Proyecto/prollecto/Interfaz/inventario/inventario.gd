extends Node2D

@onready var slots: Array = [
	$HBoxContainer/Panel,
	$HBoxContainer/Panel2,
	$HBoxContainer/Panel3,
	$HBoxContainer/Panel4,
]

var estilos: Array = []   # NUEVO: un StyleBoxFlat propio por panel

func _ready() -> void:
	add_to_group("inventario")
	_numerar_slots()
	_preparar_estilos()   # NUEVO

func _preparar_estilos() -> void:   # NUEVO
	for panel in slots:
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.15, 0.15, 0.15, 1)   # gris oscuro, tu color normal
		estilo.corner_radius_top_left = 6
		estilo.corner_radius_top_right = 6
		estilo.corner_radius_bottom_left = 6
		estilo.corner_radius_bottom_right = 6
		panel.add_theme_stylebox_override("panel", estilo)
		estilos.append(estilo)

func _numerar_slots() -> void:
	for i in slots.size():
		var label_numero: Label = slots[i].get_node_or_null("LabelNumero")
		if label_numero:
			label_numero.text = str(i + 1)

func agregar_item(nombre_item: String, icono: Texture2D) -> bool:
	for panel in slots:
		var texture_rect: TextureRect = panel.get_node("TextureRect")
		if texture_rect.texture == null:
			texture_rect.texture = icono
			texture_rect.get_node("Label").text = nombre_item
			return true
	return false
func marcar_slot_equipado(numero: int) -> void:
	print("Marcando slot: ", numero, " estilos.size(): ", estilos.size())   # DEBUG
	for i in slots.size():
		if i == numero - 1:
			estilos[i].bg_color = Color(1, 0.85, 0, 1)
		else:
			estilos[i].bg_color = Color(0.15, 0.15, 0.15, 1)
