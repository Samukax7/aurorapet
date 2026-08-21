# AuroraPet — Documento Passo a Passo do Projeto

**Engine:** Godot 4.7.1  
**Build atual:** V0.0 — protótipo web jogável  
**Última revisão:** 21 de agosto de 2026  
**Escopo desta revisão:** consolidar o que está implementado e registrar o próximo caminho sem alterar código ou assets.

> Este documento descreve a estrutura real do AuroraPet neste momento. Ele separa o que já está funcionando, o que foi preparado tecnicamente e o que continua pendente para a V0.1. Os assets dos bosses estão disponíveis na área de criação e devem ser integrados em uma etapa posterior; nesta revisão eles não foram movidos, editados ou conectados.

## 1. Conceito geral

AuroraPet combina um V-Pet de cuidados com uma camada de progressão RPG e exploração cósmica. O pet modular permanece como a unidade central do jogo. O jogador começa cuidando de um Deepmon recém-nascido, libera jogos e treino gradualmente, desbloqueia combate contra Ecos e depois acessa duas rotas distintas: a exploração livre do Deepworld e a campanha narrativa da EVA.

A arquitetura mantém a cascata principal `main > console_frame > deepworld > pet`, com a interface do pet sobreposta ao mundo e o controlador do console responsável por encaminhar os comandos físicos para o estado ativo.

## 2. Sequência inicial implementada

A entrada do jogo deve ser percorrida nesta ordem:

| Passo | Tela ou estado | Situação atual |
|---:|---|---|
| 1 | BIOS com logo AuroraPet | Implementado |
| 2 | Menu inicial com Start, Continue e Options | Implementado |
| 3 | Boas-vindas e introdução ao Deepworld | Implementado |
| 4 | Explicação dos controles | Implementado |
| 5 | Escolha das facções Luz, Trevas e Neutro | Implementado |
| 6 | Seleção do ovo correspondente | Implementado |
| 7 | Eclosão com confirmação pelo botão verde e shake do ovo | Implementado |
| 8 | Página de status do pet | Implementado |
| 9 | Entrada no gameplay de cuidados | Implementado |

A `OpeningFlow` controla esse pipeline. O modo DEV continua separado da experiência narrativa: o código `DEV` cria EVA como pet de teste, usa fundo padrão, pula história, facção, ovo e eclosão e entrega o jogador diretamente ao gameplay com progressão máxima.

## 3. Gameplay inicial e tutorial disfarçado

O pet recém-nascido inicia com fome em 20% e energia em 30%. A intenção é que o jogador perceba naturalmente a primeira sequência de cuidado: alimentar o pet e, quando a energia estiver baixa, colocá-lo para dormir.

O tutorial não deve apresentar um manual extenso. As mensagens atuais foram suavizadas para indicar apenas o contexto imediato:

| Estado | Mensagem contextual |
|---|---|
| Fome inicial baixa | “A fome está baixa. Escolha uma comida.” |
| Energia baixa | “A energia caiu. Deixe o pet dormir.” |
| Conclusão | “Novo jogo disponível: Jogo da Velha” |

Ao concluir a alimentação e o primeiro sono, o pet alcança o nível 2 e libera o Jogo da Velha. As vontades especiais do pet consultam `PetSkills` antes de sortear uma solicitação; dessa forma, treino e jogos não são pedidos enquanto ainda estiverem indisponíveis.

## 4. Progressão do pet

A progressão combina nível, XP, atributos RPG, habilidades e evolução visual. A categoria `Batalhar` é liberada no nível 6, enquanto os jogos e o treino seguem a tabela já existente em `pet_skills.gd`.

| Conteúdo | Regra atual |
|---|---|
| Comer, cuidar e dormir | Disponível no nascimento |
| Jogo da Velha | Nível 2 |
| Jokenpô | Nível 3 |
| Treino | Nível 4 |
| 2048 | Nível 5 |
| Categoria Batalhar | Nível 6 |
| Sala de Treinos | Nível 6 |
| Explorar Deepworld | Nível 6 |
| Aventura com EVA | Desbloqueio narrativo após encontro e aceite da ajuda |

A árvore de habilidades continua separada da árvore de acesso aos menus. `PetSkills` controla nível, XP, atributos, ataques e habilidades; `PetStats` controla fome, energia, humor, saúde, higiene, disciplina, obediência, audácia, doença, sono, sujeira e eventos comportamentais.

