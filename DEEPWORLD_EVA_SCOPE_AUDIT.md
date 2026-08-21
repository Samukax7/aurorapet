# AuroraPet — Auditoria de Escopo Deepworld/Eva

**Data:** 21 de agosto de 2026
**Engine:** Godot 4.7.1
**Objetivo:** comparar o roteiro completo de Deepworld/Eva com o estado estável do projeto antes de reconstruir a cena de batalha.

## 1. Diagnóstico executivo

A visão do documento faz sentido e é compatível com o DNA já definido para o AuroraPet: um V-Pet de cuidado contínuo, com geração procedural, evolução, minijogos, RPG e batalhas contra Ecos. A combinação também está coerente do ponto de vista de identidade do projeto: **Game Boy/V-Pet** para a apresentação e a rotina, **Tamagotchi** para necessidades e cuidados, **Pokémon/Digimon** para ovos, evolução e encontros, e **D&D/D20** para a camada de aleatoriedade e cálculo de combate.

O problema atual não é a ideia do jogo. É a separação entre duas camadas que ainda não foram conectadas: a lógica de batalha já existe como um controlador técnico, enquanto o roteiro descreve uma **cena de batalha encenada no Deepworld**, com o pet do jogador visível, um Eco visualmente presente, plataforma, fundo e uma camada de interface sobreposta. Por isso a tela atual pode funcionar tecnicamente e, ao mesmo tempo, parecer completamente diferente da referência.

> **Conclusão principal:** não devemos continuar apenas ajustando fontes, cores ou caixas da cena atual. O próximo bloco precisa reconstruir a composição da batalha, mantendo a lógica existente, mas adicionando combatentes visuais e uma integração explícita com o palco do Deepworld.

## 2. O que já está estável no projeto

| Sistema | Estado atual | Relação com o roteiro |
|---|---|---|
| Cascata principal | `main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn` | Compatível com a arquitetura-base do documento |
| Console físico e controles | Estáveis, com D-pad e botões coloridos | Compatível com a proposta Game Boy/V-Pet |
| Pet modular | `pet.tscn` possui base, cauda, asas, orelhas, olhos, identidade, stats, skills e evolução | Compatível e reutilizável na batalha |
| Fundo e plataforma | Deepworld possui fundo padrão, fundos por facção e plataforma fixa | Compatível com a regra de plataforma permanente |
| Geração procedural | Identidade, seed, facção, paleta e peças modulares já existem | Compatível, embora o roteiro ainda cite camadas futuras que não estão todas presentes |
| Necessidades | Fome, energia, saúde, humor, sono, doença e sujeira | Compatível com a camada V-Pet |
| Progressão | XP, níveis, habilidades, Resistência e sete estágios oficiais | Compatível com o núcleo do AuroraPet |
| Minijogos | Jokenpô, Jogo da Velha e 2048 | Compatível com o ciclo de brincar |
| Save | Save local v3 com identidade, necessidades, progressão, inventário, moedas, diário e conquistas | Compatível como base offline da versão V 0.0 |
| Código DEV | `DEV` inicia EVA de teste no nível máximo, sem sobrescrever o save real | Útil para desenvolvimento, mas não é ainda a EVA narrativa |
| Batalha | Turnos, quatro comandos, D20, iniciativa, EN, dano, status, guarda, fuga e Eco procedural | A lógica-base está implementada; a composição visual está incompleta |

A implementação atual confirma que o núcleo do V-Pet está mais avançado do que o roteiro MVP original. O projeto não precisa recomeçar. Ele precisa adicionar a camada Deepworld/Eva sobre sistemas que já foram validados.

## 3. A divergência que causa o problema visual da batalha

Na cena `console_frame.tscn`, o `Deepworld`, o `PetUI` e a `BatalhaDeExploracao` são instanciados como irmãos dentro de `ScreenContent`. Isso não é necessariamente errado: permite manter a batalha como uma tela de interface sobreposta sem quebrar a cascata. Porém, no momento de abrir a exploração, `console_controller.gd` esconde tanto `PetUI` quanto o nó inteiro `Deepworld`.

A cena de batalha atual contém um `BattleCard` independente com painéis, barras, quatro botões e log. Ela não contém uma instância do `pet.tscn`, não possui uma cena de Eco, não apresenta uma plataforma, não mostra o fundo do Deepworld e não possui uma camada para a Eva. O inimigo é criado apenas como dados: nome, facção, nível, HP e atributos. Consequentemente, a interface mostra o texto “PET” e “ECO”, mas não mostra os personagens que deveriam ocupar o campo.

