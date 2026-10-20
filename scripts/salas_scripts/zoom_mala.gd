extends "res://scripts/salas_scripts/salas_manager.gd"

@onready var mala_sprite: Sprite2D = $Malagrande
@onready var ponto_roteador: Node2D = $pontoroteador

var mala_aberta: bool = false
const ID_ROTEADOR := "res://recursos/roteador.tres"
const IMAGEM_MALA_ABERTA := "res://assets/itens/malaAberta.jpeg.jpeg"

func _ready():
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)
	Objetos.garantir_padrao(name)
	var roteador_no_mundo := Objetos.get_objetos_cena(name)
	mala_aberta = GlobalSingleton.roteador_coletado or not roteador_no_mundo.is_empty()
	mala_sprite.texture = load(IMAGEM_MALA_ABERTA if mala_aberta else "res://assets/itens/malagrande.png")
	if not roteador_no_mundo.is_empty():
		iniciar_itens_cena(name, roteador_no_mundo)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if mala_aberta:
		return

	mala_aberta = true
	mala_sprite.texture = load(IMAGEM_MALA_ABERTA)
	if not GlobalSingleton.roteador_coletado:
		_gerar_roteador_no_mundo()
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
