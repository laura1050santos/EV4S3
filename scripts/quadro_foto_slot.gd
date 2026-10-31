extends Panel

var quadro: Node
var indice: int

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		return data.has("quadro_foto") and data.get("quadro") == quadro
	return data is Object and data.get("item") is itemData and quadro.aceita_foto(data.item)

func _drop_data(_pos: Vector2, data: Variant) -> void:
	if data is Dictionary:
		quadro.trocar_fotos(int(data.quadro_foto), indice)
	else:
		quadro.fixar_foto(data, indice)

func _get_drag_data(_pos: Vector2) -> Variant:
	var foto: itemData = quadro.fotos[indice]
	if foto == null:
		return null
	var imagem := TextureRect.new()
	imagem.texture = foto.inventory_icon
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.size = Vector2(100, 100)
	imagem.position = Vector2(-50, -50)
	var preview := Control.new()
	preview.add_child(imagem)
	set_drag_preview(preview)
	return {"quadro": quadro, "quadro_foto": indice}

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		quadro.retirar_foto(indice)
		accept_event()
