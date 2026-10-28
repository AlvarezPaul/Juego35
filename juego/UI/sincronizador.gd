extends Node

const URL_PHP := "https://joyfully-showbiz-spotting.ngrok-free.dev/juego35/guardar_puntaje.php"
const ARCHIVO_PENDIENTES := "user://puntajes_pendientes.json"
const TIMEOUT_SEG := 5.0
const INTERVALO_SEG := 60.0

var _sincronizando := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var timer := Timer.new()
	timer.wait_time = INTERVALO_SEG
	timer.autostart = true
	timer.timeout.connect(sincronizar)
	add_child(timer)
	sincronizar.call_deferred()


func sincronizar() -> void:
	if _sincronizando:
		return
	_sincronizando = true

	var req := HTTPRequest.new()
	req.timeout = TIMEOUT_SEG
	add_child(req)
	var headers := PackedStringArray(["Content-Type: application/json", "ngrok-skip-browser-warning: true"])

	while true:
		var pendientes := _leer()
		if pendientes.is_empty():
			break
		var actual = pendientes[0]
		if req.request(URL_PHP, headers, HTTPClient.METHOD_POST, JSON.stringify(actual)) != OK:
			break

		var r = await req.request_completed
		var resultado: int = r[0]
		var codigo: int = r[1]
		var cuerpo: String = (r[3] as PackedByteArray).get_string_from_utf8()

		var enviado := false
		if resultado == HTTPRequest.RESULT_SUCCESS:
			if codigo == 200:
				var json = JSON.parse_string(cuerpo)
				enviado = json is Dictionary and json.get("status", "") == "success"
			elif codigo == 400:
				enviado = true  # el servidor lo rechazó por inválido: se descarta para no trabar la cola
		if not enviado:
			break  # servidor o túnel apagado: se reintenta en el próximo ciclo

		var actuales := _leer()
		if not actuales.is_empty() and JSON.stringify(actuales[0]) == JSON.stringify(actual):
			actuales.remove_at(0)
			_escribir(actuales)

	req.queue_free()
	_sincronizando = false


func _leer() -> Array:
	if not FileAccess.file_exists(ARCHIVO_PENDIENTES):
		return []
	var archivo := FileAccess.open(ARCHIVO_PENDIENTES, FileAccess.READ)
	if archivo == null:
		return []
	var datos = JSON.parse_string(archivo.get_as_text())
	if datos is Array:
		return datos
	return []


func _escribir(pendientes: Array) -> void:
	var archivo := FileAccess.open(ARCHIVO_PENDIENTES, FileAccess.WRITE)
	if archivo == null:
		return
	archivo.store_string(JSON.stringify(pendientes))
