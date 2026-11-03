extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var mala_sprite: TextureRect = $RecorteMala/Malagrande
@onready var cenario_fechado: Sprite2D = $CenarioFechado
@onready var ponto_roteador: Node2D = $pontoroteador
@onready var som_abrindo_mala: AudioStreamPlayer2D = $AudioListener2D/SomAbrindoMala

var mala_aberta: bool = false
const ID_ROTEADOR := "res://recursos/roteador.tres"
const ID_CHAVE := "res://recursos/ChaveMala.tres"
const IMAGEM_MALA_ABERTA := "res://assets/cenarios/maletazoomaberta.png"
const ROTEADOR_NA_MALA = preload("res://assets/itens/roteadornamala.png")

func _ready():
	GlobalSingleton.registrar_cena_atual(scene_file_path)
	var nome_desta_cena = self.name # O nome do nó raiz desta cena
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	# Compatibilidade com partidas em que o roteador já havia sido retirado.
	var aberta_anteriormente: bool = GlobalSingleton.roteador_coletado or GlobalSingleton.roteador_instalado
	for info in objetos:
		if info["item"].resource_path == ID_ROTEADOR:
			aberta_anteriormente = true
	mala_aberta = GlobalSingleton.fase_liberada >= 2 and (bool(Progresso.carregar("mala_aberta", false)) or aberta_anteriormente)
	_atualizar_visual()
	var itens_visiveis: Array = objetos.filter(func(info): return mala_aberta or info["item"].resource_path != ID_ROTEADOR)
	iniciar_itens_cena(name, itens_visiveis)
	for info in itens_visiveis:
		if info["item"].resource_path == ID_ROTEADOR and info["pos"].distance_to(ponto_roteador.position) < 1.0:
			_ajustar_roteador_na_mala(get_node_or_null("roteador"))


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if mala_aberta:
		return
	var drop_area = get_tree().get_first_node_in_group("world_drop_area")
	if drop_area != null and drop_area.inventario_possui_item(load(ID_CHAVE)):
		_abrir_com_chave()

func receber_item_drop(item: itemData, alvo: Area2D) -> bool:
	if item == null or item.resource_path != ID_CHAVE or alvo != $Area2D:
		return false
	return _abrir_com_chave()

func _abrir_com_chave() -> bool:
	if GlobalSingleton.fase_liberada < 2 or mala_aberta:
		return false
	mala_aberta = true
	som_abrindo_mala.play()
	Progresso.salvar("mala_aberta", true)
	Objetos.marcar_instalado_por_recurso(ID_CHAVE)
	var drop_area = get_tree().get_first_node_in_group("world_drop_area")
	if drop_area != null:
		drop_area.remover_item_por_recurso(ID_CHAVE)
	if GlobalSingleton.item_mao != null and GlobalSingleton.item_mao.resource_path == ID_CHAVE:
		GlobalSingleton.item_mao = null
	_atualizar_visual()
	if not GlobalSingleton.roteador_coletado and not GlobalSingleton.roteador_instalado:
		_gerar_roteador_no_mundo()
	SaveManager.salvar()
	return true

func _atualizar_visual() -> void:
	cenario_fechado.show()
	$MalaFechada.visible = not mala_aberta
	mala_sprite.visible = mala_aberta
	if mala_aberta:
		mala_sprite.texture = load(IMAGEM_MALA_ABERTA)

# Clique na Mala para abrir
func _gerar_roteador_no_mundo() -> void:
	var recurso_roteador = load(ID_ROTEADOR)
	var posicao := ponto_roteador.global_position
	var registro = Objetos.get_por_recurso(ID_ROTEADOR)
	if registro == null:
		Objetos.salvar_objetos("roteador", ID_ROTEADOR,
			Objetos.pos_para_json(int(posicao.x), int(posicao.y)), name)
	else:
		if int(registro["coletado"]) != 0:
			return
		Objetos.soltar_por_recurso(ID_ROTEADOR, posicao, name)
	_ajustar_roteador_na_mala(spawnar_itens(recurso_roteador, posicao))

func _ajustar_roteador_na_mala(visual: Sprite2D) -> void:
	if visual == null:
		return
	visual.texture = ROTEADOR_NA_MALA
	visual.position = Vector2(610, 500)
	visual.scale = Vector2(0.65, 0.65)
	var colisao: CollisionShape2D = visual.get_node("Area2D/CollisionShape2D")
	var forma := RectangleShape2D.new()
	forma.size = Vector2(344, 315)
	colisao.shape = forma
	colisao.position = Vector2(-81, -17.5)
