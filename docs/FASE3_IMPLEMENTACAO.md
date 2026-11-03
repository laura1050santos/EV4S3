# Fase 3 — auditoria e implementação incremental

Referência atual: `CONTEXTO_EV4S3_ATUALIZADO_CODEX.md`, lido em 30/10/2026, substituindo o planejamento anterior.
Este relatório descreve os arquivos inspecionados; não substitui as decisões narrativas da especificação.

**Direção atual aprovada:** o cuco abre às 12h por ajuste do ponteiro dos minutos, com horas proporcionais. Entrega BACKUP-03, não códigos. A futura recuperação exigirá cartão + recuperador.exe do ZIP. Após ler e fechar registro_excluido.dat, haverá conversa por mensageiro; só o fim da conversa concluirá a Fase 3. As referências históricas abaixo a 91BC e conclusão pela leitura estão substituídas por essa decisão.

**Revisão posterior do usuário:** as fotos agora são fixadas e reordenadas no quadro, acima do calendário. As letras ficam na frente em tinta invisível, reveladas pela lanterna violeta no zoom. Essa decisão substitui as referências históricas a virar/examinar o verso abaixo.

## Já implementado

- `tela_email.gd`: respostas revisáveis, seleção e leituras no SQLite; até seis e-mails, quatro recursos cadastrados atualmente. Preservar a decisão mais recente de até seis, apesar da referência antiga a três no documento.
- `PopupConclusao`: imagens `secreto.png` e `alerta criptografia.png`; clique na segunda chama conclusão da Fase 2, objetivo concluído e seleção de fases.
- Estados separados existentes: `emails_concluidos`, `secreto_dat_desbloqueado` e `fases_concluidas[1]`. O último impede repetir a conclusão; notificações pendentes são retomadas ao abrir os e-mails.
- Retorno da Fase 3: `zoom_monitor.tscn`, com `Tela_Inicial` aberta pelo `pc_control.gd`.
- Navegador: artigo educativo de Vigenère, buscas com e sem acentos e sites opcionais dos contatos. Não revela NEXO.
- Pastas e visualizador: `aniversarios.txt`, `registro_equipamentos.txt`, contatos, rascunho e procedimentos já abrem suas imagens.
- `registro.png` foi inspecionado: contém CASA-03 — calendário.
- Inspeção de itens, lanterna violeta e persistência SQLite já existem. Isso não determina que as fotos usarão tinta invisível.

## Ainda falta

1. Interface e documento cifrado de `secreto.dat`: implementados e testados na etapa seguinte, descrita abaixo.
2. Ícone condicionado à descoberta, entrada, animação e releitura: implementados e testados.
3. Calendário físico e quatro fotografias: implementados nesta etapa, descrita abaixo; arte provisória fornecida pelo usuário.
4. ZIP funcional: implementado na etapa descrita abaixo, com senha e visualização de imagem.png.
5. Cuco, cartão, pista visual do meio-dia no ZIP e recuperador.exe implementados.
6. Recuperação, registro, leitura e mensageiro implementados nesta etapa. Falta conectar a conversa concluída à progressão/transição da Fase 3, conforme separação de etapas solicitada.
7. Textos narrativos definitivos. Não inventar o motivo do sequestro nem canonizar responsáveis.

## Divergências e cuidados

- O banco permanece em `res://data.db`, em `BDD/database.gd`, conforme decisão explícita do usuário. Não migrar para `user://`.
- A seleção ainda aponta os fallbacks de Fases 3 e 4 para caminhos inexistentes; a Fase 3 atualmente funciona porque sua última cena é preenchida ao concluir os e-mails. Corrigir ao integrar a progressão correspondente.
- As salas compartilhadas ficam em `scenes/fase1`; `registrar_cena_atual` infere fase pelo caminho. Verificar o registro da fase ativa antes de integrar os novos checkpoints.
- `NEXO` é a chave aprovada da cifra; `91BC` será a única chave do registro. `24091998` permanece a senha provisória do ZIP. Não usar a combinação antiga `7F3A91BC`.
- Fotos: usar verso simples como padrão previsto. A lanterna violeta existente não autoriza automaticamente sua aplicação neste puzzle.
- A Fase 3 termina somente após a recuperação e leitura do registro; abrir o ZIP não conclui a fase.

