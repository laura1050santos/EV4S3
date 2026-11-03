extends SceneTree

var verificacoes: int = 0
var falhas: int = 0

func _initialize() -> void:
	_run.call_deferred()

func conferir(condicao: bool, descricao: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(descricao)

func _run() -> void:
	await process_frame
	await process_frame
	var banco = root.get_node("Database").db
	var progresso = load("res://BDD/Progresso.gd")
	var objetos = load("res://BDD/Objetos.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	var itens_antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	for chave in ["zip_aberto", "registro_excluido_recuperado", "registro_excluido_lido", "mensageiro_pendente", "mensageiro_iniciado", "mensageiro_concluido"]:
		progresso.salvar(chave, false)
	progresso.salvar("mensageiro_indice", 0)
	objetos.salvar_objetos("BACKUP-03", "res://recursos/Backup03.tres", objetos.pos_para_json(589, 180), "ZoomCuco", "compartimento_cuco")
	objetos.marcar_coletado_por_recurso("res://recursos/Backup03.tres")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 3
	global.fases_concluidas = [true, true, false, false]
	global.pc_conectado = true
	var pc = load("res://scenes/fase1/sub_viewport_container.tscn").instantiate()
	root.add_child(pc)
	await process_frame
	await process_frame
	var telas = pc.get_node("SubViewport/pcControl/Telas")
	var zip = telas.get_node("Arquivo_ZIP")
	var recuperador = telas.get_node("Recuperador")
	var registro = telas.get_node("RegistroRecuperado")
	var chat = telas.get_node("Mensageiro")
	var pasta = telas.get_node("Tela_Pastas")
	conferir(not recuperador.abrir(), "Sem ZIP aberto não acessa recuperador")
	conferir(not registro.abrir(), "Registro não abre antes de recuperar")
	conferir(not chat.abrir(), "Mensageiro não abre antecipadamente")
	telas.get_node("Tela_Inicial/menu/Messenger").pressed.emit()
	conferir(chat.visible and not chat.get_node("Corpo/Avancar").visible and not bool(progresso.carregar("mensageiro_iniciado", false)), "Menu abre históricos sem disparar narrativa")
	conferir(chat.get_node("Lateral/Conversas").get_child_count() == 3, "Três conversas da família disponíveis antes do registro")
	conferir(chat.get_node("Lateral/Contato").visible and chat.get_node("Lateral/Contato/Status").text == "Offline", "Contato desconhecido permanece disponível offline antes do gatilho")
	chat.get_node("Lateral/Contato/Abrir").pressed.emit()
	conferir(chat.consulta and chat.get_node("Corpo/Historico/Baloes").get_child_count() == 0 and not chat.get_node("Corpo/Avancar").visible, "Contato offline abre sem revelar mensagens antecipadamente")
	conferir(not bool(progresso.carregar("mensageiro_iniciado", false)), "Consultar contato offline não inicia conversa narrativa")
	for nome in chat.CONVERSAS.HISTORICOS:
		chat.abrir_historico(nome)
		conferir(chat.get_node("Corpo/Historico/Baloes").get_child_count() == chat.CONVERSAS.HISTORICOS[nome].size(), "Histórico completo: " + nome)
		var baloes_familia = chat.get_node("Corpo/Historico/Baloes")
		conferir(baloes_familia.get_child(0).get_child(0) is PanelContainer, "Mensagem do contato à esquerda: " + nome)
		conferir(baloes_familia.get_child(1).get_child(1) is PanelContainer, "Mensagem de Helena à direita: " + nome)
		chat.avancar()
		chat.finalizar()
		conferir(not bool(progresso.carregar("mensageiro_concluido", false)) and not global.fases_concluidas[2], "Ler histórico familiar não conclui fase: " + nome)
		chat.abrir_aplicativo(telas.get_node("Tela_Inicial"))
	chat.get_node("Voltar").pressed.emit()
	conferir(not chat.visible and telas.get_node("Tela_Inicial").visible, "Históricos podem ser fechados")
	conferir(not pasta.get_node("Tela/Recuperados").visible, "Pasta de arquivos recuperados ainda oculta")
	objetos.guardar_em_estacao("res://recursos/Backup03.tres", "leitor_sd_pc")
	conferir(not recuperador.abrir(), "SD antecipado sozinho não libera ferramenta")
	objetos.marcar_coletado_por_recurso("res://recursos/Backup03.tres")
	zip.abrir(pasta)
	zip.get_node("Bloqueado/Senha").text = "24091998"
	zip.tentar_abrir()
	conferir(zip.get_node("Conteudo/Recuperador").text == "recuperador.exe", "ZIP contém programa")
	conferir(zip.imagem.resource_path == "res://assets/computador_telas/foto_cuco_antiga.png", "ZIP usa foto nova do cuco")
	zip.get_node("Conteudo/Recuperador").pressed.emit()
	conferir(recuperador.visible and not zip.visible, "Programa abre pelo ZIP")
	conferir(recuperador.get_node("Corpo/Recuperar").disabled, "Cartão no inventário não equivale a conectado")
	recuperador.recuperar()
	await create_timer(0.1).timeout
	conferir(not bool(progresso.carregar("registro_excluido_recuperado", false)), "Software sem mídia não recupera")
	recuperador.fechar()
	objetos.guardar_em_estacao("res://recursos/Backup03.tres", "leitor_sd_pc")
	zip.get_node("Conteudo/Recuperador").pressed.emit()
	conferir(not recuperador.get_node("Corpo/Recuperar").disabled, "Software e cartão habilitam recuperação")
	recuperador.recuperar()
	conferir(recuperador.recuperando, "Animação de recuperação iniciada")
	recuperador.fechar()
	await create_timer(1.4).timeout
	conferir(not bool(progresso.carregar("registro_excluido_recuperado", false)), "Fechar cancela recuperação sem liberar documento")
	recuperador.abrir(zip)
	recuperador.recuperar()
	objetos.marcar_coletado_por_recurso("res://recursos/Backup03.tres")
	await create_timer(0.6).timeout
	conferir(not bool(progresso.carregar("registro_excluido_recuperado", false)), "Mídia removida impede conclusão")
	recuperador.fechar()
	objetos.guardar_em_estacao("res://recursos/Backup03.tres", "leitor_sd_pc")
	recuperador.abrir(zip)
	recuperador.get_node("Corpo/Recuperar").pressed.emit()
	await create_timer(1.4).timeout
	conferir(bool(progresso.carregar("registro_excluido_recuperado", false)) and recuperador.get_node("Corpo/Progresso").value == 100, "Recuperação concluída persiste e chega a 100%")
	conferir(not bool(progresso.carregar("registro_excluido_lido", false)) and not chat.visible, "Recuperação não equivale a leitura nem abre conversa")
	recuperador.fechar()
	zip.fechar()
	conferir(pasta.get_node("Tela/Recuperados").visible, "Recuperados aparece em Arquivos")
	pasta.get_node("Tela/Recuperados").pressed.emit()
	conferir(telas.get_node("PastaRecuperados").visible, "Abre pasta Recuperados")
	# Um documento longo permite testar fechamento antes de alcançar o final.
	var original = registro.documento
	var longo = original.duplicate()
	longo.texto = "Trecho longo de teste.\n".repeat(200)
	registro.documento = longo
	telas.get_node("PastaRecuperados/Corpo/Registro").pressed.emit()
	await process_frame
	await process_frame
	conferir(registro.visible and not chat.visible, "Abrir registro não dispara conversa")
	registro.fechar()
	conferir(not chat.visible and not bool(progresso.carregar("mensageiro_pendente", false)), "Fechar sem terminar leitura não dispara conversa")
	registro.documento = original
	objetos.marcar_coletado_por_recurso("res://recursos/Backup03.tres")
	telas.get_node("PastaRecuperados/Corpo/Registro").pressed.emit()
	await process_frame
	await process_frame
	conferir(registro.visible, "Documento já recuperado pode ser relido sem SD conectado")
	registro.get_node("Corpo/Texto").get_v_scroll_bar().value = registro.get_node("Corpo/Texto").get_v_scroll_bar().max_value
	registro._verificar_leitura()
	conferir(bool(progresso.carregar("registro_excluido_lido", false)), "Chegar ao fim marca leitura separadamente")
	conferir(not chat.visible, "Ler até fim ainda não abre conversa antes de fechar")
	registro.get_node("Voltar").pressed.emit()
	conferir(chat.visible and bool(progresso.carregar("mensageiro_iniciado", false)), "Fechar depois da leitura inicia mensageiro")
	conferir(chat.get_node("Notificacao").playing, "Primeira mensagem toca notificação")
	conferir(chat.indice == 0 and not global.fases_concluidas[2], "Conversa começa online sem concluir fase")
	for i in range(2):
		chat.get_node("Corpo/Avancar").pressed.emit()
	conferir(chat.get_node("Corpo/Resposta/Texto").text == "Quem é você?" and chat.get_node("Corpo/Avancar").text == "Enviar", "Resposta predefinida aparece antes de enviar")
	chat.get_node("Corpo/Avancar").pressed.emit()
	var baloes = chat.get_node("Corpo/Historico/Baloes")
	conferir(baloes.get_child_count() == 3 and baloes.get_child(2).get_meta("autor") == "Você", "Histórico separa mensagens por autor")
	conferir(baloes.get_child(0).get_child(0) is PanelContainer and baloes.get_child(2).get_child(1) is PanelContainer, "Recebidas à esquerda e enviadas à direita")
	conferir(chat.indice == 3 and int(progresso.carregar("mensageiro_indice", 0)) == 3, "Mensagens e resposta do protagonista persistem")
	chat.get_node("Voltar").pressed.emit()
	conferir(not chat.visible and not bool(progresso.carregar("mensageiro_concluido", false)), "X durante conversa preserva progresso sem concluir a fase")
	telas.get_node("Tela_Inicial/menu/Messenger").pressed.emit()
	conferir(chat.visible and chat.indice == 3, "Aba da barra retoma conversa no ponto salvo")
	chat.abrir_historico("Lucas")
	chat.avancar()
	conferir(int(progresso.carregar("mensageiro_indice", 0)) == 3, "Histórico familiar não avança conversa pendente")
	chat.get_node("Lateral/Contato/Abrir").pressed.emit()
	conferir(not chat.consulta and chat.indice == 3 and chat.get_node("Corpo/Avancar").visible, "Contato desconhecido retoma conversa após ler família")
	chat.finalizar()
	conferir(not bool(progresso.carregar("mensageiro_concluido", false)), "Não conclui conversa antes da última mensagem")
	pc.queue_free()
	await process_frame
	pc = load("res://scenes/fase1/sub_viewport_container.tscn").instantiate()
	root.add_child(pc)
	await process_frame
	await process_frame
	telas = pc.get_node("SubViewport/pcControl/Telas")
	chat = telas.get_node("Mensageiro")
	conferir(chat.visible and chat.indice == 3, "Interrupção retoma conversa no computador")
	conferir(not chat.get_node("Notificacao").playing, "Retomada não repete primeira notificação")
	for i in range(5):
		chat.avancar()
	conferir(chat.get_node("Corpo/Estado").text.contains("offline") and not chat.get_node("Voltar").disabled, "Contato fica offline ao fim do diálogo")
	var sinais: Array = [0]
	chat.conversa_concluida.connect(func(): sinais[0] += 1)
	chat.get_node("Corpo/Avancar").pressed.emit()
	conferir(bool(progresso.carregar("mensageiro_concluido", false)) and not bool(progresso.carregar("mensageiro_pendente", true)), "Conclusão da conversa salva e encerra pendência")
	conferir(sinais[0] == 1 and not chat.visible, "Emite conclusão uma única vez")
	registro = telas.get_node("RegistroRecuperado")
	registro.abrir(telas.get_node("Tela_Inicial"))
	await process_frame
	registro.fechar()
	conferir(not chat.visible and not chat.abrir(), "Reabrir e fechar registro não repete conversa concluída")
	telas.get_node("Tela_Inicial/menu/Messenger").pressed.emit()
	conferir(chat.visible and chat.indice == 8 and not chat.get_node("Corpo/Avancar").visible, "Barra permite reler histórico concluído sem repetir sequência")
	chat.get_node("Voltar").pressed.emit()
	conferir(not chat.visible and sinais[0] == 1, "Fechar histórico não emite nova conclusão")
	conferir(global.fase_liberada == 4 and global.fases_concluidas[2], "Conversa concluída encerra Fase 3 e libera Fase 4")
	conferir(int(progresso.carregar("fase_liberada", 0)) == 4 and progresso.carregar("fases_concluidas", [])[2], "Conclusão da fase persiste no SQLite")
	conferir(root.get_node("TransicaoFase").em_transicao and root.get_node("TransicaoFase/Label").visible, "Exibe objetivo concluído")
	conferir(global.ultima_cena_por_fase[4] == "res://scenes/fase1/ParedeNorte.tscn", "Fase 4 aponta para a porta existente")
	await create_timer(4.0).timeout
	conferir(current_scene != null and current_scene.scene_file_path == "res://scenes/telaInicial/selecao_fases.tscn", "Transição chega à seleção de fases")
	pc.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Partida original preservada após testes")
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	conferir(itens_antes == banco.get_query_result(), "Itens originais preservados após testes")
	print("RECUPERACAO: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
