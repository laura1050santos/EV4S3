extends Window

func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)

func _process(delta: float) -> void:
	pass

func _on_login_button_pressed():
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	Firebase.Auth.login_with_email_and_password(email, password)
	%StateLabel.text = "Autenticando..."


func _on_signup_button_pressed() -> void:
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	Firebase.Auth.signup_with_email_and_password(email, password)
	%StateLabel.text = "Cadastrando..."
	
func on_login_succeeded(auth):
	print(auth)
	%StateLabel.text = "Você está autenticado !"
	
func on_signup_succeeded(auth):
	print(auth)
	%StateLabel.text = "Você está cadastrado !"
	
func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Falha na autenticação: %s" % message
	
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Falha no cadastro: %s" % message
	pass
