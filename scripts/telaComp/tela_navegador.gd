extends Control

const Artigo = preload("res://scripts/telaComp/artigo_navegador.gd")
@export var artigos: Array[Artigo] = [preload("res://recursos/navegador/vigenere.tres"), preload("res://recursos/navegador/tecnolar.tres"), preload("res://recursos/navegador/vigia_residencial.tres"), preload("res://recursos/navegador/arquivo_lin_barde.tres")]
var site_atual: Control
@onready var barra: LineEdit = $BarraPesquisa
@onready var resultado: Label = $Resultado
@onready var pagina: Control = $PaginaArtigo

func _ready() -> void:
	barra.text_submitted.connect(pesquisar)
	$Button.pressed.connect(func(): pesquisar(barra.text))
	barra.text_changed.connect(func(_texto: String): resultado.hide())
	$PaginaArtigo/Margem/Coluna/Voltar.pressed.connect(voltar_pesquisa)

func normalizar_termo(texto: String) -> String:
	return texto.strip_edges().to_lower()

func pesquisar(texto: String) -> void:
	var termo: String = normalizar_termo(texto)
	if termo.is_empty():
		resultado.text = "Digite um termo para pesquisar."
		resultado.show()
		return
	for artigo in artigos:
		if artigo == null:
			continue
		for alternativa in artigo.termos:
			if termo == normalizar_termo(alternativa):
				abrir_artigo(artigo)
				return
	resultado.text = "Nenhum resultado encontrado."
	resultado.show()

func abrir_artigo(artigo: Artigo) -> void:
	if is_instance_valid(site_atual):
		site_atual.hide()
		site_atual.queue_free()
		site_atual = null
	if artigo.estilo != 0:
		pagina.hide()
		resultado.hide()
		barra.hide()
		$Button.hide()
		site_atual = Control.new()
		site_atual.set_script(preload("res://scripts/telaComp/site_contato.gd"))
		add_child(site_atual)
		site_atual.voltar.connect(voltar_pesquisa)
		site_atual.construir(artigo)
		barra.release_focus()
		return
	$PaginaArtigo/Margem/Coluna/Endereco.text = artigo.endereco
	$PaginaArtigo/Margem/Coluna/Titulo.text = artigo.titulo
	$PaginaArtigo/Margem/Coluna/Conteudo.text = artigo.conteudo
	$PaginaArtigo/Margem/Coluna/Conteudo.scroll_to_line(0)
	resultado.hide()
	barra.hide()
	$Button.hide()
	pagina.show()
	barra.release_focus()
	$PaginaArtigo/Margem/Coluna/Voltar.grab_focus()

func voltar_pesquisa() -> void:
	if is_instance_valid(site_atual):
		site_atual.hide()
		site_atual.queue_free()
		site_atual = null
	pagina.hide()
	barra.show()
	$Button.show()
	resultado.hide()
	barra.grab_focus()
