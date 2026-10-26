extends CanvasLayer

@onready var name_input: LineEdit = $Username
@onready var boton_guardar: Button = $BotonGuardar
@onready var http_request: HTTPRequest = get_node_or_null("../HTTPRequest")

const URL_PHP := "https://TU-DIRECCION.ngrok-free.app/juego35/guardar_puntaje.php"

# Si no hay servidor (XAMPP apagado, sin internet, etc.) el puntaje NO se pierde:
# se guarda en la PC y se manda a la base de datos solo cuando el servidor responda.
# Estos archivos quedan en la carpeta de datos del juego (user://).
const ARCHIVO_PENDIENTES := "user://puntajes_pendientes.json"  # cola para mandar a la base
const ARCHIVO_CSV := "user://puntajes_locales.csv"             # copia legible (Excel)
const TIMEOUT_SEG := 5.0

var _ultimo_envio: Dictionary = {}
var _sincronizando := false


func _ready() -> void:
	if http_request == null:
		push_error("No se encontró el nodo HTTPRequest en la escena sala.")
		return

	# La pantalla final y la petición deben funcionar aunque el árbol esté pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	http_request.process_mode = Node.PROCESS_MODE_ALWAYS
	http_request.timeout = TIMEOUT_SEG
	name_input.max_length = 50

	if not boton_guardar.pressed.is_connected(_on_boton_guardar_pressed):
		boton_guardar.pressed.connect(_on_boton_guardar_pressed)
	if not http_request.request_completed.is_connected(_on_http_request_completed):
		http_request.request_completed.connect(_on_http_request_completed)

	# Si quedaron puntajes sin mandar de otras partidas, los intentamos mandar ahora.
	call_deferred("_sincronizar_pendientes")


func _on_boton_guardar_pressed() -> void:
	Autoloadsonido.play_click()
	var nombre_jugador := name_input.text.strip_edges()

	if nombre_jugador.is_empty():
		print("Ingresá un nombre antes de guardar el puntaje.")
		return

	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		print("Ya hay una petición de guardado en curso.")
		return

	boton_guardar.disabled = true
	boton_guardar.text = "Guardando..."

	_ultimo_envio = {
		"nombre": nombre_jugador,
		"tiempo": Cronometro.tiempo,
		"fecha": Time.get_datetime_string_from_system(false, true)
	}
	_enviar_puntaje(_ultimo_envio)


func _enviar_puntaje(datos: Dictionary) -> void:
	var headers := PackedStringArray(["Content-Type: application/json", "ngrok-skip-browser-warning: true"])
	var error := http_request.request(
		URL_PHP,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(datos)
	)

	if error != OK:
		print("No se pudo iniciar la petición HTTP. Código: ", error)
		_guardar_sin_conexion(datos)


func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var respuesta := body.get_string_from_utf8()
	print("Respuesta del servidor (HTTP ", response_code, "): ", respuesta)

	# Servidor apagado / sin conexión / MySQL caído (error 5xx): lo guardamos en la PC.
	if result != HTTPRequest.RESULT_SUCCESS or response_code >= 500:
		print("No se pudo guardar en el servidor (¿XAMPP apagado?). Se guarda en esta PC.")
		_guardar_sin_conexion(_ultimo_envio)
		return

	if response_code != 200:
		print("El servidor devolvió el código HTTP ", response_code)
		_restaurar_boton()
		return

	var json = JSON.parse_string(respuesta)
	if not json is Dictionary:
		print("La respuesta PHP no es un JSON válido.")
		_guardar_sin_conexion(_ultimo_envio)
		return

	if json.get("status", "") == "success":
		boton_guardar.disabled = true
		boton_guardar.text = "Puntaje guardado"
		print("¡Puntaje guardado correctamente!")
		# Ya que hay servidor, aprovechamos para mandar los que habían quedado pendientes.
		call_deferred("_sincronizar_pendientes")
	else:
		print("Error al guardar: ", json.get("message", "Error desconocido"))
		_restaurar_boton()


