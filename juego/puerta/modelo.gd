extends StaticBody3D

var abierto = false
# para no poder interactuar con la puerta mientras esta en una animacion
var interactuable = true
@export var animation_player: AnimationPlayer
@export var texto_abrir: String = "Abrir con la E"
@export var texto_cerrar: String = "Cerrar con la E"

# El RayCast del jugador lee esta variable para mostrar el mensaje.
# Si está vacía, el mensaje se oculta.
var texto_interaccion: String = ""


func _ready() -> void:
	texto_interaccion = texto_abrir


func interact():
	if interactuable == false:
		return
	interactuable = false
	texto_interaccion = ""  # oculta el mensaje durante la animación

	abierto = !abierto
	if abierto:
		animation_player.play("abrir")
	else:
		animation_player.play("cerrar")

	await get_tree().create_timer(1.0, false).timeout

	interactuable = true
	texto_interaccion = texto_cerrar if abierto else texto_abrir
