# EV4S3 — Contexto atualizado para o Codex (Fases 3 e 4)

**Atualização:** 30/10/2026  
**Objetivo:** registrar o planejamento aprovado e o ponto exato de continuidade do Codex. Este arquivo **substitui o planejamento de puzzles** do documento `CONTEXTO_EV4S3_FASES_3_E_4.md` quando houver conflito. Não é prova de que os recursos planejados já estejam no repositório.

> **Primeira ação do Codex:** auditar cenas/scripts reais e verificar o último trabalho reportado. Não recriar `secreto.dat` ou alterar o banco de dados antes de verificar a implementação existente.

## 1. Visão geral

EV4S3 é um jogo de investigação e escape room em **Godot 4 / GDScript**, com objetos físicos e investigação digital. O protagonista está preso em um ambiente associado à família **Lin Barde**.

| Fase | Papel | Como termina |
|---|---|---|
| 1 | Explorar o local, resolver puzzles físicos e consertar/ligar o computador | Computador operacional |
| 2 | Investigar o PC, classificar e-mails como phishing/legítimos | Descoberta de `secreto.dat` e aviso de criptografia |
| 3 | Decifrar uma mensagem, relacionar fotos e documentos, investigar o relógio-cuco | Ler `registro_excluido.dat` e descobrir por que foi sequestrado e por que deve fugir |
| 4 | Abrir a saída por PIN usando pistas recontextualizadas | Porta destrancada, fuga e cena final |

**Limitação essencial:** pouco tempo de desenvolvimento. Manter exploração física interessante; remover passos redundantes e mecanismos paralelos de senha.

## 2. Estado de implementação informado pelo Codex (não repetir trabalho)

O Codex relatou o seguinte estado após sua última etapa:

> "Mantive o banco em `res://data.db` e implementei esta etapa:
> - `secreto.dat` aparece em **Arquivos** após sua descoberta.
> - Aceita palavra-chave e decifra com Vigenère real.
> - Mostra erro para chave incorreta e animação ao acertar.
> - Salva a decifragem e permite releitura.
> **17 verificações passaram**, preservando sua partida.
> Para testar: abra **Arquivos → secreto.dat** e use `NEXO`. O texto está identificado como provisório.
> Após validar essa tela, seguimos para o calendário e as quatro fotografias."

**Classificação:** implementação **relatada pelo Codex**, ainda dependente de validação prática pelo usuário. Os 17 testes são afirmação do Codex, não testes executados neste documento.

### Cuidados técnicos imediatos

- **Banco atual declarado pelo Codex:** `res://data.db`. O planejamento antigo citava `user://data.db`; **não alterar, migrar, copiar ou recriar automaticamente o banco**. Conferir como `Database`, `Progresso`, `SaveManager` e demais classes realmente tratam esse caminho, e preservar a partida. Se houver divergência, relatar antes de modificar.
- SQLite é a fonte de verdade para estados persistentes; não criar salvamento JSON paralelo.
- Reaproveitar `GlobalSingleton.concluir_fase(indice_fase)` se for a API de conclusão atual, após inspecionar a assinatura e seu comportamento.
- Manter os e-mails já classificados acessíveis; não modificar sorteios e persistência da Fase 2 para implementar a Fase 3.
- O texto recuperado de `secreto.dat` ainda é **provisório**: é esperado revisá-lo em uma etapa narrativa posterior, sem refazer o algoritmo Vigenère.
- Priorizar scripts/funções completos, integrados e compactos; implementar incrementalmente e orientar como testar.

## 3. Decisões definitivas de escopo

### Manter

- **Cifra de Vigenère real** e chave `NEXO` para `secreto.dat` (já implementada segundo o Codex).
- Pesquisa educativa no navegador fictício: Vigenère/cifra polialfabética (sem fingir que é criptografia moderna segura).
- Referência `REF-CASA-03` no arquivo, levando ao calendário através de `registro_equipamentos.txt`.
- Calendário com datas e instrução **"do mais velho para o mais novo"**.
- **Quatro fotografias físicas separadas, espalhadas por cômodos existentes**: não substituir por álbum único. Uma letra por fotografia, de preferência no verso, acessível por zoom/virar foto.
- `aniversarios.txt` com nascimento de cada familiar, para ordenar as letras e obter `NEXO`.
- `arquivo.zip` protegido por senha encontrada no texto decifrado (`24091998`, valor anterior ainda sujeito à narrativa final).
- `imagem.png` **dentro do ZIP**, apontando visualmente para um detalhe do **relógio-cuco já existente**.
- **Investigar fisicamente o relógio-cuco** e descobrir a chave curta `91BC` em cartão/compartimento simples.
- `registro_excluido.dat` como último arquivo a abrir, revelando o motivo do sequestro e a urgência de fuga.
- Fase 4 com PIN numérico na porta, teclas desgastadas + pista antiga e ambígua em gaveta.

