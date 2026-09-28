extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var mala_sprite: Sprite2D = $Malagrande
@onready var ponto_roteador: Node2D = $pontoroteador

var mala_aberta: bool = false

func _ready():
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)
	
	# Descomenta a linha abaixo APENAS para resetar o teste, depois remove-a
	# GlobalSingleton.roteador_coletado = false

	# Lógica corrigida:
	if GlobalSingleton.roteador_coletado:
		mala_aberta = true
		mala_sprite.texture = load("res://assets/itens/malaAberta.jpeg.jpeg") # Mala aberta quando já coletado
	else:
		mala_aberta = false
		mala_sprite.texture = load("res://assets/itens/malagrande.png") # Mala fechada no início!
# Clique na Mala para abrir
func _on_mala_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not mala_aberta:
			mala_aberta = true
			mala_sprite.texture = load("res://assets/cenarios/mala_aberta.png")
			
			# Se ainda não foi recolhido, faz aparecer o Roteador como item no mundo
			if not GlobalSingleton.roteador_coletado:
				_gerar_roteador_no_mundo()

func _gerar_roteador_no_mundo() -> void:
	var recurso_roteador = preload("res://recursos/Roteador.tres") # Ajusta o teu caminho
	
	# Usa a tua própria função do salas_manager.gd para criar o item na cena
	adicionar_item_na_sala(recurso_roteador, ponto_roteador.global_position)
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not mala_aberta:
			mala_aberta = true
			mala_sprite.texture = load("res://assets/itens/malaAberta.jpeg.jpeg")
			
			if not GlobalSingleton.roteador_coletado:
				_gerar_roteador_no_mundo()
	pass # Replace with function body.
