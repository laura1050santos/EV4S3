extends "res://scripts/salas_scripts/salas_manager.gd"
var lanterna_node: Node = null
var node = preload("res://scenes/inventario/worldItem.tscn")

func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
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
		$Sprite2D.texture = preload( "res://assets/cenarios/salaaquarioseta.png")
		get_node("buraco/colisaoBuraco").disabled = false
		
		
func ativar_enigma_som():
	print("volume maximo \nquebrar o aquario")
	

	
