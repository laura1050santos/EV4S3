extends "res://scripts/salas_scripts/salas_manager.gd"

const CHAO_FECHADO = preload("res://assets/cenarios/chao.png")
const CHAO_ABERTO = preload("res://assets/cenarios/chao_aberto.png")

func _ready():
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path

	var nome_desta_cena = self.name
	Objetos.garantir_padrao(nome_desta_cena)

	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	var alcapao = Enigmas.get_nome("alcapao")
	var aberto: bool = alcapao != null and alcapao["resolvido"] == 1

	if not aberto:
		objetos = objetos.filter(func(info): return info["nome"] != "placa mae")

	iniciar_itens_cena(nome_desta_cena, objetos)
	_atualizar_estado_alcapao()

func _atualizar_estado_alcapao() -> void:
	var alcapao = Enigmas.get_nome("alcapao")
	if alcapao == null:
		$Sprite2D.texture = CHAO_FECHADO
		return

	var aberto: bool = alcapao["resolvido"] == 1
	$Sprite2D.texture = CHAO_ABERTO if aberto else CHAO_FECHADO
	$Sprite2D/PainelSenha.visible = not aberto

	if aberto:
		_mostrar_placa_mae()
	else:
		_esconder_placa_mae()

func _mostrar_placa_mae() -> void:
	if has_node("placa mae"):
		return

	var info = Objetos.get_nome("placa mae")
	if info == null:
		return

	if int(info["coletado"]) != 0:
		return

	var recurso = load(info["recurso"])
	var posicao = JSON.parse_string(info["pos"])

	if recurso != null and posicao is Dictionary:
		spawnar_itens(
			recurso,
			Vector2(posicao["x"], posicao["y"])
		)

func _esconder_placa_mae() -> void:
	var placa = get_node_or_null("placa mae")
	if placa != null:
		placa.queue_free()
