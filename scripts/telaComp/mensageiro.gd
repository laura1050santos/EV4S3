extends Control

signal conversa_concluida
const CONVERSAS = preload("res://conteudo/conversas_familia.gd")
const MENSAGENS: Array[String] = [
	"Desconhecido: Você conseguiu abrir o registro.",
	"Desconhecido: Então já sabe por que está aí.",
	"Você: Quem é você?",
	"Desconhecido: Isso não importa agora.",
	"Desconhecido: O computador alimenta a fechadura, mas não abre a porta sozinho.",
	"Desconhecido: Olhe para o painel ao lado da saída. Com atenção.",
	"Você: Como você sabe disso?",
	"Desconhecido: E não confie em tudo o que leu."
]
var origem: Control
var indice: int = 0
var consulta: bool = false

func _ready() -> void:
	$Voltar.pressed.connect(_fechar_janela)
	$Corpo/Avancar.pressed.connect(avancar)
	$Lateral/Contato/Abrir.pressed.connect(_abrir_contato_desconhecido)
	for nome in CONVERSAS.HISTORICOS:
		var cartao: Panel = $Lateral/Contato.duplicate(0)
		cartao.name = str(nome)
		cartao.position = Vector2.ZERO
		cartao.custom_minimum_size = Vector2(400, 130)
		cartao.get_node("Avatar").text = str(nome).left(1)
		cartao.get_node("Nome").text = str(nome)
		cartao.get_node("Status").text = "Conversa salva"
		var botao: Button = cartao.get_node("Abrir")
		botao.tooltip_text = "Ler conversa com " + str(nome)
		botao.add_to_group("botoes_computador")
		botao.pressed.connect(abrir_historico.bind(str(nome)))
		$Lateral/Conversas.add_child(cartao)
	_atualizar_contato()

func _atualizar_contato() -> void:
	$Lateral/Contato.show()
	var ativo: bool = bool(Progresso.carregar("mensageiro_pendente", false)) and not bool(Progresso.carregar("mensageiro_concluido", false))
	$Lateral/Contato/Status.text = "Online" if ativo else "Offline"
	$Lateral/TituloContatos.text = "CONVERSAS SALVAS"

func _abrir_contato_desconhecido() -> void:
	if abrir(origem):
		return
	consulta = true
	var concluida: bool = bool(Progresso.carregar("mensageiro_concluido", false))
	indice = MENSAGENS.size() if concluida else 0
	_mostrar()
	$Lateral/Contato/Status.text = "Offline"
	$Corpo/Estado.text = "Desconhecido ficou offline." if concluida else "Desconhecido está offline."
	$Corpo/Estado.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	$Corpo/Rodape/Texto.text = "Desconhecido · Offline"
	$Corpo/Resposta/Texto.text = "O contato encerrou a conversa." if concluida else "Nenhuma mensagem recebida."
	$Corpo/Avancar.hide()
	show()

func abrir_historico(nome: String) -> void:
	if not CONVERSAS.HISTORICOS.has(nome):
		return
	consulta = true
	_atualizar_contato()
	$Cabecalho/Titulo.text = "Conversa com " + nome
	$Corpo/Estado.text = "Histórico de conversa"
	$Corpo/Estado.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	$Corpo/Rodape/Texto.text = "Conversa salva · Somente leitura"
	$Corpo/Resposta/Texto.text = "Esta conversa está arquivada."
	$Corpo/Avancar.hide()
	$Voltar.disabled = false
	var mensagens: Array = CONVERSAS.HISTORICOS[nome]
	_montar_historico(mensagens, mensagens.size(), "Helena", false)
	show()

func abrir_aplicativo(tela_origem: Control) -> void:
	if abrir(tela_origem):
		return
	origem = tela_origem
	consulta = true
	var concluida: bool = bool(Progresso.carregar("mensageiro_concluido", false))
	if not concluida:
		if is_instance_valid(origem):
			origem.hide()
		abrir_historico("Augusto")
		return
	indice = MENSAGENS.size() if concluida else 0
	_mostrar()
	$Corpo/Estado.text = "Desconhecido ficou offline." if concluida else "Nenhuma conversa no momento."
	$Lateral/Contato/Status.text = "Offline"
	$Corpo/Rodape/Texto.text = "Desconhecido · Offline"
	$Corpo/Resposta/Texto.text = "O contato encerrou a conversa." if concluida else "Nenhuma mensagem recebida."
	$Corpo/Avancar.hide()
	$Voltar.disabled = false
	origem.hide()
	show()

func _fechar_janela() -> void:
	if consulta or indice < MENSAGENS.size():
		minimizar()
	else:
		finalizar()

func minimizar() -> void:
	hide()
	var desktop := get_parent().get_node_or_null("Tela_Inicial")
	if desktop != null:
		for tela in get_parent().get_children():
			if tela is Control:
				tela.hide()
		desktop.show()
	elif is_instance_valid(origem):
		origem.show()

