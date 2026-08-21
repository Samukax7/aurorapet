# Plano de animação da EVA a partir do GIF completo

## Mapeamento do GIF original

| Estado | Quadros | Uso |
|---|---:|---|
| Entrada de boas-vindas | 0–71 | EVA atravessa a tela e chega ao ambiente |
| Sinal de apresentação/escolha | 72–119 | Giro, caudas abertas e partículas; usar junto de mensagens e escolhas |
| Transição para outra tela | 120–191 | Movimento lateral e voo; alternar `flip_h` para trocar o lado de chegada |
| Idle final | 192–239 | Loop contínuo enquanto a tela aguarda o jogador |
| Close final | 216–239 | Encerramento próximo da ficha de status, usando os quadros finais mais estáveis |

## Estratégia de integração

A spritesheet completa terá 240 células organizadas em 16 colunas por 15 linhas, com células RGBA de 160×160 px. Cada quadro será recortado a partir da silhueta transparente da raposa, centralizado sem cortar caudas ou partículas. A posição do `Sprite2D` será animada pela cena: a entrada e as transições deslocam a EVA horizontalmente, enquanto o idle mantém a posição e repete os quadros 192–239.

A propriedade `flip_h` será alternada nas transições para a EVA voar para o lado oposto. Os quadros 72–119 serão usados como reações/sinais de escolha e os quadros 216–239 como close final, com escala maior e posição no canto inferior direito da ficha.
