extends SceneTree

var banco
var progresso
var falhas: int = 0
var verificacoes: int = 0

func _initialize() -> void:
	_run.call_deferred()

func conferir(condicao: bool, descricao: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(descricao)

func _run() -> void:
	await process_frame
	banco = root.get_node("Database").db
	progresso = load("res://BDD/Progresso.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	# A tela de e-mails restaura a descoberta quando já foi concluída.
	# Isolar também esse estado para testar a condição anterior à descoberta.
	progresso.salvar("emails_concluidos", false)
	progresso.salvar("secreto_dat_desbloqueado", false)
	progresso.salvar("secreto_dat_decifrado", false)
	var tela = load("res://scenes/fase1/sub_viewport_container.tscn").instantiate()
	root.add_child(tela)
	await process_frame
	var paginas = tela.get_node("SubViewport/pcControl/Telas")
	var pasta = paginas.get_node("Tela_Pastas")
	var secreto = paginas.get_node("Arquivo_DAT")
	conferir(not secreto.abrir(pasta), "Arquivo indisponível antes da descoberta")
	conferir(not pasta.get_node("Tela/Secreto").visible, "Ícone oculto antes da descoberta")
	progresso.salvar("secreto_dat_desbloqueado", true)
	pasta.show()
	pasta._atualizar_secreto()
	conferir(pasta.get_node("Tela/Secreto").visible, "Ícone disponível após descoberta")
	pasta.get_node("Tela/Secreto").pressed.emit()
	conferir(secreto.visible and not pasta.visible, "Abertura pelo ícone")
	secreto.decifrar()
	conferir(secreto.status.text.contains("Preencha"), "Chave vazia")
	secreto.campo.text = "123"
	secreto.decifrar()
	conferir(secreto.status.text.contains("apenas letras"), "Formato inválido")
	secreto.campo.text = "ERRADA"
	secreto.decifrar()
	conferir(not secreto.recuperado, "Chave incorreta não revela conteúdo")
	conferir(not bool(progresso.carregar("secreto_dat_decifrado", false)), "Erro não persiste sucesso")
	secreto.campo.text = "GWJK"
	secreto.decifrar()
	secreto.fechar()
	await create_timer(1.2).timeout
	conferir(not bool(progresso.carregar("secreto_dat_decifrado", false)), "Fechar cancela decifragem pendente")
	secreto.abrir(pasta)
	secreto.campo.text = " gwjk "
	secreto.campo.text_submitted.emit(secreto.campo.text)
	conferir(secreto.decifrando, "Enter inicia animação")
	await create_timer(1.2).timeout
	conferir(secreto.recuperado, "Chave correta recupera documento")
	var esperado = load("res://scripts/criptografia/vigenere.gd").normalizar(FileAccess.get_file_as_string("res://conteudo/secreto_fonte.txt").strip_edges())
	conferir(secreto.get_node("Coluna/Mensagem").text == esperado, "Conteúdo exibido é a decifragem real")
	conferir(esperado.contains("24091998"), "Documento contém senha do ZIP")
	conferir(bool(progresso.carregar("secreto_dat_decifrado", false)), "Sucesso salvo no SQLite")
	conferir(progresso.carregar("secreto_dat_chave", "") == "GWJK", "Chave normalizada persistida")
	secreto.fechar()
	secreto.abrir(pasta)
	conferir(secreto.recuperado and not secreto.decifrando, "Releitura imediata")
	tela.queue_free()
	await process_frame
	var outra = load("res://scenes/Computador_Telas/arquivo_secreto.tscn").instantiate()
	root.add_child(outra)
	await process_frame
	outra.abrir()
	conferir(outra.recuperado, "Nova instância restaura documento pelo SQLite")
	outra.queue_free()
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso preservado após o teste")
	print("SECRETO: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)

