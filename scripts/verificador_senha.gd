extends Control

@export var correct_password: Array[int] = [1, 2, 3, 4] #senha aqui
@onready var digit_buttons: Array[TextureButton] = [$Digito1, $Digito2, $Digito3, $Digito4]

func _ready() -> void:
	var alcapao = Enigmas.get_nome("alcapao")
	if alcapao != null and alcapao["resolvido"] == 1:
		visible = false
		return

	for btn in digit_buttons:
		btn.pressed.connect(_check_password)

func _check_password() -> void:
	var current_sequence: Array[int] = []
	for btn in digit_buttons:
		current_sequence.append(btn.current_digit)

	if current_sequence == correct_password:
		open_door()

func open_door() -> void:
	Enigmas.atualizar_enigma("alcapao", 1)

	var cena = get_tree().current_scene
	if cena.has_method("_atualizar_estado_alcapao"):
		cena._atualizar_estado_alcapao()
