extends Area2D

func _ready() -> void:
	input_event.connect(_examinar)
	$FotosFixadas.input_event.connect(_examinar)
	for indice in range(4):
		var caminho: String = Objetos.get_recurso_em_estacao("quadro_foto_" + str(indice))
		if caminho.is_empty() or not ResourceLoader.exists(caminho):
			continue
		var foto: itemData = load(caminho)
		var miniatura := Sprite2D.new()
		miniatura.texture = foto.icon
		miniatura.scale = Vector2(0.07, 0.07)
		miniatura.position = Vector2(-100 + indice * 60, -60)
		add_child(miniatura)

func _examinar(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	get_viewport().set_input_as_handled()
	get_tree().change_scene_to_file("res://scenes/fase3/zoom_quadro.tscn")
