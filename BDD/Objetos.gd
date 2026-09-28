class_name Objetos


static func criar_tabela():
	var sql_objetos = """
	CREATE TABLE IF NOT EXISTS Objetos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		recurso TEXT NOT NULL UNIQUE,
		pos TEXT,
		cena TEXT
	);
	"""

	Database.db.query(sql_objetos)


static func salvar_objetos(nome, recurso, pos, cena):
	var sql = """
	INSERT INTO Objetos (nome, recurso, pos, cena)
	VALUES (?, ?, ?, ?);
	"""

	Database.db.query_with_bindings(sql, [
		nome,
		recurso,
		pos,
		cena
	])

	print("Objeto salvo: ", nome)


static func atualizar_objeto(nome, recurso, pos, cena):
	var sql = """
	UPDATE Objetos
	SET recurso = ?,
		pos = ?,
		cena = ?
	WHERE nome = ?;
	"""

	Database.db.query_with_bindings(sql, [
		recurso,
		pos,
		cena,
		nome
	])

	print("Objeto atualizado: ", nome)


static func get_objetos_cena(cena):
	var sql = """
	SELECT id, nome, recurso, pos, cena
	FROM Objetos
	WHERE cena = ?;
	"""

	Database.db.query_with_bindings(sql, [cena])
	var resultado = Database.db.get_query_result()
	var objetos = []
	for info in resultado:
		var recurso = load(info["recurso"])
		var posicao = JSON.parse_string(info["pos"])
		if posicao is Dictionary:
			posicao = Vector2(
				posicao["x"],
				posicao["y"]
			)
		objetos.append({
			"item": recurso,
			"pos": posicao,
			"cena": info["cena"]
		})

	return objetos

static func get_nome(nome):
	var sql = """
	SELECT id, nome, recurso, pos, cena
	FROM Objetos
	WHERE nome = ?;
	"""

	Database.db.query_with_bindings(sql, [nome])

	var resultado = Database.db.get_query_result()

	if resultado.size() > 0:
		return resultado[0]

	return null


static func delete_objeto(nome):
	var sql = """
	DELETE FROM Objetos
	WHERE nome = ?;
	"""

	Database.db.query_with_bindings(sql, [nome])

	print("Objeto deletado: ", nome)

static func iniciar_objetos():
	salvar_objetos("mala", "res://recursos/Mala.tres",pos_para_json(750,590),"Norte")
	salvar_objetos("chave", "res://recursos/chaveDeFenda.tres",pos_para_json(770,590),"leste")
	salvar_objetos("processador", "res://recursos/processador.tres",pos_para_json(600,550),"Sul")
	salvar_objetos("lampada quebrada", "res://recursos/LampadaQuebrada.tres",pos_para_json(575,273),"CenaTeto")
	salvar_objetos("flan", "res://recursos/flan.tres",pos_para_json(750,550),"CenaTeto")
	salvar_objetos("placa mae", "res://recursos/placaMae.tres",pos_para_json(600,400),"CenaChao")
	salvar_objetos("lanterna", "res://recursos/lanterna.tres" ,pos_para_json(500,550),"leste")

	
static func pos_para_json(x:int,y:int):
	var pos = JSON.stringify(
		{"x":x,
		"y":y}
	)
	return pos
