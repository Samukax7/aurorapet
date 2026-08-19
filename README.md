# AuroraPet — Protótipo Godot

Este projeto é o primeiro protótipo jogável do AuroraPet, baseado nos documentos de design e no diário de desenvolvimento enviados pelo criador.

## Direção do MVP

O MVP concentra-se em uma experiência de V-Pet retrô com um único pet procedural. O jogador pode alimentar, brincar, colocar o pet para descansar, elogiar e treinar. Os atributos sofrem degradação gradual, emoções mudam conforme o estado do pet e a progressão acontece por XP, nível e primeira evolução.

A batalha, o Deepworld explorável, o multiplayer, o trading, a sincronização online e o hardware físico ficam planejados para etapas posteriores. A prioridade inicial é validar o vínculo com o pet e o ciclo **cuidar → interagir → treinar → evoluir**.

## Estrutura

```text
scripts/
├── main.gd        # Montagem da interface e orquestração da cena
├── pet_state.gd   # Dados, geração procedural, decay, ações e evolução
└── pet_visual.gd  # Desenho procedural do pet e emoções
scenes/
└── main.tscn      # Cena inicial
project.godot     # Configuração Godot 4
```

## Decisões atuais

A implementação usa **Godot 4**, uma resolução lógica de 480×320 e uma apresentação ampliada para preservar a sensação de dispositivo retrô. O pet é desenhado por código nesta primeira versão para validar rapidamente a silhueta, as facções, as expressões e a animação de flutuação. As camadas SVG e os sprites pixel art poderão substituir o desenho procedural quando a direção visual estiver aprovada.

A geração utiliza uma seed fixa no protótipo para facilitar testes reproduzíveis. O valor pode ser trocado para criar novas criaturas. As facções são Luz, Trevas e Neutro; as raças são subtipos dentro dessas facções.

## Próximas etapas

1. Abrir o projeto na Godot 4 e corrigir eventuais diferenças de sintaxe conforme a versão instalada.
2. Adicionar persistência local em JSON.
3. Separar o HUD em cenas reutilizáveis.
4. Criar o primeiro minigame, preferencialmente Jokenpô.
5. Adicionar sprites modulares e efeitos sonoros.
6. Implementar uma batalha PvE simples contra um Eco.
7. Só depois avaliar Firebase, Android dedicado e hardware físico.
