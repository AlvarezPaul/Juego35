extends StaticBody3D
## Reja que solo se abre con la "Llave Reja" en la mano.
## Se usa en puerta/reja.tscn (la reja que está debajo de la rampa).

var abierto := false
var interactuable := true

@export var animation_player: AnimationPlayer
@export var texto_abrir: String = "Abrir con la E"
@export var texto_cerrar: String = "Cerrar con la E"
@export var texto_bloqueada: String = "Necesitas la llave de la regencia en la mano"

## Nombre del item del inventario que abre esta reja
## (tiene que coincidir con nombre_item de items/llave_reja.tscn).
@export var nombre_llave: String = "Llave Regencia"

# El RayCast del jugador lee esta variable para mostrar el mensaje.
var texto_interaccion: String = ""


func _ready() -> void:
	actualizar_texto()


func _process(_delta: float) -> void:
	# Mientras la reja está cerrada, el mensaje cambia según lo que tengas en la mano.
	if interactuable and not abierto:
		actualizar_texto()


func jugador_tiene_llave_en_mano() -> bool:
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null or jugador.inventario_ui == null:
		return false

	# slot_actual usa 1, 2, 3, 4... (0 = mano vacía)
	if jugador.slot_actual < 1:
		return false

	var item = jugador.inventario_ui.obtener_item(jugador.slot_actual)
	return item != null and item["nombre"] == nombre_llave


func actualizar_texto() -> void:
	if abierto:
		texto_interaccion = texto_cerrar
	elif jugador_tiene_llave_en_mano():
		texto_interaccion = texto_abrir
	else:
		texto_interaccion = texto_bloqueada


# Si no se asignó el AnimationPlayer en el editor, lo busca en la escena de la puerta.
func _asegurar_animation_player() -> void:
	if animation_player == null:
		var raiz := owner if owner != null else get_parent().get_parent()
		if raiz != null:
			animation_player = raiz.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if animation_player == null:
		push_error("Puerta sin AnimationPlayer: " + str(get_path()))


func interact() -> void:
	_asegurar_animation_player()
	if animation_player == null:
		return
	if not interactuable:
		return

	# Para abrir, la llave de la reja tiene que estar en la mano.
	if not abierto and not jugador_tiene_llave_en_mano():
		return

	interactuable = false
	texto_interaccion = ""

	abierto = not abierto
	animation_player.play("abrir" if abierto else "cerrar")

	await get_tree().create_timer(1.0, false).timeout

	interactuable = true
	actualizar_texto()
