# Reintegração após o commit 64086d7

## Origem e método

O GitHub Desktop guardou o trabalho anterior em `stash@{0}` (`8e433f4a253073c8f72e399b4483ac915b85e9e3`), baseado no commit `015b467`. O commit novo `64086d7` acrescenta efeitos de chave/mala, encaixe da fita e beep do painel, além de ajustes de volume e início dos sons.

As alterações foram comparadas arquivo a arquivo e integradas em três vias, sem aplicar/pop global do stash. Todos os arquivos de conteúdo do stash voltaram. O stash permaneceu intacto; não houve commit, push nem reset.

## Recuperado

- Enquadramento das cenas, botões de configurações e navegação por caminhos res://.
- Câmera do teto ligada/desligada conforme o conserto do PC.
- Ícones proporcionais do inventário e fotos atrás das frentes das gavetas.
- Seis e-mails novos, títulos, zoom/rolagem e feedback lateral. As três imagens JPG antigas e seus .import foram removidos novamente.
- Busca dos sites e Vigenère com normalização de quebras de linha.
- Cuco interativo, BACKUP-03, leitor SD do gabinete, recuperador e registro recuperado.
- Messenger acessível pelo menu Iniciar, gatilho ao fechar o registro lido, histórico persistente e conclusão da Fase 3 com objetivo concluído, seleção de fases e Fase 4 liberada.

## Conflitos resolvidos e novidades preservadas

| Arquivo | Integração |
|---|---|
| lixeiraZoom.tscn | Mantido o UID novo e o player de som na raiz recebidos no commit; restaurados enquadramento, configurações e destino da seta. O script aponta para o player que existe na cena. |
| zoom_tocafitas.tscn | Mantidos o novo som de encaixe e listener; restaurados enquadramento, seta e configurações. |
| parede_oeste.gd | Clique abre novamente o zoom do cuco. O som toca ao resolver o relógio; início de 2,75 segundos do commit foi aplicado nesse evento. |

Ajustes de áudio das gavetas e volumes do AudioManager foram preservados. O som de chave da mala agora toca tanto pelo clique com chave quanto pelo encaixe, somente quando a abertura é válida. No toca-fitas, retirar a fita cancela a reprodução que aguardava o delay, evitando som sem fita.

## Banco e backup

O banco atual `res://data.db` não foi substituído. Uma cópia anterior à integração está em `backups/integracao_64086d7/data_antes.db`.

- Banco atual: Fase 1, última cena start, nenhuma fase concluída.
- Banco no stash: Fase 3, última cena zoom_monitor, fases 1 e 2 concluídas.

A restauração do banco antigo não faz parte desta integração: as duas partidas continuam disponíveis. O conteúdo completo da tabela Progresso do banco atual foi comparado com o backup e preservado.

## Validação

16 testes, 624 verificações, 0 falhas.

| Teste | Verificações | Falhas |
|---|---:|---:|
| audio_commit | 9 | 0 |
| cuco | 33 | 0 |
| efeitos_audio | 12 | 0 |
| emails | 47 | 0 |
| fotos_calendario | 58 | 0 |
| guias_pc | 29 | 0 |
| icones_inventario | 36 | 0 |
| layout_cenas | 164 | 0 |
| navegador | 17 | 0 |
| quadro_fotos | 50 | 0 |
| recuperacao | 50 | 0 |
| sd_gabinete | 23 | 0 |
| secreto | 18 | 0 |
| setas | 19 | 0 |
| vigenere | 42 | 0 |
| zip | 17 | 0 |

Os testes de estado usam transações SQLite com rollback; o teste de Messenger verifica inclusive a chegada à seleção de fases. O teste de layout carrega as 62 cenas e confere as 18 cenas de exploração. O teste novo de áudio cobre mala, painel do chão e encaixe/retirada da fita durante o delay. Os avisos antigos de UNIQUE em Arrays/Cenarios continuam na inicialização e não são erros de regressão desta integração.
