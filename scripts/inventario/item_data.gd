extends Resource
class_name itemData
@export var item_name: String
@export var icon: Texture2D
@export var inventory_icon: Texture2D
@export var ativo_icon: Texture2D
@export var item_ativo: bool
@export var world_scale: Vector2 = Vector2.ONE
@export var fill_inventory_slot: bool = false


func configurar_visual_mundo(node: Sprite2D) -> void:
	node.set_meta("item_data", self)
	node.texture = ativo_icon if item_ativo else icon
	node.scale = world_scale
	if world_scale == Vector2.ONE or node.texture == null:
		return

	var hitbox := node.get_node_or_null("Area2D/CollisionShape2D") as CollisionShape2D
	if hitbox != null and hitbox.shape is RectangleShape2D:
		var hitbox_shape := hitbox.shape.duplicate() as RectangleShape2D
		hitbox_shape.size = Vector2(node.texture.get_size())
		hitbox.shape = hitbox_shape


static func ativar_luz(item: itemData, cena: Node, pos: Vector2):
	if item.item_ativo == true:
		var root = cena.get_tree().root
		
		# Evita duplicar a luz na raiz
		if root.has_node("LuzDaLanterna"):
			return
			
		var node = PointLight2D.new()
		node.set_script(preload("res://scripts/inventario/luz_lanterna.gd"))
		node.name = "LuzDaLanterna"
		
		# Adiciona direto na raiz do jogo
		root.add_child(node)
	
		
static func desligar_luz(item: itemData, cena: Node):
	print("Desligando luz...")
	var root = cena.get_tree().root
	if root.has_node("LuzDaLanterna"):
		root.get_node("LuzDaLanterna").queue_free()
		
static func desativar_item_global(tree: SceneTree):
	# 1. Garante a remoção da LuzDaLanterna da raiz se ela existir
	var root = tree.root
	if root.has_node("LuzDaLanterna"):
		root.get_node("LuzDaLanterna").queue_free()

	# 2. Se um item ativo tiver sido colocado direto na raiz (como a lanterna no reparent), limpa o nó
	if GlobalSingleton.item_mao != null:
		var nome_item = GlobalSingleton.item_mao.item_name
		if root.has_node(nome_item):
			root.get_node(nome_item).queue_free()
		
		# Desmarca a flag do item e reseta a mão do jogador
		GlobalSingleton.item_mao.item_ativo = false
		GlobalSingleton.item_mao = null
