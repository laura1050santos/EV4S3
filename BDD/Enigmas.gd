class_name Enigmas

static func criar_tabela():
	var sql_enigmas = """
	CREATE TABLE IF NOT EXISTS Enigmas (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		resolvido INTEGER
	);
	"""

	Database.db.query(sql_enigmas)
	
static func salvar_enigmas(nome, resolvido):
	if get_nome(nome) != null:
		return

	var sql = """
	INSERT INTO Enigmas (nome, resolvido)
	VALUES (?, ?);
	"""

	Database.db.query_with_bindings(sql, [
		nome,
		resolvido
	])
	print("Enigma salvo: ", nome)

static func atualizar_enigma(nome, resolvido):
	var sql = """
	UPDATE Enigmas
	SET resolvido = ?
	WHERE nome = ?;
	"""

	Database.db.query_with_bindings(sql, [
		resolvido,
		nome
	])
	print("Enigma atualizado: ", nome)

static func get_nome(nome):
	var sql = """
	SELECT id, nome, resolvido
	FROM Enigmas
	WHERE nome = ?;
	"""

	Database.db.query_with_bindings(sql, [nome])

	var resultado = Database.db.get_query_result()

	if resultado.size() > 0:
		return resultado[0]

	return null


static func delete_enigma(nome):
	var sql = """
	DELETE FROM Enigmas
	WHERE nome = ?;
	"""
	Database.db.query_with_bindings(sql, [nome])
	
	print("Enigma deletada: ", nome)
	
static func iniciar_enigmas():
	salvar_enigmas("aquario", false)
	salvar_enigmas("lampada", false)
	salvar_enigmas("alcapao", false)
