# Camadas do Deepworld por facção

## Arquitetura

O Deepworld foi reorganizado para separar o cenário da área fixa de interação. A cena `deepworld.tscn` mantém a cascata `Deepworld > Paisagem > Pet`, mas agora possui camadas independentes para o cenário e a plataforma.

| Camada | Nó | Z-index | Função |
|---|---|---:|---|
| Fundo legado | `Cenario/Fundo` | -5 | Fallback do cenário original. |
| Fundo da Luz | `Cenario/FundoLuz` | -5 | Cenário da Aurora da Luz. |
| Fundo das Trevas | `Cenario/FundoTrevas` | -5 | Cenário da Aurora das Trevas. |
| Fundo Neutro | `Cenario/FundoNeutro` | -5 | Cenário da Aurora Neutra. |
| Plataforma | `Plataforma` | 2 | Área comum fixa, sempre na frente do pet. |
| Pet | `Paisagem/Pet` | 1 | Criatura e módulos visuais, preservados na cascata. |
| UI | `console_frame/ScreenContent/PetUI` | superior | Menus, status e submenus. |

A plataforma usa a mesma resolução dos cenários, `1365 × 768`, e possui transparência na área superior. Isso permite sobrepor a arte sem deslocar a posição do pet. O pet continua em `position = Vector2(0, 488)` dentro de `Paisagem`, portanto a troca de fundo não altera seu enquadramento.

## Seleção automática

O `DeepworldController` consulta `PetIdentity.faction_id` e ativa somente a camada correspondente. As outras camadas ficam invisíveis. Se o asset da facção não puder ser carregado, o cenário legado permanece como fallback.

As três referências atuais são:

| Facção | Asset |
|---|---|
| Aurora da Luz | `assets/fundo/faccoes/deepworld_luz.png` |
| Aurora das Trevas | `assets/fundo/faccoes/deepworld_trevas.png` |
| Aurora Neutra | `assets/fundo/faccoes/deepworld_neutro.png` |

A plataforma não troca quando a facção muda. No futuro, poderão ser adicionadas variações de cor, símbolo ou brilho por facção sem modificar sua geometria.

## Próxima preparação no Krita

Para animação futura, cada cenário pode ser separado em novas subcamadas dentro de `Cenario`, mantendo a mesma resolução, origem e área segura central. O controlador já trabalha por nós de camada, então a evolução para nuvens, estrelas, partículas, cristais e elementos de parallax poderá ser feita sem reescrever a lógica de seleção por facção.
