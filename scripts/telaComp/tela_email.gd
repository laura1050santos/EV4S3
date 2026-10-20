
extends Control

signal todos_classificados

@export var emails: Array[email_data] = []

@onready var lista_inbox: VBoxContainer = $ListaEmails
@onready var visualizador: Control = $VisualizadorEmail
@onready var imagem_email: TextureRect = $VisualizadorEmail/ImagemEmail
@onready var botao_phishing: Button = $VisualizadorEmail/BotaoPhishing
@onready var botao_legitimo: Button = $VisualizadorEmail/BotaoLegitimo
@onready var botao_voltar: Button = $VisualizadorEmail/BotaoVoltar
@onready var botao_confirmar: Button = $BotaoConfirmar
@onready var label_feedback: Label = $VisualizadorEmail/LabelFeedback
@onready var label_status: Label = $LabelStatus

@onready var popup_conclusao: Control = $PopupConclusao

var item_cena = preload("res://scenes/Computador_Telas/item_email.tscn")
var sorteados: Array[int] = []
var respostas: Dictionary = {}
var lidos: Array[int] = []
var itens_por_email: Dictionary = {}
var email_atual_id: int = -1
var concluido: bool = false

func _ready() -> void:
	botao_phishing.pressed.connect(func(): responder(true))
	botao_legitimo.pressed.connect(func(): responder(false))
	botao_voltar.pressed.connect(voltar)
	botao_confirmar.pressed.connect(confirmar_classificacoes)
	todos_classificados.connect(_on_todos_classificados)

	_carregar_progresso()
	_criar_lista()
	voltar()

func _carregar_progresso() -> void:
	var salvos = Progresso.carregar("emails_sorteados", [])
	var respostas_salvas = Progresso.carregar("emails_respostas", {})
	var lidos_salvos = Progresso.carregar("emails_lidos", [])
	concluido = bool(Progresso.carregar("emails_concluidos", false))

	respostas = respostas_salvas if respostas_salvas is Dictionary else {}
	lidos.clear()

	if lidos_salvos is Array:
		for indice in lidos_salvos:
			lidos.append(int(indice))

	if salvos is Array and salvos.size() == 3:
		var validos := true
		for indice in salvos:
			var id = int(indice)
			if id < 0 or id >= emails.size() or sorteados.has(id):
				validos = false
				break
			sorteados.append(id)
		if validos:
			return
		sorteados.clear()

	_sortear_emails()

func _sortear_emails() -> void:
	if emails.size() < 3:
		push_error("Cadastre pelo menos 3 e-mails no Inspector.")
		return

	var phishing: Array[int] = []
	var legitimos: Array[int] = []
	var disponiveis: Array[int] = []

	for i in range(emails.size()):
		disponiveis.append(i)
		if emails[i].eh_phishing:
			phishing.append(i)
		else:
			legitimos.append(i)

	if not phishing.is_empty() and not legitimos.is_empty():
		sorteados.append(phishing.pick_random())
		sorteados.append(legitimos.pick_random())
		disponiveis.erase(sorteados[0])
		disponiveis.erase(sorteados[1])

	disponiveis.shuffle()
	while sorteados.size() < 3:
		sorteados.append(disponiveis.pop_back())

	sorteados.shuffle()
	respostas.clear()
	lidos.clear()
	concluido = false

	Progresso.salvar("emails_sorteados", sorteados)
	Progresso.salvar("emails_respostas", respostas)
	Progresso.salvar("emails_lidos", lidos)
	Progresso.salvar("emails_concluidos", false)

func _criar_lista() -> void:
	for filho in lista_inbox.get_children():
		filho.queue_free()

	itens_por_email.clear()

	for indice in sorteados:
		var email = emails[indice]
		var item: Button = item_cena.instantiate()
		item.get_node("Label").text = email.titulo_na_caixa
		item.pressed.connect(abrir_email.bind(indice))
		lista_inbox.add_child(item)
		itens_por_email[indice] = item
		_atualizar_cor_email(indice)

