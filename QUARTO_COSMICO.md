# Quarto Cósmico — Especificação da primeira implementação

## Objetivo

O Quarto Cósmico é uma nova área interna do Deepworld. Nesta primeira implementação, ele reutiliza a composição do mundo principal, mantém a plataforma e o pet da cascata e ativa um cenário independente chamado **Fundo Padrão**, que não pertence às facções Luz, Trevas ou Neutro.

A área foi preparada para receber futuramente acessórios, compras de comidas, animações, movimentos e customizações visuais. O Guarda-Roupas permanece como uma área reservada para a próxima etapa.

## Entrada e saída

O Quarto Cósmico fica fora de todas as opções do menu principal. Quando o menu não está ativado, o jogador pressiona o D-pad para cima. O jogo mostra uma mensagem do sistema perguntando se deseja entrar; o botão verde confirma e o botão rosa cancela.

Dentro do Quarto Cósmico, o D-pad alterna entre **Loja Cósmica** e **Guarda-Roupas**. O botão verde confirma a opção selecionada. Para sair, o jogador pressiona o botão rosa; uma mensagem do sistema pergunta se deseja sair e o botão verde confirma, enquanto o botão rosa cancela. A Loja Cósmica também pode ser abandonada pelo botão rosa ou pelo botão amarelo, retornando ao painel de áreas do quarto.

| Controle | Comportamento |
|---|---|
| D-pad para cima com o menu fechado | Solicita entrada no Quarto Cósmico |
| Verde durante a solicitação | Entra no Quarto Cósmico |
| Rosa durante a solicitação | Cancela a entrada |
| D-pad dentro do quarto | Alterna Loja Cósmica e Guarda-Roupas |
| Verde no Quarto | Confirma a área selecionada |
| Rosa no Quarto | Abre a confirmação do sistema para sair |
| Verde na confirmação de saída | Sai para o Deepworld |
| Rosa na confirmação de saída | Cancela a saída |
| D-pad dentro da Loja | Navega nas categorias e ofertas em quatro direções |
| Verde na Loja | Confirma a compra |
| Rosa ou amarelo na Loja | Retorna ao painel do Quarto |

## Fundo Padrão

O Quarto Cósmico possui o nó `FundoPadrao`, baseado no cenário geral do Deepworld. Ao abrir a área, os fundos de facção são temporariamente ocultados e o Fundo Padrão é ativado. Ao retornar, o estado anterior dos fundos é restaurado.

A plataforma do Deepworld continua pertencendo à cena `deepworld.tscn`, portanto permanece na cascata original. O Quarto Cósmico é uma área filha do Deepworld e não quebra a relação `Main > Console Frame > Deepworld > Pet`.

## Áreas do Quarto

A tela inicial do quarto apresenta dois ícones de área:

| Área | Estado |
|---|---|
| Loja Cósmica | Implementada com categorias e ofertas funcionais |
| Guarda-Roupas | Ícone e entrada preparados; conteúdo será detalhado depois |

Os ícones provisórios ficam em `assets/UI/loja_cosmica.svg` e `assets/UI/guarda_roupas.svg`. Eles podem ser substituídos posteriormente por sprites pixel art definitivos sem alterar a lógica de navegação.

## Loja Cósmica

A Loja Cósmica possui três categorias: **Visual**, **Golpes** e **Especiais**. Cada oferta possui identificador, nome, nível mínimo e preço em Pontos de Exploração.

### Visual

A categoria Visual contém cosméticos, efeitos, cenários e animações especiais. As ofertas iniciais são Aura Aurora, Rastro de Cometa, Nebulosa Viva e Órbita.

### Golpes

A categoria Golpes contém ataques fortes, ataques fracos, ataques de status, ataques de recuperação e supremas. As ofertas iniciais são Impacto Solar, Pulso Lunar, Sinal Nebular, Cura Estelar e Colapso Cósmico.

### Especiais

A categoria Especiais contém fundo exclusivo, editor de pet, músicas adicionais, editor de cenário, plataformas, catálogo de pets, hall de pets e EVA, a raposa mascote e guia de divulgação.

A Loja mostra simultaneamente o nível do pet, o XP atual, o XP acumulado, os Pontos de Exploração disponíveis e o Valor Acumulado das compras. Uma oferta pode ser bloqueada por nível ou por saldo insuficiente. Ao comprar, os pontos são descontados e o preço é adicionado ao valor acumulado.

| Informação | Fonte atual |
|---|---|
| Nível | `PetSkills.level` |
| XP atual | `PetSkills.xp` |
| XP acumulado | `PetSkills.total_xp` |
| Saldo da loja | Pontos recebidos da Batalha de Exploração |
| Valor acumulado | Total dos preços das compras confirmadas |

## Arquivos principais

| Arquivo | Responsabilidade |
|---|---|
| `scenes/quarto_cosmico.tscn` | Área do quarto, Fundo Padrão e ícones |
| `scripts/quarto_cosmico.gd` | Navegação, confirmação, pontos e retorno |
| `scenes/loja_cosmica.tscn` | Interface da loja e quadro de ofertas |
| `scripts/loja_cosmica.gd` | Categorias, ofertas, níveis, preços e compras |
| `assets/UI/loja_cosmica.svg` | Ícone provisório da loja |
| `assets/UI/guarda_roupas.svg` | Ícone provisório do Guarda-Roupas |
| `scripts/console_controller.gd` | Entrada pelo D-pad, botão verde e restauração do Deepworld |

## Próxima etapa criativa

O Guarda-Roupas ainda não altera o pet. Na próxima etapa, será necessário definir os tipos de acessórios, a organização por partes modulares, regras de equipar e remover itens, custos, preview visual, persistência das compras e relação entre roupas, efeitos, cores e facções.
