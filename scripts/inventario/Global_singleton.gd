extends Node

var itens_no_mundo = []
var cenas_visitadas =[]
var historico_cenas: Array[String] = []
# Função para registrar um item novo no mundo
func registrar_item(item_resource, posicao,nome_da_cena):
	
	if item_resource:
		var novo_item = {
			"data": item_resource,
			"pos": posicao,
			"cena": nome_da_cena,
			 # Guardamos em qual cena ele deve existir
		}
		itens_no_mundo.append(novo_item)
		
func cena_ja_foi_registrada(nome_da_cena) -> bool:
	# se a cena já foi carregada com os itens na posição inicia:
	# true: ele não coloca os itens de novo no lugar incial
	# se false: carrega os itens na posição inicial deles
	return nome_da_cena in cenas_visitadas
	
func registrar_cena_visitada(nome_da_cena):
	cenas_visitadas.append(nome_da_cena)
		
#Função para remover quando for coletado
func remover_item(item_data):
	for i in range(itens_no_mundo.size()):
		if itens_no_mundo[i].data == item_data:
			print(itens_no_mundo[i].data,item_data )
			itens_no_mundo.remove_at(i)
			print(itens_no_mundo,item_data)
			break
			
func registrar_transicao(adress_cena: String):
	if historico_cenas.is_empty() or historico_cenas[-1] != adress_cena:
		historico_cenas.append(adress_cena)

func obter_cena_anterior() -> String:
	if historico_cenas.size() < 2:
		return ""

	return historico_cenas[historico_cenas.size() - 2]
