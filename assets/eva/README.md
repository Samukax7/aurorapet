# Assets da EVA

Esta pasta reúne os assets visuais da EVA, separados por função para facilitar a prototipagem na Godot.

## Evolução

A pasta `evolution/` contém as formas evolutivas em visão frontal/T-pose e visão traseira. A spritesheet frontal de 120 px usa grade 3×2, com seis estágios. A spritesheet traseira segue a mesma organização em alta resolução.

## Idle

A pasta `idle/` contém a spritesheet final com 18 frames em grade 3×6, sendo três frames para cada um dos seis estágios. Cada célula mede 64×64 px. A prévia ampliada é apenas para conferência visual.

## Introdução

A pasta `intro/` contém as animações reutilizáveis da EVA Deusa Cósmica:

| Arquivo | Grade | Tamanho da célula | Finalidade |
|---|---:|---:|---|
| `eva_presenter_idle_12frames_64px.png` | 3×4 | 64×64 px | Apresentar o Deepworld e reaproveitar na seleção dos ovos |
| `eva_presenter_pointing_6frames_64px.png` | 3×2 | 64×64 px | Explicar os botões e comandos |
| `eva_presenter_close_6frames_64px.png` | 3×2 | 64×64 px | Encerrar a introdução com sorriso e piscada do olho direito |

As três spritesheets finais usam canal alfa real. A ordem de leitura é da esquerda para a direita e de cima para baixo. As versões `*_padded.png` possuem margem transparente de 2 px entre as células e são as versões usadas pela cena `opening_flow.tscn`, evitando que pixels de um frame vizinho apareçam acima da cabeça ou nas bordas durante a animação.

O fundo da introdução sem plataforma foi colocado em `assets/fundo/aurorapet-deepworld-intro-no-platform.png`, pois é um cenário reutilizável e não um sprite da personagem.
