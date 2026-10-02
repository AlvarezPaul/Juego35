
extends StaticBody3D

var abierto = false
var interactuable = true

@export var animation_player: AnimationPlayer
@export var texto_abrir: String = "Abrir con la E"
@export var texto_cerrar: String = "Cerrar con la E"
@export var texto_bloqueada: String = "Necesitas tener la llave en la mano"

@export var requiere_llave: bool = true
@export var nombre_llave: String = "Llave"

var texto_interaccion: String = ""


func _ready() -> void:
	actualizar_texto()


# Comprueba si la llave está actualmente equipada/en la mano
func jugador_tiene_llave_en_mano() -> bool:
	var jugador = get_tree().get_first_node_in_group("jugador")

	if jugador == null:
		return false

	# slot_actual usa 1, 2, 3, 4...
	var numero_slot = jugador.slot_actual

	if numero_slot < 1:
		return false

	var inventario = jugador.inventario_ui

	if inventario == null:
		return false

	var item = inventario.obtener_item(numero_slot)

	if item == null:
		return false

	if item["nombre"] == nombre_llave:
		return true

	return false


func actualizar_texto() -> void:
	if not abierto and requiere_llave and not jugador_tiene_llave_en_mano():
		texto_interaccion = texto_bloqueada
	elif abierto:
		texto_interaccion = texto_cerrar
	else:
		texto_interaccion = texto_abrir


func interact():
	if not interactuable:
		return

	# Para abrir, la llave tiene que estar en la mano
	if not abierto and requiere_llave and not jugador_tiene_llave_en_mano():
		print("Necesitas tener la llave en la mano.")
		actualizar_texto()
		return

	interactuable = false
	texto_interaccion = ""

	abierto = !abierto

	if abierto:
		animation_player.play("abrir")
	else:
		animation_player.play("cerrar")

	await get_tree().create_timer(1.0, false).timeout

	interactuable = true
	actualizar_texto()