## 5. Categoria Batalhar

A antiga nomenclatura “Batalha de Exploração” foi reorganizada para que o menu comunique melhor as funções do jogo.

| Opção | Função |
|---|---|
| **Sala de Treinos** | Usa a tela de combate atual contra Ecos. É o espaço para testar golpes, preparar o pet e enfrentar inimigos com dificuldade crescente. |
| **Explorar Deepworld** | Abre o mapa horizontal de ilhas e inicia a exploração livre. |
| **Aventura com EVA** | Abre o mapa vertical de capítulos, liberado apenas depois do encontro narrativo com EVA e da aceitação da ajuda. |

As três opções compartilham a base de combate em `batalha_de_exploracao.gd`, mas recebem um contexto distinto: `training`, `exploration` ou `eva`. A interface exibe os títulos Sala de Treinos, Exploração Deepworld e Aventura com EVA conforme o contexto.

## 6. Explorar Deepworld

O mapa horizontal aprovado permanece visualmente intacto. A ilha inferior direita, identificada atualmente como `data_city`, é o único ponto liberado no início da exploração. Ao abrir o mapa, a seleção começa nessa ilha.

A exploração segue este ciclo:

1. O jogador abre `Batalhar` e escolhe **Explorar Deepworld**.
2. O mapa horizontal mostra as ilhas e bloqueia as áreas ainda não descobertas.
3. O jogador confirma a ilha disponível.
4. Um sorteio baseado em seed seleciona um dos três resultados: encontro com Deepmon, moedas estelares ou XP adicional.
5. Se houver Deepmon, a Sala de Treinos é aberta com o contexto de exploração.
6. Uma vitória registra a batalha, concede XP e pontos e conta para o encontro com EVA.
7. Depois de três vitórias de exploração, o evento de EVA fica disponível.

O encontro com EVA pode ser aceito pelo botão verde ou adiado pelo botão rosa. O encontro é marcado como visto e libera progressivamente novas ilhas independentemente da resposta. A opção **Aventura com EVA**, entretanto, só aparece no menu depois que o jogador aceita ajudar EVA.

## 7. Aventura com EVA

A campanha utiliza o mapa vertical como uma sequência de progressão. A plataforma grande inferior representa a base inicial. As pedras menores representam três batalhas de preparação de cada capítulo. A pedra grande seguinte representa o boss do capítulo.

A ordem correta, de baixo para cima, é:

| Capítulo | Três batalhas menores | Boss |
|---:|---|---|
| 1 | Encontro 1, Encontro 2, Encontro 3 | Gorgon Glitch |
| 2 | Encontro 1, Encontro 2, Encontro 3 | Prisma Guard |
| 3 | Encontro 1, Encontro 2, Encontro 3 | Core Overlord |
| 4 | Encontro 1, Encontro 2, Encontro 3 | Ignis Vectis |
| 5 | Encontro 1, Encontro 2, Encontro 3 | Arquiteto do Esquecimento |
| 6 | Encontro 1, Encontro 2, Encontro 3 | O Eco Absoluto |

A plataforma inicial é apenas um marco visual. A navegação começa na primeira pedra de batalha. Cada etapa seguinte é liberada somente depois de uma vitória, e o progresso da pedra atual é salvo.

A campanha contém apenas batalhas contra Deepmons e aumenta o nível dos encontros à medida que o jogador sobe no mapa. Ao derrotar um boss, `EvaJourneyManager` libera um fragmento de memória, avança o capítulo e evolui a forma da EVA. Em caso de derrota em uma batalha de boss, o fluxo retorna ao lobby com a mensagem de que EVA trouxe o jogador de volta; o capítulo permanece disponível para uma nova tentativa.

Os sprites estáticos dos bosses estão disponíveis na área de criação. A integração deles na área visual da batalha ainda é uma pendência de implementação e não foi executada nesta revisão.

## 8. Persistência e carregamento

`AuroraPetSave` já preserva identidade, stats, habilidades, evolução, aparência, pontos, moedas, itens, diário, conquistas e o estado da Jornada EVA. A estrutura foi ampliada para registrar:

