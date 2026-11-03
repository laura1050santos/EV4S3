extends SalasManager

const BACKUP = preload("res://recursos/Backup03.tres")
const FECHADO = preload("res://assets/cenarios/cuco_fechado_zoom.png")
const ABERTO_COM_CARTAO = preload("res://assets/cenarios/cuco_aberto_sd.png")
const ABERTO_SEM_CARTAO = preload("res://assets/cenarios/cuco_aberto.png")
const CENTRO := Vector2(936, 525)
@export_range(0, 719, 1) var minutos_iniciais: float = 180.0
@export_range(1, 60, 1) var minutos_por_clique: int = 15
@export_range(0.05, 1.0, 0.05) var tolerancia_meio_dia: float = 0.5
var minutos: float = 180.0
var compartimento_aberto: bool = false
var cartao_disponivel: bool = false

func _ready() -> void:
	GlobalSingleton.registrar_cena_atual(scene_file_path)
	Objetos.salvar_objetos(BACKUP.item_name, BACKUP.resource_path,
		Objetos.pos_para_json(589, 180), name, "compartimento_cuco")
	iniciar_itens_cena(name, Objetos.get_objetos_cena(name))
	minutos = fposmod(float(Progresso.carregar("cuco_minutos", minutos_iniciais)), 720.0)
	compartimento_aberto = bool(Progresso.carregar("cuco_compartimento_aberto", false))
	if compartimento_aberto:
		minutos = 0.0
	for info in Objetos.get_objetos_container(name, "compartimento_cuco"):
		if info.item.resource_path == BACKUP.resource_path:
			cartao_disponivel = true
	$Arte/AreaCartao.input_event.connect(_clicar_cartao)
	_atualizar_visual()

func avancar_minutos(quantidade: float, persistir: bool = true) -> void:
	if compartimento_aberto:
		return
	var seguinte: float = minutos + quantidade
	var cruzou_meio_dia: bool = (quantidade > 0 and seguinte >= 720.0) or (quantidade < 0 and seguinte <= 0.0)
	minutos = fposmod(seguinte, 720.0)
	if cruzou_meio_dia or minf(minutos, 720.0 - minutos) <= tolerancia_meio_dia:
		minutos = 0.0
		compartimento_aberto = true
		Progresso.salvar("cuco_compartimento_aberto", true)
		$SomCuco.play(2.75)
		persistir = true
	_atualizar_visual()
	if persistir:
		_salvar_ponteiros()

func _atualizar_visual() -> void:
	$Arte/PonteiroMinutos.rotation = fposmod(minutos, 60.0) / 60.0 * TAU
	$Arte/PonteiroHoras.rotation = minutos / 720.0 * TAU
	$Arte/Relogio.texture = FECHADO if not compartimento_aberto else (ABERTO_COM_CARTAO if cartao_disponivel else ABERTO_SEM_CARTAO)
	$Arte/AreaCartao.input_pickable = compartimento_aberto and cartao_disponivel

func clicar_mostrador(posicao_global: Vector2) -> bool:
	if compartimento_aberto:
		return false
	var relativa: Vector2 = $Arte.to_local(posicao_global) - CENTRO
	if relativa.length() > 125.0:
		return false
	avancar_minutos(float(minutos_por_clique))
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if clicar_mostrador(get_global_mouse_position()):
			get_viewport().set_input_as_handled()

func _salvar_ponteiros() -> void:
	Progresso.salvar("cuco_minutos", minutos)

func coletar_cartao() -> bool:
	if not compartimento_aberto or not cartao_disponivel:
		return false
	var inventario = get_tree().get_first_node_in_group("world_drop_area")
	if inventario == null or not inventario.guardar_no_inventario(BACKUP):
		return false
	Objetos.marcar_coletado_por_recurso(BACKUP.resource_path)
	cartao_disponivel = false
	_atualizar_visual()
	return true

func _clicar_cartao(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		coletar_cartao()
		get_viewport().set_input_as_handled()
