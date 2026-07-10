extends Control

@export var correct_password: Array[int] = [1, 2, 3, 4] # senha aqui
@onready var digit_buttons: Array[TextureButton] = [$Digito1, $Digito2, $Digito3, $Digito4]

@onready var door = $Door

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
	$"../lixeiraAberta".visible=true
	print("Senha correta! Abrindo...")
	$".".visible = false
