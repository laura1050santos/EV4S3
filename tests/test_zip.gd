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
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	progresso.salvar("zip_aberto", false)
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 3
	global.fases_concluidas = [true, true, false, false]
	global.pc_conectado = true
	var computador = load("res://scenes/fase1/sub_viewport_container.tscn").instantiate()
	root.add_child(computador)
	await process_frame
	var telas = computador.get_node("SubViewport/pcControl/Telas")
	var pasta = telas.get_node("Tela_Pastas")
	var zip = telas.get_node("Arquivo_ZIP")
	pasta.show()
	pasta.get_node("Tela/Zip").pressed.emit()
	conferir(zip.visible and not pasta.visible, "Ícone abre arquivo.zip")
	conferir(zip.get_node("Bloqueado").visible and not zip.get_node("Conteudo").visible, "Conteúdo protegido antes da senha")
	zip.visualizar_imagem()
	conferir(not zip.get_node("VisualizadorArquivo").visible, "Imagem bloqueada antes da senha")
	zip.tentar_abrir()
	conferir(zip.get_node("Bloqueado/Feedback").text.contains("Digite"), "Senha vazia tem retorno")
	zip.get_node("Bloqueado/Senha").text = "00000000"
	zip.get_node("Bloqueado/Abrir").pressed.emit()
	conferir(not zip.desbloqueado and not bool(progresso.carregar("zip_aberto", false)), "Senha incorreta não desbloqueia")
	conferir(zip.get_node("Bloqueado/Feedback").text.contains("incorreta"), "Erro visível para senha incorreta")
	zip.get_node("Bloqueado/Senha").text = " 24091998 "
	zip.get_node("Bloqueado/Senha").text_submitted.emit(" 24091998 ")
	conferir(zip.desbloqueado and zip.get_node("Conteudo").visible and not zip.get_node("Bloqueado").visible, "Enter e senha correta abrem conteúdo")
	conferir(bool(progresso.carregar("zip_aberto", false)), "ZIP aberto persiste no SQLite")
	zip.get_node("Conteudo/Imagem").pressed.emit()
	var visualizador = zip.get_node("VisualizadorArquivo")
	conferir(visualizador.visible and visualizador.get_node("Titulo").text.contains("imagem.png"), "Arquivo interno abre no visualizador existente")
	var textura = visualizador.get_node("Imagem").texture
	conferir(textura.resource_path == "res://assets/computador_telas/foto_cuco_antiga.png", "Imagem usa nova foto do relógio às 12h")
	conferir(textura.get_image() != null, "Imagem interna possui pixels carregados")
	visualizador.get_node("Voltar").pressed.emit()
	conferir(not visualizador.visible and zip.get_node("Conteudo").visible, "Voltar da imagem mantém ZIP aberto")
	zip.get_node("Voltar").pressed.emit()
	conferir(not zip.visible and pasta.visible, "Voltar ao programa Arquivos")
	pasta.get_node("Tela/Zip").pressed.emit()
	conferir(zip.desbloqueado and zip.get_node("Bloqueado/Senha").text.is_empty(), "Reabrir não exige redigitar senha")
	computador.queue_free()
	await process_frame
	var reaberto = load("res://scenes/Computador_Telas/arquivo_zip.tscn").instantiate()
	root.add_child(reaberto)
	reaberto.abrir()
	conferir(reaberto.desbloqueado and reaberto.get_node("Conteudo").visible, "Nova instância restaura abertura pelo SQLite")
	conferir(global.fase_liberada == 3 and not global.fases_concluidas[2], "Abrir ZIP não conclui Fase 3")
	reaberto.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso original preservado após teste")
	print("ZIP: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
