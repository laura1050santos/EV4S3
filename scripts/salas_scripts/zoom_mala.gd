extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var mala_sprite: Sprite2D = $Malagrande
@onready var ponto_roteador: Node2D = $pontoroteador

var mala_aberta: bool = false
const ID_ROTEADOR := "res://recursos/roteador.tres"
const ID_CHAVE := "res://recursos/ChaveMala.tres"
const IMAGEM_MALA_ABERTA := "res://assets/itens/malaAberta.jpeg.jpeg"

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
	mala_sprite.texture = load(IMAGEM_MALA_ABERTA if mala_aberta else "res://assets/itens/malagrande.png")
	var itens_visiveis: Array = objetos.filter(func(info): return mala_aberta or info["item"].resource_path != ID_ROTEADOR)
	iniciar_itens_cena(name, itens_visiveis)


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
	Progresso.salvar("mala_aberta", true)
	Objetos.marcar_instalado_por_recurso(ID_CHAVE)
	var drop_area = get_tree().get_first_node_in_group("world_drop_area")
	if drop_area != null:
		drop_area.remover_item_por_recurso(ID_CHAVE)
	if GlobalSingleton.item_mao != null and GlobalSingleton.item_mao.resource_path == ID_CHAVE:
		GlobalSingleton.item_mao = null
	mala_sprite.texture = load(IMAGEM_MALA_ABERTA)
	if not GlobalSingleton.roteador_coletado and not GlobalSingleton.roteador_instalado:
		_gerar_roteador_no_mundo()
	SaveManager.salvar()
	return true
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
	spawnar_itens(recurso_roteador, posicao)