| Elemento da referência | Estado atual | Correção necessária |
|---|---|---|
| Pet do jogador visível no campo | Ausente; o Deepworld inteiro é ocultado | Manter um palco Deepworld ativo durante a batalha ou mostrar um palco de batalha dentro dele |
| Eco visível como oponente | Ausente; existe apenas um dicionário de atributos | Criar `eco_combatente.tscn` usando as camadas visuais do pet com tratamento de Eco |
| Pet e Eco em posições opostas | Ausentes | Criar âncoras visuais esquerda/direita no palco |
| Fundo e plataforma | Ocultados ao abrir a batalha | Exibir fundo padrão ou fundo de exploração e manter a plataforma fixa |
| Caixa de log do Eco | Não existe como área própria | Separar log do Eco e log do Pet na composição da referência |
| Status do pet | Existe apenas como painel textual resumido | Manter painel legível, conectado aos atributos reais |
| Quatro ações | Existem e a lógica está funcionando | Reposicionar na grade 2×2 da referência, sem transformar os botões em uma lista técnica |
| D20 visual | A rolagem existe na lógica | Adicionar dado, resultado e feedback visual depois que o palco estiver correto |
| Eva | Não existe como NPC de cena | Adicionar separadamente como camada narrativa, não confundir com o pet DEV |

## 4. O que o roteiro Deepworld/Eva acrescenta

O documento fornecido amplia o AuroraPet em três níveis diferentes. O primeiro é a **batalha de exploração**, na qual o pet luta contra um Eco visualmente espelhado. O segundo é a **campanha de Eva**, com seis memórias, seis capítulos, escolhas de ajudar ou recusar e evolução narrativa. O terceiro é a **presença de Eva como companheira**, com formas próprias, afeição, habilidades passivas e participação no palco.

Esses níveis não devem ser implementados todos dentro de `batalha_de_exploracao.gd`. A batalha deve continuar responsável pelo loop de turno. A campanha precisa de um gerenciador próprio. A presença visual de Eva precisa de uma cena própria. O roteiro já sugere essa separação com `EvaJourneyManager`, `BattleSystem` e `DeepworldController`, mas o projeto atual ainda possui apenas a versão estreita do `DeepworldController` e um controlador de batalha autocontido.

### 4.1 EVA de desenvolvimento versus EVA narrativa

É importante separar dois conceitos que hoje usam o mesmo nome:

| Conceito | Função |
|---|---|
| EVA DEV | Pet procedural neutro de teste, criado pelo código `DEV`, com nível 100 e conteúdo desbloqueado |
| EVA narrativa | Personagem raposa cósmica, companheira da campanha, com afeição, memórias, escolhas e formas próprias |

O código DEV está correto como ferramenta de desenvolvimento. Ele não deve ser convertido automaticamente na EVA narrativa. A EVA narrativa precisa de uma identidade persistente própria, uma cena `EvaNPC.tscn` e um `EvaJourneyManager` separado. Assim, quando o conjunto visual especial estiver pronto, ele poderá entrar como recompensa sem alterar o pet procedural comum.

## 5. Conflitos de nomenclatura e regras que precisam ser resolvidos

O projeto estável possui nomes oficiais aprovados para o pet do jogador: **Bebê, Criança, Juvenil, Jovem, Adulto, Forma Máxima e Entidade Cósmica**. O documento de Eva descreve outra linha: **Bebê, Criança, Adolescente, Jovem Adulta, Anciã, Lendária e Deusa Raposa**. Isso não precisa ser um conflito se forem tratados como dois sistemas diferentes.

A recomendação é manter `PetEvolution` com a nomenclatura oficial do AuroraPet e criar um enum próprio para os estágios de Eva. O pet do jogador pertence ao sistema de evolução do V-Pet; Eva pertence ao arco narrativo das seis memórias.

Também existe uma diferença de balanceamento na Guarda. O roteiro propõe prioridade `+10`, enquanto a implementação estável utiliza prioridade simples `+1` e redução de dano de 60%. Como a lógica atual já foi testada, a recomendação é não trocar esse valor durante a reconstrução visual. Primeiro devemos montar o palco e validar a experiência. O valor `+10` pode ser avaliado depois em uma rodada específica de balanceamento.

O roteiro também menciona uma resolução interna de `895×815`, enquanto a versão Web e a referência permanente do console trabalham com viewport lógica de `1080×650`, com o `ScreenContent` escalonado dentro da moldura física. A reconstrução visual deve usar a coordenada local real do `ScreenContent` e não importar diretamente as dimensões literárias do documento, para evitar o problema de telas grandes ou pequenas que já ocorreu no Quarto Cósmico.

## 6. Arquitetura recomendada para a próxima etapa

A solução mais segura preserva a cascata e evita que a lógica precise criar ou remover peças modulares por código.

```text
main.tscn
└── console_frame.tscn
    └── ScreenContent
        ├── Deepworld
        │   ├── Cenario
        │   ├── Plataforma
        │   ├── Paisagem/Pet                 ← pet normal do V-Pet
        │   ├── BattleStage                  ← novo palco interno
        │   │   ├── PlayerCombatant           ← instância de pet.tscn
        │   │   └── EcoCombatant               ← instância de eco_combatente.tscn
        │   └── EvaNPC                        ← futuro, separado da batalha
        ├── PetUI                             ← HUD do ciclo V-Pet
        ├── BatalhaDeExploracao               ← UI de combate sobreposta
        └── OpeningFlow
```

