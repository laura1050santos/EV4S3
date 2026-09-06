extends SubViewportContainer

@onready var tela_computador: SubViewportContainer = $"."

func _ready():
	tela_computador.mouse_entered.connect(_on_entrou_na_tela)
	tela_computador.mouse_exited.connect(_on_saiu_da_tela)

func _on_entrou_na_tela():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # some o cursor real
	# o cursor falso dentro do SubViewport passa a "ser visto" naturalmente

func _on_saiu_da_tela():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # volta o cursor real
