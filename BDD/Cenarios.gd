class_name Cenarios

static func criar_tabela():
	var sql_cenarios = """
	CREATE TABLE IF NOT EXISTS Cenarios (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		cena TEXT NOT NULL UNIQUE,
		sprite TEXT
	);
	"""

	Database.db.query(sql_cenarios)
	
static func salvar_cenarios( cena, sprite):
	var sql = """
	INSERT INTO Cenarios (cena, sprite)
	VALUES (?, ?)
	ON CONFLICT(cena)
	DO UPDATE SET sprite = excluded.sprite;
	"""
	
	Database.db.query_with_bindings(sql, [
		cena,
		sprite
	])
	
	print("Cena salva: ", cena)


static func get_cena(cena):
	var sql = """
	SELECT id, cena, sprite
	FROM Cenarios
	WHERE cena = ?;
	"""
	
	Database.db.query_with_bindings(sql, [cena])
	
	var resultado = Database.db.get_query_result()
	
	if resultado.size() > 0:
		return resultado
	
	return null


static func delete_cena(cena):
	var sql = """
	DELETE FROM Cenarios
	WHERE cena = ?;
	"""
	
	Database.db.query_with_bindings(sql, [cena])
	
	print("Cena deletada: ", cena)
