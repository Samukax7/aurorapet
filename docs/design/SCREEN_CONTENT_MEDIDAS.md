# Contrato de layout do ScreenContent — AuroraPet

**Projeto:** AuroraPet principal
**Data de referência:** 25 de agosto de 2026
**Escopo:** telas internas do console, Deepworld, menus, mapas, visual novel, batalha e futuras interfaces do projeto.

## Objetivo

Este documento define o espaço lógico que deve ser usado por todas as cenas exibidas dentro da tela do console. A regra principal é separar **coordenadas internas de design** das dimensões físicas da janela. As cenas não devem ser redimensionadas manualmente para cada monitor, resolução ou modo de execução.

> Toda interface interna do AuroraPet deve ser desenhada em coordenadas locais de **1080 × 650 pixels**. O ajuste para a janela física é responsabilidade da casca ativa: `main_responsive.gd → Console Base → GameplayRoot` no principal ou `mobile_main.gd → GameplayRoot` no mobile.

## Medidas oficiais

| Elemento | Medida ou valor | Uso correto |
|---|---:|---|
| Viewport lógico do projeto | `1080 × 650` | Referência de criação para todas as telas internas |
| Centro lógico | `(540, 325)` | Ponto de centralização de painéis, logos e overlays |
| Largura lógica | `1080 px` | Coordenadas horizontais de `0` a `1080` |
| Altura lógica | `650 px` | Coordenadas verticais de `0` a `650` |
| Margem segura horizontal recomendada | `24 px` | Evitar que textos e painéis encostem nas bordas |
| Margem segura vertical recomendada | `18 px` | Evitar conflito com título e faixa de instruções |
| Área segura recomendada | `(24, 18)–(1056, 632)` | Conteúdo principal que precisa permanecer legível |
| Área inferior de instruções | `y = 610–650` | Reservada para dicas de controle, quando necessária |
| Área superior de título | `y = 18–78` | Reservada para título e identificação da tela |

A área de `1080 × 650` é o limite lógico completo. A margem segura não é uma segunda viewport nem deve provocar uma escala adicional; ela apenas define onde o conteúdo importante deve ser posicionado para permanecer legível.

## Cadeia de transformação

A cena `main.tscn` instancia o console na posição lógica `(540, 325)`. O script `main_responsive.gd` calcula uma escala uniforme com base no tamanho físico da janela:

```text
fit_scale = min(viewport_width / 1080, viewport_height / 650)
console_scale = 0.3 × fit_scale
console_position = centro da janela física
```

A escala deve ser uniforme. Não aplicar uma escala horizontal diferente da vertical em telas internas, mapas, lojas ou visual novels, porque isso distorce sprites, plataformas e fontes.

| Arquivo | Configuração de referência |
|---|---|
| `project.godot` | Viewport lógico `1080 × 650`, modo de janela configurado pelo projeto |
| `scripts/main_responsive.gd` | `DESIGN_VIEWPORT = Vector2(1080, 650)` e centro `(540, 325)` |
| `scripts/screen_content.gd` | `LOGICAL_SIZE = Vector2(1080, 650)` e `LOGICAL_CENTER = Vector2(540, 325)` |
| `scenes/main.tscn` | `Console Base` posicionado em `(540, 325)` com escala-base `0.3` |
| `scenes/gameplay_root.tscn` | `ScreenContent` é o espaço lógico compartilhado das telas |
| `scenes/console_frame.tscn` | Casca principal com moldura e controles físicos |
| `scenes/mobile_main.tscn` | Casca paralela com interface touchscreen |

## Regras para cenas internas

Cenas adicionadas diretamente sob `ScreenContent` devem ocupar o retângulo lógico inteiro usando anchors completos ou offsets explícitos de `0, 0, 1080, 650`. O root de uma tela não deve receber uma escala manual para compensar a escala do console.

Para uma tela completa, use a seguinte referência conceitual:

```text
root Control
anchors: full rect
offset_left: 0
offset_top: 0
offset_right: 1080
offset_bottom: 650
```

Painéis e textos devem respeitar a área segura, salvo quando um fundo artístico precisar cobrir toda a tela. Fundos podem ocupar `0–1080` e `0–650`; textos, botões, seleção e informações essenciais devem ficar dentro de `(24, 18)–(1056, 632)`.