### Simplificar/remover do caminho obrigatório

- Remover a montagem de chave em duas partes (`chave.rec`, `7F3A` + `91BC` = `7F3A91BC`); **não implementar `chave.rec` como requisito**. A chave final do registro é somente **`91BC`**.
- Não criar puzzles adicionais de acróstico, A1Z26, Cifra de César, linha do tempo com ordenação ou "quem está mentindo" como minijogo independente.
- Não espalhar novas travas ou senhas intermediárias sem necessidade.
- Não eliminar nem apagar assets/scripts já presentes sem antes inspecionar dependências; se `chave.rec` existir, torná-lo não obrigatório, preservando dados até decisão explícita.
- Não criar álbum único: as fotos separadas foram expressamente mantidas.

## 4. Fase 2 → Fase 3: ponto de entrada

Conclusão desejada da Fase 2:

```text
Classificar corretamente os e-mails → confirmar
  → NOVOS ARQUIVOS ENCONTRADOS: secreto.dat
  → [Visualizar arquivo]
  → ERRO: arquivo criptografado; chave necessária
  → [OK]
  → objetivo concluído → seleção de fases → Fase 3
```

A caixa de e-mails permite classificação revisável e marcação de lidos; o popup de conclusão foi objeto de integração e seu estado real deve ser inspecionado. **Não presumir que o popup está ou não resolvido.** `secreto.dat` já aparece em **Arquivos** quando descoberto, segundo o Codex.

## 5. Fase 3 — passo a passo DEFINITIVO para implementação

### Passo 1 — `secreto.dat` (JÁ RELATADO COMO IMPLEMENTADO)

- O arquivo existe no programa **Arquivos**, visível após a descoberta.
- Mostra que contém texto cifrado com **Cifra de Vigenère** e a referência **`REF-CASA-03`**.
- Aceita palavra-chave, valida entrada, decifra com algoritmo real, anima sucesso, persiste e permite releitura.
- **Palavra-chave: `NEXO`.**
- **Próxima ação:** somente testar no Godot e checar persistência/releitura; não implementar de novo.

### Passo 2 — Navegador fictício (verificar se já existe resultado)

O jogador pode pesquisar **Vigenère**, **Cifra de Vigenère** ou **cifra polialfabética**, entendendo que a cifra histórica usa palavra-chave. Não dar a chave específica. Normalizar acentos/caixa na busca se já houver infraestrutura para isso. Pesquisas opcionais podem continuar, mas não são bloqueios obrigatórios.

### Passo 3 — `registro_equipamentos.txt`

Documento no computador, área administrativa, apontando:

```text
REFERÊNCIAS RESIDENCIAIS
CASA-01 — escritório
CASA-02 — arquivo
CASA-03 — calendário
```

Objetivo do jogador: relacionar **`REF-CASA-03` → `CASA-03` → calendário físico**. Reusar visualizador atual; não construir aplicativo novo.

### Passo 4 — Calendário físico

- Fica próximo do post-it já existente no cenário.
- Exibe as quatro datas de aniversário de julho (dias e meses marcados).
- Abaixo, dica **"do mais velho para o mais novo"**.
- A dica indica uma ordem de pessoas, não entrega letras.
- Implementar como interação simples de zoom/exame reutilizando sistema atual.

### Passo 5 — `aniversarios.txt`

Arquivo pessoal com:

```text
Augusto Lin Barde — 18/07/1968
Helena Lin Barde — 07/07/1973
Marina Lin Barde — 24/07/1998
Lucas Lin Barde — 12/07/2004
```

Ordenação do mais velho ao mais novo: **Augusto → Helena → Marina → Lucas**.

### Passo 6 — Quatro fotografias físicas, SEPARADAS

As quatro fotografias estarão em **cômodos já existentes**, sem exigir cenas adicionais de ambiente. Cada uma tem um retrato, uma identidade reconhecível e **uma letra visível ao virar/examinar o verso**. Não exigir tinta invisível ou ferramenta extra; pode reutilizar uma cena/script genérico de foto parametrizado.

| Fotografia | Letra no verso |
|---|---|
| Augusto | N |
| Helena | E |
| Marina | X |
| Lucas | O |

As localizações específicas devem ser escolhidas **depois de examinar o mapa/cenas reais**, de preferência aproveitando gavetas e objetos pouco utilizados. **Não inventar caminhos de cena nem assumir que quatro fotos já existem.**