## Etapa atual: rotina matemática

Implementada em `scripts/criptografia/vigenere.gd`, independente de interface, banco ou cenas.

- `cifrar(texto, chave)` e `decifrar(texto, chave)` aplicam os deslocamentos reais.
- A-Z, em maiúsculas; acentos latinos comuns são convertidos para a letra base, inclusive marcas combinantes.
- Espaços, pontuação e números são preservados e não avançam a chave.
- A comparação após decifrar é com o texto original normalizado, pois caixa e acentos são removidos por definição.
- Chave vazia ou com símbolos/números é rejeitada. Espaços externos são removidos.
- Não contém senha esperada, texto narrativo nem lógica de desbloqueio.
- Teste persistente: `tests/test_vigenere.gd`. Inclui vetor clássico ATTACKATDAWN/LEMON, NEXO, caracteres acentuados, separadores, estabilidade, chaves inválidas e ida/volta.

Validação em 29/10/2026: 41 verificações da cifra, zero falhas, executadas com Godot em projeto mínimo isolado, sem autoloads ou banco. O fluxo completo de conclusão da Fase 2 também passou no Godot, incluindo notificações, seleção, entrada da Fase 3 no desktop e releitura sem repetir a conclusão; alterações de progresso do teste foram revertidas por transação SQLite.

## Etapa concluída: estrutura mínima de secreto.dat

A interface reutiliza `Arquivo_DAT` do subviewport:

- título `secreto.dat`, método Vigenère e referência REF-CASA-03;
- prévia estável do criptograma; LineEdit para palavra-chave; botão Decifrar;
- validação sem revelar a resposta, animação curta e visualizador do texto completo;
- conteúdo cifrado em recurso separado da UI, com origem de edição e geração controlada antes do jogo;
- persistência de `secreto_dat_decifrado` separada de `secreto_dat_desbloqueado`;
- conservar o ZIP único e encaminhar sua senha pelo conteúdo do documento;
- texto narrativo temporário claramente identificado enquanto aguarda revisão.

Integrar e testar essa etapa antes de avançar para calendário e fotografias. Não criar o painel da Fase 4 nesta etapa.

Implementação: `arquivo_secreto.tscn`, `arquivo_secreto.gd`, ícone em `tela_pastas.tscn` e recurso `recursos/documentos/secreto.tres`. A interface decifra o criptograma e verifica o hash do resultado; não compara a entrada com uma senha fixa. A chave aceita é persistida junto de `secreto_dat_decifrado` para decifrar novamente na releitura. Fechar durante a animação cancela a operação.

O conteúdo provisório é editável em `conteudo/secreto_fonte.txt`. Após revisão, gerar novamente o recurso com Godot: `--headless --path CAMINHO_DO_PROJETO --script res://tools/gerar_secreto.gd`. Essa ferramenta de autoria contém a chave de trabalho NEXO; não é executada pela interface durante o jogo. O arquivo ZIP permanece único, e sua abertura funcional fica para a etapa correspondente.

Validação: `tests/test_secreto.gd`, 17 verificações, zero falhas no Godot. Inclui descoberta, ícone, chaves vazia/inválida/incorreta, cancelamento, Enter, resultado real, senha do ZIP, persistência e nova instância. Teste executado em transação com rollback; comparação das linhas de Progresso com backup confirmou preservação da partida. A inicialização do projeto ainda registra erros preexistentes de sementes SQLite duplicadas em Arrays/Cenarios.

Teste manual: após descobrir o arquivo nos e-mails, abrir Arquivos → secreto.dat; experimentar uma chave incorreta e depois NEXO; fechar e reabrir para conferir a releitura. A decifragem não conclui a Fase 3. Próxima etapa: calendário e quatro fotografias.

