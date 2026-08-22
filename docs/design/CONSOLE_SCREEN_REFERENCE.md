# Referência de tela do console

## Assets observados

O console físico `aurorapet-console-pixel-body.png` e a moldura isolada `aurorapet-screen-only-pixel-mockup.png` possuem 4096 × 3072 px. A moldura isolada mostra uma área interna de tela ampla, centralizada dentro do dispositivo, com proporção visual diferente da janela web atual.

## Estado técnico atual

O projeto usa viewport lógica de 1080 × 650 px, com `window/stretch/mode = "canvas_items"` e `window/stretch/aspect = "expand"`. O `Console Base` é centralizado pelo script `main_responsive.gd`, com escala base de 0,3 multiplicada pelo fator de ajuste da janela.

A instância atual de `ScreenContent` está dentro de `console_frame.tscn`, porém usa offsets `(-557, -662)` até `(338, 153)`, resultando em 895 × 815 px, escala adicional aproximada de `(1,231249, 1,218436)` e transformação própria. Essa combinação explica por que muitas cenas usam coordenadas que não coincidem diretamente com a viewport de 1080 × 650.

## Contrato implementado

A referência lógica comum agora é um `ScreenContent` de **1080 × 650 px**, centralizado no nó `Console Base` com offsets de `(-540, -325)` até `(540, 325)`. O script `scripts/screen_content.gd` define `LOGICAL_SIZE` e `LOGICAL_CENTER` para que futuras cenas e efeitos usem os mesmos valores sem depender do tamanho da janela.

Todas as cenas de tela continuam instanciadas sob esse único `ScreenContent`: gameplay, UI, abertura, minijogos, batalha, mapas, menu Batalhar e Quarto Cósmico. As cenas de UI que estavam no espaço legado de aproximadamente 895 × 815 foram convertidas para 1080 × 650. Os mapas, que já usavam 1080 × 650, foram preservados.

O `Deepworld` agora usa `Vector2(540, 325)` como centro no `ScreenContent`. O Quarto Cósmico e a Loja Cósmica receberam uma compensação controlada para ocupar o mesmo espaço lógico apesar de o Deepworld usar escala própria para os assets de fundo.

A janela web continua podendo expandir e reduzir o jogo proporcionalmente. A janela é responsável apenas pelo fator de escala; as cenas não devem mais usar o tamanho da janela para corrigir margens individualmente.

A cena atual foi preservada pelos backups em `backups/opening_flow_before_manual_adjustments.tscn`, `backups/console_frame_before_screencontent_migration.tscn` e `backups/screencontent_before_migration/`. A validação deve conferir o centro, as margens, o pet, a EVA, os ovos, os mapas, a batalha, os minijogos e o Quarto Cósmico.
