# AuroraPet — Hierarquia de cenas em cascata

A composição do protótipo segue uma cadeia de instâncias. A cena mais externa apresenta o projeto, enquanto cada cena interna controla apenas sua própria responsabilidade.

```text
main.tscn
└── Console Base              [instancia console_frame.tscn]
    └── ScreenContent
        ├── Deepworld          [instancia deepworld.tscn]
        │   └── Paisagem
        │       └── Pet        [instancia pet.tscn]
        │           ├── CorpoBase
        │           ├── Cauda
        │           ├── Asas
        │           ├── Orelhas
        │           ├── Olhos
        │           ├── PetStats
        │           ├── PetSkills
        │           └── AnimationPlayer
        └── PetUI               [instancia pet_ui.tscn]
```

## Responsabilidades

`pet.tscn` controla o corpo, os módulos visuais, as animações, os status e a progressão do pet. `deepworld.tscn` controla a paisagem e o posicionamento do pet dentro do mundo. `console_frame.tscn` controla a moldura, a tela, a UI e os controles físicos. `main.tscn` é a frente da cascata e apresenta o console completo.

## Ordem visual

A `Paisagem` fica atrás do pet. O nó `Pet` e seus módulos usam uma ordem relativa positiva para garantir que cauda, asas, orelhas, corpo e olhos apareçam acima do fundo. A `PetUI` fica acima do mundo e do pet, mas abaixo da moldura visual da tela. Os controles físicos ficam fora da área de jogo e possuem hitboxes separados.

## Regra de edição

> Alterações feitas na cena de origem devem ser refletidas nas instâncias superiores. Não duplique módulos do pet em `deepworld.tscn` ou em `main.tscn`.

Para editar o pet, abra `scenes/pet.tscn`. Para editar o mundo, abra `scenes/deepworld.tscn`. Para editar console, tela e controles, abra `scenes/console_frame.tscn`. Use `main.tscn` para executar e conferir o resultado final.