## Etapa de 30/10/2026: calendário + fotografias

- Conferidos os scripts anteriores de `secreto.dat`, os dois arquivos de pistas e o artigo de Vigenère. `aniversarios.png` já traz as quatro datas completas e `registro.png` já relaciona CASA-03 ao calendário; preservados sem duplicação.
- `scenes/fase3/calendario_fisico.tscn` é instanciado em `ParedeLeste.tscn`, no quadro ao lado do post-it, posição (727, 277). É um Area2D fixo, sem itemData nem registro em Objetos; clicar abre o visualizador existente com as quatro datas de julho e a instrução de idade. A imagem original `assets/itens/calendario.png` é preservada; as informações são desenhadas pela interface.
- Quatro itemData em `recursos/fotos/`: foto_1=Augusto/N, foto_2=Helena/E, foto_3=Marina/X, foto_4=Lucas/O. Recursos parametrizam identidade e verso. A inspeção existente ganhou botão Virar foto, com nome visível na frente; mantém o comportamento anterior do papel Morse.
- Locais após inspeção do mapa real: Augusto, segunda gaveta do PC (582,493); Helena, terceira gaveta da cômoda Sul (733,513); Marina, vão livre da estante Oeste (375,425); Lucas, chão à esquerda da porta Norte (431,590). São quatro fotos físicas, não um álbum. A ordem não é montada automaticamente.
- `Objetos.FOTOS_FAMILIA` registra somente fotos ausentes por INSERT OR IGNORE, inclusive em salas já visitadas. Coleta, posição após soltar e gavetas usam as tabelas existentes; não há migração, reset nem mudança do caminho `res://data.db`. Escala física 0.1, mantida ao soltar.
- Exame e verso registram `foto_examinada_FotoAugusto`, `foto_verso_FotoAugusto` e equivalentes; calendário registra `calendario_examinado`. Esses estados não bloqueiam o uso de NEXO, não exigem UV, não concluem fase e não alteram os e-mails.
- Teste persistente `tests/test_fotos_calendario.gd`: cenas reais, gavetas, identidade/verso, exame pelo inventário, coleta, reposicionamento, registro idempotente, calendário e regressão do papel Morse. Escritas de teste feitas em transação com rollback e comparação do progresso antes/depois.
- Validação automatizada no Godot: 63 verificações de fotos/calendário e 18 de regressão de `secreto.dat`, zero falhas. O teste de `secreto.dat` foi isolado também do estado `emails_concluidos`, pois a tela de e-mails corretamente restaura a descoberta em partidas já avançadas. Avaliação visual pelo jogador ainda deve ser feita com a arte provisória.

Teste manual desta etapa: na parede do PC, clicar no calendário ao lado do post-it; abrir a segunda gaveta e examinar a foto com botão direito; Virar foto revela N. Repetir nas demais paredes, incluindo exame após guardar no inventário e após soltar. Relacionar as identidades a `aniversarios.txt`; voltar a `secreto.dat` e usar NEXO. Próximo sistema: ZIP e imagem do relógio, seguindo a chave única 91BC do novo contexto.

## Revisão: quadro de fotos + tinta invisível

