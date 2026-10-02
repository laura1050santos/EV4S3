extends "res://scripts/salas_scripts/salas_manager.gd"

# Variáveis para rastrear a colocação das peças no gabinete
var gpu_instalada: bool = false
var processador_instalado: bool = false
var placa_mae_instalada: bool = false

# Usamos get_node_or_null para evitar travamentos caso o nó $monitorLigado não exista na cena do gabinete
@onready var tela_ligada: Sprite2D = $monitorLigado if has_node("monitorLigado") else null

	
	 # O nome do nó raiz desta cena
	
	
func _ready():
	#GlobalSingleton.fase_liberada = 2 Teste do funcionamento do gatilho fase 2
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
	var imgGabinete = Cenarios.get_cena("GabineteAberto")
	if imgGabinete:
		$GabinetePc.texture = load("res://assets/cenarios/pcvazio.png")
	
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)

	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena("ZoomPc")
	print(objetos, " ",nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	atualizar_estado_da_tela()
	_verificar_conclusao_gabinete()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():		
		var chave = get_node_or_null("chave")
		if chave:
			$GabinetePc.texture = load("res://assets/cenarios/pcvazio.png")
			Cenarios.salvar_cenarios("GabineteAberto", "res://assets/cenarios/pcvazio.png")

func _on_slot_gpu_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent()
	if objeto_detectado is Sprite2D and objeto_detectado.name == "gpu":
		objeto_detectado.global_position = Vector2(406, 377)
		Objetos.atualizar_objeto("gpu", "res://recursos/gpu.tres", Vector2(406, 377),"ZoomPc")

		gpu_instalada = true
		_verificar_conclusao_gabinete()

func _on_slot_processador_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent() 
	if objeto_detectado is Sprite2D and objeto_detectado.name == "processador":
		objeto_detectado.global_position = Vector2(524, 395)
		Objetos.atualizar_objeto("processador", "res://recursos/processador.tres", Vector2(524, 395),"ZoomPc")
		processador_instalado = true
		_verificar_conclusao_gabinete()

func _on_slot_placa_mae_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent() 
	if objeto_detectado is Sprite2D and objeto_detectado.name == "PlacaMae":
		objeto_detectado.global_position = Vector2(362, 366)
		Objetos.atualizar_objeto("placa mae", "res://recursos/placaMae.tres", Vector2(524, 366),"ZoomPc")
		placa_mae_instalada = true
		_verificar_conclusao_gabinete()

# Função que valida se todas as peças foram colocadas e aciona a Fase 2
func _verificar_conclusao_gabinete() -> void:
	if gpu_instalada and processador_instalado and placa_mae_instalada:
		print("Gabinete completo! Concluindo Fase 1 e liberando Fase 2...")
		# Define qual cena do quarto deve carregar quando o jogador entrar/continuar na Fase 2
		GlobalSingleton.ultima_cena_por_fase[2] = "res://scenes/quarto/sala_computador.tscn" # Ajuste o caminho do seu quarto se for diferente!
		
		# Conclui a fase 1 no Singleton (fase_liberada passa a ser 2)
		GlobalSingleton.concluir_fase(1)	
			
func atualizar_estado_da_tela():
	# Só altera a visibilidade se o nó realmente existir na cena
	if tela_ligada != null:
		if GlobalSingleton.fase_liberada >= 2:
			tela_ligada.visible = true
			print("Fase 2+: Computador ligado (Sem Conexão).")
		else:
			tela_ligada.visible = false
			print("Fase 1: Computador desligado.")
	else:
		print("Nota: O nó 'monitorLigado' não existe na cena zoom_pc.tscn. Ignorando atualização de sprite.")
