extends SceneTree

var verificacoes: int = 0
var falhas: int = 0

func _initialize() -> void:
	_run.call_deferred()

func conferir(valor: bool, descricao: String) -> void:
	verificacoes += 1
	if not valor:
		falhas += 1
		push_error(descricao)

func _run() -> void:
	await process_frame
	await process_frame
	var banco = root.get_node("Database").db
	var progresso = load("res://BDD/Progresso.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	progresso.salvar("emails_sorteados", [2, 1, 3, 0])
	progresso.salvar("emails_respostas", {})
	progresso.salvar("emails_lidos", [])
	progresso.salvar("emails_concluidos", false)
	var pc = load("res://scenes/fase1/sub_viewport_container.tscn").instantiate()
	root.add_child(pc)
	await process_frame
	await process_frame
	var tela = pc.get_node("SubViewport/pcControl/Telas/Tela_Email")
	conferir(tela.emails.size() == 6 and tela.sorteados.size() == 6, "Seis e-mails disponíveis inclusive em sorteio antigo")
	conferir(tela.sorteados.slice(0, 4) == [2, 1, 3, 0], "Ordem já salva preservada")
	var imagens = ["03_dados_vazados", "02_senha_alterada", "04_acao_na_conta", "05_compra_urgente", "06_premio_aniversario", "01_fatura_mensal"]
	var classificacao = [true, false, true, true, true, false]
	for i in range(6):
		var email = tela.emails[i]
		conferir(email.imagem.resource_path.ends_with(imagens[i] + ".png"), "Imagem nova associada: " + str(i))
		conferir(email.eh_phishing == classificacao[i], "Classificação pelo conteúdo: " + str(i))
		tela.abrir_email(i)
		conferir(tela.imagem_email.texture == email.imagem and tela.imagem_email.expand_mode == 1 and tela.imagem_email.stretch_mode == 5, "Exibição sem distorção: " + str(i))
		conferir(tela.imagem_email.custom_minimum_size.x <= tela.leitura.size.x, "Imagem nova cabe na largura ao abrir: " + str(i))
		var zoom_anterior: float = tela.zoom_leitura
		tela.get_node("VisualizadorEmail/Mais").pressed.emit()
		conferir(tela.zoom_leitura > zoom_anterior, "Botão amplia leitura: " + str(i))
		tela.get_node("VisualizadorEmail/Ajustar").pressed.emit()
		conferir(tela.imagem_email.custom_minimum_size.x <= tela.leitura.size.x, "Visualização completa cabe na largura: " + str(i))
		conferir(tela.itens_por_email[i].get_node("Label").text == email.titulo_na_caixa, "Assunto na caixa de entrada: " + str(i))
		tela.responder(classificacao[i])
		tela.voltar()
	conferir(not tela.botao_confirmar.disabled, "Seis respostas habilitam confirmação")
	tela.confirmar_classificacoes()
	conferir(tela.concluido and bool(progresso.carregar("emails_concluidos", false)), "Classificação correta conclui puzzle existente")
	pc.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Save preservado após rollback")
	print("EMAILS: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
