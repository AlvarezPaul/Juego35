extends StaticBody3D

var abierto = false
#para no poder interactuar con la puerta mienstras esta en una animacion
var interactuable = true
@export var animation_player: AnimationPlayer

func interact():
	if interactuable == true:
		interactuable = false
		abierto = !abierto
		if abierto == false:
			animation_player.play("cerrar")
		if abierto == true:
			animation_player.play("abrir")
		await get_tree().create_timer(1.0, false).timeout
		interactuable = true