Com as datas, jogador forma **NEXO**, sem o jogo reorganizar automaticamente as fotos. Não precisar criar interface drag-and-drop de ordenação.

### Passo 7 — Decifrar `secreto.dat` (REUTILIZAR IMPLEMENTAÇÃO)

Voltar a **Arquivos → secreto.dat**, inserir `NEXO`, ler o texto recuperado. Sua última parte precisa fornecer a senha de **`arquivo.zip`**: `24091998` (planejada; confirmar ao escrever a versão final). O texto provisório já implementado pode ser adaptado **sem refazer a cifra**.

### Passo 8 — Abrir `arquivo.zip`

O ZIP está visível no computador, mas protegido por senha. Usar `24091998` para abrir. **Conteúdo obrigatório simplificado:**

```text
arquivo.zip
└── imagem.png   (detalhe reconhecível do relógio-cuco)
```

Pode existir material extra de ambientação se já implementado, mas **nenhum `chave.rec` obrigatório**. O arquivo `registro_excluido.dat` permanece separado na área **Recuperados**, bloqueado até receber a chave encontrada no relógio. Evitar duplicar ZIP/registro.

### Passo 9 — Identificar e investigar o relógio-cuco

Abrir `imagem.png` mostra um detalhe identificável do relógio-cuco físico já presente em uma das salas. O jogador visita esse relógio, examina o detalhe/compartimento e encontra um pequeno cartão, por exemplo:

```text
RECUPERAÇÃO DE REGISTROS
Arquivo: registro_excluido.dat
Chave: 91BC
```

Implementação mínima: um zoom/interação no relógio-cuco existente e exibição de cartão/imagem. **Sem minigame novo no relógio.**

### Passo 10 — Recuperar `registro_excluido.dat`

- Arquivo separado visível no computador em **Recuperados** (ou localização equivalente já implementada).
- Ao tentar abrir, pede **uma única chave de recuperação: `91BC`**.
- Entrada correta libera conteúdo; persistir estado de acesso/leitura, usando o mecanismo de progresso atual.
- **Não exigir `7F3A91BC`; não usar a chave dividida anterior.**

### Passo 11 — Revelação narrativa e conclusão

O registro informa explicitamente:

1. **Por que o protagonista foi sequestrado e está nesse local.**
2. **Por que precisa fugir agora.**
3. Que **o computador energiza o sistema da porta**, mas a fechadura continua exigindo autenticação.
4. Que o **painel à direita da porta controla o acesso**.
5. Uma contextualização discreta para as pistas antigas da Fase 4 (desgaste de teclas e anotação na gaveta), **sem dizer o PIN**.

**Em aberto:** os detalhes definitivos do crime, dos responsáveis e o texto narrativo integral. Não transformar sugestões anteriores (manipulação de registros, lista de vítimas, responsável dentro da casa) em fatos canônicos sem aprovação. Pode usar um texto claramente marcado como provisório.

Concluir a Fase 3 **após o jogador efetivamente ler a revelação**, e executar a transição atual de objetivo concluído para seleção de fases, liberando a Fase 4.

### Fluxograma resumido

```text
Fase 2 concluída → secreto.dat encontrado
    ↓
Fase 3: secreto.dat → Vigenère + REF-CASA-03 [JÁ RELATADO IMPLEMENTADO]
    ↓
Navegador: aprender o que é Vigenère
    ↓
registro_equipamentos.txt → CASA-03 = calendário
    ↓
Calendário → quatro datas + "do mais velho para o mais novo"
    ↓
aniversarios.txt + 4 fotografias físicas em cômodos separados
    ↓
Letras ordenadas → NEXO
    ↓
Decifrar secreto.dat [JÁ RELATADO IMPLEMENTADO] → senha do ZIP
    ↓
Abrir arquivo.zip → imagem.png (relógio-cuco)
    ↓
Investigar relógio-cuco → cartão com chave 91BC
    ↓
Abrir registro_excluido.dat com 91BC
    ↓
Revelação do sequestro + necessidade de fuga
    ↓
FASE 3 CONCLUÍDA → FASE 4
```

## 6. Fase 4 — manter o planejamento aprovado

### Premissa

- O computador fornece energia à porta, mas ela permanece trancada.
- À direita há um painel anteriormente parecido com uma imagem genérica; na fase final, ganha interação/zoom de teclado com **PIN de quatro dígitos**.
- O jogador deve perceber **quatro teclas mais desgastadas** e deduzir quais dígitos compõem o PIN.
- Uma **anotação antiga e ambígua em gaveta**, acessível desde antes, sugere a ordem da combinação; só ganha significado completo após a revelação do registro na Fase 3.
- Um exemplo anterior foi `2, 5, 7, 9` e ordem do maior para o menor = `9752`, **mas isso é apenas exemplo**, não PIN definitivo.

