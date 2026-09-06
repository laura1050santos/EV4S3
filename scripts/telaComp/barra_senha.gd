extends LineEdit
@onready var barra_senha: LineEdit = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barra_senha.text_submitted.connect(_on_entrar)
	$"../Button".pressed.connect(func(): _on_entrar(barra_senha.text))

func _on_entrar(texto: String):
	if texto == "Catarina":
		print("Senha correta: ", texto)
	else:
		print("INCORRETO")