A cena não deve consultar o tamanho físico da janela para calcular posições internas. Para centralizar um elemento, use o centro lógico `(540, 325)` ou o método `center_control()` de `ScreenContentSpace`.

## Regra específica para mapas

Mapas verticais, como o mapa da campanha da EVA, possuem uma área de conteúdo maior que a viewport para permitir scroll. O asset atual `assets/maps/eva_campaign_progression_map.png` possui **1440 × 2560 pixels**, proporção **9:16**. Para a largura lógica de 1080 pixels, a versão sem distorção ocupa **1080 × 1920 pixels** dentro do `MapContent`; a viewport continua sendo apenas `1080 × 650` e revela o mapa por rolagem. Isso não altera o tamanho da tela visível:

| Parte | Regra |
|---|---|
| Viewport visível | Sempre `1080 × 650` |
| Conteúdo do mapa | Pode ter altura maior que `650` |
| Fundo do mapa | Deve preservar a proporção original; não esticar horizontalmente e verticalmente de forma independente |
| Scroll inicial | Deve ser definido a partir do ponto inicial marcado no mapa, não a partir de um valor arbitrário |
| Pontos e bosses | Devem usar coordenadas do mapa completo, depois ser recortados pela viewport do `ScrollContainer` |
| Painéis de título e seleção | Devem usar `z_index` superior ao fundo e permanecer dentro da área segura |

Quando a imagem completa do mapa marcada pelo responsável for recebida, o primeiro ponto, o último ponto e cada boss devem ser medidos na própria imagem. Não reposicionar esses elementos por tentativa visual na tela escalada.

Para caber uma imagem inteira dentro de uma área de referência sem distorção, usar a lógica:

```text
fit_scale = min(area_width / image_width, area_height / image_height)
render_size = image_size × fit_scale
position = centro_da_area - render_size / 2
```

Se a imagem for mais alta que a viewport, ela deve permanecer inteira no `MapContent` e ser navegada por scroll. Se a intenção for mostrar a imagem inteira simultaneamente, deve-se aplicar o `fit_scale` dentro da área segura e aceitar margens laterais ou superior/inferior; nunca cortar silenciosamente o início ou o fim.

## O que não fazer

Não usar a escala do `Deepworld` como referência para dimensionar menus internos. O `Deepworld` é uma cena de mundo com transformação própria, enquanto `ScreenContent` é o contrato de UI. Também não usar a posição física da moldura, do sprite do console ou da janela do editor como coordenada de layout.

Não definir uma tela como `1080 × 650` e depois aplicar uma escala não uniforme apenas para fazê-la caber. Não colocar títulos, instruções ou painéis essenciais fora do retângulo lógico. Não alterar `main_responsive.gd`, `screen_content.gd` ou a escala-base do console para corrigir um único mapa ou uma única cena.

## Checklist antes de aprovar uma tela

| Verificação | Critério |
|---|---|
| Espaço lógico | Root da tela ocupa `1080 × 650` |
| Centralização | Elementos centrais usam `(540, 325)` como referência |
| Proporção | Não existe escala manual não uniforme |
| Margens | Conteúdo essencial respeita pelo menos `24 px` horizontal e `18 px` vertical |
| Legibilidade | Textos ficam dentro da área segura e não são cortados pelo console |
| Scroll | O conteúdo maior que a viewport usa `ScrollContainer`, sem mover a viewport inteira |
| Camadas | Fundo fica abaixo; seleção, títulos e instruções ficam acima |
| Validação | A cena é testada no Godot 4.7.1 em runtime normal e headless |
| Mobile | Nenhuma alteração é transferida ao mobile antes da aprovação explícita no principal |

## Arquivos de referência

Este contrato deve ser consultado junto de:

- `scripts/screen_content.gd`
- `scripts/main_responsive.gd`
- `scenes/main.tscn`
- `scenes/console_frame.tscn`
- `scenes/mapa_campanha_eva.tscn`
- `scripts/mapa_campanha_eva.gd`

A partir deste documento, qualquer ajuste de proporção deve ser descrito em **coordenadas lógicas do ScreenContent**, indicando a posição, o tamanho, a escala e a margem utilizada. A cópia `AuroraPetMobileVersion` permanece congelada até a aprovação das alterações no AuroraPet principal.
