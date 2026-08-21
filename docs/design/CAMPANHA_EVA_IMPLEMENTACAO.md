# Campanha da EVA — Primeira camada implementada

## Objetivo

A campanha da EVA é uma camada narrativa independente do pet procedural e do modo DEV. O pet do jogador continua usando a evolução oficial do AuroraPet, enquanto a EVA possui progressão própria, memórias, afeição, escolhas e estágios narrativos.

## Arquitetura

| Elemento | Responsabilidade |
|---|---|
| `scripts/eva_journey_manager.gd` | Estado da campanha, escolhas, capítulos, memórias, afeição, evolução e bônus |
| `scenes/eva_npc.tscn` | Presença visual separada da EVA dentro do Deepworld |
| `scripts/eva_npc.gd` | Idle, direção e reações visuais da EVA narrativa |
| `AuroraPetSave` | Persistência do estado da campanha dentro do save v3 |
| `ConsoleController` | Conexão dos sinais da campanha com mensagens e progressão da UI |

## Estado persistido

O save registra `current_stage`, `affection_level`, `current_chapter`, `helped_eva`, `journey_started`, `journey_completed`, `choice_recorded` e `unlocked_fragments`. Saves antigos continuam válidos porque o bloco `eva_journey` é opcional e recebe valores padrão quando não existe.

## Primeiro arco

A escolha inicial usa as duas ramificações definidas no roteiro: ajudar a EVA inicia a jornada e libera o Capítulo 1; escolher “não agora” registra a decisão sem apagar o progresso do pet. A jornada pode ser iniciada posteriormente por uma ação de campanha, sem converter a EVA narrativa no pet DEV.

A campanha possui seis capítulos planejados: O Silêncio dos Ecos, O Espelho Fragmentado, Os Algoritmos Esquecidos, A Forja da Supernova, O Abismo da Memória e O Retorno à Origem. Cada capítulo pode liberar um fragmento de memória e avançar o estágio narrativo da EVA.

## Próximos incrementos

A camada seguinte deverá criar a tela de diálogo da EVA e uma ação explícita de “Falar com EVA”. Depois disso, os capítulos poderão ser conectados à exploração e à batalha por sinais, sem colocar regras de campanha dentro do controlador de combate. O `EvaNPC` já está separado dentro do Deepworld para receber essa integração visual.

## Regra de separação

> A EVA DEV é uma ferramenta de teste. A EVA narrativa é uma personagem persistente da campanha. As duas não devem compartilhar identidade, evolução ou estado de save.
