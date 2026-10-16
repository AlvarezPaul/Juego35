extends Area3D
## Objeto que está en el piso y se puede agarrar mirándolo y apretando E.
## El RayCast3D del jugador (ray_cast_3d.gd) llama a interact() y muestra
## el mensaje de "texto_interaccion" mientras lo mirás.

@export var nombre_item: String = "Linterna"
@export var icono: Texture2D
@export var escena_item: PackedScene
@export var texto_interaccion: String = "Agarrar con la E"


# Lo llama el RayCast del jugador cuando mirás el objeto y apretás E.
func interact() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")

	if jugador != null:
		recoger(jugador)


func recoger(jugador) -> void:

	var inventario = jugador.inventario_ui

	if inventario == null:
		return

	# Si no se asignó la escena a mano, usamos la escena a la que
	# pertenece este objeto. Así, al tirarlo, se vuelve a crear igual.
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

	# Equiparlo automáticamente.
	jugador.slot_actual = slot + 1
	jugador._actualizar_item_en_mano(slot + 1)
	inventario.marcar_slot_equipado(slot + 1)

	# Borramos el objeto entero (el nodo raíz), no solo el Area3D.
	if raiz != null and raiz.scene_file_path != "":
		raiz.queue_free()
	else:
		queue_free()
