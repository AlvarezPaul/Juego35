extends Area3D
## Objeto que está en el piso y se puede agarrar mirándolo y apretando E.
## El RayCast3D del jugador llama a interact() y muestra el mensaje.

@export var nombre_item: String = "Llave Salida" # Cambiar a "Linterna" según corresponda
@export var icono: Texture2D	
@export var escena_item: PackedScene
@export var texto_interaccion: String = "Agarrar la Llave de la Salida (E)"


# Lo llama el RayCast del jugador cuando mirás el objeto y apretás E.
func interact() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")

	if jugador != null:
		recoger(jugador)


func recoger(jugador) -> void:
	# Verificamos si el jugador tiene referencia al inventario
	if not "inventario_ui" in jugador or jugador.inventario_ui == null:
		print("Error: El jugador no tiene asignado 'inventario_ui'.")
		return

	var inventario = jugador.inventario_ui

	# Si no se asignó la escena a mano, intentamos usar la del nodo raíz
	var raiz := get_parent()
	var escena := escena_item

	if escena == null and raiz != null and raiz.has_method("get_scene_file_path") and raiz.scene_file_path != "":
		escena = load(raiz.scene_file_path)

	var slot = inventario.agregar_item_y_devolver_slot(
		nombre_item,
		icono,
		escena
	)

	if slot == -1:
		print("Inventario lleno.")
		return

	# Equiparlo automáticamente (asegurándonos de que los métodos existan en el jugador)
	var slot_a_usar = slot + 1
	if jugador.has_method("_actualizar_item_en_mano"):
		jugador.slot_actual = slot_a_usar
		jugador._actualizar_item_en_mano(slot_a_usar)
	
	if inventario.has_method("marcar_slot_equipado"):
		inventario.marcar_slot_equipado(slot_a_usar)

	# CORRECCIÓN DE BORRADO: 
	# Nos aseguramos de borrar el nodo contenedor (raíz) o este nodo de forma segura.
	if raiz != null and raiz != get_tree().current_scene:
		raiz.queue_free()
	else:
		queue_free()
