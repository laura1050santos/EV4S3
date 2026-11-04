extends SalasManager

const FUNDO_PAINEL_DESLIGADO = preload("res://assets/cenarios/tela porta.png")
const FUNDO_PAINEL_LIGADO = preload("res://assets/cenarios/tela porta painel ligado.png")

@onready var parede_roteador_area: Area2D = $ParedeRoteador
@onready var roteador_parede_sprite: Sprite2D = $roteadorParede
@onready var som_Porta = $ListenerPorta/PortaTrancada

@onready var som_Interruptor = $ListenerInterruptor/Interruptor
func _ready():
	$Sprite2D.texture = FUNDO_PAINEL_LIGADO if GlobalSingleton.fase_liberada >= 4 else FUNDO_PAINEL_DESLIGADO
	_exibir_dica_inicial()
	parede_roteador_area.add_to_group("item_drop_targets")
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	if GlobalSingleton.fase_liberada >= 2:
		Objetos.disponibilizar_chave_mala()
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)
	if GlobalSingleton.fase_liberada == 2:
		for info in objetos:
			if info["item"].resource_path == "res://recursos/ChaveMala.tres":
				GlobalSingleton.get_node("EventoPortaFase2").registrar_porta_vista()
				break
	
	for o in objetos:
		print(o)
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


func _exibir_dica_inicial() -> void:
	if GlobalSingleton.fase_liberada == 1:
		GlobalSingleton.get_node("TutorialLanterna").iniciar()


func interruptor_ativar():
	GlobalSingleton.alternar_lampada()
	
func aplicar_estado_lampada():
	var luz = $Escuro/LuzLampada
	luz.visible = GlobalSingleton.lampada_ligada


# Evento de clique na Mala no cenário
func _on_mala_2d_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://scenes/fase2/zoomMala.tscn")

func spawnar_itens(item_ou_caminho, posicao):
	var visual = super.spawnar_itens(item_ou_caminho, posicao)
	if visual != null and visual.has_meta("item_data"):
		var item: itemData = visual.get_meta("item_data")
		if item.resource_path == "res://recursos/ChaveMala.tres":
			visual.scale = Vector2(0.3, 0.3)
			visual.rotation_degrees = -8.0
			var forma := RectangleShape2D.new()
			forma.size = Vector2(264, 100)
			visual.get_node("Area2D/CollisionShape2D").shape = forma
	return visual


# Evento de interação com a área da Parede do Roteador ($ParedeRoteador)
func _on_parede_roteador_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# CORREÇÃO: Garante que o evento é um CLIQUE do mouse antes de ler button_index
	if event is InputEventMouseButton and event.pressed:
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


func receber_item_drop(item: itemData, alvo: Area2D) -> bool:
	if alvo != parede_roteador_area or item == null:
		return false
	if GlobalSingleton.fase_liberada < 2 or item.resource_path != "res://recursos/roteador.tres":
		return false
	if GlobalSingleton.roteador_instalado:
		return false
	GlobalSingleton.item_mao = item
	instalar_roteador()
	return true


func _on_area_interruptor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		som_Interruptor.play()
		var lampada = Enigmas.get_nome("lampada")
		if lampada["resolvido"] == 1:
			interruptor_ativar()
			

func instalar_roteador():
	if GlobalSingleton.roteador_instalado:
		return

	GlobalSingleton.roteador_instalado = true
	Objetos.marcar_instalado_por_recurso("res://recursos/roteador.tres")
	
	GlobalSingleton.item_mao = null

	# 2. Remove da árvore de cena o Sprite2D/worldItem que está na mão
	_destruir_item_visual_da_mao()

	# 3. Exibe o roteador fixado na parede
	roteador_parede_sprite.visible = true
	SaveManager.salvar()
	print("Roteador instalado na parede com sucesso!")


func _destruir_item_visual_da_mao():
	var root = get_tree().root
	_varrer_e_remover_world_item(root)


func _limpar_icone_item_ativo():
	var root = get_tree().root
	for no in root.get_children():
		_procurar_e_remover_no_mao(no)


func abrir_puzzle_fios():
	print("Carregando puzzle de fios...")
	get_tree().change_scene_to_file("res://scenes/fase2/puzzleRoteador.tscn")
	

func _procurar_e_remover_no_mao(no_atual: Node):
	if no_atual == null:
		return

	var nome_no = no_atual.name.to_lower()
	if "mao" in nome_no or "hand" in nome_no or "itemativo" in nome_no or "item_cursor" in nome_no:
		no_atual.queue_free()
		return

	for filho in no_atual.get_children():
		_procurar_e_remover_no_mao(filho)

func _varrer_e_remover_world_item(no_atual: Node):
	if no_atual == null:
		return
		
	if no_atual is Sprite2D and no_atual != roteador_parede_sprite:
		if no_atual.has_meta("item_data") or "worlditem" in no_atual.name.to_lower() or "item" in no_atual.name.to_lower():
			var dados = no_atual.get_meta("item_data") if no_atual.has_meta("item_data") else null
			if dados and (dados.item_name == "roteador" or "roteador" in dados.resource_path.to_lower()):
				no_atual.queue_free()
				return
			elif not no_atual.get_parent() is SalasManager:
				no_atual.queue_free()
				return

	for filho in no_atual.get_children():
		_varrer_e_remover_world_item(filho)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if roteador_parede_sprite.visible == true:
			abrir_puzzle_fios()


func _on_area_porta_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		som_Porta.play()
  # Replace with function body.
