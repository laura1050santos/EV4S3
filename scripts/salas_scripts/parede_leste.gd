extends "res://scripts/salas_scripts/salas_manager.gd"
@onready var gaveta1_sprite = $Gaveta1Pc
@onready var gaveta2_sprite = $Gaveta2Pc
@onready var gaveta3_sprite = $Gaveta3Pc

func _ready():
	GlobalSingleton.ultima_cena =  get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais=[

		{
		"item": preload("res://recursos/lanterna.tres"),
		"pos": Vector2(500, 550),
		"cena": nome_desta_cena
		},
		{
		"item": preload("res://recursos/chaveDeFenda.tres"),
		"pos": Vector2(770, 550),
		"cena": nome_desta_cena
		},
#itens que começam na cena
]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	var lanterna = get_node_or_null("lanterna")
	if lanterna :
		lanterna.z_index=1

func _on_gaveta_1_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		GlobalSingleton.gaveta_1 = !GlobalSingleton.gaveta_1
		gaveta1_sprite.visible = GlobalSingleton.gaveta_1
		print("Ativado 1")

func _on_gaveta_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
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

func _on_pc_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/fase1/zoom_pc.tscn") # Replace with function body.

func _on_monitor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn") # Replace with function body.

# ==== TESTE DE TRANSIÇÃO =====
func _input(event):
	if event.is_action_pressed("ui_accept"):  # tecla Enter/Espaço por padrão
		TransicaoFase.show_phase_complete("res://scenes/telaInicial/selecao_fases.tscn")
