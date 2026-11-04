extends Panel

@onready var icon: TextureRect = $icon


func _ready() -> void:
	update_ui()


@export var item: itemData:
	set(value):
		item = value

		if is_node_ready():
			update_ui()

func update_ui():
	icon.scale = Vector2.ONE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#atualiza a iinterface do slote e do item no mundo
	if not item: 
		icon.texture = null
		tooltip_text = ""
		icon.hide()
		return
	icon.texture = item.inventory_icon
	tooltip_text = item.item_name
	icon.show()
		
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not item:
		return null
		
	# Efeito visual enquanto o item é arrastado
	var preview = TextureRect.new()
	preview.texture = item.inventory_icon
	preview.expand_mode = icon.expand_mode
	preview.stretch_mode = icon.stretch_mode
	preview.custom_minimum_size = icon.size * icon.scale
	preview.size = preview.custom_minimum_size
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2 # Centraliza o mouse no item
	c.modulate.a = 0.5 # Deixa transparente de forma segura
	
	set_drag_preview(c) #função do godot para criar um painel enquanto o item é arrastado
	icon.hide()
	return self

func _gui_input(event: InputEvent) -> void:
	if item == null or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
		return
	if item.item_name == "lanterna":
		item.item_ativo = not item.item_ativo
		if item.item_ativo:
			itemData.ativar_luz(item, self, Vector2.ZERO)
		else:
			itemData.desligar_luz(item, self)
		accept_event()
	elif item.pode_inspecionar():
		var drop_area = get_tree().get_first_node_in_group("world_drop_area")
		if drop_area != null:
			drop_area.inspecionar_papel(item)
			accept_event()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.has("quadro_foto"):
		return item == null and is_instance_valid(data.quadro)
	#avalia se o lugar onde o item foi solto é valido. Pode ser usado para validação
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.has("quadro_foto"):
		if item == null and is_instance_valid(data.quadro):
			data.quadro.retirar_foto(int(data.quadro_foto), self)
		return
	# ativada quando um item é solto pelo mouse, se o local for valido
	var tmp = item
	item = data.item
	data.item = tmp
	icon.show()
	data.icon.show()
	update_ui()
	data.update_ui()
	
