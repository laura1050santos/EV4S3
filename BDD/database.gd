extends Node

var db: SQLite


func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"
	var sucesso = db.open_db()
	criar_tabelas()
	novo_jogo()
	if not sucesso:
		print("Erro ao abrir o banco de dados.")
		return

func criar_tabelas():
	Cenarios.criar_tabela()
	Objetos.criar_tabela()
	Enigmas.criar_tabela()
	Arrays.criar_tabela()
	Config.criar_tabelas()

func novo_jogo():
	Objetos.deletarTabela()
	Objetos.iniciar_objetos()
	Arrays.deletarTabela()
	Arrays.iniciar_array()
	Enigmas.deletarTabela()
	Enigmas.iniciar_enigmas()
	Cenarios.deletarTabela()
	Cenarios.iniciar_cenarios()
	var a = get_tree().root
	
	if a:
		a.queue_free()
		print(a)
	
