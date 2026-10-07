class_name Objetos

const PADRAO := {
	"Norte": [
		{"nome": "mala", "recurso": "res://recursos/Mala.tres", "pos": Vector2(750, 590)},
	],
	"leste": [
		{"nome": "chave", "recurso": "res://recursos/chaveDeFenda.tres", "pos": Vector2(770, 590)},
		{"nome": "lanterna", "recurso": "res://recursos/lanterna.tres", "pos": Vector2(500, 550)},
	],
	"Sul": [
		{"nome": "processador", "recurso": "res://recursos/processador.tres", "pos": Vector2(600, 550)},
	],
	"oeste": [
		{"nome": "fita cassete", "recurso": "res://recursos/FitaCassete.tres", "pos": Vector2(600, 550)},
	],
	"CenaTeto": [
		{"nome": "lampada quebrada", "recurso": "res://recursos/LampadaQuebrada.tres", "pos": Vector2(575, 273)},
		{"nome": "flan", "recurso": "res://recursos/flan.tres", "pos": Vector2(750, 550)},
	],
	"CenaChao": [
		{"nome": "placa mae", "recurso": "res://recursos/placaMae.tres", "pos": Vector2(600, 400)},
	],
	"Zoom Lixeira":[
		{"nome": "gpu", "recurso": "res://recursos/gpu.tres", "pos": Vector2(600, 400)},
	],
	
	
}


static func criar_tabela():
	Database.db.query("""
	CREATE TABLE IF NOT EXISTS Objetos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		recurso TEXT NOT NULL UNIQUE,
		pos TEXT,
		cena TEXT,
		coletado INTEGER NOT NULL DEFAULT 0
	);
	""")
	Database.db.query("""
	CREATE TABLE IF NOT EXISTS CenasVisitadas (
		cena TEXT PRIMARY KEY
	);""")


static func cena_ja_visitada(cena) -> bool:
	Database.db.query_with_bindings(
		"SELECT cena FROM CenasVisitadas WHERE cena = ?;", [cena]
	)
	return Database.db.get_query_result().size() > 0


static func marcar_cena_visitada(cena):
	Database.db.query_with_bindings(
		"INSERT OR IGNORE INTO CenasVisitadas (cena) VALUES (?);", [cena]
	)


static func garantir_padrao(cena: String):
	if cena_ja_visitada(cena):
		return
	for o in PADRAO.get(cena, []):
		salvar_objetos(
			o["nome"],
			o["recurso"],
			pos_para_json(int(o["pos"].x), int(o["pos"].y)),
			cena
		)
	marcar_cena_visitada(cena)


static func salvar_objetos(nome, recurso, pos, cena):
	var sql = """
	INSERT OR IGNORE INTO Objetos (nome, recurso, pos, cena)
	VALUES (?, ?, ?, ?);
	"""
	if not Database.db.query_with_bindings(sql, [nome, recurso, pos, cena]):
		push_error("Erro ao salvar objeto: " + Database.db.error_message)
		return
	print("Objeto salvo: ", nome)


static func marcar_coletado_por_recurso(recurso: String):
	if not Database.db.query_with_bindings(
		"UPDATE Objetos SET coletado = 1 WHERE recurso = ?;", [recurso]
	):
		push_error("Erro ao marcar coletado: " + Database.db.error_message)


static func atualizar_objeto(nome, recurso, pos, cena):
	var sql = """
	UPDATE Objetos
	SET recurso = ?, pos = ?, cena = ?
	WHERE nome = ?;
	"""
	Database.db.query_with_bindings(sql, [recurso, pos, cena, nome])
	print("Objeto atualizado: ", nome)

static func soltar_por_recurso(recurso: String, pos: Vector2, cena: String):
	Database.db.query_with_bindings(
		"UPDATE Objetos SET coletado = 0, pos = ?, cena = ? WHERE recurso = ?;",
		[pos_para_json(int(pos.x), int(pos.y)), cena, recurso]
	)

static func get_objetos_cena(cena):
	var sql = """
	SELECT id, nome, recurso, pos, cena
	FROM Objetos
	WHERE cena = ? AND coletado = 0;
	"""
	Database.db.query_with_bindings(sql, [cena])
	var resultado = Database.db.get_query_result()
	var objetos = []
	for info in resultado:
		var recurso = load(info["recurso"])
		var posicao = JSON.parse_string(info["pos"])
		if not (posicao is Dictionary) or recurso == null:
			push_error("Objeto inválido no banco: " + str(info["nome"]))
			continue
		objetos.append({
			"nome": info["nome"],
			"item": recurso,
			"pos": Vector2(posicao["x"], posicao["y"]),
			"cena": info["cena"]
		})
	return objetos


static func get_nome(nome):
	Database.db.query_with_bindings(
		"SELECT id, nome, recurso, pos, cena FROM Objetos WHERE nome = ?;", [nome]
	)
	var resultado = Database.db.get_query_result()
	if resultado.size() > 0:
		return resultado[0]
	return null


static func delete_objeto(nome):
	Database.db.query_with_bindings("DELETE FROM Objetos WHERE nome = ?;", [nome])
	print("Objeto deletado: ", nome)


static func pos_para_json(x: int, y: int):
	return JSON.stringify({"x": x, "y": y})
	
static func iniciar_objetos():
	for cena in PADRAO.keys():
		garantir_padrao(cena)
		
static func resetar():
	Database.db.query("DELETE FROM Objetos;")
	Database.db.query("DELETE FROM CenasVisitadas;")