- `scenes/fase3/zoom_quadro.tscn` abre ao clicar no calendário ou na área das miniaturas acima dele. Retorno para a parede Leste, preservando o post-it independente. A parede também mostra miniaturas das fotos fixadas ao revisitar.
- Arrastar fotos do inventário aos quatro espaços fixa-as. Arrastar entre posições troca a ordem ou move para um espaço vazio. Soltar sobre uma posição ocupada devolve a foto anterior ao slot de inventário que originou o arraste. Botão direito retira para o inventário se houver espaço; arrastar de volta para um slot vazio também funciona.
- Persistência reutiliza a tabela Objetos e o estado de estação existente: coletado=2, cena=`estacao:quadro_foto_0` até `estacao:quadro_foto_3`. Não cria JSON paralelo, não duplica fotos nem as recria nos cômodos de origem. A ordem não é validada ou corrigida automaticamente.
- `itemData.letra_violeta` substitui `letra_verso`. Os retratos e nomes permanecem na frente; letras N/E/X/O são sobrepostas à frente usando `inscricao_violeta.tscn`, máscara 2 e material LIGHT_ONLY. Aparecem somente com a lanterna existente ligada em modo violeta, mantendo luz fixa e tecla F. Removida a ação de revelar pelo verso; os estados antigos de verso, se presentes no SQLite, não são utilizados nem apagados.
- Teste manual atual: recolher uma foto; clicar no calendário; arrastar ao espaço escolhido; repetir com as demais; trocar a ordem arrastando. Equipar a lanterna no cenário e pressionar F; conferir letras somente com modo violeta ativo. Sair do zoom e retornar para conferir ordem. Retirar uma foto e testar inventário cheio. Não há conclusão automática de fase por organizar as fotos.
- Testes: `tests/test_quadro_fotos.gd` cobre fixação, rejeição de itens, trocas, retirada, persistência/reentrada, tinta sem luz/branca/violeta/desligada, inventário cheio, entrada real no zoom e preservação da partida. `tests/test_fotos_calendario.gd` foi atualizado para o exame sem verso.
- O zoom reutiliza SalasManager para restaurar também itens soltos, incluindo a lanterna deixada nessa cena. O inventário trata cancelamento do arraste iniciado no quadro, cuja origem não é um slot com ícone.
- Validação: 42 verificações do quadro, 56 de regressão das fotos e 18 do arquivo secreto, todas sem falhas no Godot. Alterações dos testes revertidas por transação SQLite; conferidas igualdade do Progresso e dos itens/posições originais. A apresentação visual ainda depende da avaliação no jogo.

## Etapa: abertura e visualização de arquivo.zip

Escopo solicitado pelo usuário: somente ZIP, preservando quadro/calendário/fotos para ajustes visuais manuais.

- O ícone Zip existente em Arquivos abre `scenes/Computador_Telas/arquivo_zip.tscn`, instanciado no espaço Arquivo_ZIP do subviewport. Sem ícones duplicados.
- Senha provisória 24091998, já entregue pelo documento secreto; aceita pelo botão ou Enter, com retorno para entrada vazia/incorreta. Não há exigência extra de ter aberto outra tela: conhecer a senha basta.
- Estado `zip_aberto` no SQLite existente permite reabrir sem redigitar e restaura acesso em nova instância. Banco continua res://data.db.
- Conteúdo único: imagem.png. Reutiliza o visualizador de imagens existente. A textura é um AtlasTexture com detalhe reconhecível do relógio-cuco no cenário salaestar.png, sem gerar ou alterar imagens de origem. Pode ser substituída no campo exportado imagem da nova cena.
- Esta implementação representa o arquivo fictício dentro do jogo; não cria nem extrai arquivos ZIP externos. Não inclui chave.rec, cartão 91BC, interação física com o relógio nem conclusão da fase.
- Teste `tests/test_zip.gd`: 17 verificações sem falhas, incluindo clique real do ícone/sinais, senha vazia/incorreta/correta, Enter, pixels da imagem, retornos, releitura, nova instância, progresso e ausência de conclusão antecipada. Escritas de teste revertidas por transação e igualdade do Progresso verificada.

Teste manual: computador → Arquivos → arquivo.zip → senha 24091998 → imagem.png. Voltar à lista do ZIP, voltar aos arquivos e reabrir para conferir a persistência. Próxima etapa futura: examinar o relógio físico, quando autorizada.

## Revisão visual: cenários completos de post-it e calendário

