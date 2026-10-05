extends StaticBody3D

var abierto = false
var interactuable = true

@export var animation_player: AnimationPlayer
@export var texto_abrir: String = "Abrir con la E"
@export var texto_cerrar: String = "Cerrar con la E"
@export var texto_bloqueada: String = "Necesitas algo para abrirla"

@export var requiere_llave: bool = true
@export var nombre_llave: String = "Ganzua"

# Si está activado, el ítem se gasta al abrir la puerta por primera vez
# y la puerta queda desbloqueada para siempre.
@export var consumir_item: bool = false

# El RayCast del jugador lee esta variable para mostrar el mensaje.
# Se calcula cada vez que la mirás, así siempre está actualizada.
var texto_interaccion: String:
	get:
		return _calcular_texto()


func _calcular_texto() -> String:
	if not interactuable:
		return ""
	if abierto:
		return texto_cerrar
	if requiere_llave and not jugador_tiene_llave_en_mano():
		return texto_bloqueada
	return texto_abrir


# Comprueba si el ítem requerido está actualmente en la mano
func jugador_tiene_llave_en_mano() -> bool:
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return false

	var numero_slot = jugador.slot_actual
	if numero_slot < 1:
		return false

	var inventario = jugador.inventario_ui
	if inventario == null:
		return false

	var item = inventario.obtener_item(numero_slot)
	if item == null:
		return false

	return item["nombre"] == nombre_llave


func _consumir_item_en_mano() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return

	var inventario = jugador.inventario_ui
	if inventario == null:
		return

	inventario.quitar_item(jugador.slot_actual)
	jugador.slot_actual = 0
	jugador._actualizar_item_en_mano(0)
	inventario.marcar_slot_equipado(0)


func interact():
	if not interactuable:
		return

	# Para abrir, el ítem tiene que estar en la mano
	if not abierto and requiere_llave and not jugador_tiene_llave_en_mano():
		return

	interactuable = false

	var abre_con_item := (not abierto) and requiere_llave

	abierto = !abierto

	if abierto:
		animation_player.play("abrir")
	else:
		animation_player.play("cerrar")

	# Se gasta el ítem y la puerta queda destrabada.
	if abre_con_item and consumir_item:
		_consumir_item_en_mano()
		requiere_llave = false

	await get_tree().create_timer(1.0, false).timeout
	interactuable = true
