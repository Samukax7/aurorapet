# AuroraPet — Hierarquia 2D em Cascata

A cena principal será construída como uma composição 2D ordenada. Cada nível representa uma camada visual ou funcional, evitando que o código misture apresentação, jogo e controles.

```text
AuroraPet (Node2D)
├── Background (Node2D)
│   ├── BackGlow (Polygon2D/ColorRect)
│   └── Vignette (CanvasModulate)
├── ConsoleStage (Node2D)
│   ├── ConsoleShadow (Polygon2D)
│   ├── ConsoleBody (Polygon2D)
│   ├── ConsoleHighlight (Line2D/Polygon2D)
│   ├── ConsoleInset (Polygon2D)
│   ├── ScreenAssembly (Node2D)
│   │   ├── ScreenShadow (Polygon2D)
│   │   ├── ScreenBezel (Polygon2D)
│   │   ├── ScreenGlass (Polygon2D)
│   │   ├── ScreenGame (Node2D)
│   │   │   ├── PetShadow (Polygon2D)
│   │   │   ├── PetBody (Node2D)
│   │   │   ├── PetHighlights (Node2D)
│   │   │   └── PetEffects (Node2D)
│   │   └── ScreenHud (CanvasLayer/Control)
│   │       ├── PetName
│   │       ├── StatusBars
│   │       └── Message
│   └── PhysicalControls (Node2D)
│       ├── DPadShadow
│       ├── DPad
│       ├── ButtonYellow
│       ├── ButtonGreen
│       └── ButtonPink
├── InputLayer (Node)
│   ├── KeyboardController
│   └── TouchController
└── DebugOverlay (CanvasLayer)
```

## Ordem de construção

1. **Background**: define a cor e o espaço da aplicação.
2. **ConsoleShadow**: cria a sombra externa e a sensação de profundidade.
3. **ConsoleBody**: desenha o corpo principal branco.
4. **ConsoleHighlight e ConsoleInset**: adicionam bordas, rebaixos e reflexos.
5. **ScreenAssembly**: cria a moldura física da tela.
6. **ScreenGame**: recebe o pet e o cenário do jogo.
7. **ScreenHud**: fica acima do jogo, mas dentro da tela do console.
8. **PhysicalControls**: fica acima do corpo e recebe interação.
9. **InputLayer**: controla teclado, toque e futuramente controles físicos.
10. **DebugOverlay**: permanece separado para não contaminar a apresentação final.

A regra é: **pais controlam composição; filhos controlam apenas seu próprio conteúdo**. O console não deve conhecer a lógica de fome, e o pet não deve conhecer a posição dos botões físicos.

## Proporção

A viewport lógica será 960×540, proporção 16:9. A composição interna manterá uma área segura central de aproximadamente 860×470. Em telas menores, toda a árvore será escalada uniformemente por `canvas_items`, sem deformar círculos, botões ou a tela.