- Imagens fornecidas pelo usuário: `assets/cenarios/zoom_postit.png` e `zoom_calendario.png`, 1920×1080. Aplicadas às cenas existentes com centro (576,324) e escala 0.6, mantendo área 1152×648 e os caminhos anteriores de navegação.
- `scenes/fase2/zoom_postIt.tscn` passa a mostrar o cenário completo, substituindo o item post-it isolado.
- `scenes/fase3/zoom_quadro.tscn` usa a arte completa do calendário. Removidos os polígonos de fundo provisórios, calendário provisório, título, datas digitadas, instruções, legendas e tooltips dos espaços de foto. Os textos já desenhados na imagem não foram alterados. Letras UV preservadas como parte da mecânica.
- Quatro posições em uma fileira acima do calendário: nó `Conteudo/AreaFotos` na posição (318,115); tamanho padrão de cada espaço (116,138), intervalo 20. Posição ajustável diretamente no nó; tamanho e intervalo exportados em `scripts/zoom_quadro.gd`. Só uma borda discreta indica espaços vazios.
- Arraste, troca, retirada, lanterna e SQLite preservados. Nenhuma alteração no posicionamento manual do calendário na parede Leste ou no progresso preparado para teste.

## Etapa: relógio-cuco e BACKUP-03

- `scenes/fase3/zoom_cuco.tscn` abre pelo relógio da parede Oeste, sem bloqueio por fase. O clique da parede passa a abrir o zoom; o som do cuco é reservado à resolução.
- Usa os arquivos novos sem alterar os desenhos: zoom_cuco como cenário; cuco_fechado_zoom, cuco_aberto_sd e cuco_aberto como três estados. O desenho maior de seta_horas foi usado como minutos e o menor de seta_minutos como horas; os nomes dos nós indicam sua função real. Pivô alinhado ao centro do mostrador, em (936,525) na arte original.
- Início configurável em 500 minutos (8h20). Arrastar o ponteiro maior altera minutos; cada volta equivale a 60 minutos e avança o menor em 30 graus. Movimento nos dois sentidos, sem saltar ao clicar. Apenas o maior é manipulável.
- Às 12h, toca cuckoo.mp3 e troca para portinha aberta com cartão. Pequena tolerância configurável e detecção de cruzamento evitam perder a solução num arraste rápido. Após resolver, ponteiros permanecem no meio-dia e a abertura não é repetida.
- Progresso usa `cuco_minutos` e `cuco_compartimento_aberto` no SQLite atual. Posição salva ao soltar e também ao sair da cena durante o arraste. Reentrada não toca novamente.
- `recursos/Backup03.tres`: itemData BACKUP-03, com AtlasTexture do sd.png original. Registro único em Objetos criado ao visitar o relógio, na cena ZoomCuco e container compartimento_cuco. Coleta usa inventário e coletado existentes; se estiver cheio, cartão continua na portinha. Depois de recolhido, usa arte aberta sem SD e não recria o item. Itens deixados no zoom são restaurados via SalasManager.
- Botão direito permite examinar o cartão pelo visualizador existente, evitando ativação genérica sem textura. Coleta antecipada na Fase 1 permitida; cartão sozinho não recupera arquivo nem conclui fase.
- Escopo desta etapa: relógio e cartão. Ainda faltam imagem do ZIP indicando 12h, recuperador.exe, registro e mensageiro. Não implementar códigos antigos.
- Teste manual: clicar no cuco da parede Oeste; arrastar a ponta do ponteiro maior ao redor do mostrador até ambos apontarem para XII; ouvir o cuco e clicar no SD revelado. Sair/voltar ou carregar partida para conferir estados. Testar inventário cheio antes de recolher.
- Validação automatizada no Godot: `tests/test_cuco.gd`, 33 verificações sem falhas, incluindo voltas completas, giro reverso, cruzamento de meio-dia, ponteiros salvos, saída durante arraste, coleta antecipada, inventário cheio, ausência de duplicação e restauração de cartão solto. As 12 verificações de áudio também passaram, agora com o cuco disparado pela resolução. Testes em transação com rollback; Progresso e Objetos originais conferidos sem alterações.

### Revisão do controle: cliques

