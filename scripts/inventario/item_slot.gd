extends Panel

@onready var icon: TextureRect = $icon
@export var item : itemData:
	set(value):
		item  = value
		if is_node_ready and item:
			update_ui()
func _ready():
	update_ui()

func update_ui():
	#atualiza a iinterface do slote e do item no mundo
	if not item: 
		icon.texture = null
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
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = icon.size # Copia o tamanho do seu ícone atual
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2 # Centraliza o mouse no item
	c.modulate.a = 0.5 # Deixa transparente de forma segura
	
	set_drag_preview(c) #função do godot para criar um painel enquanto o item é arrastado
	icon.hide()
	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	#avalia se o lugar onde o item foi solto é valido. Pode ser usado para validação
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	# ativada quando um item é solto pelo mouse, se o local for valido
	var tmp = item
	item = data.item
	data.item = tmp
	icon.show()
	data.icon.show()
	update_ui()
	data.update_ui()

func _notification(what):
	#'avisa' se o item foi solto e mostra ele.É ativado no final da ação
	if what == NOTIFICATION_DRAG_END:
		if item:
			icon.show()