### Evitar

- Não colocar lista completa dos dígitos **e** ordem explícita em documentos já disponíveis na Fase 1.
- Não tornar a Fase 3 irrelevante permitindo resolver trivialmente a saída antes da revelação.
- Não adicionar interruptor de retenção, segunda trava, novo algoritmo criptográfico ou um segundo PIN.
- Não obrigar o jogador a recolher todos os objetos de ambientação para conseguir fugir.

### Passo a passo

```text
Ler registro_excluido.dat e compreender a urgência de fuga
    ↓
Fase 4 liberada; painel passa a ser examinável como teclado
    ↓
Investigar desgaste nas quatro teclas
    ↓
Relembrar/encontrar bilhete ambíguo na gaveta
    ↓
Inferir a ordem, digitar o PIN correto
    ↓
Porta destranca → abertura → cena final
```

### Gavetas e objetos decorativos

- **Uma gaveta útil:** bilhete com pista vaga, por exemplo: “Ele sempre começa pelo maior. Nunca entendi essa mania de terminar pelo menor.” Não citar "PIN" ou "PORTA-01" nela.
- **Outras gavetas:** contas, envelopes, pilhas ou papéis narrativos opcionais. Não forçar cada gaveta a ser essencial.
- Esses objetos podem existir desde cedo e ganhar significado sem que o jogo entregue a solução.

## 7. Estados a preservar no SQLite

Verificar estados já existentes antes de criar campos/chaves adicionais; conceitos distintos:

- `secreto.dat` descoberto/visível (Fase 2).
- `secreto.dat` decifrado/releitura (já relatado implementado).
- ZIP aberto.
- Cartão/chave do relógio-cuco encontrado, se necessário persistir.
- `registro_excluido.dat` desbloqueado **e lido**.
- Fase 3 concluída, Fase 4 liberada.
- Painel de PIN disponível e porta aberta/final concluído.

Em recarga da partida, não perder fotos, pistas e acesso a arquivos, nem repetir cutscenes já consumidas. Evitar alterar o local atual do SQLite ou salvar progresso só em RAM.

## 8. Próximas tarefas — seguir exatamente de onde o Codex parou

1. **Validar manualmente** `Arquivos → secreto.dat` com `NEXO`, testar chave inválida, animação, releitura e retomada da partida. A implementação é reportada e não deve ser reescrita sem bug.
2. Inspecionar as cenas atuais e implementar **calendário físico**, próximo do post-it existente, com datas e dica.
3. Adicionar/adequar `registro_equipamentos.txt` e `aniversarios.txt` no visualizador já existente, se não estiverem implementados.
4. Implementar **quatro fotografias separadas**, reutilizando uma cena genérica de zoom/verso e definindo locais com base no mapa real.
5. Conferir/polir resultado educativo no navegador sobre Vigenère, se faltar.
6. Ajustar o texto provisório de `secreto.dat` para entregar a senha do ZIP; **preservar lógica real de Vigenère**.
7. Implementar ZIP (se ainda não existir), `imagem.png` e interação simples com relógio-cuco, exibindo `91BC`.
8. Implementar bloqueio/leitura de `registro_excluido.dat` por `91BC` e conclusão da Fase 3.
9. Só então implementar o painel de PIN e o bilhete de gaveta da Fase 4.
10. Testar transições, persistência, cenas revisitadas e regressão da Fase 1 e da Fase 2.

**Não é necessário concluir tudo em uma intervenção.** Trabalhar em etapas pequenas; primeiro calendário + arquivos de pista + fotos.

## 9. Mensagem pronta para Codex

> Leia `CONTEXTO_EV4S3_ATUALIZADO_CODEX.md`, que substitui as versões antigas quando houver conflito. Você já relatou ter implementado `secreto.dat` com Vigenère real, chave `NEXO`, feedback visual e persistência; também disse que 17 verificações passaram e que o banco permaneceu em `res://data.db`. **Não refaça essa etapa e não mude o banco.** Primeiro confirme no repositório o que existe e me oriente a testar essa tela. Depois continue pelo calendário e pelas **quatro fotografias separadas**, reutilizando cenas existentes. A Fase 3 foi simplificada: após decifrar `secreto.dat`, a senha abre o ZIP com uma imagem do relógio-cuco; investigar o relógio fornece a chave curta `91BC` para `registro_excluido.dat`. Não usar `chave.rec` nem a combinação `7F3A91BC`. A Fase 3 termina ao ler a revelação. Mantenha a Fase 4 baseada no PIN e nas pistas antigas, sem entregá-lo antecipadamente. Evite refatorações e forneça código integrado e testes por etapa.
