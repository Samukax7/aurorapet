# AuroraPet — Auditoria de Ligações entre Scripts

**Status:** mapa técnico inicial para o P1
**Fonte:** cenas e scripts locais de `aurorapet-main`
**Objetivo:** registrar quem possui estado, quem apresenta estado e quem apenas roteia sinais antes da refatoração.

## Regra de responsabilidade

O estado deve existir em um único dono. Cenas visuais apresentam esse estado. `ConsoleController` roteia eventos entre sistemas, mas não deve duplicar regras de progressão, batalha ou persistência.

## Cascata de cenas

```text
main.tscn
└── console_frame.tscn
    └── ScreenContent
        ├── Deepworld + DeepworldController
        │   └── Pet + PetStats + PetSkills + PetEvolution + PetIdentity + PetRandomizer
        ├── MapaExploracao
        ├── MapaCampanhaEva
        ├── EvaVisualNovel
        ├── EvaJourneyManager
        ├── BatalhaDeExploracao
        └── AuroraPetSave
```

## Donos de estado

| Sistema | Dono atual | Deve possuir |
|---|---|---|
| Identidade do pet | `PetIdentity` | seed, nome, facção, linhagem, elemento e traços |
| Aparência do pet | `PetRandomizer` | peças, paleta, cosméticos e aplicação visual |
| Necessidades | `PetStats` | fome, energia, humor, saúde, higiene, sono, doença e recusas |
| Progressão do pet | `PetSkills` + `PetEvolution` | XP, nível, atributos, habilidades e evolução do pet |
| Jornada da EVA | `EvaJourneyManager` | capítulos, cristais, afeição, decisão inicial e formas narrativas |
| Apresentação da EVA | `EvaVisualNovel` + `EvaNPC` | diálogos, poses, fundos e presença visual |
| Mapa de exploração | `MapaExploracao` | seleção e exibição das regiões; progressão deve vir do save/dados centrais |
| Mapa da Jornada | `MapaCampanhaEva` | seleção e exibição dos nós; progressão deve vir do save/dados centrais |
| Combate | `BatalhaDeExploracao` | turnos, ações, rolagem, dano, resultado e recompensa de combate |
| Roteamento | `ConsoleController` | abrir/fechar telas e conectar sinais, sem regras duplicadas |
| Persistência | `AuroraPetSave` | schema, migrações, save/load e estado persistente do mundo |

## Fluxo atual observado

### Exploração

```text
PetUI → ConsoleController
      → MapaExploracao
      → _on_exploration_area_selected()
      → sorteio local de coin/xp/deepmon
      → BatalhaDeExploracao
      → battle_completed
      → AuroraPetSave.register_exploration_battle()
      → unlock_next_exploration_island()
```

Problemas encontrados:

- o sorteio de resultado está no `ConsoleController`;
- o desbloqueio de ilha ocorre por vitória comum;
- não há estado de hostilidade ou nuvem por ilha;
- a lista de ilhas pertence ao save e outra lista visual pertence ao mapa;
- o resultado `deepmon` abre batalha, apesar do nome sugerir encontro de criatura.

### Jornada da EVA

```text
MapaCampanhaEva
      → ConsoleController._on_eva_stage_selected()
      → dicionário local de encontros
      → EvaVisualNovel.open_chapter()
      → BatalhaDeExploracao em contexto eva
      → battle_completed
      → MapaCampanhaEva.advance_to_stage()
      → EvaJourneyManager.complete_current_chapter()
      → cristal + evolução + save
```

Problemas encontrados:

- `MapaCampanhaEva`, `ConsoleController`, `EvaJourneyManager` e `EvaVisualNovel` mantêm dados separados;
- o controlador já possui encontros de capítulo 6 que não estão no mapa visual;
- o limite do save está fixado em 21;
- a progressão visual e a progressão narrativa podem divergir;
- o Boss é identificado por nome textual, não por uma definição central.

### Vínculo da EVA

`EvaJourneyManager` possui `record_care()` e `record_shared_activity()`, mas a auditoria inicial não encontrou chamadas efetivas a partir das ações do Lobby, treino, exploração, batalha ou sono.

Regra proposta:

- o vínculo narrativo pertence à EVA da Jornada e é salvo em `EvaJourneyManager`;
- a EVA pet do pós-game reutiliza a personagem e os desbloqueios, mas não cria outro vínculo narrativo;
- a EVA DEV não registra vínculo, cristais ou evolução no save real;
- `ConsoleController` encaminha eventos de atividade para o `EvaJourneyManager` quando a Jornada estiver ativa.

### Save

`AuroraPetSave` já centraliza identidade, stats, skills, evolução, pontos, compras, campanha e ilhas desbloqueadas. Ainda precisa receber:

- versão nova de schema;
- migração das formas antigas da EVA;
- dados de quinze ilhas menores e seis maiores;
- estado e hostilidade de cada ilha;
- recursos da expedição e inventário do Guarda-Roupas;
- flags de Guardião restaurado;
- EVA pet especial pós-game.

## Fonte única planejada

O P1 deve criar uma definição central de campanha, por exemplo `eva_campaign_data.gd`, contendo:

```text
id
tipo (base, menor, maior)
ordem
capítulo
região
boss
ilha_exploracao_id
nome_publico
nome_secreto
linhas_narrativas
cristal
forma_eva_antes
forma_eva_depois
recompensas
próximo_nó
```

O mapa, o controlador, a Visual Novel, a batalha e o save devem consultar essa definição, sem manter dicionários paralelos.

## Critérios de conclusão da auditoria

- cada variável de progressão possui um único dono;
- cada sinal tem emissor e receptor registrados;
- não há listas duplicadas de Bosses, fases ou formas;
- a progressão do mapa e do save usa os mesmos IDs;
- o modo DEV não grava estado narrativo;
- a nova estrutura pode ser testada em modo headless e visualmente na Godot.
