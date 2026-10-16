class_name Cronometro
extends RefCounted

static var mostrar: bool = false # lo controla el check de Ajustes
static var corriendo: bool = false
static var tiempo: float = 0.0

static func iniciar() -> void:
	tiempo = 0.0
	corriendo = true

static func detener() -> void:
	corriendo = false

static func sumar(delta: float) -> void:
	if corriendo:
		tiempo += delta

static func formato() -> String:
	var t: int = int(tiempo)
	var h: int = floori(t / 3600.0)
	var m: int = floori((t % 3600) / 60.0)
	var s: int = t % 60
	if h > 0:
		return "%02d:%02d:%02d" % [h, m, s]
	return "%02d:%02d" % [m, s]
