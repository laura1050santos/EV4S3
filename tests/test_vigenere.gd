extends SceneTree

const Cifra = preload("res://scripts/criptografia/vigenere.gd")
var verificacoes: int = 0
var falhas: int = 0

func _initialize() -> void:
	_igual(Cifra.cifrar("ATTACKATDAWN", "LEMON"), "LXFOPVEFRNHR", "Vetor clássico: cifrar")
	_igual(Cifra.decifrar("LXFOPVEFRNHR", "LEMON"), "ATTACKATDAWN", "Vetor clássico: decifrar")
	_igual(Cifra.cifrar("ATTACK AT DAWN! 24091998", "LEMON"), "LXFOPV EF RNHR! 24091998", "Separadores não avançam a chave")
	_igual(Cifra.cifrar("AAAA", "NEXO"), "NEXO", "Deslocamentos da chave NEXO")
	_igual(Cifra.decifrar("NEXO", "NEXO"), "AAAA", "Deslocamentos inversos")
	_igual(Cifra.normalizar("À ação, órgão, café, açúcar e maçã!"), "A ACAO, ORGAO, CAFE, ACUCAR E MACA!", "Acentos")
	_igual(Cifra.normalizar("ac\u0327a\u0303o"), "ACAO", "Acentos decompostos")
	for texto in ["", "Mensagem confidencial.", "Chave do ZIP: 24091998", "Ação e memória: julho/1998.\nNEXO", "0123!?\n", "Um registro — com símbolos 🙂."]:
		var cifrado: String = Cifra.cifrar(texto, "NEXO")
		_igual(Cifra.decifrar(cifrado, "NEXO"), Cifra.normalizar(texto), "Ida e volta: " + texto)
		_igual(Cifra.cifrar(texto, " nexo "), cifrado, "Normalização da chave")
		_igual(Cifra.cifrar(texto, "NEXO"), cifrado, "Criptograma estável")
	for invalida in ["", "   ", "N3XO", "NEXO!", "NE XO"]:
		_igual(Cifra.chave_valida(invalida), false, "Chave inválida")
		_igual(Cifra.cifrar("MENSAGEM", invalida), "", "Cifragem rejeita chave inválida")
		_igual(Cifra.decifrar("MENSAGEM", invalida), "", "Decifragem rejeita chave inválida")
	var protegido: String = Cifra.cifrar("REGISTRO CONFIDENCIAL", "NEXO")
	_igual(Cifra.decifrar(protegido, "ABCD") == "REGISTRO CONFIDENCIAL", false, "Chave errada não recupera a mensagem")
	print("VIGENERE: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)

func _igual(recebido: Variant, esperado: Variant, descricao: String) -> void:
	verificacoes += 1
	if recebido != esperado:
		falhas += 1
		push_error(descricao + ": recebido=" + str(recebido) + "; esperado=" + str(esperado))
