extends Control

signal voltar

func construir(artigo: Resource) -> void:
	name = "SiteContato"
	position = Vector2(8, 215)
	size = Vector2(1799, 709)
	z_index = 1
	clip_contents = true
	# Reutiliza a mesma cena de leitura do artigo de Vigenère.
	var pagina = preload("res://scenes/Computador_Telas/pagina_artigo.tscn").instantiate()
	add_child(pagina)
	pagina.position = Vector2.ZERO
	pagina.size = size
	pagina.show()
	var coluna = pagina.get_node("Margem/Coluna")
	var botao: Button = coluna.get_node("Voltar")
	botao.pressed.connect(func(): voltar.emit())
	var endereco: Label = coluna.get_node("Endereco")
	var titulo: Label = coluna.get_node("Titulo")
	var conteudo: RichTextLabel = coluna.get_node("Conteudo")
	endereco.text = artigo.endereco
	titulo.text = artigo.titulo
	conteudo.bbcode_enabled = true
	var fundo: Color
	var texto: Color
	var destaque: Color
	var apresentacao: String
	match artigo.estilo:
		1:
			fundo = Color("#f4f8fc")
			texto = Color("#17304b")
			destaque = Color("#247dad")
			apresentacao = "[b]TECNOLOGIA QUE ACOMPANHA A SUA CASA[/b]\nAssistência técnica • Manutenção de rede\n\n[b]Atendimento à família Lin Barde[/b]\n\n"
		2:
			fundo = Color("#111d29")
			texto = Color("#eedbb4")
			destaque = Color("#e5b75f")
			apresentacao = "[b]SEGURANÇA E CONTROLE DE ACESSO[/b]\nProteção • Atendimento residencial • Privacidade\n\n[b]Residência Lin Barde[/b]\n\n"
		_:
			fundo = Color("#f2e9d8")
			texto = Color("#352b28")
			destaque = Color("#743842")
			apresentacao = "[b]UMA FAMÍLIA, MUITOS REGISTROS[/b]\nDocumentação • Fotografias • Registros familiares\n\n[b]Apresentação do acervo[/b]\n\n"
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fundo
	estilo.border_color = destaque
	estilo.border_width_top = 8
	pagina.add_theme_stylebox_override("panel", estilo)
	endereco.add_theme_color_override("font_color", destaque)
	titulo.add_theme_color_override("font_color", destaque)
	conteudo.add_theme_color_override("default_color", texto)
	conteudo.add_theme_font_size_override("bold_font_size", 30)
	conteudo.text = apresentacao + str(artigo.conteudo)
	if artigo.estilo == 3:
		var serifada := SystemFont.new()
		serifada.font_names = PackedStringArray(["Georgia", "Times New Roman"])
		titulo.add_theme_font_override("font", serifada)
