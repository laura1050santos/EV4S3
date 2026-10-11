class_name GavetasController
extends Node


var sala_id: String = ""
var sprites: Dictionary = {}
var areas: Dictionary = {}


signal gaveta_alterada(
	id: String,
	aberta: bool
)


func configurar(id_da_sala: String, sprites_das_gavetas: Dictionary, areas_das_gavetas: Dictionary) -> void:
	sala_id = id_da_sala
	sprites = sprites_das_gavetas
	areas = areas_das_gavetas

	print("[GAVETAS] Configurando sala: ", sala_id)

	_conectar_gavetas()
	restaurar_gavetas()


func _conectar_gavetas() -> void:
	for id in areas.keys():
		var area = areas[id]

		if area == null:
			push_error("[GAVETAS] Area2D da gaveta " + str(id) + " é null.")
			continue

		if not area is Area2D:
			push_error("[GAVETAS] O nó da gaveta " + str(id) + " não é Area2D.")
			continue

		area.input_pickable = true

		var callback = func(_viewport: Node, event: InputEvent, _shape_idx: int):
			_on_gaveta_input_event(event, str(id))

		area.input_event.connect(callback)

		print("[GAVETAS] Gaveta conectada: ", sala_id, "_", id, " | Nó: ", area.get_path())


func restaurar_gavetas() -> void:
	if not GlobalSingleton.gavetas.has(sala_id):
		push_error("[GAVETAS] Sala não encontrada no Global: " + sala_id)
		return

	for id in sprites.keys():
		if not GlobalSingleton.gavetas[sala_id].has(id):
			push_warning("[GAVETAS] Gaveta " + str(id) + " não existe em " + sala_id)
			continue

		var aberta: bool = GlobalSingleton.gavetas[sala_id][id]
		sprites[id].visible = aberta

		print("[GAVETAS] Restaurada ", sala_id, "_", id, " = ", aberta)


func _on_gaveta_input_event(event: InputEvent, id: String) -> void:
	if not (event is InputEventMouseButton):
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not event.pressed:
		return

	print("[GAVETAS] CLIQUE recebido: ", sala_id, "_", id)

	alternar_gaveta(id)


func alternar_gaveta(id: String) -> void:
	if not GlobalSingleton.gavetas.has(sala_id):
		return

	if not GlobalSingleton.gavetas[sala_id].has(id):
		return

	var novo_estado = not (
		GlobalSingleton.gavetas[sala_id][id]
	)

	GlobalSingleton.gavetas[sala_id][id] = novo_estado

	if sprites.has(id):
		sprites[id].visible = novo_estado

	gaveta_alterada.emit(
		id,
		novo_estado
	)

	print(
		"Gaveta ",
		sala_id,
		"_",
		id,
		": ",
		novo_estado
	)
