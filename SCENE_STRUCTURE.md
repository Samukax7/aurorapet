# AuroraPet — Hierarquia de cenas em cascata

A composição do protótipo segue uma cadeia de instâncias. A cena mais externa apresenta o projeto, enquanto cada cena interna controla apenas sua própria responsabilidade.

```text
main.tscn
└── Console Base              [instancia console_frame.tscn]
    ├── Moldura e controles físicos
    └── GameplayRoot           [instancia gameplay_root.tscn]
        └── ScreenContent
            ├── Deepworld      [instancia deepworld.tscn]
            │   └── Paisagem
            │       └── Pet    [instancia pet.tscn]
            └── PetUI          [instancia pet_ui.tscn]

mobile_main.tscn
├── GameplayRoot               [a mesma gameplay_root.tscn]
└── MobileTouchControls        [atalhos e gestos próprios]
```

## Responsabilidades

`gameplay_root.tscn` é a fonte compartilhada de gameplay, save, áudio e telas. `console_frame.tscn` é a casca principal e controla apenas a moldura e os controles físicos. `mobile_main.tscn` é a casca paralela touchscreen. O jogo é o mesmo; apresentação e entrada são deliberadamente diferentes.

## Ordem visual

A `Paisagem` fica atrás do pet. O nó `Pet` e seus módulos usam uma ordem relativa positiva para garantir que cauda, asas, orelhas, corpo e olhos apareçam acima do fundo. A `PetUI` fica acima do mundo e do pet, mas abaixo da moldura visual da tela. Os controles físicos ficam fora da área de jogo e possuem hitboxes separados.

## Regra de edição

> Alterações feitas na cena de origem devem ser refletidas nas instâncias superiores. Não duplique módulos do pet em `deepworld.tscn` ou em `main.tscn`.

Para editar regras ou telas compartilhadas, use `gameplay_root.tscn` e suas subcenas. Para editar o aparelho principal, use `console_frame.tscn`. Para editar a experiência touch, use `mobile_main.tscn` e `mobile_touch_controls.gd`. `main.tscn` continua sendo a execução principal do projeto.
