extends Area3D
##esto es para los objetos recogibles

@export var nombre_item: String = "Objeto"
@export var icono: Texture2D

var _jugador_cerca := false


func _ready() -> void:
	body_entered.connect(_jugador_entro)
	body_exited.connect(_jugador_salio)


func _process(_delta: float) -> void:
	if _jugador_cerca and Input.is_action_just_pressed("recoger"):
		var inventario = get_tree().get_first_node_in_group("inventario")
		if inventario:
			inventario.agregar_item(nombre_item, icono)
			queue_free()


func _jugador_entro(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		_jugador_cerca = true


func _jugador_salio(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		_jugador_cerca = false