`pet.tscn` continua sendo a fonte das peças do pet. `PlayerCombatant` pode ser uma instância visual da mesma cena, configurada para refletir a identidade e a aparência do pet ativo. `EcoCombatant` pode instanciar a mesma base modular com uma paleta e efeitos de Eco, sem criar ou remover nós de peças durante o jogo.

A cena de batalha deve permanecer como UI sobreposta para preservar o contrato do `ConsoleController`, mas o controlador não deve mais desligar o `Deepworld` inteiro. Em vez disso, ao entrar na batalha, ele deve ocultar apenas o `Paisagem/Pet` normal e ativar o `BattleStage` com os dois combatentes. Ao sair, o processo inverso restaura o V-Pet. Essa troca mantém o mundo e a plataforma visíveis e permite uma composição semelhante à referência sem duplicar o console.

A lógica de `batalha_de_exploracao.gd` deve receber referências aos nós visuais ou a um adaptador de combatente, mas continuar responsável somente por estado de batalha, HP, EN, iniciativa, D20, dano, status e sinais. A nova cena de Eco deve cuidar do visual do Eco; não deve conter regras de dano.

## 7. Ordem segura de implementação

| Ordem | Bloco | Objetivo | Risco |
|---:|---|---|---|
| 1 | Palco de batalha | Adicionar `BattleStage`, âncoras, plataforma/fundo ativos e dois slots de combatente | Médio |
| 2 | Reutilização do pet | Mostrar uma instância visual do pet ativo no lado do jogador | Médio |
| 3 | Eco visual | Criar o Eco espelhado a partir das peças existentes, com paleta/efeito distinto | Médio |
| 4 | Transição do controlador | Parar de ocultar o Deepworld inteiro e ativar/desativar apenas o palco de batalha | Alto |
| 5 | UI da referência | Reorganizar log do Eco, log do Pet, status e quatro ações em relação ao campo | Médio |
| 6 | D20 visual | Exibir dado, resultado e efeito de crítico/falha sem alterar a regra já testada | Baixo |
| 7 | Eva narrativa | Criar `EvaJourneyManager`, save de afeição/memórias e `EvaNPC.tscn` | Alto |
| 8 | Campanha | Implementar capítulos, escolhas, fragmentos, guardiões e evolução narrativa | Muito alto |

A etapa imediata não deve incluir os seis capítulos, o minigame de combinar cores, itens de Eva ou formas especiais. Esses elementos dependem de uma camada de campanha que ainda não existe. O próximo incremento técnico deve ser somente o **palco de batalha com Pet + Eco visíveis**, porque ele resolve a divergência que motivou a revisão e usa os assets que já estão no projeto.

## 8. Veredito

O roteiro faz sentido e fortalece o projeto. Ele não precisa substituir o AuroraPet atual; deve ser tratado como uma expansão narrativa e de RPG sobre uma base de V-Pet já funcional.

O projeto está estável nos sistemas de cuidado, progressão, persistência, geração procedural e regras básicas de batalha. A parte que está fora do escopo descrito é a camada de apresentação e encenação do Deepworld: combatentes visíveis, Eco visual, Eva como NPC, palco de exploração e campanha persistente.

Portanto, a próxima correção não é “deixar a caixa mais parecida”. É **reconstruir a batalha como uma cena de campo**, mantendo a UI como camada sobreposta e conectando os personagens visuais ao estado de combate. Depois que essa fundação estiver aprovada visualmente, a campanha de Eva poderá ser implementada sem reescrever o núcleo do V-Pet.

## Referências do diagnóstico

[1]: docs/design/AuroraPet_Deepworld_Roteiro.md "Roteiro técnico e literário do Deepworld/Eva fornecido pelo usuário"
[2]: docs/design/Deepworld_Eva.txt "Notas de mundo, Eva, combate e evolução fornecidas pelo usuário"
[3]: IMPLEMENTATION_ROADMAP.md "Roadmap técnico e critérios de estabilidade do AuroraPet"
[4]: scenes/console_frame.tscn "Montagem real de ScreenContent no projeto"
[5]: scenes/deepworld.tscn "Cenário, plataforma e pet modular ativos"
[6]: scenes/pet.tscn "Estrutura modular reutilizável do pet"
[7]: scenes/batalha_de_exploracao.tscn "Cena atual da interface de batalha"
[8]: scripts/console_controller.gd "Transições entre V-Pet, Deepworld e batalha"
[9]: scripts/batalha_de_exploracao.gd "Estado e resolução atual da batalha"
[10]: BATTLE_SYSTEM_RESEARCH.md "Pesquisa e decisões do sistema de combate"
