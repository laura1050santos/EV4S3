extends "res://scripts/salas_scripts/salas_manager.gd"


# =========================================================
# IDENTIFICAÇÃO DA CENA NO BANCO
# =========================================================

# Para os objetos, esta cena será SEMPRE identificada pelo mesmo nome no SQLite.
const CENA_ID := "ZoomPc"

# =========================================================
# POSIÇÕES DAS PEÇAS INSTALADAS
# =========================================================

const POS_GPU := Vector2(406, 377)
const POS_PROCESSADOR := Vector2(524, 395)
const POS_PLACA_MAE := Vector2(362, 366)

# =========================================================
# RECURSOS
# =========================================================

const RECURSO_GPU := "res://recursos/gpu.tres"
const RECURSO_PROCESSADOR := "res://recursos/processador.tres"
const RECURSO_PLACA_MAE := "res://recursos/placaMae.tres"

# =========================================================
# ESTADO DO GABINETE
# =========================================================

var gpu_instalada: bool = false
var processador_instalado: bool = false
var placa_mae_instalada: bool = false

# =========================================================
# MONITOR
# =========================================================

@onready var tela_ligada: Sprite2D = (
	$monitorLigado if has_node("monitorLigado") else null
)


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	# Última cena (global) — usa o path real da cena.
	GlobalSingleton.ultima_cena = get_tree().current_scene.scene_file_path

	# Estado visual do gabinete
	var img_gabinete = Cenarios.get_cena("GabineteAberto")
	if img_gabinete:
		$GabinetePc.texture = load("res://assets/cenarios/pcvazio.png")

	# Registrar cena atual
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)

	# Objetos da cena (banco)
	Objetos.garantir_padrao(CENA_ID)
	var objetos = Objetos.get_objetos_cena(CENA_ID)
	print("Objetos encontrados no ZoomPc: ", objetos)

	# Restaurar estado das peças e spawnar itens
	_restaurar_estado_gabinete(objetos)
	iniciar_itens_cena(CENA_ID, objetos)

	# Tela e verificação de fase
	atualizar_estado_da_tela()
	_verificar_conclusao_gabinete()


# =========================================================
# RESTAURAR PEÇAS INSTALADAS
# =========================================================

func _restaurar_estado_gabinete(objetos: Array) -> void:
	gpu_instalada = false
	processador_instalado = false
	placa_mae_instalada = false

	for info in objetos:
		if not info.has("nome") or not info.has("pos"):
			continue

		var nome := str(info["nome"])
		var posicao: Vector2 = info["pos"]

		match nome:
			"gpu":
				if posicao.distance_to(POS_GPU) < 2.0:
					gpu_instalada = true
			"processador":
				if posicao.distance_to(POS_PROCESSADOR) < 2.0:
					processador_instalado = true
			"placa mae":
				if posicao.distance_to(POS_PLACA_MAE) < 2.0:
					placa_mae_instalada = true

	print("Estado restaurado | GPU: ", gpu_instalada,
		" | Processador: ", processador_instalado,
		" | Placa mãe: ", placa_mae_instalada)


# =========================================================
# ABRIR GABINETE
# =========================================================

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var chave = get_node_or_null("chave")
		if chave:
			$GabinetePc.texture = load("res://assets/cenarios/pcvazio.png")
			Cenarios.salvar_cenarios("GabineteAberto", "res://assets/cenarios/pcvazio.png")


# =========================================================
# GPU / PROCESSADOR / PLACA MÃE
# =========================================================

func _on_slot_gpu_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent()
	if not objeto_detectado is Sprite2D:
		return
	if not _objeto_tem_recurso(objeto_detectado, RECURSO_GPU):
		return

	objeto_detectado.global_position = POS_GPU
	Objetos.atualizar_objeto("gpu", RECURSO_GPU,
		Objetos.pos_para_json(int(POS_GPU.x), int(POS_GPU.y)), CENA_ID)

	gpu_instalada = true
	print("GPU instalada.")
	_verificar_conclusao_gabinete()


func _on_slot_processador_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent()
	if not objeto_detectado is Sprite2D:
		return
	if not _objeto_tem_recurso(objeto_detectado, RECURSO_PROCESSADOR):
		return

	objeto_detectado.global_position = POS_PROCESSADOR
	Objetos.atualizar_objeto("processador", RECURSO_PROCESSADOR,
		Objetos.pos_para_json(int(POS_PROCESSADOR.x), int(POS_PROCESSADOR.y)), CENA_ID)

	processador_instalado = true
	print("Processador instalado.")
	_verificar_conclusao_gabinete()


func _on_slot_placa_mae_area_entered(area: Area2D) -> void:
	var objeto_detectado = area.get_parent()
	if not objeto_detectado is Sprite2D:
		return
	if not _objeto_tem_recurso(objeto_detectado, RECURSO_PLACA_MAE):
		return

	objeto_detectado.global_position = POS_PLACA_MAE
	Objetos.atualizar_objeto("placa mae", RECURSO_PLACA_MAE,
		Objetos.pos_para_json(int(POS_PLACA_MAE.x), int(POS_PLACA_MAE.y)), CENA_ID)

	placa_mae_instalada = true
	print("Placa mãe instalada.")
	_verificar_conclusao_gabinete()


# =========================================================
# IDENTIFICAR ITEM PELO RESOURCE
# =========================================================

func _objeto_tem_recurso(objeto: Node, caminho_recurso: String) -> bool:
	if not objeto.has_meta("item_data"):
		return false
	var item = objeto.get_meta("item_data")
	if item == null:
		return false
	return item.resource_path == caminho_recurso


# =========================================================
# CONCLUSÃO DO GABINETE
# =========================================================

func _verificar_conclusao_gabinete() -> void:
	if not gpu_instalada or not processador_instalado or not placa_mae_instalada:
		return

	print("Gabinete completo! Concluindo Fase 1 e liberando Fase 2...")
	GlobalSingleton.ultima_cena_por_fase[2] = "res://scenes/quarto/sala_computador.tscn"
	GlobalSingleton.concluir_fase(1)


# =========================================================
# MONITOR
# =========================================================

func atualizar_estado_da_tela() -> void:
	if tela_ligada == null:
		print("Nota: o nó 'monitorLigado' não existe na cena zoom_pc.tscn.")
		return

	if GlobalSingleton.fase_liberada >= 2:
		tela_ligada.visible = true
		print("Fase 2+: Computador ligado (Sem Conexão).")
	else:
		tela_ligada.visible = false
		print("Fase 1: Computador desligado.")