Por solicitação do usuário, o arraste foi substituído por clique no mostrador. Cada clique esquerdo avança 15 minutos; o ponteiro menor acompanha proporcionalmente. O início padrão agora é 3h (180 minutos), ficando mais distante do meio-dia. Início e incremento são exportados no script para ajuste no editor. Horários já salvos e compartimentos já abertos são preservados. Movimento do mouse não altera os ponteiros; cada clique salva imediatamente no SQLite.

Teste atualizado: 33 verificações sem falhas, incluindo 36 cliques de 3h a 12h, movimentos do mouse sem efeito, restauração do horário, abertura, som e cartão. Escritas de teste revertidas, sem alterar a partida original.

## Etapa: SD no gabinete e sala do cuco

- A parede Oeste usa `salaestar_cucofechado.png` antes da resolução e `salaestar.png` após `cuco_compartimento_aberto=true`. O estado é restaurado em cada visita; recolher o cartão não fecha o cuco.
- A parede Leste permite acessar `zoom_pc.tscn` também após a Fase 1, para usar o leitor de cartão. A entrada do monitor permanece separada.
- Novo alvo `GabinetePc/slotSD`, com a posição da entrada externa nas imagens atualizadas do gabinete. Aceita somente BACKUP-03 previamente coletado. A tampa pode permanecer fechada; peças internas continuam exigindo abertura com chave de fenda.
- Overlay `sd_inserido_pc.png` herda o transform do gabinete para manter perspectiva e posição, e fica visível com a tampa aberta ou fechada. Arrastar do inventário encaixa; clicar no leitor com cartão inserido o devolve ao inventário. Inventário cheio mantém o cartão no leitor.
- Persistência reutiliza estação SQLite `leitor_sd_pc` e coletado=2 em Objetos; não duplica estado em Progresso. A futura interface de recuperação deve consultar essa estação para detectar a mídia conectada, além de exigir recuperador.exe do ZIP. Inserir o SD sozinho ainda não recupera registro nem conclui fase.
- Validação: 23 verificações de inserção/retirada, posição, estado da sala e acesso ao gabinete na Fase 3; 29 da montagem/guias do PC e 33 do cuco, todas sem falhas. Testes com rollback preservaram progresso e itens da partida.

## Etapa: foto do ZIP, recuperador, registro e mensageiro

- `arquivo.zip` mantém a senha atual 24091998 e passa a conter imagem.png (foto_cuco_antiga.png fornecida pelo usuário, mostrando XII) e recuperador.exe. A foto usa o visualizador existente, sem alterar o asset original.
- O recuperador só abre com zip_aberto=true. Recuperar exige BACKUP-03 conectado na estação SQLite leitor_sd_pc; tê-lo no inventário ou encontrá-lo cedo não basta. A condição é revalidada ao longo da animação. Fechar ou sair durante a recuperação cancela a operação, sem liberar arquivo parcial.
- Recuperação concluída persiste registro_excluido_recuperado e habilita leitura pelo programa e por Arquivos → Recuperados → registro_excluido.dat. Depois da cópia ao computador, a releitura não exige manter o SD conectado. Não há senha adicional, recuperação real de disco nem execução de programas externos.
- Texto em recursos/documentos/registro_excluido.tres, explicitamente provisório. Motivo do sequestro e urgência de fuga continuam aguardando aprovação narrativa; placeholders não definem responsáveis ou fatos canônicos. O texto técnico da porta não revela PIN.
- registro_recuperado.gd controla abertura/leitura/fechamento separadamente. Chegar ao final do texto visível ou da rolagem salva registro_excluido_lido. Abrir ou apenas recuperar não dispara mensagem. Fechar após leitura salva mensageiro_pendente e emite fechado_apos_leitura.
- pc_control reaproveitado para abrir o Control Mensageiro no evento ou retomar pendência ao reconstruir o computador. Interface fictícia com título azul, histórico, status online/offline, diálogo provisório do adendo e avanço por clique. Som simples reaproveita click_mouse.mp3.
- Persistência: mensageiro_iniciado, mensageiro_indice, mensageiro_pendente e mensageiro_concluido. Cada mensagem persiste o índice; interrupção retoma antes da conclusão. Releitura do registro não repete conversa concluída.
- Ao encerrar a conversa, o sinal conversa_concluida é emitido, mas ainda não chama concluir_fase(3) nem TransicaoFase: integração de progressão e painel da porta continuam na etapa seguinte, conforme escopo comunicado. PIN não definido nem implementado.
- Componentes novos: janela_arquivo.tscn como base visual reutilizável; recuperador, pasta_recuperados, registro_recuperado e mensageiro dentro do subviewport. Interfaces existentes, arquivo secreto e SQLite em res://data.db preservados.
- Validação: 37 verificações em tests/test_recuperacao.gd, 17 do ZIP, 18 do secreto e 23 do leitor SD, todas sem falhas. Incluem combinações inválidas de mídia/software, cancelamento, remoção de mídia, recuperação, leitura antes/depois de rolar, fechamento, notificação, resposta, retomada e não repetição; Progresso e Objetos conferidos iguais após rollback.
- Teste manual: coletar BACKUP-03 e encaixar no gabinete; computador → Arquivos → arquivo.zip → recuperador.exe → Recuperar registro → Abrir registro_excluido.dat. Ler até o final e fechar; avançar conversa até offline e encerrar. Voltar a Arquivos → Recuperados para reler sem repetir o mensageiro. Fase 3 permanece ativa até a futura integração da conclusão.