func _restaurar_boton() -> void:
	boton_guardar.disabled = false
	boton_guardar.text = "Guardar puntaje"


# ---------------------------------------------------------------------------
# Guardado local (cuando no hay servidor)
# ---------------------------------------------------------------------------

func _guardar_sin_conexion(datos: Dictionary) -> void:
	var pendientes := _leer_pendientes()
	pendientes.append(datos)
	_escribir_pendientes(pendientes)
	_agregar_al_csv(datos)

	# Queda deshabilitado para no guardar el mismo puntaje dos veces.
	boton_guardar.disabled = true
	boton_guardar.text = "Guardado en la PC"
	print("Puntaje guardado localmente en: ", ProjectSettings.globalize_path(ARCHIVO_PENDIENTES))


func _leer_pendientes() -> Array:
	if not FileAccess.file_exists(ARCHIVO_PENDIENTES):
		return []
	var archivo := FileAccess.open(ARCHIVO_PENDIENTES, FileAccess.READ)
	if archivo == null:
		return []
	var datos = JSON.parse_string(archivo.get_as_text())
	if datos is Array:
		return datos
	return []


func _escribir_pendientes(pendientes: Array) -> void:
	var archivo := FileAccess.open(ARCHIVO_PENDIENTES, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo escribir " + ARCHIVO_PENDIENTES)
		return
	archivo.store_string(JSON.stringify(pendientes))


func _agregar_al_csv(datos: Dictionary) -> void:
	var archivo: FileAccess
	if FileAccess.file_exists(ARCHIVO_CSV):
		archivo = FileAccess.open(ARCHIVO_CSV, FileAccess.READ_WRITE)
		if archivo != null:
			archivo.seek_end()
	else:
		archivo = FileAccess.open(ARCHIVO_CSV, FileAccess.WRITE)
		if archivo != null:
			archivo.store_line("nombre,tiempo_segundos,fecha")
	if archivo == null:
		return

	var nombre := str(datos.get("nombre", "")).replace(",", " ").replace("\"", "")
	archivo.store_line("%s,%.2f,%s" % [nombre, float(datos.get("tiempo", 0.0)), datos.get("fecha", "")])


# Manda a la base los puntajes que quedaron guardados en la PC. Si el servidor
# sigue apagado, no hace nada y los deja para la próxima vez.
func _sincronizar_pendientes() -> void:
	if _sincronizando:
		return
	var pendientes := _leer_pendientes()
	if pendientes.is_empty():
		return

	_sincronizando = true
	var req := HTTPRequest.new()
	req.timeout = TIMEOUT_SEG
	req.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(req)

	var headers := PackedStringArray(["Content-Type: application/json", "ngrok-skip-browser-warning: true"])
	while not pendientes.is_empty():
		var error := req.request(URL_PHP, headers, HTTPClient.METHOD_POST, JSON.stringify(pendientes[0]))
		if error != OK:
			break

		var r = await req.request_completed  # [result, codigo, headers, body]
		var resultado: int = r[0]
		var codigo: int = r[1]
		if resultado != HTTPRequest.RESULT_SUCCESS or codigo >= 500:
			break  # el servidor sigue sin responder: probamos otro día

		if codigo == 200:
			var json = JSON.parse_string((r[3] as PackedByteArray).get_string_from_utf8())
			if not (json is Dictionary and json.get("status", "") == "success"):
				break

		# Se envió bien (o el servidor lo rechazó por inválido: se descarta para no trabar la cola).
		pendientes.remove_at(0)
		_escribir_pendientes(pendientes)

	req.queue_free()
	_sincronizando = false


func _on_intentar_de_nuevo_pressed() -> void:
	Autoloadsonido.play_click()
	Mensajetexto.reset_mensajes()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/pantalla_de_carga.tscn")

func _on_volver_al_menu_pressed() -> void:
	Autoloadsonido.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Menu.tscn")
