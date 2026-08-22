# Auditoria de camadas da EVA na cena de abertura

**Data:** 21 de agosto de 2026  
**Escopo:** inspeção sem alteração de código ou de posições.

## Resumo

A EVA está configurada em `z_index = 5`, enquanto `StoryPanel`, `EggPanel`, `EggSelectionPanel` e `PetStatusPanel` permanecem no z-index padrão. Como todos esses nós pertencem ao mesmo `OpeningFlow`, que possui `z_index = 30`, a EVA é desenhada na frente desses painéis quando suas áreas se sobrepõem.

O `ControlsSpeechBubble` possui `z_index = 6`, portanto o balão da tela de controles fica corretamente acima da EVA. Essa exceção não se aplica aos outros painéis da abertura.

## Área aproximada dos sprites

O atlas da EVA tem 2560 × 2400 px, organizado em 16 × 15 células de 160 × 160 px. Isso significa que cada frame ocupa aproximadamente 160 × 160 px antes da escala do nó.

| Sprite | Escala atual | Área aproximada de um frame | Posição inicial |
|---|---:|---:|---:|
| `PresenterSprite` | 2,4× | 384 × 384 px | `(185, 645)` |
| `GuideSprite` | 2,2× | 352 × 352 px | `(145, 355)` |
| `StatusSprite` | 2,2× | 352 × 352 px | `(680, 555)` |

Como os nós são `Sprite2D`, a posição representa o centro do frame. Portanto, a área ocupada se estende aproximadamente metade da largura e altura para cada lado da posição.

## Conflitos encontrados

| Estado | Elemento em risco | Diagnóstico |
|---|---|---|
| Boas-vindas / `story` | `StoryPanel` e texto da história | `PresenterSprite` termina em torno de x=185, mas seu frame pode alcançar aproximadamente x=377. O painel começa em x=315. Existe sobreposição de até cerca de 62 px; como a EVA está em z=5, ela pode cobrir a borda e parte do conteúdo da história. |
| Controles / `controls` | Borda esquerda do `ControlsPanel` | O `GuideSprite` chega aproximadamente até x=321, enquanto o painel começa em x=300. O risco é pequeno e o balão de fala está protegido em z=6, mas a borda e o conteúdo inicial do painel podem ser tocados pela EVA. |
| Escolha dos ovos / `egg_select` | `EggSelectionPanel`, opções e descrição da aura | `PresenterSprite` termina em torno de x=185 e pode ocupar até x=377. O painel começa em x=255. A sobreposição potencial é grande, especialmente porque a descrição da aura fica na parte inferior do mesmo painel. |
| Eclosão / `egg` | Ovo, painel de eclosão e instruções | `GuideSprite` chega aproximadamente de x=254 a x=606, dentro da área do `EggPanel`, e está em z=5. O ovo e o painel estão no z padrão. A EVA pode passar na frente do ovo ou do texto de instrução. |
| Status / `status` | Identidade, atributos e botão invisível de saída | `StatusSprite` ocupa aproximadamente x=504–856 e y=379–731. O `PetStatusPanel` vai até x=795 e y=690. A EVA pode cobrir a coluna direita da identidade, dos atributos e da mensagem inferior, além de ultrapassar a borda do painel. |

## Animação e risco adicional

As posições são animadas por interpolação durante as transições. Assim, o conflito não ocorre apenas na posição final: durante o voo, a EVA atravessa áreas de conteúdo. No estado `status`, depois do ciclo de 240 frames, o voo de saída move o sprite até x=1030, fazendo a EVA deixar o console; esse movimento é desejado, mas precisa respeitar a camada dos elementos que devem continuar legíveis enquanto ela passa.

A variação de escala do ciclo completo aumenta e reduz ligeiramente a área ocupada. Por isso, ajustes baseados somente na posição central podem falhar nos frames de maior escala.

## Recomendações para a próxima alteração

A solução mais segura é separar a ordem de desenho em camadas explícitas. A UI textual e os botões devem ficar acima da EVA, enquanto a EVA pode continuar acima do fundo e atrás dos painéis de leitura. Uma configuração recomendada é:

| Camada | Elementos |
|---:|---|
| 0 | `Background`, `IntroBackdrop` |
| 2 | EVA e elementos decorativos da apresentação |
| 6 | `StoryPanel`, `ControlsPanel`, `EggSelectionPanel`, `EggPanel`, `PetStatusPanel` |
| 7 | `ControlsSpeechBubble` e balões prioritários |
| 8 | Botões, descrições da aura e mensagens de confirmação |

Além do z-index, convém reservar áreas sem sobreposição: EVA à esquerda na história, lateral oposta ao painel na seleção dos ovos, lateral do ovo durante a eclosão e canto inferior fora da coluna de atributos no status. O voo de saída deve continuar usando o `flip_h` e a trajetória para a direita, mas pode receber um limite de posição ou máscara visual para não interferir na leitura antes de sair.

## Conclusão

A auditoria confirma que a preocupação é válida: **a EVA pode ficar na frente dos sprites e textos em quatro dos cinco estados relevantes**, principalmente na escolha dos ovos, na eclosão e na tela de status. O problema principal é estrutural, causado pela combinação de `z_index = 5` nos sprites e z-index padrão nos painéis, agravado pelo tamanho de cada frame e pelas trajetórias de entrada.

Nenhum script, cena, posição ou asset foi alterado durante esta auditoria.
