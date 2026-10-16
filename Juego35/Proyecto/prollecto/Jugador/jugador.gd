extends CharacterBody3D
## Controla el movimiento del jugador en primera persona:
## caminar, correr, saltar, stamina, sonido de pasos,
## linterna y head bob.

@export var velocidad_correr: float = 10.0
@export var velocidad: float = 6.0
@export var fuerza_salto: float = 4.5
@export var intensidad_bob: float = 0.05
@export var velocidad_bob: float = 9.0

@export var stamina_maxima: float = 100.0
@export var consumo_stamina: float = 25.0
@export var regen_stamina: float = 15.0
@export var retraso_regen: float = 1.0

# Intensidad de la luz de la linterna
@export var intensidad_linterna: float = 1.0

@export var icono_linterna: Texture2D

@onready var pasos: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var camara: Camera3D = $Cabeza/Camera3D
@onready var luz_linterna: SpotLight3D = $Cabeza/Camera3D/SpotLight3D
@onready var modelo_linterna: Node3D = $Cabeza/Camera3D/linterna

var _posicion_camara_inicial: Vector3
var _tiempo_bob: float = 0.0

var stamina: float = stamina_maxima
var _tiempo_desde_ultimo_uso: float = 0.0

var slot_actual: int = 0
var inventario_ui: Node = null

signal stamina_cambiada(actual: float, maxima: float)


func _ready() -> void:
	_posicion_camara_inicial = camara.position

	# Configurar intensidad de la linterna
	luz_linterna.light_energy = intensidad_linterna

	# Empieza sin nada equipado.
	modelo_linterna.visible = false
	luz_linterna.visible = false

	call_deferred("_agregar_item_inicial")


func _agregar_item_inicial() -> void:
	inventario_ui = get_tree().get_first_node_in_group("inventario")


func _process(_delta: float) -> void:
	# La luz solo funciona si la linterna está equipada.
	if Input.is_action_just_pressed("flashlight") and slot_actual == 1:
		luz_linterna.visible = not luz_linterna.visible


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_alternar_slot(1)

			KEY_2:
				_alternar_slot(2)

			KEY_3:
				_alternar_slot(3)

			KEY_4:
				_alternar_slot(4)


func _alternar_slot(numero: int) -> void:
	if slot_actual == numero:
		# Si ya tenía ese slot, lo guarda.
		slot_actual = 0
		_actualizar_item_en_mano(0)
	else:
		# Cambia al nuevo slot.
		slot_actual = numero
		_actualizar_item_en_mano(numero)

	if inventario_ui:
		inventario_ui.marcar_slot_equipado(slot_actual)


func _actualizar_item_en_mano(numero: int) -> void:
	# Solo el slot 1 tiene la linterna.
	modelo_linterna.visible = (numero == 1)

	# Si no está equipada, apaga la luz.
	if numero != 1:
		luz_linterna.visible = false


func _physics_process(delta: float) -> void:
	_aplicar_gravedad(delta)
	_procesar_salto()

	var movimiento = _procesar_movimiento(delta)

	move_and_slide()

	var corriendo := _esta_corriendo()

	_actualizar_sonido_pasos(movimiento, corriendo)
	_actualizar_head_bob(movimiento, delta, corriendo)


func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _procesar_salto() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = fuerza_salto


func _procesar_movimiento(delta: float) -> Vector3:
	var input_dir := Input.get_vector(
		"left",
		"right",
		"forward",
		"backward"
	)

	var direccion := (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	# Solo intenta correr si:
	# - está apretando correr
	# - se está moviendo
	# - está en el piso
	var quiere_correr := (
		Input.is_action_pressed("correr")
		and direccion != Vector3.ZERO
		and is_on_floor()
	)

	# Puede correr únicamente si tiene stamina.
	var puede_correr := (
		quiere_correr
		and stamina > 0.0
	)

	var vel_actual: float

	if puede_correr:
		vel_actual = velocidad_correr
	else:
		vel_actual = velocidad

	_actualizar_stamina(puede_correr, delta)

	if direccion != Vector3.ZERO:
		velocity.x = direccion.x * vel_actual
		velocity.z = direccion.z * vel_actual
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			vel_actual
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			vel_actual
		)

	return direccion


func _esta_corriendo() -> bool:
	if not is_on_floor():
		return false

	if stamina <= 0.0:
		return false

	if not Input.is_action_pressed("correr"):
		return false

	if velocity.length() < velocidad_correr - 0.5:
		return false

	return true


func _actualizar_stamina(corriendo: bool, delta: float) -> void:
	if corriendo:
		# Solo gasta stamina mientras realmente corre.
		stamina -= consumo_stamina * delta

		if stamina < 0.0:
			stamina = 0.0

		_tiempo_desde_ultimo_uso = 0.0

	else:
		# Caminando o quieto NO gasta stamina.
		_tiempo_desde_ultimo_uso += delta

		if _tiempo_desde_ultimo_uso >= retraso_regen:
			stamina += regen_stamina * delta

			if stamina > stamina_maxima:
				stamina = stamina_maxima

	stamina_cambiada.emit(stamina, stamina_maxima)


func _actualizar_sonido_pasos(
	direccion: Vector3,
	corriendo: bool
) -> void:

	var caminando := (
		direccion != Vector3.ZERO
		and is_on_floor()
	)

	# Los pasos suenan un poco más rápidos al correr.
	if corriendo:
		pasos.pitch_scale = 1.3
	else:
		pasos.pitch_scale = 1.0

	if caminando and not pasos.playing:
		pasos.play()

	elif not caminando and pasos.playing:
		pasos.stop()


func _actualizar_head_bob(
	direccion: Vector3,
	delta: float,
	corriendo: bool
) -> void:

	if direccion != Vector3.ZERO and is_on_floor():

		var factor_bob := 1.5 if corriendo else 1.0

		_tiempo_bob += (
			delta
			* velocidad_bob
			* factor_bob
		)

		camara.position.y = (
			_posicion_camara_inicial.y
			+ sin(_tiempo_bob)
			* intensidad_bob
			* factor_bob
		)

	else:

		camara.position.y = lerp(
			camara.position.y,
			_posicion_camara_inicial.y,
			delta * 5.0
		)
