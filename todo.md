# AuroraPet — Tarefas

## Arquitetura do pet modular

- [x] Manter o corpo, olhos, orelhas, asas e cauda como nós Sprite2D independentes dentro de `scenes/pet.tscn`.
- [x] Usar a cascata `ConsoleFrame > ScreenContent > Deepworld > Paisagem > Pet` como composição principal.
- [x] Remover as camadas modulares duplicadas de `deepworld.tscn`.
- [x] Substituir o `PetAssembler` por sorteio de texturas no `PetRandomizer`.
- [x] Permitir definir uma variante individual por código com `set_part_variant()`.
- [x] Permitir sortear novamente o conjunto com `reroll()`.
- [ ] Adicionar controles visuais para trocar cada peça diretamente no editor, se necessário.
- [ ] Adicionar regras de combinação e pesos de sorteio por espécie/raridade.

## Integração do console

- [x] Manter a cascata `Console Base > ScreenContent > Deepworld`.
- [x] Remover a composição duplicada de `Deepworld` e `ScreenContent` diretamente de `main.tscn`.
- [ ] Ajustar visualmente a escala e o enquadramento final dentro da tela do console.

## Assets

- [ ] Validar caminhos dos assets modulares no editor Godot.
- [ ] Remover fundos opacos dos 20 assets modulares e preservar transparência.
- [x] Criar D-pad pixel art separado e três botões redondos verde, amarelo e rosa.
- [x] Copiar os quatro controles para `assets/console/controles`.
- [x] Adicionar os cinco ícones do menu em `assets/UI`.

## Progressão e habilidades

- [x] Criar estrutura local de habilidades com Golpe Fraco, Golpe Forte, Golpe de Status e Defesa.
- [x] Adicionar nível, XP e requisitos básicos de desbloqueio.
- [x] Conectar ações de cuidado, brincar e treino a ganhos iniciais de XP.
- [ ] Criar UI visual da árvore de habilidades no console.
- [ ] Conectar habilidades desbloqueadas ao sistema de combate PvE.
