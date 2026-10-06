extends CanvasLayer

func _process(delta: float) -> void:
	$TextoFPS.text = str(int(Engine.get_frames_per_second())) + " FPS"
