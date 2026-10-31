class_name CifraVigenere
extends RefCounted

const SEM_ACENTOS := {
	"A": "ÀÁÂÃÄÅ", "E": "ÈÉÊË", "I": "ÌÍÎÏ", "O": "ÒÓÔÕÖ",
	"U": "ÙÚÛÜ", "C": "Ç", "N": "Ñ", "Y": "ÝŸ"
}

# Regra do jogo: letras maiúsculas sem acentos; outros símbolos são preservados.
# Espaços, números e pontuação não consomem uma posição da palavra-chave.
static func normalizar(texto: String) -> String:
	var resultado: String = texto.to_upper()
	for letra in SEM_ACENTOS:
		for variante in SEM_ACENTOS[letra]:
			resultado = resultado.replace(variante, letra)
	var normalizado: String = ""
	for caractere in resultado:
		var codigo: int = caractere.unicode_at(0)
		if codigo < 0x0300 or codigo > 0x036f:
			normalizado += caractere
	return normalizado

static func chave_valida(chave: String) -> bool:
	var limpa: String = normalizar(chave.strip_edges())
	if limpa.is_empty():
		return false
	for caractere in limpa:
		var codigo: int = caractere.unicode_at(0)
		if codigo < 65 or codigo > 90:
			return false
	return true

static func cifrar(texto: String, chave: String) -> String:
	return _transformar(texto, chave, 1)

static func decifrar(texto_cifrado: String, chave: String) -> String:
	return _transformar(texto_cifrado, chave, -1)

static func _transformar(texto: String, chave: String, direcao: int) -> String:
	if not chave_valida(chave):
		return ""
	var limpa: String = normalizar(chave.strip_edges())
	var resultado: String = ""
	var indice_chave: int = 0
	for caractere in normalizar(texto):
		var codigo: int = caractere.unicode_at(0)
		if codigo >= 65 and codigo <= 90:
			var deslocamento: int = limpa.unicode_at(indice_chave % limpa.length()) - 65
			resultado += String.chr(posmod(codigo - 65 + direcao * deslocamento, 26) + 65)
			indice_chave += 1
		else:
			resultado += caractere
	return resultado
