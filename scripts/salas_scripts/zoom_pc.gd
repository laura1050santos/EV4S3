extends "res://scripts/salas_scripts/salas_manager.gd"


# =========================================================
# IDENTIFICAÇÃO DA CENA NO BANCO
# =========================================================

const CENA_ID := "ZoomPc"

# =========================================================
# POSIÇÕES DAS PEÇAS INSTALADAS
# =========================================================

const POS_GPU := Vector2(655.96576, 276.35736)
const POS_PROCESSADOR := Vector2(530.5, 399.5)
const POS_PLACA_MAE := Vector2(632.3792, 166.3087)
const POS_GPU_ANTIGA := Vector2(406, 377)
const POS_PROCESSADOR_ANTIGA := Vector2(524, 395)
const POS_PLACA_MAE_ANTIGA := Vector2(362, 366)

# =========================================================
# RECURSOS
# =========================================================

const RECURSO_GPU := "res://recursos/gpu.tres"
const RECURSO_PROCESSADOR := "res://recursos/processador.tres"
const RECURSO_PLACA_MAE := "res://recursos/placaMae.tres"
const VISUAIS_INSTALADOS := {
	"gpu": preload("res://assets/itens/GPU_Feito.png"),
	"processador": preload("res://assets/itens/Processador_Feito.png"),
	"placa mae": preload("res://assets/itens/PlacaMae_Feito.png")
}

# =========================================================
# ESTADO DO GABINETE
# =========================================================

var gpu_instalada: bool = false
var processador_instalado: bool = false
var placa_mae_instalada: bool = false
var gabinete_aberto: bool = false

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
	_definir_gabinete_aberto(img_gabinete != null, false)

	# Registrar cena atual
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)

	# Objetos da cena (banco)
	Objetos.garantir_padrao(CENA_ID)
	var objetos = Objetos.get_objetos_cena(CENA_ID)
	print("Objetos encontrados no ZoomPc: ", objetos)

	# Restaurar estado das peças e spawnar itens
	_restaurar_estado_gabinete(objetos)
	var itens_soltos: Array = objetos.filter(func(info):
		var nome := str(info["nome"])
		return not ((nome == "gpu" and gpu_instalada)
			or (nome == "processador" and processador_instalado)
			or (nome == "placa mae" and placa_mae_instalada))
	)
	iniciar_itens_cena(CENA_ID, itens_soltos)

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

		var posicao_correta := Vector2.ZERO
		var posicao_antiga := Vector2.ZERO
		match nome:
			"gpu":
				posicao_correta = POS_GPU
				posicao_antiga = POS_GPU_ANTIGA
			"processador":
				posicao_correta = POS_PROCESSADOR
				posicao_antiga = POS_PROCESSADOR_ANTIGA
			"placa mae":
				posicao_correta = POS_PLACA_MAE
				posicao_antiga = POS_PLACA_MAE_ANTIGA
			_:
				continue

		if posicao.distance_to(posicao_correta) < 2.0:
			_marcar_componente_instalado(nome)
		elif posicao.distance_to(posicao_antiga) < 2.0:
			# Migra peças encaixadas pelo posicionamento da versão anterior.
			Objetos.atualizar_objeto(
				nome,
				info["item"].resource_path,
				Objetos.pos_para_json(int(posicao_correta.x), int(posicao_correta.y)),
				CENA_ID
			)
			info["pos"] = posicao_correta
			_marcar_componente_instalado(nome)

	print("Estado restaurado | GPU: ", gpu_instalada,
		" | Processador: ", processador_instalado,
		" | Placa mãe: ", placa_mae_instalada)


# =========================================================
# ABRIR GABINETE
# =========================================================

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if gabinete_aberto:
			return
		var chave = get_node_or_null("chave")
		var item_mao: itemData = GlobalSingleton.item_mao
		if (chave != null and _objeto_tem_recurso(chave, "res://recursos/chaveDeFenda.tres")) or (item_mao != null and item_mao.resource_path == "res://recursos/chaveDeFenda.tres"):
			_definir_gabinete_aberto(true)

func _definir_gabinete_aberto(aberto: bool, persistir: bool = true) -> void:
	gabinete_aberto = aberto
	$GabinetePc.texture = load("res://assets/cenarios/pcvazio.png" if aberto else "res://assets/cenarios/pcfechado.png")
	for visual in $GabinetePc.get_children():
		if visual is Sprite2D and str(visual.name).begins_with("Instalado_"):
			visual.visible = aberto
	for nome_slot in ["slotGPU", "slotProcessador", "slotPlacaMae"]:
		get_node(nome_slot).set_deferred("monitoring", aberto)
		get_node(nome_slot).set_deferred("monitorable", aberto)
	if not persistir:
		return
	if aberto:
		if Cenarios.get_cena("GabineteAberto") == null:
			Cenarios.salvar_cenarios("GabineteAberto", "res://assets/cenarios/pcvazio.png")
	else:
		Cenarios.delete_cena("GabineteAberto")


