# AuroraPet — Paleta Cósmica

A paleta foi desenhada para destacar o pet contra o fundo predominantemente anil do Deepworld. São dez cores principais e dez complementares, organizadas em pares de oposição cromática.

| Par | Cor principal — base, orelhas e cauda | Cor complementar — olhos e asas |
|---:|---|---|
| 1 | Coral Nebulosa `#FF6B7A` | Turquesa Plasma `#6BFFF0` |
| 2 | Laranja Solar `#FFB347` | Azul Cometa `#4793FF` |
| 3 | Dourado Estelar `#FFE27A` | Azul Íon `#7A97FF` |
| 4 | Verde Plasma `#B8F06A` | Violeta Íon `#A26AF0` |
| 5 | Esmeralda Aurora `#5AF0B0` | Carmesim Nebulosa `#F05A9A` |
| 6 | Ciano Cometa `#55E9FF` | Vermelho Solar `#FF6B55` |
| 7 | Azul Elétrico `#79D8FF` | Pêssego Estelar `#FFA079` |
| 8 | Magenta Galáctico `#FF68E1` | Verde Laser `#68FF86` |
| 9 | Violeta Cósmico `#E28CFF` | Lima Aurora `#A9FF8C` |
| 10 | Rosa Quasar `#FF9BCE` | Menta Estelar `#9BFFCC` |

## Regra visual

A cada sorteio, o sistema escolhe um dos dez pares. A cor principal é aplicada ao conjunto visual formado por `CorpoBase`, `Orelhas` e `Cauda`. A cor complementar é aplicada a `Olhos` e `Asas`.

A regra mantém uma leitura visual simples: o corpo forma uma família cromática única e os elementos de destaque criam contraste complementar. Nenhuma cor depende de alteração permanente dos PNGs; o sistema usa `self_modulate` nos `Sprite2D`, preservando os assets originais e a edição manual no Inspector.

## Controle de desenvolvimento

O sorteio ocorre ao iniciar o jogo e pode ser repetido com a tecla `R` durante o desenvolvimento. O método público `reroll_palette()` também fica disponível para botões, testes automatizados e futuras telas de personalização.
