# AuroraPet — Estrutura do Loop Principal V0.1

## Objetivo

O loop principal deve conduzir o jogador da introdução até um ciclo compreensível de cuidados, jogos, treino, combate contra Ecos, exploração do Deepworld e, posteriormente, a Jornada com EVA.

## Sequência de entrada

A sequência inicial permanece composta por BIOS com a logo AuroraPet, menu inicial, boas-vindas e introdução ao Deepworld, explicação dos controles, escolha de facção, seleção/eclosão do ovo, página de status e entrada no gameplay de cuidados. A abertura já possui essa estrutura em `OpeningFlow`; o ajuste necessário é reduzir a linguagem de tutorial explícito e transformar as orientações em objetivos contextuais curtos.

## Progressão do pet

| Fase | Conteúdo principal | Regra de acesso |
|---|---|---|
| Nascimento | Comer, cuidar e dormir | Disponível imediatamente |
| Primeira evolução | Jogos iniciais | Após concluir o cuidado inicial e alcançar o nível 2 |
| Desenvolvimento | Jogos adicionais e treino | Conforme nível e atributos |
| Combate | Sala de Treinos contra Ecos | Ao liberar a categoria Batalhar |
| Exploração | Mapa horizontal e encontros variáveis | Após liberar combate; começa na ilha inferior direita |
| Jornada EVA | Mapa vertical de capítulos e bosses | Após três batalhas de exploração e o encontro com EVA |

A vontade do pet nunca deve apontar para uma ação ainda indisponível. O gerador de vontades deve consultar a progressão atual antes de sortear entre jogos, treino ou outros desejos.

## Categoria Batalhar

A categoria Batalhar passa a conter três possibilidades progressivas:

| Opção | Função |
|---|---|
| **Sala de Treinos** | Tela de batalha atual contra Ecos. Serve para preparar o pet, testar golpes e enfrentar Ecos com nível crescente. |
| **Explorar Deepworld** | Mapa horizontal de ilhas. A exploração começa exclusivamente na ilha inferior direita. Cada entrada sorteia encontro, moeda ou XP adicional. |
| **Aventura com EVA** | Mapa vertical de progressão. Só aparece depois do encontro com EVA e da aceitação da ajuda. |

A tela atual de batalha deve ser renomeada internamente e visualmente para Sala de Treinos quando usada no modo de treino. A mesma base de combate pode ser reutilizada nos demais modos, recebendo um contexto explícito de encontro.

## Exploração do Deepworld

O mapa horizontal aprovado deve permanecer visualmente inalterado. Sua lógica precisa adicionar estado de desbloqueio. A ilha inferior direita é a primeira disponível. As outras ilhas são liberadas gradualmente depois do encontro com EVA, independentemente da resposta dada pelo jogador.

Cada exploração gera um código aleatório determinístico por sessão/seed e seleciona um resultado entre encontro com Deepmon, moeda ou XP adicional. Encontros com Deepmons usam a Sala de Treinos com nomenclatura de exploração e aumento gradual de nível.

Depois de três batalhas de exploração, o evento de encontro com EVA torna-se disponível. O jogador pode aceitar ou recusar a ajuda; a opção Aventura com EVA deve ser liberada após o evento, sem depender da escolha narrativa, conforme a regra de desbloqueio definida para o mapa.

## Jornada com EVA

A Jornada possui apenas batalhas contra Deepmons, com nível crescente até os bosses. O sprite estático do boss deve ser utilizado na cena de batalha. Ao derrotar um boss, EVA recupera um fragmento de memória e avança para o próximo estágio/evolução.

Se o jogador perder uma batalha de boss, o fluxo retorna ao lobby com uma mensagem curta informando que EVA o trouxe de volta. A derrota não apaga o progresso do capítulo, mas impede o avanço até uma nova vitória.

A ordem dos bosses no mapa vertical é, de baixo para cima: Gorgon Glitch, Prisma Guard, Core Overlord, Ignis Vectis, Arquiteto do Esquecimento e O Eco Absoluto. Entre cada boss existem três batalhas menores; a plataforma inferior é a base inicial.

## Estados persistentes necessários

O save deve manter, além do estado atual do pet e da Jornada EVA, o número de batalhas de exploração concluídas, se o encontro com EVA está disponível ou já ocorreu, quais ilhas estão liberadas, se a Aventura com EVA está disponível, o estágio atual da campanha e o contexto de batalha usado na última sessão.

## Critérios de aceitação

A sequência de introdução deve terminar na tela de cuidados. No nível inicial, o pet deve desejar apenas ações disponíveis. A categoria Batalhar deve apresentar a Sala de Treinos e a Exploração quando liberada, sem mostrar Aventura com EVA antes do encontro. A Exploração deve iniciar na ilha inferior direita. Após três batalhas, EVA deve aparecer como evento disponível. A Aventura com EVA deve abrir o mapa vertical e conduzir cada seleção a uma batalha real. Os bosses devem evoluir a dificuldade, conceder fragmentos e avançar a campanha somente após vitória. O mapa horizontal aprovado não deve sofrer alterações visuais.
