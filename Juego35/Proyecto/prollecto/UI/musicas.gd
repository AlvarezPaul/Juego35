extends AudioStreamPlayer
## Música global del juego.
##
## Este script vive en el nodo autoload "Musica" (ver project.godot).
## Al ser un autoload, Godot lo mantiene vivo durante TODO el juego y no
## lo destruye al cambiar de escena con change_scene_to_file(). Por eso
## la música no se reinicia al pasar del menú a la sala o a los créditos:
## siempre es el mismo AudioStreamPlayer sonando de principio a fin.
##
## Si en algún momento agregan una escena nueva y quieren silenciar o
## cambiar la música ahí, no toquen este nodo: agreguen su propio
## AudioStreamPlayer local en esa escena, o llamen a las funciones
## públicas de este script (detener_musica / reanudar_musica).

const RUTA_MUSICA_POR_DEFECTO := "res://salas/musica_menu.mp3"


func _ready() -> void:
	# Sigue sonando aunque el árbol de escena esté en pausa
	# (por ejemplo, si más adelante agregan un menú de pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Red de seguridad: si por algún motivo el stream no vino asignado
	# desde el editor (Musica.tscn), lo carga por código.
	if stream == null:
		stream = load(RUTA_MUSICA_POR_DEFECTO)

	# Loop manual: cuando el track termina, arranca de nuevo.
	if not finished.is_connected(_reiniciar_loop):
		finished.connect(_reiniciar_loop)

	if not playing:
		play()


func _reiniciar_loop() -> void:
	play()


## Función pública por si en el futuro quieren silenciar la música
## desde otra escena (por ejemplo, al entrar a un jumpscare).
func detener_musica() -> void:
	stop()


## Función pública para retomar la música donde estaba.
func reanudar_musica() -> void:
	if not playing:
		play()
