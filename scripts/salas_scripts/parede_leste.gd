extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var gaveta1_sprite = $Gaveta1Pc
@onready var gaveta2_sprite = $Gaveta2Pc
@onready var gaveta3_sprite = $Gaveta3Pc

# Referência opcional caso você tenha um Sprite2D para a tela acesa no monitor
# @onready var monitor_sprite = $MonitorSprite

func _ready():
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)
	
	# Restaura o estado das gavetas ao entrar na sala
	gaveta1_sprite.visible = GlobalSingleton.gaveta_1
	gaveta2_sprite.visible = GlobalSingleton.gaveta_2
	gaveta3_sprite.visible = GlobalSingleton.gaveta_3

	var nome_desta_cena = self.name # O nome do nó raiz desta cena

	var itens_iniciais = [
		{
			"item": preload("res://recursos/lanterna.tres"),
			"pos": Vector2(500, 550),
			"cena": nome_desta_cena
		},
		{
			"item": preload("res://recursos/chaveDeFenda.tres"),
			"pos": Vector2(770, 590),
			"cena": nome_desta_cena
		},
	]
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	
	var lanterna = get_node_or_null("lanterna")
	if lanterna:
		lanterna.z_index = 1

	# Atualiza o visual da sala de acordo com a fase atual
	_atualizar_estado_fase()

func _atualizar_estado_fase() -> void:
	if GlobalSingleton.fase_liberada >= 2:
		# Exemplo: Trocar o sprite do monitor para "Sem Conexão" na Fase 2
		# monitor_sprite.texture = load("res://assets/cenarios/monitor_sem_conexao.png")
		print("Sala do PC configurada para a Fase 2")

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

func _on_gaveta_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		GlobalSingleton.gaveta_3 = !GlobalSingleton.gaveta_3
		gaveta3_sprite.visible = GlobalSingleton.gaveta_3
		print("Ativado 3")

# Clique no Gabinete
func _on_pc_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GlobalSingleton.fase_liberada == 1:
			# Na Fase 1, abre o zoom do gabinete para montar as peças
			get_tree().change_scene_to_file("res://scenes/fase1/zoom_pc.tscn")
		else:
			# Na Fase 2 em diante, o gabinete já está montado
			print("O gabinete já está montado com todas as peças.")

# Clique no Monitor
func _on_monitor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GlobalSingleton.fase_liberada == 1:
			get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn")
		elif GlobalSingleton.fase_liberada == 2:
			# Na Fase 2, abre o zoom da tela indicando "Sem Conexão / Configuração do Roteador"
			get_tree().change_scene_to_file("res://scenes/fase2/zoom_monitor_fase2.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		TransicaoFase.show_phase_complete("res://scenes/telaInicial/selecao_fases.tscn")
