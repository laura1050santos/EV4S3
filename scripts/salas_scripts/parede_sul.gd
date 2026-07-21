extends "res://scripts/salas_scripts/salas_manager.gd"
var lanterna_node: Node = null
var node = preload("res://scenes/inventario/worldItem.tscn")

func _ready():
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
	var configMenu = get_node("BotaoConfig/configuracao")
	configMenu.volMax.connect(ativar_enigma_som)

	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	
	var itens_iniciais=[
		#itens que começam na cena
	
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	gaveta1_sprite.visible = GlobalSingleton.gaveta_1
	gaveta2_sprite.visible = GlobalSingleton.gaveta_2
	
	
@onready var gaveta1_sprite = $Gaveta1Aquario
@onready var gaveta2_sprite = $gaveta2
@onready var gaveta3_sprite = $gaveta_3

func _on_gaveta_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		GlobalSingleton.gaveta_1 = !GlobalSingleton.gaveta_1
		gaveta1_sprite.visible = GlobalSingleton.gaveta_1
		print("Ativado 1")


func _on_gaveta2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		GlobalSingleton.gaveta_2 = !GlobalSingleton.gaveta_2
		gaveta2_sprite.visible = GlobalSingleton.gaveta_2
		print("Ativado 2")
	pass
		
func _on_gaveta_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		GlobalSingleton.gaveta_3 = !GlobalSingleton.gaveta_3
		gaveta3_sprite.visible = GlobalSingleton.gaveta_3
		print("Ativado 3")
	pass # Replace with function body.
			
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


 # Replace with function body.
