extends SceneTree
var verificacoes: int = 0
var falhas: int = 0
func _initialize() -> void:
	_run.call_deferred()
func conferir(valor: bool, mensagem: String) -> void:
	verificacoes += 1
	if not valor:
		falhas += 1
		push_error(mensagem)
func _run() -> void:
	await process_frame
	await process_frame
	var tela = load("res://scenes/Computador_Telas/tela_navegador.tscn").instantiate()
	root.add_child(tela)
	for termo in ["Vigenère", "TecnoLar", "Vigia Residencial", "Arquivo Particular Lin Barde"]:
		tela.pesquisar(termo)
		await process_frame
		await process_frame
		conferir(not tela.resultado.visible, "Pesquisa encontra: " + termo)
		conferir(tela.pagina.visible or is_instance_valid(tela.site_atual), "Resultado abre artigo: " + termo)
		var pagina = tela.pagina if tela.pagina.visible else tela.site_atual
		conferir(pagina.position.y >= 215 and pagina.position.y + pagina.size.y <= 932, "Artigo preserva abas do navegador: " + termo)
		tela.voltar_pesquisa()
		conferir(tela.barra.visible, "Volta à pesquisa: " + termo)
	tela.pesquisar("termo inexistente")
	conferir(tela.resultado.visible, "Termo desconhecido mantém feedback")
	tela.queue_free()
	await process_frame
	print("NAVEGADOR: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