### Visual provisório do mensageiro
- Interface inspirada em mensageiros antigos: lateral com o contato Desconhecido, cabeçalho azul, balões recebidos à esquerda e enviados à direita, área inferior com resposta predefinida e botão Enviar. Status online/offline aparece no contato e no rodapé.
- Gatilho, diálogo e persistência preservados. Validação atualizada: 40 verificações de recuperação/mensageiro, sem falhas; SQLite preservado após rollback.

- Acesso pelo botão Messenger da barra de tarefas do desktop. Antes do gatilho abre vazio; durante a conversa retoma o índice; após concluir permite reler o histórico offline sem emitir nova conclusão. Botão Minimizar retorna ao desktop sem encerrar a conversa. Teste de recuperação atualizado: 46 verificações sem falhas. Save conferido na Fase 3, diante do monitor, preservando os puzzles já resolvidos.

- E-mails atualizados para as seis imagens novas em computador_telas. Assuntos correspondem aos cabeçalhos das imagens. Classificação aprovada pelo conteúdo: legitimo1/2, phishing1/4 são golpes; phishing2/3 são legítimos. AtlasTexture enquadra o conteúdo sem alterar as imagens originais; visualizador mantém proporção e títulos longos quebram linha. Seis recursos cadastrados na cena, preservando a classe dos quatro índices anteriores. Teste tests/test_emails.gd: 29 verificações, sem falhas, incluindo preenchimento de sorteio antigo, classificação e rollback do save.

### Reintegração após atualização de 02/11/2026
Sistemas locais recuperados do stash do GitHub Desktop e integrados aos novos áudios. Seis e-mails finais 01 a 06 substituem os anteriores; abertura ajustada à largura, rolagem/zoom e feedback à esquerda. Pesquisa e conflito da lixeira corrigidos. Auditoria detalhada em docs/AUDITORIA_ATUALIZACAO_2026-11-02.md. Total validado: 330 verificações sem falhas. Banco atual preservado na Fase 1; banco anterior na Fase 3 continua no stash.

### Correção das setas laterais
A referência antiga uid://du3u5e5blrq5k para a parede oeste não corresponde ao UID atual da cena. Destinos de navegação serializados convertidos para caminhos res:// válidos. Setas laterais agora validam destino, evitam troca dupla e conferem o retorno real da troca diferida. WordDropArea volta a MOUSE_FILTER_IGNORE ao terminar arrasto, liberando cliques nas áreas 2D. tests/test_setas.gd: 19 verificações sem falhas, com volta completa pelas quatro paredes nos dois sentidos e rollback do save.

