class_name Enigmas

static func criar_tabela():
	var sql_enigmas = """
	CREATE TABLE IF NOT EXISTS Enigmas (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		resolvido INTERGER
	);
	"""

	Database.db.query(sql_enigmas)
	
static func salvar_enigmas( nome, resolvido):
	var sql = """
	INSERT INTO Enigmas (nome, resolvido)
	VALUES (?, ?)
	ON CONFLICT(nome)
	DO UPDATE SET resolvido = excluded.resolvido;
	"""
	
	Database.db.query_with_bindings(sql, [
		nome,
		resolvido
	])
	
	print("Enigma salva: ", nome)


static func get_nome(nome):
	var sql = """
	SELECT id, enigma, resolvido
	FROM Enigmas
	WHERE enigma = ?;
	"""
	
	Database.db.query_with_bindings(sql, [nome])
	
	var resultado = Database.db.get_query_result()
	
	if resultado.size() > 0:
		return resultado
	
	return null


static func delete_enigma(nome):
	var sql = """
	DELETE FROM Enigmas
	WHERE nome = ?;
	"""
	
	Database.db.query_with_bindings(sql, [nome])
	
	print("Enigma deletada: ", nome)
