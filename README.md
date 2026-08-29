# AuroraPet — Protótipo Godot

AuroraPet é um V-Pet cósmico em pixel art, com foco em cuidado, interação, progressão e montagem modular de criaturas. Este repositório contém o protótipo atual em **Godot 4.7**, organizado para preservar uma cascata de cenas editável e fácil de prototipar.

## Estado atual

O protótipo já possui um console virtual com tela, mundo cósmico, pet modular, UI de ações, barras de status, decaimento básico, efeitos simples das ações e uma base local de progressão por XP e habilidades.

O ciclo funcional atual é:

```text
Cuidar → Brincar → Treinar → Ganhar XP → Desbloquear habilidades
```

## Cascata de cenas

A composição principal segue uma cadeia de instâncias. Cada alteração deve ser feita na cena de origem correspondente para ser refletida nas cenas superiores.

```text
main.tscn
└── Console Base        [console_frame.tscn]
    ├── Moldura e controles físicos
    └── GameplayRoot     [gameplay_root.tscn]
        └── ScreenContent
            ├── Deepworld [deepworld.tscn]
            │   └── Pet   [pet.tscn]
            └── PetUI     [pet_ui.tscn]

mobile_main.tscn
├── GameplayRoot         [a mesma gameplay_root.tscn]
└── Interface touch
```

## Sistemas implementados

`pet_randomizer.gd` troca as texturas dos módulos existentes sem criar nós dinamicamente. `pet_stats.gd` mantém fome, energia, humor e saúde entre 0 e 100, aplica decaimento ao longo do tempo e processa as ações comer, brincar, limpar, treinar e dormir. `pet_skills.gd` fornece a base da árvore de habilidades com nível, XP, requisitos e os quatro movimentos iniciais: Golpe Fraco, Golpe Forte, Golpe de Status e Defesa.

A `PetUI` fornece o menu de ações e a ficha de status compartilhados. No console principal, D-pad e botões físicos controlam o jogo. No mobile, os mesmos comandos são acionados por toque direto, atalhos contextuais e gestos.

## Próximas etapas

A próxima etapa visual é criar a UI da árvore de habilidades no console. Depois disso, o sistema poderá ser conectado a um combate PvE contra um inimigo Eco. Persistência local, emoções visuais, geração procedural completa, minigames e Firebase permanecem no roadmap posterior.

## Execução

Abra `project.godot` no Godot 4.7 ou superior e execute `scenes/main.tscn` para o produto principal. Use `scenes/mobile_main.tscn` para validar a apresentação touchscreen. Regras compartilhadas pertencem a `gameplay_root.tscn` e suas subcenas; mudanças exclusivas de apresentação pertencem à casca correspondente.
