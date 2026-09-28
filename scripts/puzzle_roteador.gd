extends Node2D

const TOTAL_CONEXOES: int = 4
var conexoes_feitas: int = 0

var fio_sendo_arrastado: Line2D = null
var cor_fio_atual: String = ""
var pos_inicial_fio: Vector2 = Vector2.ZERO

const CORES = {
	"vermelho": Color.RED,
	"verde": Color.GREEN,
	"amarelo": Color.YELLOW,
	"azul": Color.DODGER_BLUE
}

@onready var origens = {
	"vermelho": $fioVermelho_Esquerda,
	"verde": $fioVerde_Esquerda,
	"amarelo": $fioAmarelo_Esquerda,
	"azul": $fioAzul_ESquerda
}

@onready var destinos = {
	"vermelho": $Area2D4fioVermelho_Direita,
	"verde": $FioVerde_Direita,
	"amarelo": $FioAmarelo_direita,
	"azul": $FioAzul_Direita
}

var linhas_criadas = {}
var fios_conectados = {
	"vermelho": false,
	"verde": false,
	"amarelo": false,
	"azul": false
}

func _ready():
	# Limpa qualquer Line2D estática sobressalente do editor
	for node in get_children():
		if node is Line2D:
			node.queue_free()
			
	# Conecta os sinais de entrada de cada Area2D da esquerda
	for cor in origens.keys():
		var area: Area2D = origens[cor]
		area.input_pickable = true
		area.input_event.connect(_on_area_esquerda_input_event.bind(cor))

func _process(_delta):
	if fio_sendo_arrastado != null:
		# Ponto 0 é fixo no local exato do clique inicial no conector
		# Ponto 1 segue a posição atual do mouse em tempo real
		fio_sendo_arrastado.points = PackedVector2Array([pos_inicial_fio, get_global_mouse_position()])

func _on_area_esquerda_input_event(_viewport, event, _shape_idx, cor: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if fios_conectados[cor] or fio_sendo_arrastado != null:
			return
			
		cor_fio_atual = cor
		# GRAVA A POSIÇÃO REAL DO MOUSE ONDE O JOGADOR CLICOU NO CONECTOR
		pos_inicial_fio = get_global_mouse_position()
		
		var nova_linha = Line2D.new()
		nova_linha.width = 16.0
		nova_linha.default_color = CORES[cor]
		nova_linha.top_level = true
		
		add_child(nova_linha)
		
		fio_sendo_arrastado = nova_linha
		linhas_criadas[cor] = nova_linha
		print("Fio iniciado no ponto real do mouse: ", pos_inicial_fio)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_soltar_fio()

func _soltar_fio():
	if fio_sendo_arrastado == null:
		return
		
	var pos_mouse = get_global_mouse_position()
	var area_destino: Area2D = destinos[cor_fio_atual]
	
	# Detecta se soltou próximo do destino correto da direita
	if pos_mouse.distance_to(area_destino.global_position) < 120.0 or _verificar_colisao_destino(pos_mouse, area_destino):
		# Trava a ponta final no local real onde soltou sobre o destino da direita
		fio_sendo_arrastado.points = PackedVector2Array([
			pos_inicial_fio,
			pos_mouse
		])
		
		fios_conectados[cor_fio_atual] = true
		conexoes_feitas += 1
		print("Fio ", cor_fio_atual, " conectado com sucesso!")
		_verificar_vitoria()
	else:
		fio_sendo_arrastado.queue_free()
		linhas_criadas.erase(cor_fio_atual)
		print("Soltou fora, linha removida.")
		
	fio_sendo_arrastado = null
	cor_fio_atual = ""

func _verificar_colisao_destino(pos: Vector2, area_alvo: Area2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	var resultados = space_state.intersect_point(query)
	for res in resultados:
		if res.collider == area_alvo:
			return true
	return false

func _verificar_vitoria():
	if conexoes_feitas >= TOTAL_CONEXOES:
		print("TODOS OS FIOS CONECTADOS!")
		GlobalSingleton.pc_conectado = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn")
