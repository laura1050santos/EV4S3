extends Control

@export var arquivos: Dictionary = {}
var origem: Control

func _ready() -> void:
	$BotaoFechar.pressed.connect(_fechar_pasta)
	for nome_botao in arquivos:
		var botao: Button = get_node("Tela/" + str(nome_botao))
		var caminho: String = str(arquivos[nome_botao])
		botao.tooltip_text = str(botao.get_meta("nome_arquivo"))
		if caminho.is_empty() or not ResourceLoader.exists(caminho):
			botao.disabled = true
			botao.tooltip_text = "Conteúdo ainda indisponível."
		else:
			botao.pressed.connect(_abrir_arquivo.bind(botao, caminho))

func _abrir_arquivo(botao: Button, caminho: String) -> void:
	$VisualizadorArquivo.abrir(str(botao.get_meta("nome_arquivo")), load(caminho))

func abrir(pasta_origem: Control = null) -> void:
	origem = pasta_origem
	for nome in ["Tela_Pastas", "Pasta_Pessoal", "Pasta_Tecnico"]:
		var outra = get_parent().get_node_or_null(nome)
		if outra != null and outra != self:
			outra.hide()
	$VisualizadorArquivo.hide()
	show()

func _fechar_pasta() -> void:
	hide()
	if is_instance_valid(origem):
		origem.show()
