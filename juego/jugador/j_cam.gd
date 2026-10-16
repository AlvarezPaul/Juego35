extends Node3D
## Rotación de cámara en primera persona controlada con el mouse.
## El nodo padre (CharacterBody3D) rota en Y (izquierda/derecha) y este
## nodo rota en X (arriba/abajo), con el pitch limitado a +/-90°.

@export var sensibilidad: float = 0.2
@export var pitch_maximo_grados: float = 90.0

var _pitch_maximo_rad: float


func _ready() -> void:
	_pitch_maximo_rad = deg_to_rad(pitch_maximo_grados)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sensibilidad))
		rotate_x(deg_to_rad(-event.relative.y * sensibilidad))
		rotation.x = clamp(rotation.x, -_pitch_maximo_rad, _pitch_maximo_rad)
