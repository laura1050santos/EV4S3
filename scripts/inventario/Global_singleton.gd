extends Node

var ultima_cena = ""
var itens_no_mundo = []
var cenas_visitadas =[]
var historico_cenas: Array[String] = []
var item_mao=null
var enigma_luz_resolvido= false

var gaveta_1 = false # teste da gaveta do aquario
var gaveta_2 = false
var gaveta_3 = false
var lixeiraAberta = false
var volume = 0
# Função para registrar um item novo no mundo
var holder := Node.new()


# ==== SELEÇÃO DE FASE ====
var fase_liberada: int = 1
var fases_concluidas: Array = [false, false, false, false]

var ultima_cena_por_fase: Dictionary = {
	1: "res://scenes/fase1/ParedeNorte.tscn",
	2: "",
	3: "",
	4: ""
}
# ==================

func _ready():
	holder.name = "PersistentItems"
	get_tree().root.call_deferred("add_child", holder)
	
func registrar_item(item_resource, posicao,nome_da_cena):
	
	if item_resource:
		var novo_item = {
			"data": item_resource.resource_path,
			"pos": posicao,
			"cena": nome_da_cena,
			 # Guardamos em qual cena ele deve existir
		}
		itens_no_mundo.append(novo_item)
		print(GlobalSingleton.itens_no_mundo)
		
		
func cena_ja_foi_registrada(nome_da_cena) -> bool:
	# se a cena já foi carregada com os itens na posição inicia:
	# true: ele não coloca os itens de novo no lugar incial
	# se false: carrega os itens na posição inicial deles
	return nome_da_cena in cenas_visitadas
	
func registrar_cena_visitada(nome_da_cena):
	cenas_visitadas.append(nome_da_cena)
		
#Função para remover quando for coletado
func remover_item(item_data):
	var caminho_item = item_data.resource_path
	
	for i in range(itens_no_mundo.size()):
		if itens_no_mundo[i].data == caminho_item:
			print(itens_no_mundo[i].data,caminho_item )
			itens_no_mundo.remove_at(i)
			print(itens_no_mundo)
			break
			
func registrar_transicao(adress_cena: String):
	if historico_cenas.is_empty() or historico_cenas[-1] != adress_cena:
		historico_cenas.append(adress_cena)

func obter_cena_anterior() -> String:
	if historico_cenas.size() < 2:
		return ""

	return historico_cenas[historico_cenas.size() - 2]
	
# ======= FUNÇÕES DO SISTEMA DE FASES =====

func extrair_numero_fase(caminho: String) -> int:
	var regex = RegEx.new()
	regex.compile("fase(\\d+)")
	var resultado = regex.search(caminho)
	if resultado:
		return int(resultado.get_string(1))
	return 0

func registrar_cena_atual(caminho: String):
	ultima_cena = caminho
	var numero_fase = extrair_numero_fase(caminho)
	if numero_fase > 0:
		ultima_cena_por_fase[numero_fase] = caminho

func concluir_fase(indice_fase: int):
	fases_concluidas[indice_fase - 1] = true
	if indice_fase == fase_liberada and fase_liberada < 4:
		fase_liberada += 1
	SaveManager.salvar()
