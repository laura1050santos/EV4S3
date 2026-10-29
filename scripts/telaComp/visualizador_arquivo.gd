extends Control

func _ready() -> void:
	$Voltar.pressed.connect(hide)

func abrir(nome_arquivo: String, imagem: Texture2D) -> void:
	$Titulo.text = nome_arquivo
	$Imagem.texture = imagem
	show()
	$Voltar.grab_focus()