| Estado persistente | Finalidade |
|---|---|
| `exploration_battles_completed` | Contar vitórias de exploração até o encontro com EVA |
| `eva_encounter_available` | Informar que o evento de EVA pode ser resolvido |
| `eva_encounter_seen` | Impedir repetição do primeiro encontro |
| `eva_adventure_unlocked` | Controlar a aparição da Aventura com EVA |
| `exploration_islands_unlocked` | Liberar ilhas gradualmente |
| `eva_progress_stage_index` | Restaurar a pedra atual do mapa vertical |

Saves anteriores continuam sendo lidos com valores padrão compatíveis, incluindo a ilha inferior direita como ponto inicial.

## 9. Arquivos principais e responsabilidades

| Arquivo | Responsabilidade |
|---|---|
| `scenes/main.tscn` | Raiz da aplicação e composição geral |
| `scenes/console_frame.tscn` | Console físico, viewport e controles |
| `scenes/deepworld.tscn` | Fundo, plataforma, pet e palco do Deepworld |
| `scripts/opening_flow.gd` | BIOS, menu, narrativa inicial, facções, ovo e status |
| `scripts/console_controller.gd` | Roteamento dos controles e abertura dos modos |
| `scripts/pet_stats.gd` | Necessidades, sono, doença, vontades, recusas e tutorial contextual |
| `scripts/pet_skills.gd` | XP, níveis, atributos, habilidades e locks de conteúdo |
| `scripts/pet_ui.gd` | Menu principal, submenus, mensagens e apresentação dos locks |
| `scripts/aurorapet_save.gd` | Persistência do pet, mundo, ilhas e campanha EVA |
| `scripts/batalha_de_exploracao.gd` | Combate D20 reutilizável nos três contextos |
| `scripts/mapa_exploracao.gd` | Seleção e desbloqueio do mapa horizontal |
| `scripts/mapa_campanha_eva.gd` | Progressão vertical por pedras e bosses |
| `scripts/eva_journey_manager.gd` | Capítulos, memórias, afeição e evolução da EVA |

## 10. Procedimento de validação

Antes de publicar uma alteração, o projeto deve ser validado em modo headless com Godot 4.7.1. A validação precisa confirmar que não existem erros de parsing, scripts ausentes, propriedades conflitantes ou cenas que não carregam.

Depois da validação, a exportação Web deve ser gerada pelo preset `Web V 0.0`. Os artefatos publicados ficam em `docs/`, incluindo HTML, JavaScript, PCK, WASM, manifest, ícones e Service Worker. O projeto não deve publicar plugins locais, arquivos temporários ou a pasta intermediária de exportação.

## 11. Estado atual da V0.0

A V0.0 é um protótipo jogável com a introdução, criação procedural do pet, necessidades, jogos, treino, Quarto Cósmico, batalha D20, Sala de Treinos, exploração horizontal, campanha vertical e persistência básica já estruturados.

A implementação atual foi validada headless e publicada no commit `755005e`. O mapa horizontal foi preservado. O documento de arquitetura do loop está em `CORE_LOOP_V0.1.md`, enquanto este arquivo funciona como guia operacional passo a passo.

## 12. Próximas etapas da V0.1

A ordem recomendada de trabalho é estabilizar as animações da abertura, corrigir escala e alinhamento das animações do pet, refinar a legibilidade da batalha, integrar os sprites estáticos dos bosses, adicionar reações visuais completas, animar o fundo, inserir áudio, finalizar o Guarda-Roupas Cósmico e executar a vistoria técnica de saves, responsividade, foco de botões e cache web.

A V0.1 só deve ser publicada depois que a build Web for testada em desktop e celular, o fluxo de primeiro jogo e Continue forem verificados, a campanha puder ser concluída sem bloqueios e os assets dos bosses estiverem conectados à cena de batalha.

## Referências internas

- [`CORE_LOOP_V0.1.md`](CORE_LOOP_V0.1.md) — estrutura do loop principal.
- [`ROADMAP_V0.1_PENDENCIAS.md`](ROADMAP_V0.1_PENDENCIAS.md) — prioridades visuais e técnicas.
- [`MODOS_BATALHAR_CAMPANHA_EVA.md`](MODOS_BATALHAR_CAMPANHA_EVA.md) — conceito dos modos de batalha.
- [`CAMPANHA_EVA_IMPLEMENTACAO.md`](CAMPANHA_EVA_IMPLEMENTACAO.md) — primeira camada técnica da campanha.
- [`INTRODUCAO_EVA_BASE.md`](INTRODUCAO_EVA_BASE.md) — sequência narrativa e visual da introdução.
