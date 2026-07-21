extends Resource
class_name itemData
@export var item_name: String
@export var icon: Texture2D
@export var inventory_icon: Texture2D
@export var ativo_icon: Texture2D
@export var item_ativo: bool

static func ativar_luz(item: itemData, cena: Node, pos: Vector2):
	if item.item_ativo == true:
		var root = cena.get_tree().root
		
		# Evita duplicar a luz na raiz
		if root.has_node("LuzDaLanterna"):
			return
			
		var luz = preload("res://assets/itens/luzLanterna.png")
		var node = PointLight2D.new()
		node.name = "LuzDaLanterna"
		node.texture = luz
		
		# Adiciona direto na raiz do jogo
		root.add_child(node)
		node.global_position = Vector2(650, 325)
	
		
static func desligar_luz(item: itemData, cena: Node):
	print("Desligando luz...")
	var root = cena.get_tree().root
	if root.has_node("LuzDaLanterna"):
		root.get_node("LuzDaLanterna").queue_free()
