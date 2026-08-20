# Referência de medidas da tela do console

> Este documento é a referência oficial para posicionamento, escala e composição de interfaces dentro do display do AuroraPet.

## Regra principal

As interfaces internas devem ser dimensionadas pela moldura visual da tela do console, e não apenas pela viewport lógica do projeto. A cena de referência é `scenes/console_frame.tscn`, especialmente os nós `ScreenContent` e `Tela`.

O `ScreenContent` define a área lógica de trabalho para o jogo. O sprite `Tela` define a moldura visual que limita o que o jogador realmente enxerga dentro do console. Elementos que precisam acompanhar a tela devem ser centralizados usando o mesmo referencial do `ScreenContent` e respeitar a moldura do sprite `Tela`.

## Medidas da viewport do projeto

| Propriedade | Valor |
|---|---:|
| Nome da versão | AuroraPet V 0.0 |
| Viewport lógica horizontal | 1080 px |
| Viewport lógica vertical | 650 px |
| Tamanho padrão da janela | 1080 × 650 px |
| Stretch mode | `canvas_items` |
| Stretch aspect | `expand` |
| Cor de fundo padrão | `#071332` aproximadamente |

Esses valores estão definidos em `project.godot`. Eles servem como referência global para o jogo, mas não devem ser confundidos com a área visual interna do sprite da tela.

## Cena `console_frame.tscn`

| Nó | Propriedade | Valor |
|---|---|---:|
| `ScreenContent` | offset esquerdo | -557 px |
| `ScreenContent` | offset superior | -662 px |
| `ScreenContent` | offset direito | 338 px |
| `ScreenContent` | offset inferior | 153 px |
| `ScreenContent` | largura lógica | 895 px |
| `ScreenContent` | altura lógica | 815 px |
| `ScreenContent` | escala X | 1.231249 |
| `ScreenContent` | escala Y | 1.218436 |
| `Tela` | posição | `(-9, -123)` |
| `Tela` | escala X | 0.6100007 |
| `Tela` | escala Y | 0.5199993 |
| `Deepworld` | posição | `(447, 407)` |
| `Deepworld` | escala X | 0.31497505 |
| `Deepworld` | escala Y | 0.35 |

O sprite `Tela` utiliza o arquivo `assets/console/aurorapet-screen-only-pixel-mockup.png`, com dimensões de origem **4096 × 3072 px**. A moldura interna visível do asset é a referência visual para conferir se um overlay está ultrapassando o display.

## Escala responsiva da cena Main

A cena `main.tscn` instancia o console em posição inicial `(540, 325)` e escala inicial `0.3`. O script `scripts/main_responsive.gd` recalcula a escala em runtime:

```gdscript
fit_scale = min(viewport_size.x / 1080.0, viewport_size.y / 650.0)
console_base.scale = Vector2.ONE * 0.3 * fit_scale
```

Por consequência, uma interface filha do `Console Base` também recebe a escala responsiva do console. Não se deve aplicar uma escala arbitrária baseada apenas na janela sem considerar essa herança.

## Regra para interfaces filhas do Deepworld

O `Deepworld` possui escala aproximada de `0.31497505 × 0.35`. Uma interface criada diretamente dentro dele precisa considerar essa escala herdada.

A relação usada anteriormente para preencher a área lógica era:

| Elemento | Escala de compensação anterior |
|---|---:|
| Interface filha do Deepworld, X | 3.174856 |
| Interface filha do Deepworld, Y | 2.857143 |

Essa compensação preenche o `ScreenContent` lógico, mas pode ultrapassar a moldura visual da tela do console. Para o Quarto Cósmico, a referência visual atual aprovada usa:

| Elemento | Escala atual de referência |
|---|---:|
| `QuartoCosmico/Room`, X | 2.8 |
| `QuartoCosmico/Room`, Y | 2.5 |
| `LojaCosmica`, X | 2.8 |
| `LojaCosmica`, Y | 2.5 |

Essa escala cria um pequeno recuo em relação ao preenchimento lógico total e deve ser o ponto de partida para futuras alterações do Quarto e da Loja.

## Regra para o Fundo Padrão e a plataforma

O `Fundo Padrão` do Quarto Cósmico deve permanecer em escala natural `Vector2(1, 1)` dentro do `Deepworld`. Não aplicar a escala de compensação da interface ao fundo, pois isso estica o cenário em relação à plataforma.

| Elemento | Asset de origem | Escala base atual |
|---|---|---:|
| Fundo Padrão | `assets/fundo/aurorapet-deepworld-landscape.png` | `1 × 1` dentro do Quarto |
| Plataforma | `assets/fundo/deepworld_plataforma.png` | `3.0363233 × 2.980633` no Deepworld |
| Fundo Neutro | `assets/fundo/faccoes/deepworld_neutro.png` | `3.0340772 × 2.9694102` no Deepworld |

Os assets do cenário e da plataforma possuem proporção próxima de 16:9. A plataforma é fixa e deve permanecer ativa conforme a regra do Deepworld; somente o fundo muda quando necessário.

## Procedimento para futuras telas

Antes de criar ou redimensionar uma interface, verificar a hierarquia da cena. Se o elemento estiver diretamente em `ScreenContent`, começar pela área lógica de `895 × 815` e conferir a moldura visual. Se estiver dentro de `Deepworld`, calcular a escala herdada antes de definir a escala local.

Depois, posicionar o conteúdo centralmente, testar as bordas esquerda, direita, superior e inferior dentro da tela do console e conferir se o fundo mantém proporção com a plataforma. Para overlays de lojas e menus, manter uma margem interna e evitar usar automaticamente a compensação total do Deepworld.

## Arquivos de referência

| Arquivo | Função |
|---|---|
| `project.godot` | Viewport lógica e stretch do projeto |
| `scenes/main.tscn` | Posição e escala responsiva inicial do console |
| `scripts/main_responsive.gd` | Escala final do console conforme a janela |
| `scenes/console_frame.tscn` | ScreenContent, Tela e cascata principal |
| `scenes/deepworld.tscn` | Escala do Deepworld, fundo e plataforma |
| `scenes/quarto_cosmico.tscn` | Interface do Quarto e Fundo Padrão |
| `scenes/loja_cosmica.tscn` | Overlay da Loja Cósmica |
