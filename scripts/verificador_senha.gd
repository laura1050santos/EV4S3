extends Control

@export var correct_password: Array[int] = [1, 2, 3, 4] # senha aqui
@onready var digit_buttons: Array[TextureButton] = [$Digito1, $Digito2, $Digito3, $Digito4]

@onready var door = $Door
@onready var fechado: Sprite2D = $".."
@onready var aberto: Texture2D = preload("res://assets/cenarios/chao_aberto.png")

func _ready() -> void:
	print("iterando", digit_buttons.size())
	for btn in digit_buttons:
		btn.pressed.connect(_check_password)

func _check_password() -> void:
	print("checando senha . . . .")
	var current_sequence: Array[int] = []
	for btn in digit_buttons:
		current_sequence.append(btn.current_digit)
		
	print("sequência atual: ", current_sequence)
	print("senha correta: ", correct_password)
	
	if current_sequence == correct_password:
		open_door()

func open_door() -> void:
	print("Senha correta! Abrindo...")
	fechado.texture = aberto
	visible = false
	#aberto.visible = true
	#door.visible = false