# =========================================================
# GPU / PROCESSADOR / PLACA MÃE
# =========================================================

func _on_slot_gpu_area_entered(area: Area2D) -> void:
	_instalar_componente_no_slot(area.get_parent(), "slotGPU")


func _on_slot_processador_area_entered(area: Area2D) -> void:
	_instalar_componente_no_slot(area.get_parent(), "slotProcessador")


func _on_slot_placa_mae_area_entered(area: Area2D) -> void:
	_instalar_componente_no_slot(area.get_parent(), "slotPlacaMae")


func receber_item_drop(item: itemData, slot: Area2D) -> bool:
	if not gabinete_aberto or item == null or not slot.is_in_group("slots_componentes"):
		return false

	var esperado := ""
	match slot.name:
		"slotGPU": esperado = RECURSO_GPU
		"slotProcessador": esperado = RECURSO_PROCESSADOR
		"slotPlacaMae": esperado = RECURSO_PLACA_MAE
		_: return false
	if item.resource_path != esperado:
		return false
	if (
		(slot.name == "slotGPU" and gpu_instalada)
		or (slot.name == "slotProcessador" and processador_instalado)
		or (slot.name == "slotPlacaMae" and placa_mae_instalada)
	):
		return false

	var visual = preload("res://scenes/inventario/worldItem.tscn").instantiate()
	visual.name = item.item_name
	visual.set_meta("item_data", item)
	visual.texture = item.icon
	add_child(visual)
	_instalar_componente_no_slot(visual, slot.name)
	return true


func _instalar_componente_no_slot(objeto: Node, nome_slot: String) -> void:
	if not gabinete_aberto:
		return
	if not objeto is Sprite2D or not objeto.has_meta("item_data"):
		return
	var item: itemData = objeto.get_meta("item_data")
	if item == null:
		return

	var nome_objeto := ""
	var recurso_esperado := ""
	var posicao := Vector2.ZERO
	match nome_slot:
		"slotGPU":
			nome_objeto = "gpu"
			recurso_esperado = RECURSO_GPU
			posicao = POS_GPU
			if gpu_instalada: return
		"slotProcessador":
			nome_objeto = "processador"
			recurso_esperado = RECURSO_PROCESSADOR
			posicao = POS_PROCESSADOR
			if processador_instalado: return
		"slotPlacaMae":
			nome_objeto = "placa mae"
			recurso_esperado = RECURSO_PLACA_MAE
			posicao = POS_PLACA_MAE
			if placa_mae_instalada: return
		_:
			return
	if item.resource_path != recurso_esperado:
		return

	objeto.global_position = posicao
	Objetos.atualizar_objeto(
		nome_objeto,
		recurso_esperado,
		Objetos.pos_para_json(int(posicao.x), int(posicao.y)),
		CENA_ID
	)
	# O drop direto vem do inventário: também precisa persistir como item na cena.
	Objetos.soltar_por_recurso(recurso_esperado, posicao, CENA_ID)
	_marcar_componente_instalado(nome_objeto)
	objeto.hide()
	objeto.queue_free()
	print(item.item_name, " instalado.")
	_verificar_conclusao_gabinete()


func _marcar_componente_instalado(nome_objeto: String) -> void:
	match nome_objeto:
		"gpu": gpu_instalada = true
		"processador": processador_instalado = true
		"placa mae": placa_mae_instalada = true
	_mostrar_componente_instalado(nome_objeto)

func _mostrar_componente_instalado(nome_objeto: String) -> void:
	if not VISUAIS_INSTALADOS.has(nome_objeto):
		return
	var nome_visual := "Instalado_" + nome_objeto.replace(" ", "_")
	if $GabinetePc.has_node(NodePath(nome_visual)):
		return
	# As imagens _Feito usam a mesma tela de 1920x1080 do gabinete.
	# Herdar seu transform mantém a posição, a escala e a perspectiva da arte.
	var visual := Sprite2D.new()
	visual.name = nome_visual
	visual.texture = VISUAIS_INSTALADOS[nome_objeto]
	visual.visible = gabinete_aberto
	visual.z_index = 2 if nome_objeto == "gpu" else (1 if nome_objeto == "processador" else 0)
	$GabinetePc.add_child(visual)


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
	Progresso.salvar("pc_consertado", true)
	_definir_gabinete_aberto(false)
	print("Gabinete completo! Acesse o monitor para iniciar o computador.")


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