func _atualizar_cor_email(indice: int) -> void:
	if not itens_por_email.has(indice):
		return

	var item: Button = itens_por_email[indice]
	var label: Label = item.get_node("Label")
	var lido = lidos.has(indice)

	item.modulate = Color.WHITE
	label.add_theme_color_override("font_color", Color("#666666") if lido else Color("#9A3838"))

	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color("#D9D9D9") if lido else Color("#FFFDF5")
	estilo.border_color = Color("#888888") if lido else Color("#C94E55")
	estilo.set_border_width_all(2)

	item.add_theme_stylebox_override("normal", estilo)
	item.add_theme_stylebox_override("hover", estilo)
	item.add_theme_stylebox_override("pressed", estilo)

func abrir_email(indice: int) -> void:
	email_atual_id = indice
	imagem_email.texture = emails[indice].imagem

	if not lidos.has(indice):
		lidos.append(indice)
		Progresso.salvar("emails_lidos", lidos)

	_atualizar_cor_email(indice)
	visualizador.show()
	lista_inbox.hide()
	botao_confirmar.hide()
	label_status.hide()

	botao_phishing.disabled = concluido
	botao_legitimo.disabled = concluido
	_atualizar_feedback()

func responder(marcou_como_phishing: bool) -> void:
	if email_atual_id == -1 or concluido:
		return

	respostas[str(email_atual_id)] = marcou_como_phishing
	Progresso.salvar("emails_respostas", respostas)
	_atualizar_feedback()

	print("E-mail ", email_atual_id, " classificado como: ", "Phishing" if marcou_como_phishing else "Legítimo")

func _atualizar_feedback() -> void:
	var resposta = respostas.get(str(email_atual_id), null)
	label_feedback.show()

	if resposta == null:
		label_feedback.text = "Ainda não classificado."
		label_feedback.modulate = Color.WHITE
	elif resposta:
		label_feedback.text = "Sua escolha: PHISHING"
		label_feedback.modulate = Color(1.0, 0.75, 0.35)
	else:
		label_feedback.text = "Sua escolha: LEGÍTIMO"
		label_feedback.modulate = Color(0.45, 0.85, 1.0)

	if concluido:
		label_feedback.text += " (Confirmado)"

func voltar() -> void:
	visualizador.hide()
	lista_inbox.show()
	botao_confirmar.show()
	label_status.show()
	email_atual_id = -1
	_atualizar_status()

func _atualizar_status() -> void:
	if concluido:
		label_status.text = "Classificação concluída!"
		botao_confirmar.disabled = true
		return

	var quantidade := 0
	for indice in sorteados:
		if respostas.has(str(indice)):
			quantidade += 1

	label_status.text = str(quantidade) + " de " + str(sorteados.size()) + " classificados."
	botao_confirmar.disabled = quantidade != sorteados.size() or sorteados.is_empty()

func confirmar_classificacoes() -> void:
	print("CONFIRMAR pressionado!")

	if concluido:
		print("Puzzle já concluído anteriormente.")
		return

	for indice in sorteados:
		if not respostas.has(str(indice)):
			label_status.text = "Classifique todos os e-mails antes de confirmar."
			print("Ainda existem mensagens sem classificação.")
			return

	var erros := 0
	for indice in sorteados:
		var resposta: bool = bool(respostas[str(indice)])
		if resposta != emails[indice].eh_phishing:
			erros += 1

	if erros > 0:
		label_status.text = "Há classificações incorretas. Revise os e-mails."
		print("Confirmação: ", erros, " classificação(ões) incorreta(s).")
		return

	concluido = true
	Progresso.salvar("emails_concluidos", true)
	_atualizar_status()
	print("SUCESSO: Todos os e-mails classificados corretamente!")
	todos_classificados.emit()
	
func _on_todos_classificados() -> void:
	print("Abrindo notificação de conclusão...")
	popup_conclusao.iniciar()
