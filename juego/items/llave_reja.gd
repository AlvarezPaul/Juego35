extends Area3D
## Objeto que está en el piso (Llave de la Reja) y se puede agarrar con la E.
## El RayCast3D del jugador llama a interact() y muestra el texto.

@export var nombre_item: String = "Llave Reja"
@export var icono: Texture2D
@export var escena_item: PackedScene
@export var texto_interaccion: String = "Agarrar llave de la reja (E)"


# Lo llama el RayCast del jugador cuando mirás la llave y presionás E.
func interact() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador != null:
		recoger(jugador)


func recoger(jugador) -> void:
	var inventario = jugador.inventario_ui
	if inventario == null:
		return

	# Si no se asignó la escena a mano, guardamos la escena del objeto
	# para que al tirarlo al suelo con la tecla de tirar se instancie correctamente.
	var raiz := get_parent()
	var escena := escena_item
	if escena == null and raiz != null and raiz.scene_file_path != "":
		escena = load(raiz.scene_file_path)

	var slot = inventario.agregar_item_y_devolver_slot(
		nombre_item,
		icono,
		escena
	)

	if slot == -1:
		print("Inventario lleno.")
		return

	# Equipar automáticamente el nuevo ítem
	jugador.slot_actual = slot + 1
	jugador._actualizar_item_en_mano(slot + 1)
	inventario.marcar_slot_equipado(slot + 1)

	# Borrar el objeto del suelo (nodo raíz completo si tiene padre)
	if raiz != null and raiz.scene_file_path != "":
		raiz.queue_free()
	else:
		queue_free()
