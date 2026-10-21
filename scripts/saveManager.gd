extends Node


# =========================================================
# SALVAR
# =========================================================

func salvar() -> void:
	itemData.desativar_item_global(get_tree())	
	var cena_atual = get_tree().current_scene
	if cena_atual != null:
		if not cena_atual.scene_file_path.is_empty():
			GlobalSingleton.ultima_cena = cena_atual.scene_file_path

	# Progresso geral
	Progresso.marcar_partida_criada()

	Progresso.salvar("ultima_cena", GlobalSingleton.ultima_cena)
	Progresso.salvar("lixeiraAberta", GlobalSingleton.lixeiraAberta)
	Progresso.salvar("gavetas",GlobalSingleton.gavetas)
	Progresso.salvar("fase_liberada", GlobalSingleton.fase_liberada)
	Progresso.salvar("fases_concluidas", GlobalSingleton.fases_concluidas)
	Progresso.salvar("pc_conectado", GlobalSingleton.pc_conectado)
	Progresso.salvar("lampada_ligada", GlobalSingleton.lampada_ligada)
	Progresso.salvar("roteador_coletado", GlobalSingleton.roteador_coletado)
	Progresso.salvar("roteador_instalado", GlobalSingleton.roteador_instalado)
	Progresso.salvar("cont_enigma_som", GlobalSingleton.cont_enigma_som)
	Progresso.salvar("ultima_cena_por_fase", GlobalSingleton.ultima_cena_por_fase)
	Progresso.salvar("cenas_visitadas", GlobalSingleton.cenas_visitadas)
	Progresso.salvar("historico_cenas", GlobalSingleton.historico_cenas)

	print("Partida salva no SQLite.")


# =========================================================
# CARREGAR
# =========================================================

func carregar() -> void:
	if not Progresso.existe_partida():
		print("Nenhuma partida encontrada no SQLite.")
		return

	Inventario.get_node("canvasLayer").show()

	GlobalSingleton.ultima_cena = Progresso.carregar("ultima_cena", "")
	
	var gavetas_salvas = Progresso.carregar("gavetas",{})
	GlobalSingleton.gavetas = {
	"leste": {"1": false, "2": false, "3": false},
	"sul":   {"1": false, "2": false, "3": false}
	}

	if gavetas_salvas is Dictionary:
		for sala in gavetas_salvas.keys():
			if not GlobalSingleton.gavetas.has(sala):
				GlobalSingleton.gavetas[sala] = {}

			var gavetas_da_sala = gavetas_salvas[sala]
			if not (gavetas_da_sala is Dictionary):
				continue

			for gaveta_id in gavetas_da_sala.keys():
				GlobalSingleton.gavetas[sala][str(gaveta_id)] = bool(gavetas_da_sala[gaveta_id])
	
	GlobalSingleton.lixeiraAberta = Progresso.carregar("lixeiraAberta", false)
	GlobalSingleton.fase_liberada = int(Progresso.carregar("fase_liberada", 1))

	var fases = Progresso.carregar("fases_concluidas", [false, false, false, false])
	GlobalSingleton.fases_concluidas = fases

	GlobalSingleton.pc_conectado = Progresso.carregar("pc_conectado", false)
	GlobalSingleton.lampada_ligada = bool(Progresso.carregar("lampada_ligada", true))
	GlobalSingleton.roteador_coletado = Progresso.carregar("roteador_coletado", false)
	GlobalSingleton.roteador_instalado = Progresso.carregar("roteador_instalado", false)
	GlobalSingleton.cont_enigma_som = int(Progresso.carregar("cont_enigma_som", 0))

	# Cenas visitadas
	var cenas = Progresso.carregar("cenas_visitadas", [])
	GlobalSingleton.cenas_visitadas.clear()
	for cena in cenas:
		GlobalSingleton.cenas_visitadas.append(str(cena))

	# Histórico
	var historico = Progresso.carregar("historico_cenas", [])
	GlobalSingleton.historico_cenas.clear()
	for cena in historico:
		GlobalSingleton.historico_cenas.append(str(cena))

	# Última cena por fase
	# JSON transforma chaves numéricas em String!
	var salvo_por_fase = Progresso.carregar("ultima_cena_por_fase", {})
	GlobalSingleton.ultima_cena_por_fase = {
		1: "res://scenes/fase1/zoom_pc.tscn",
		2: "res://scenes/fase1/ParedeNorte.tscn",
		3: "",
		4: ""
	}
	if salvo_por_fase is Dictionary:
		for chave in salvo_por_fase.keys():
			var numero := int(chave)
			var caminho_salvo := str(salvo_por_fase[chave])
			if ResourceLoader.exists(caminho_salvo):
				GlobalSingleton.ultima_cena_por_fase[numero] = caminho_salvo
			elif numero == 2:
				GlobalSingleton.ultima_cena_por_fase[numero] = "res://scenes/fase1/ParedeNorte.tscn"

	# Restauramento do inventário
	var drop_area = Inventario.get_node("WordDropArea")
	drop_area.carregar_inventario_do_banco()

	Inventario.get_node("canvasLayer").show()

	# Ir para a cena salva
	if GlobalSingleton.ultima_cena.is_empty():
		push_warning("A partida existe, mas não possui última cena.")
		return

	print("Carregando partida SQLite: ", GlobalSingleton.ultima_cena)

	var erro = get_tree().change_scene_to_file(GlobalSingleton.ultima_cena)
	if erro != OK:
		push_error("Não foi possível carregar a cena salva.")


# =========================================================
# NOVO JOGO
# =========================================================

func novo_jogo() -> void:
	print("=== NOVO JOGO ===")

	var drop_area = Inventario.get_node("WordDropArea")
	drop_area.limpar_inventario()

	Database.novo_jogo()
	Progresso.salvar("emails_sorteados", [])
	Progresso.salvar("emails_respostas", {})
	Progresso.salvar("emails_concluidos", false)
	Progresso.salvar("emails_lidos", [])
	resetar_global()
	Progresso.marcar_partida_criada()
	salvar()


# =========================================================
# RESET DO GLOBAL
# =========================================================

func resetar_global() -> void:
	GlobalSingleton.ultima_cena = "res://scenes/fase1/zoom_pc.tscn"

	GlobalSingleton.itens_no_mundo.clear()
	GlobalSingleton.cenas_visitadas.clear()
	GlobalSingleton.historico_cenas.clear()

	GlobalSingleton.item_mao = null

	GlobalSingleton.gavetas = {
		"leste": {"1": false,"2": false,"3": false},
		"sul": {"1": false,"2": false,"3": false}
	}

	GlobalSingleton.lixeiraAberta = false
	GlobalSingleton.cont_enigma_som = 0

	GlobalSingleton.roteador_coletado = false
	GlobalSingleton.roteador_instalado = false

	GlobalSingleton.fase_liberada = 1
	GlobalSingleton.fases_concluidas = [false, false, false, false]

	GlobalSingleton.pc_conectado = false
	GlobalSingleton.lampada_ligada = true

	GlobalSingleton.ultima_cena_por_fase = {
		1: "res://scenes/fase1/zoom_pc.tscn",
		2: "res://scenes/fase1/ParedeNorte.tscn",
		3: "",
		4: ""
	}
