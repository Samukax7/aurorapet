# Revisão dos assets dos bosses

## Estado observado

O asset fonte disponível em `/home/ubuntu/aurorapet_bosses_spritesheet_126_source.png` possui 2304 × 1536 px, fundo branco e seis bosses dispostos em uma grade de três colunas por duas linhas. A versão preparada `/home/ubuntu/aurorapet_bosses_spritesheet_126px.png` possui 378 × 252 px e preserva a mesma composição em seis células de aproximadamente 126 × 126 px.

A ordem visual observada é:

| Posição | Boss correspondente na campanha |
|---|---|
| Linha 1, coluna 1 | Gorgon Glitch |
| Linha 1, coluna 2 | Prisma Guard |
| Linha 1, coluna 3 | Core Overlord |
| Linha 2, coluna 1 | Ignis Vectis |
| Linha 2, coluna 2 | Arquiteto do Esquecimento |
| Linha 2, coluna 3 | O Eco Absoluto |

## Características importantes

Os sprites foram produzidos em pixel art colorido, com fundo branco e elementos de efeito ao redor de alguns personagens. A versão 378 × 252 px é adequada como folha de referência, mas a integração na batalha deve evitar usar a folha inteira diretamente. O ideal é preparar seis recortes individuais de 126 × 126 px, mantendo transparência ou removendo o branco sem apagar brilhos brancos pertencentes aos próprios personagens.

Os bosses têm proporções visuais diferentes entre si. Portanto, a cena de batalha deve usar um contêiner comum com ajuste individual de escala e posição, em vez de assumir que os seis ocuparão exatamente a mesma área. O sprite deve ser estático durante a batalha, com eventuais efeitos de brilho ou entrada aplicados separadamente pela cena.

## Resultado da integração

Os seis recortes individuais foram preparados em `assets/bosses/`:

- `gorgon_glitch.png`
- `prisma_guard.png`
- `core_overlord.png`
- `ignis_vectis.png`
- `arquiteto_do_esquecimento.png`
- `eco_absoluto.png`

A folha transparente `bosses_spritesheet_126_transparent.png` também foi mantida como referência. A cena `batalha_de_exploracao.tscn` agora possui um contêiner `BossSprite`, e `batalha_de_exploracao.gd` carrega o recorte correspondente quando o contexto é `eva` e o encontro é um boss. O sprite fica oculto no lobby, na Sala de Treinos e nos encontros comuns.

A integração preserva as células de 126 × 126 px, usa textura sem suavização e mantém a proporção dentro de um contêiner maior para acomodar as diferenças de escala entre os seis personagens.

## Validação adicional

O recorte individual de `gorgon_glitch.png` confirmou que a célula 126 × 126 mantém o personagem centralizado, com margem suficiente para os efeitos pixelados laterais. A integração pode ampliar o recorte em um contêiner maior sem esticar a imagem, usando filtro de textura sem suavização e preservando a proporção.
