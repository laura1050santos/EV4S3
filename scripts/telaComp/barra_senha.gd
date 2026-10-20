extends LineEdit

@onready var barra_senha: LineEdit = $"."
@onready var aviso_senha: Label = $"../AvisoSenha"

func _ready() -> void:
	barra_senha.text_submitted.connect(_on_entrar)
	barra_senha.text_changed.connect(_on_texto_alterado)
	$"../Button".pressed.connect(func(): _on_entrar(barra_senha.text))
	aviso_senha.hide()

func _on_entrar(texto: String) -> void:
	if texto == "LBD-3451":
		barra_senha.clear()
		aviso_senha.hide()
		var telas = get_parent().get_parent()
		telas.get_node("Tela_Senha").hide()
		telas.get_node("Tela_Inicial").show()
	else:
		barra_senha.clear()
		aviso_senha.text = "Senha incorreta."
		aviso_senha.show()

func _on_texto_alterado(_novo_texto: String) -> void:
	aviso_senha.hide()