func abrir(tela_origem: Control = null) -> bool:
	if bool(Progresso.carregar("mensageiro_concluido", false)):
		return false
	if not bool(Progresso.carregar("mensageiro_pendente", false)) or not bool(Progresso.carregar("registro_excluido_recuperado", false)) or not bool(Progresso.carregar("registro_excluido_lido", false)):
		return false
	origem = tela_origem
	consulta = false
	$Corpo/Avancar.show()
	indice = clampi(int(Progresso.carregar("mensageiro_indice", 0)), 0, MENSAGENS.size())
	var primeira_vez: bool = not bool(Progresso.carregar("mensageiro_iniciado", false))
	Progresso.salvar("mensageiro_iniciado", true)
	if is_instance_valid(origem):
		origem.hide()
	_mostrar()
	show()
	$Corpo/Avancar.grab_focus()
	if primeira_vez:
		$Notificacao.play()
	return true

func avancar() -> void:
	if consulta or not is_visible_in_tree() or bool(Progresso.carregar("mensageiro_concluido", false)):
		return
	if indice >= MENSAGENS.size():
		finalizar()
		return
	indice += 1
	Progresso.salvar("mensageiro_indice", indice)
	_mostrar()

func _mostrar() -> void:
	_atualizar_contato()
	$Cabecalho/Titulo.text = "Conversa com Desconhecido"
	var offline: bool = indice >= MENSAGENS.size()
	$Corpo/Estado.text = "Desconhecido ficou offline." if offline else "Desconhecido está online."
	$Corpo/Estado.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4) if offline else Color(0.05, 0.4, 0.16))
	$Lateral/Contato/Status.text = "Offline" if offline else "Online"
	$Corpo/Rodape/Texto.text = "Desconhecido · Offline" if offline else "Desconhecido · Online"
	_montar_historico()
	$Voltar.disabled = false
	var resposta: bool = not offline and MENSAGENS[indice].begins_with("Você: ")
	$Corpo/Resposta/Texto.text = MENSAGENS[indice].trim_prefix("Você: ") if resposta else ("O contato encerrou a conversa." if offline else "Aguardando mensagem…")
	$Corpo/Avancar.text = "Encerrar conversa" if offline else ("Enviar" if resposta else "Continuar")

func _montar_historico(mensagens: Array = MENSAGENS, quantidade: int = -1, autor_enviado: String = "Você", rolar_fim: bool = true) -> void:
	var lista: VBoxContainer = $Corpo/Historico/Baloes
	for filho in lista.get_children():
		lista.remove_child(filho)
		filho.queue_free()
	for numero in range(indice if quantidade < 0 else quantidade):
		var partes: PackedStringArray = str(mensagens[numero]).split(": ", true, 1)
		var enviada: bool = partes[0] == autor_enviado
		var linha := HBoxContainer.new()
		linha.name = "Mensagem_" + str(numero)
		linha.set_meta("autor", partes[0])
		linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lista.add_child(linha)
		var espaco := Control.new()
		espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		espaco.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var balao := PanelContainer.new()
		balao.name = "Balao"
		balao.custom_minimum_size = Vector2(930, 0)
		balao.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.86, 0.95, 1.0) if enviada else Color.WHITE
		estilo.border_color = Color(0.77, 0.83, 0.88)
		estilo.set_border_width_all(1)
		estilo.set_corner_radius_all(12)
		estilo.set_content_margin_all(18)
		balao.add_theme_stylebox_override("panel", estilo)
		if enviada:
			linha.add_child(espaco)
		linha.add_child(balao)
		if not enviada:
			linha.add_child(espaco)
		var coluna := VBoxContainer.new()
		coluna.add_theme_constant_override("separation", 8)
		balao.add_child(coluna)
		var autor := Label.new()
		autor.text = ("Helena" if partes[0] == "Você" else partes[0]) + ":"
		autor.add_theme_font_size_override("font_size", 26)
		autor.add_theme_color_override("font_color", Color(0.08, 0.3, 0.52))
		autor.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coluna.add_child(autor)
		var texto := Label.new()
		texto.text = partes[1]
		texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texto.add_theme_font_size_override("font_size", 30)
		texto.add_theme_color_override("font_color", Color(0.1, 0.12, 0.15))
		texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coluna.add_child(texto)
	if rolar_fim:
		_rolar_ao_fim.call_deferred()
	else:
		_rolar_ao_inicio.call_deferred()

func _rolar_ao_inicio() -> void:
	$Corpo/Historico.scroll_vertical = 0

func _rolar_ao_fim() -> void:
	$Corpo/Historico.scroll_vertical = int($Corpo/Historico.get_v_scroll_bar().max_value)

func finalizar() -> void:
	if consulta:
		minimizar()
		return
	if indice < MENSAGENS.size() or bool(Progresso.carregar("mensageiro_concluido", false)):
		return
	Progresso.salvar("mensageiro_concluido", true)
	Progresso.salvar("mensageiro_pendente", false)
	hide()
	if is_instance_valid(origem):
		origem.show()
	conversa_concluida.emit()
