extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var mala_area = $Mala/Area2D 
@onready var parede_roteador_area: Area2D = $ParedeRoteador
@onready var roteador_parede_sprite: Sprite2D = $roteadorParede

func _ready():
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)
	var nome_desta_cena = self.name

	var itens_iniciais = []
	iniciar_itens_cena(nome_desta_cena, itens_iniciais)
	
	_configurar_interacao_mala()
	
	# Garante a visibilidade correta dependendo do estado salvo no GlobalSingleton
	if GlobalSingleton.roteador_instalado:
		roteador_parede_sprite.visible = true
	else:
		roteador_parede_sprite.visible = false

func _configurar_interacao_mala() -> void:
	if mala_area:
		var interativa = GlobalSingleton.fase_liberada >= 2
		mala_area.input_pickable = interativa

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
		
	# --- INSTALAÇÃO (Clique Esquerdo com o Roteador na mão) ---
	if event.button_index == MOUSE_BUTTON_LEFT:
		if GlobalSingleton.item_mao != null:
			var recurso_item = GlobalSingleton.item_mao
			var nome_item = recurso_item.get("item_name") if recurso_item is Resource else ""
			
			if nome_item == "roteador":
				instalar_roteador()
			elif nome_item == "RelogioCuco":
				get_tree().change_scene_to_file("res://scenes/start.tscn")

	# --- ATIVAÇÃO (Clique Direito no Roteador instalado) ---
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if GlobalSingleton.roteador_instalado:
			abrir_puzzle_fios()

func _on_area_interruptor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if GlobalSingleton.enigma_luz_resolvido == true:
			interruptor_ativar()
			
func instalar_roteador():
	GlobalSingleton.roteador_instalado = true
	
	# Verifica se a função existe antes de chamar para evitar erros
	if GlobalSingleton.has_method("remover_item_da_mao"):
		GlobalSingleton.remover_item_da_mao()
	else:
		GlobalSingleton.item_mao = null
		
	roteador_parede_sprite.visible = true
	print("Roteador instalado na parede com sucesso!")

func abrir_puzzle_fios():
	print("Carregando puzzle de fios...")
	get_tree().change_scene_to_file("res://scenes/fase2/puzzle_fios.tscn")
