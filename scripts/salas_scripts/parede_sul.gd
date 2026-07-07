extends "res://scripts/salas_scripts/salas_manager.gd"
var lanterna_node: Node = null
var node = preload("res://scenes/inventario/worldItem.tscn")

func _ready():
	var configMenu = get_node("BotaoConfig/configuracao")
	configMenu.volMax.connect(ativar_enigma_som)

	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	
	var itens_iniciais=[
		#itens que começam na cena
	
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	
@onready var meu_sprite = $Gaveta1Aquario
func _on_gaveta_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Verifica se o evento foi um clique do botão esquerdo do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Verifica se o botão foi pressionado (e não solto)
		if event.pressed:
			GlobalSingleton.sprite_visivel = not GlobalSingleton.sprite_visivel
			
			# 2. Aplica o novo estado visualmente no sprite
			meu_sprite.visible = GlobalSingleton.sprite_visivel
			print("Sprite ativado!")
			
			
func _input(event: InputEvent):
	if get_tree().root.has_node("lanterna"):
		get_node("buraco/colisaoBuraco").disabled = false
		
func ativar_enigma_som():
	print("volume maximo \nquebrar o aquario")
	var existe = false

	for info in GlobalSingleton.itens_no_mundo:
		if info["data"].item_name == "LampadaQuebrada":
			existe = true
			break
	if not has_node("processador") or !existe:
		var item = Node2D.new()
		item.name = "processador"
		item.position = Vector2(670,375)

		var sprite = Sprite2D.new()
		var texture = load("res://assets/itens/teto-lampada-quebrada.png")
		sprite.texture = texture
		item.add_child(sprite)

		var area = Area2D.new()
		item.add_child(area)

		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = texture.get_size()
		collision.shape = shape
		area.add_child(collision)
		add_child(item)
		
		GlobalSingleton.registrar_item(preload("res://recursos/LampadaQuebrada.tres"),Vector2(670,375),self.name)
# Replace with function body.
