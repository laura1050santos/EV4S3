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
	"""
	
	Database.db.query_with_bindings(sql, [
		cena,
		sprite
	])
	
	print("Cena salva: ", cena)
static func atualizar_cenario(cena, sprite):
	var sql = """
	UPDATE Cenarios
	SET sprite = ?
	WHERE cena = ?;
	"""

	Database.db.query_with_bindings(sql, [
		sprite,
		cena
	])

	print("Cenário atualizado: ", cena)


static func get_cena(cena):
	var sql = """
	SELECT id, cena, sprite
	FROM Cenarios
	WHERE cena = ?;
	"""
	Database.db.query_with_bindings(sql, [cena])
	var resultado = Database.db.get_query_result()
	if resultado.size() > 0:
		return resultado[0]
	return null


static func delete_cena(cena):
	var sql = """
	DELETE FROM Cenarios
	WHERE cena = ?;
	"""
	
	Database.db.query_with_bindings(sql, [cena])
	
	print("Cena deletada: ", cena)
	
	
static func iniciar_cenarios():
	salvar_cenarios("norte","res://assets/cenarios/tela porta.png")
	salvar_cenarios("sul","res://assets/cenarios/salaaquario.png")
	salvar_cenarios("leste","res://assets/cenarios/cenapc.png")
	salvar_cenarios("oeste","res://assets/cenarios/salaestar.png")

	salvar_cenarios("chao","res://assets/cenarios/chao.png")
	salvar_cenarios("teto","res://assets/cenarios/teto-sem-protetor-sem-lampada.png")

	salvar_cenarios("zoomMonitor","res://assets/cenarios/computador_desligado.png")
	salvar_cenarios("zoomPc","res://assets/cenarios/pcvazio.png")
	salvar_cenarios("zoomTele","res://assets/cenarios/cena-telegrafo-inicial.png")
	salvar_cenarios("zoomLixeira","res://assets/cenarios/lixeiraperto.png")
