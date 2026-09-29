extends SalasManager

@onready var mala_area = $Mala/Area2D 
@onready var parede_roteador_area: Area2D = $ParedeRoteador
@onready var roteador_parede_sprite: Sprite2D = $roteadorParede

func _ready():

	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	
	for o in objetos:
		print (o)
		if o["nome"] == "mala":
			print(o)
			var root = get_tree().root
			if root.get_node_or_null("Norte/Mala/Area2D"):
					var colisionMala = root.get_node_or_null("Norte/Mala/Area2D/CollisionShape2D")
					if GlobalSingleton.fase_liberada == 2:
						print("colisao da mala ativada")
						colisionMala.disabled = false
				# Garante a visibilidade correta dependendo do estado salvo no GlobalSingleton
	if GlobalSingleton.roteador_instalado:
		roteador_parede_sprite.visible = true
	else:
		roteador_parede_sprite.visible = false

func interruptor_ativar():
	var LuzLampada = load("res://scenes/escuro.tscn").instantiate()
	var root = get_tree().root
	if root.get_node_or_null("Escuro/LuzLampada"):
		var luzNoRoot = root.get_node_or_null("Escuro/LuzLampada")
		if luzNoRoot.enabled == true:
			luzNoRoot.enabled = false
		else:
			luzNoRoot.enabled = true
	else:
		root.add_child(LuzLampada)
		LuzLampada = LuzLampada.get_child(1)
		LuzLampada.enabled = true

# Evento de clique na Mala no cenário
func _on_mala_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GlobalSingleton.fase_liberada == 1:
			print("A mala está trancada / não há motivo para mexer nela agora.")
		elif GlobalSingleton.fase_liberada >= 2:
			get_tree().change_scene_to_file("res://scenes/fase2/zoom_mala.tscn")

# Evento de interação com a área da Parede do Roteador ($ParedeRoteador)
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
		
	# --- INSTALAÇÃO / INTERAÇÃO (Clique Esquerdo) ---
	if event.button_index == MOUSE_BUTTON_LEFT:
		# 1. Se o jogador está segurando um item na mão
		if GlobalSingleton.item_mao != null:
			var recurso_item = GlobalSingleton.item_mao
			var nome_item = recurso_item.get("item_name") if recurso_item is Resource else ""
			
			if nome_item == "roteador":
				instalar_roteador()
			elif nome_item == "RelogioCuco":
				get_tree().change_scene_to_file("res://scenes/start.tscn")
				
		# 2. Se a mão está vazia, mas o roteador já foi instalado na parede
		elif GlobalSingleton.roteador_instalado:
			if not GlobalSingleton.pc_conectado:
				print("Abrindo puzzle de fios do roteador...")
				get_tree().change_scene_to_file("res://scenes/fase2/puzzleRoteador.tscn")
			else:
				print("O roteador já está com os fios conectados!")

func _on_area_interruptor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var lampada = Enigmas.get_nome("lampada")
		if lampada["resolvido"] == 1:
			interruptor_ativar()
			
func instalar_roteador():
	# 1. Define as flags lógicas globais
	GlobalSingleton.roteador_instalado = true
	
	if GlobalSingleton.has_method("remover_item_da_mao"):
		GlobalSingleton.remover_item_da_mao()
	else:
		GlobalSingleton.item_mao = null

	# 2. Remove da árvore de cena o Sprite2D/worldItem que está na mão
	_destruir_item_visual_da_mao()

	# 3. Exibe o roteador fixado na parede
	roteador_parede_sprite.visible = true
	print("Roteador instalado na parede com sucesso!")


func _destruir_item_visual_da_mao():
	var root = get_tree().root
	_varrer_e_remover_world_item(root)
func _limpar_icone_item_ativo():
	var root = get_tree().root
	
	# Varre todos os nós filhos da cena principal e da UI para encontrar o Sprite/Item do rato
	for no in root.get_children():
		# Procura em telas de interface (CanvasLayer, HUD, UI, etc.)
		_procurar_e_remover_no_mao(no)

func abrir_puzzle_fios():
	print("Carregando puzzle de fios...")
	get_tree().change_scene_to_file("res://scenes/fase2/puzzleRoteador.tscn")
	
func _procurar_e_remover_no_mao(no_atual: Node):
	if no_atual == null:
		return

	var nome_no = no_atual.name.to_lower()
	
	# Se o nó tiver nomes comuns do ícone que segue o rato/mão, remove-o
	if "mao" in nome_no or "hand" in nome_no or "itemativo" in nome_no or "item_cursor" in nome_no:
		no_atual.queue_free()
		return

	# Busca recursiva nos filhos
	for filho in no_atual.get_children():
		_procurar_e_remover_no_mao(filho)


func _varrer_e_remover_world_item(no_atual: Node):
	if no_atual == null:
		return
		
	# Procura por nós do tipo Sprite2D que não sejam o próprio roteador da parede
	if no_atual is Sprite2D and no_atual != roteador_parede_sprite:
		# Verifica se é um item de mundo/mão (pelo script, meta ou nome)
		if no_atual.has_meta("item_data") or "worlditem" in no_atual.name.to_lower() or "item" in no_atual.name.to_lower():
			var dados = no_atual.get_meta("item_data") if no_atual.has_meta("item_data") else null
			# Se os dados forem do roteador ou o nó estiver sem pai fixo no cenário
			if dados and (dados.item_name == "roteador" or "roteador" in dados.resource_path.to_lower()):
				no_atual.queue_free()
				return
			elif not no_atual.get_parent() is SalasManager: # Se for um nó instanciado na UI/Mão
				no_atual.queue_free()
				return

	# Busca recursiva nos nós filhos
	for filho in no_atual.get_children():
		_varrer_e_remover_world_item(filho)
