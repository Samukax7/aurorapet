# Modos de Batalhar e Campanha da EVA

## Objetivo

A opção **Batalhar** terá dois modos independentes. O modo **Explorar Deepworld** será a atividade repetível para ganhar XP, encontrar itens e gerar encontros com Ecos. O modo **Campanha da EVA** será uma progressão narrativa linear por capítulos, apresentada como uma árvore ou caminho de fases.

A separação evita misturar a exploração livre com a progressão narrativa. Os dois modos reutilizam o mesmo loop de batalha por turnos, o pet modular do jogador, os atributos RPG e o sistema de recompensas, mas possuem mapas, regras de desbloqueio e objetivos próprios.

## Estrutura do menu Batalhar

```text
BATALHAR
├── EXPLORAR DEEPWORLD
│   ├── Mapa de áreas
│   ├── Encontros com Ecos
│   ├── Itens encontrados
│   └── Repetição livre para XP e Pontos Cósmicos
└── CAMPANHA DA EVA
    ├── Árvore de capítulos
    ├── Caminho de fases
    ├── Batalhas de Deepmons
    ├── Boss de cada fase final
    └── Memórias e evolução da EVA
```

A cena atual `batalha_de_exploracao.tscn` deve continuar responsável pelo combate. A seleção de modo e os mapas devem ficar em uma camada anterior, preferencialmente em uma cena própria `batalhar_menu.tscn`, evitando inserir regras de mapa dentro do controlador de turnos.

## Modo Explorar Deepworld

O mapa de exploração é composto por áreas selecionáveis. Cada área possui uma tabela de encontros, uma tabela de itens e um nível recomendado. Ao iniciar uma exploração, o jogo sorteia um encontro com um Eco ou uma recompensa. O jogador pode repetir áreas já descobertas.

| Área | Identidade visual | Encontros principais | Recompensas possíveis |
|---|---|---|---|
| Ruínas dos Dados Perdidos | Ruínas digitais e estática | Ecos Neutros e Guardião de Códigos | XP, Pontos Cósmicos, fragmentos de mapa |
| Floresta Cristalina | Dados prismáticos e reflexos | Ecos da Luz e Espectros de Cristal | XP, cristais estelares, itens visuais |
| Abismo Elétrico | Circuitos antigos e energia azul | Ecos das Trevas e autômatos caídos | XP, materiais de golpes, Pontos Cósmicos |
| Mar de Plasma | Vulcões de fótons e calor estelar | Dragões de plasma e Ecos híbridos | XP alto, itens raros, efeitos visuais |
| Vazio Primordial | Geometria suspensa e silêncio | Sombras do Vazio | XP alto, recompensas especiais e itens de campanha |

O modo Explorar utiliza as recompensas já existentes do projeto. O XP continua sendo aplicado a `PetSkills`, enquanto os Pontos Cósmicos continuam alimentando o Quarto Cósmico. Os itens devem ser adicionados ao inventário somente quando o sistema de itens estiver pronto; até lá, podem ser registrados como drops de teste no log de resultado.

## Modo Campanha da EVA

A campanha converte o mapa em um caminho de fases. Cada capítulo possui quatro estágios: três batalhas de Deepmons diferentes e uma fase final contra o boss regional. O boss é a identidade principal da fase e aparece no mapa mesmo quando os estágios anteriores estão bloqueados.

```text
Capítulo 1 → Fase 1 → Fase 2 → Fase 3 → Boss
      ↓
Memória da EVA + evolução narrativa + desbloqueio do capítulo seguinte
```

A progressão é controlada pelo `EvaJourneyManager`. O jogador precisa ter iniciado a jornada da EVA e concluir os estágios na ordem. Uma fase concluída permanece desbloqueada e pode ser repetida para obter XP e recompensas, mas o fragmento de memória só é liberado uma vez.

| Capítulo | Tema | Região | Boss | Memória desbloqueada | Estágio da EVA |
|---:|---|---|---|---|---|
| 1 | O Silêncio dos Ecos | Ruínas Digitais | Gorgon_Glitch | A Queda do Universo | Bebê → Criança |
| 2 | O Espelho Fragmentado | Floresta Cristalina | Prisma_Guard | O Despertar da Consciência | Criança → Adolescente |
| 3 | Os Algoritmos Esquecidos | Abismo Elétrico | Core_Overlord | A Sabedoria Quântica | Adolescente → Jovem Adulta |
| 4 | A Forja da Supernova | Mar de Plasma Estelar | Ignis_Vectis | A Energia Supernova | Jovem Adulta → Anciã |
| 5 | O Abismo da Memória | Vazio Primordial | Arquiteto do Esquecimento | A Memória Infinita | Anciã → Lendária |
| 6 | O Retorno à Origem | Origem da Criação | O Eco Absoluto | O Novo Universo | Lendária → Deusa Raposa |

