extends Resource
class_name itemData
@export var item_name: String
@export var icon: Texture2D
@export var inventory_icon: Texture2D
@export var ativo_icon: Texture2D
@export var item_ativo: bool

static func ativar_luz(item: itemData, cena: Node, pos: Vector2):
	if item.item_ativo == true:
		# Evita duplicar a luz caso o jogador clique várias vezes seguidas
		if cena.has_node("LuzDaLanterna"):
			return
			
		var luz = preload("res://assets/itens/luzLanterna.png")
		var node = PointLight2D.new()
		node.name = "LuzDaLanterna"
		node.texture = luz
		
		# IMPORTANTE: Primeiro adiciona à árvore, depois define a posição global
		cena.add_child(node)
		node.global_position = Vector2(500,350)
	else: 
		itemData.desligar_luz(item, cena)
		
static func desligar_luz(item: itemData, cena: Node):
	print("Desligando luz...")
	if cena.has_node("LuzDaLanterna"):
		cena.get_node("LuzDaLanterna").queue_free()