### Padronização dos cenários
Auditoria das 62 cenas; 18 cenas de exploração com enquadramento comum e configurações acessíveis. Acrescentado botão nas seis telas que faltavam. Corrigidos monitor, mala aberta, limites das telas virtuais e página de Vigenère. Relatório: docs/REVISAO_CENAS_2026-11-02.md. Validação final: 428 verificações sem falhas em nove testes, com rollback do progresso.

### Fotos nas gavetas e ícones do inventário
Fotos nos containers das paredes leste/sul passam a usar uma camada abaixo da frente da respectiva gaveta; fotos soltas no mundo mantêm sua camada normal. Quatro espaços do inventário usam margens de 8 px, escala unitária e proporção preservada, incluindo a fita. Espaços vazios limpam tooltip. Validação: 36 verificações de ícones, 58 de fotos/calendário e 50 do quadro, sem falhas.

### Conclusão da Fase 3 pelo Messenger
O sinal conversa_concluida agora encerra a Fase 3 pelo sistema existente, mostra Objetivo concluído, salva o progresso no SQLite e transita à seleção de fases. O botão Encerrar conversa só conclui após a última mensagem e o status offline; minimizar, abrir aplicativo vazio e reler histórico não concluem novamente. Desktop exibido ao encerrar. Fase 4 liberada com destino válido na ParedeNorte; painel/PIN continuam pendentes. Corrigidos os destinos padrão inexistentes das fases 3/4. tests/test_recuperacao.gd: 50 verificações sem falhas, incluindo animação, persistência, seleção de fases e rollback.

### Reintegração após 64086d7
Trabalho recuperado do stash 8e433f4, preservando os efeitos de áudio novos e os ajustes de volume. Conflitos da lixeira, toca-fitas e parede oeste resolvidos. Messenger continua concluindo a Fase 3 após a última mensagem. Banco atual mantido integralmente; backup em backups/integracao_64086d7/data_antes.db. Validação: 624 verificações sem falhas em 16 testes. Relatório: docs/REINTEGRACAO_64086d7.md.

### Artes novas da mala e roteador
Mala do cenário usa recorte de maletazoomfechada.png; zoom alterna maletazoomfechada/maletazoomaberta no mesmo enquadramento com fundo da sala. Colisão e som de chave preservados. Roteador usa roteadordefrente no inventário e solto; dentro da mala usa roteadornamala com hitbox própria. O recurso res://recursos/roteador.tres e o marcador persistido foram mantidos para preservar saves. Excluídos roteadorFeio.webp e seu .import. Validação: 167 verificações de cenas, 44 de ícones, 10 de áudio/mala e 19 de navegação, sem falhas.

### Correção do close da mala
O zoom deve aproximar o cenário junto do objeto. O fundo usa agora um recorte ampliado do canto inferior direito da sala (porta/parede/chão), sem mostrar a porta inteira nem reutilizar a mala antiga embutida no fundo. Artes fechada/aberta e roteador compartilham a mesma transformação para manter apoio no chão e posição coerente. Enquadramento e regras de chave preservados.

### Enquadramento original confirmado pelo usuário
Referência aprovada: zoom_malafechada.png. Voltou a ser o fundo na composição original, substituindo o recorte da sala da tentativa anterior. A mala antiga embutida foi coberta por faixas de parede/porta/chão da mesma textura por composição de cena, mantendo o arquivo original intacto. Artes novas fechada/aberta e roteador compartilham transformação no close; moldura limita o primeiro plano aberto. Conferência visual com capturas reais do Godot e 178 verificações sem falhas; SQLite em rollback nos testes.


## Atualização da chave — 03/11/2026

A chave atual de secreto.dat é GWJK, substituindo NEXO nas etapas anteriores deste histórico. Na ordem de nascimento: Augusto = G, Helena = W, Marina = J, Lucas = K. O criptograma foi regenerado; a senha de arquivo.zip permanece 24091998.