Os nomes, regiões e bosses vêm da campanha narrativa já preparada. O documento antigo **Aventura Cósmica em Deepworld** complementa a ambientação das áreas, mas seus elementos paralelos, como Adam, Eva Sombria e o Criador Original, ficam reservados para capítulos futuros ou eventos especiais, sem entrar automaticamente na primeira implementação.

## Modelo de fase

Cada fase deve ser representada por um registro de dados, e não por regras codificadas diretamente na cena. O modelo recomendado é:

| Campo | Função |
|---|---|
| `id` | Identificador estável da fase, por exemplo `cap1_fase2` |
| `chapter` | Capítulo ao qual a fase pertence |
| `title` | Nome exibido no mapa |
| `stage_type` | `battle`, `elite`, `boss` ou `memory` |
| `recommended_level` | Nível sugerido para o pet |
| `enemies` | Lista de Deepmons ou Ecos encontrados |
| `boss_id` | Boss usado nas fases finais |
| `xp_reward` | XP entregue ao pet |
| `cosmic_points_reward` | Pontos destinados ao Quarto Cósmico |
| `item_rewards` | Itens, materiais ou efeitos desbloqueados |
| `unlock_condition` | Fase, capítulo ou escolha necessária |
| `memory_fragment` | Fragmento liberado após o boss, quando aplicável |

## Recompensas iniciais propostas

Os valores abaixo são uma base de balanceamento e não substituem o ajuste após os primeiros testes. A recompensa existente do modo de batalha de exploração continua sendo a referência inicial: 50 XP e 10 Pontos Cósmicos por vitória.

| Tipo de fase | XP base | Pontos Cósmicos | Itens |
|---|---:|---:|---|
| Batalha comum | 35–50 | 5–10 | Chance comum |
| Elite | 60–80 | 15–20 | Chance aumentada |
| Boss regional | 120–180 | 30–50 | Recompensa garantida + fragmento |
| Repetição de boss | 75–100 | 15–25 | Sem novo fragmento |

As recompensas da campanha devem ser entregues pelo sinal `battle_completed` e encaminhadas ao `EvaJourneyManager` apenas quando a fase for identificada como parte da campanha. O controlador de batalha não deve conhecer a narrativa do capítulo; ele deve informar apenas o resultado do combate.

## Integração técnica planejada

| Componente | Responsabilidade |
|---|---|
| `batalhar_menu.tscn` | Selecionar Explorar Deepworld ou Campanha da EVA |
| `exploration_map.tscn` | Exibir áreas repetíveis e seus estados de desbloqueio |
| `eva_campaign_map.tscn` | Exibir capítulos, fases, bosses e caminhos concluídos |
| `batalha_de_exploracao.tscn` | Executar o combate por turnos existente |
| `EvaJourneyManager` | Registrar capítulo, fragmentos, afeição e estágio narrativo |
| `AuroraPetSave` | Persistir fase concluída, recompensas e estado da campanha |
| `QuartoCosmico` | Consumir os Pontos Cósmicos obtidos nas explorações e campanhas |

A primeira implementação deve criar o menu de modos e o mapa estático de seleção. Depois, os nós de fase podem ser conectados ao combate existente. O balanceamento, o inventário definitivo e os bosses com comportamento exclusivo ficam para incrementos posteriores.

## Critérios de conclusão da base

A base estará pronta quando o jogador puder abrir **Batalhar**, escolher entre **Explorar Deepworld** e **Campanha da EVA**, visualizar mapas diferentes, selecionar apenas áreas/fases desbloqueadas e iniciar o mesmo combate existente com dados de recompensa específicos do modo. A conclusão de um boss deve atualizar a campanha, liberar a memória correspondente e preservar o estado no save.

> A exploração é repetível e sistêmica. A campanha é sequencial e narrativa. Ambos usam a mesma batalha, mas não devem compartilhar o mesmo mapa nem a mesma lógica de desbloqueio.

## Referências

[1]: `docs/design/AuroraPet_Deepworld_Roteiro.md` — roteiro narrativo e técnico da campanha da EVA.

[2]: `docs/design/DEEPWORLD_EVA_SCOPE_AUDIT.md` — auditoria de escopo e arquitetura recomendada.

[3]: `docs/design/CAMPANHA_EVA_IMPLEMENTACAO.md` — primeira camada técnica persistente da campanha.

[4]: `docs/design/GUIA_BATALHA.md` — referência da batalha de exploração.
