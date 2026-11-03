extends SceneTree

const Cifra = preload("res://scripts/criptografia/vigenere.gd")
const Documento = preload("res://scripts/criptografia/documento_cifrado.gd")
const CHAVE_DE_EDICAO := "GWJK"
const FONTE := "res://conteudo/secreto_fonte.txt"
const DESTINO := "res://recursos/documentos/secreto.tres"

func _initialize() -> void:
	if not FileAccess.file_exists(FONTE):
		push_error("Fonte do documento não encontrada: " + FONTE)
		quit(1)
		return
	var original: String = FileAccess.get_file_as_string(FONTE).strip_edges()
	if original.is_empty():
		push_error("O documento de origem está vazio.")
		quit(1)
		return
	var documento = Documento.new()
	documento.criptograma = Cifra.cifrar(original, CHAVE_DE_EDICAO)
	documento.hash_texto = Cifra.normalizar(original).sha256_text()
	if Cifra.decifrar(documento.criptograma, CHAVE_DE_EDICAO).sha256_text() != documento.hash_texto:
		push_error("O teste de geração do criptograma falhou.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://recursos/documentos"))
	var erro: Error = ResourceSaver.save(documento, DESTINO)
	if erro != OK:
		push_error("Erro ao salvar o documento cifrado: " + str(erro))
		quit(1)
		return
	print("SECRETO_GERADO: criptograma estável salvo em ", DESTINO)
	quit()
