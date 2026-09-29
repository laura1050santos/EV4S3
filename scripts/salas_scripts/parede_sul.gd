extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var lanterna: Node = get_tree().root.get_node_or_null("lanterna")
var node = preload("res://scenes/inventario/worldItem.tscn")

@onready var processador 
@onready var gaveta1_sprite = $Gaveta1Aquario
@onready var gaveta2_sprite = $gaveta2
@onready var gaveta3_sprite = $gaveta_3

func _ready():
	var cena =Cenarios.get_cena("sul")
	if cena:
		$cena.texture = load(cena["sprite"])
		
	var configMenu = get_node("BotaoConfig/configuracao")
	configMenu.volMax.connect(ativar_enigma_som)
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	 
	processador = get_tree().root.get_node_or_null("Sul/processador")
	var aquario = Enigmas.get_nome("aquario")
	if aquario["resolvido"] == 0 :
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
	var aquario = Enigmas.get_nome("aquario")
	if aquario["resolvido"] == 0 :

		Enigmas.atualizar_enigma("aquario", 1)
		$SomVidroQuebrando.play()

		Cenarios.atualizar_cenario("sul","res://assets/cenarios/aquarioquebrado(1).png")
		$cena.texture  = preload("res://assets/cenarios/aquarioquebrado(1).png")	

func _input(event: InputEvent):
	if lanterna:
		$cena.texture = preload("res://assets/cenarios/salaaquarioseta.png")
		$buraco/colisaoBuraco.disabled = false
	var aquario = Enigmas.get_nome("aquario")
	if aquario["resolvido"] == 1 :
		$cena.texture = preload("res://assets/cenarios/aquarioquebrado(1).png")
	
func _on_area_cabeca_quebrada_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():
		if processador:
			if processador.visible ==false:
				processador.visible = true
				var area = processador.get_node("Area2D/CollisionShape2D")
				area.disabled = false # Replace with function body.
