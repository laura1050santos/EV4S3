extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var lanterna: Node = get_tree().root.get_node_or_null("lanterna")
var node = preload("res://scenes/inventario/worldItem.tscn")

@onready var processador 
@onready var gaveta1_sprite = $Gaveta1Aquario
@onready var gaveta2_sprite = $gaveta2
@onready var gaveta3_sprite = $gaveta_3

func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var configMenu = get_node("BotaoConfig/configuracao")
	configMenu.volMax.connect(ativar_enigma_som)

	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	
	var itens_iniciais=[

		{ "item": preload("res://recursos/processador.tres"),
		"pos":Vector2(600,550),
		"cena":nome_desta_cena,
		},#itens que começam na cena
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	processador = get_tree().root.get_node_or_null("Sul/processador")
	if GlobalSingleton.cont ==0:
		processador.visible = false
		var area = processador.get_node("Area2D/CollisionShape2D")
		area.disabled = true
	gaveta1_sprite.visible = GlobalSingleton.gaveta_1
	gaveta2_sprite.visible = GlobalSingleton.gaveta_2

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
			
func ativar_enigma_som():
	if GlobalSingleton.cont == 0 :
		GlobalSingleton.cont = 1
		print("volume maximo \nquebrar o aquario")
		$SomVidroQuebrando.play()
		

		$aquarioInteiro.texture  = preload("res://assets/cenarios/aquarioquebrado(1).png")	

func _input(event: InputEvent):
	if lanterna:
		$aquarioInteiro.texture = preload("res://assets/cenarios/salaaquarioseta.png")
		$buraco/colisaoBuraco.disabled = false
	if GlobalSingleton.cont==1:
		$aquarioInteiro.texture = preload("res://assets/cenarios/aquarioquebrado(1).png")
		


func _on_area_cabeca_quebrada_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():
		processador.visible = true
		
		var area = processador.get_node("Area2D/CollisionShape2D")
		area.disabled = false # Replace with function body.
