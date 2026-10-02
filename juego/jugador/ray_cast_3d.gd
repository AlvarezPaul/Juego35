extends RayCast3D

var _label: Label


func _ready() -> void:
	# Para poder mirar objetos que son Area3D (como la linterna del piso).
	collide_with_areas = true

	# El rayo sale exactamente desde la cámara, así apunta a donde está el puntito.
	position = Vector3.ZERO

	# Que el rayo ignore el cuerpo del jugador.
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador is CollisionObject3D:
		add_exception(jugador)

	_crear_mensaje()


func _crear_mensaje() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)

	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Lo bajamos un poco del centro de la pantalla.
	_label.offset_top = 100
	_label.offset_bottom = 100
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 3)
	_label.visible = false
	capa.add_child(_label)


func _process(_delta: float) -> void:
	# Actualiza el rayo en este mismo frame para que responda al instante.
	force_raycast_update()

	var objetivo = _buscar_interactuable()

	if objetivo == null:
		_label.visible = false
		return

	# Mensaje solo si el objeto define "texto_interaccion".
	var texto = objetivo.get("texto_interaccion")
	if texto != null and texto != "":
		_label.text = texto
		_label.visible = true
	else:
		_label.visible = false

	if Input.is_action_just_pressed("interaccion"):
		_label.visible = false
		objetivo.interact()


func _buscar_interactuable():
	if not is_colliding():
		return null

	# obtiene la informacion del objeto que esta colisionando el raycast
	var obj = get_collider()

	# si el objeto golpeado no tiene interact(), busca en sus padres
	# (por ejemplo, la puerta tiene varios StaticBody3D hijos para el marco
	# que no tienen el script, pero su padre "modelo" si lo tiene)
	while obj != null and is_instance_valid(obj) and not obj.has_method("interact"):
		obj = obj.get_parent()

	if obj == null or not is_instance_valid(obj):
		return null

	return obj
