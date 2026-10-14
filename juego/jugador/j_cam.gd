extends Node3D
## Rotación de cámara en primera persona controlada con el mouse.

@export var pitch_maximo_grados: float = 90.0

var _pitch_maximo_rad: float


func _ready() -> void:
	_pitch_maximo_rad = deg_to_rad(pitch_maximo_grados)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensibilidad_actual: float = 0.02 + Sensmouseglobal.sensibilidad_mouse * 0.018
		get_parent().rotate_y(
			deg_to_rad(-event.relative.x * sensibilidad_actual)
		)

		rotation.x -= deg_to_rad(
			event.relative.y * sensibilidad_actual
		)

		rotation.x = clamp(
			rotation.x,
			-_pitch_maximo_rad,
			_pitch_maximo_rad
		)
