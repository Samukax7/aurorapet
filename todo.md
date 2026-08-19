# AuroraPet — Tarefas

## Arquitetura do pet modular

- [x] Manter o corpo, olhos, orelhas, asas e cauda como nós Sprite2D independentes dentro de `scenes/pet.tscn`.
- [x] Usar a cascata `ConsoleFrame > ScreenContent > Deepworld > Paisagem > Pet` como composição principal.
- [x] Remover as camadas modulares duplicadas de `deepworld.tscn`.
- [x] Substituir o `PetAssembler` por sorteio de texturas no `PetRandomizer`.
- [x] Permitir definir uma variante individual por código com `set_part_variant()`.
- [x] Permitir sortear novamente o conjunto com `reroll()`.
- [ ] Adicionar controles visuais para trocar cada peça diretamente no editor, se necessário.
- [x] Adicionar regras de combinação e pesos de sorteio por espécie/raridade.

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

## Evolução e novas habilidades

- [x] Criar o nó `PetEvolution` com estágios de bebê a entidade cósmica.
- [x] Aplicar crescimento visual por marco de nível.
- [x] Expandir a árvore com habilidades avançadas e pré-requisitos.
- [x] Exibir feedback de nível, evolução e habilidade desbloqueada na tela.
- [ ] Criar uma tela navegável da árvore de habilidades.
- [ ] Trocar camadas visuais específicas por estágio de evolução.

## Variações visuais por evolução

- [x] Criar perfis de variantes para olhos, orelhas, asas e cauda por estágio.
- [x] Aplicar o perfil automaticamente ao evoluir ou carregar um estágio avançado.
- [x] Preservar as escolhas manuais do estágio bebê por padrão.
- [ ] Adicionar assets exclusivos de aura, roupas, acessórios e efeitos para os estágios finais.

## Level design — paleta e randomização visual

- [x] Definir 20 cores cósmicas organizadas em dez pares complementares.
- [x] Aplicar a cor principal a base, orelhas e cauda.
- [x] Aplicar a cor complementar a olhos e asas.
- [x] Sortear peças e paleta ao iniciar o jogo.
- [x] Adicionar a tecla `R` para repetir o sorteio durante o desenvolvimento.
- [ ] Revisar com direção criativa se a paleta precisa de ajustes de saturação ou luminosidade.

## Lógica — decaimento tranquilo

- [x] Reduzir as taxas de queda para um ciclo mais relaxado.
- [x] Fazer o decaimento por intervalos de tempo configuráveis.
- [x] Manter a saúde estável enquanto fome e energia não estiverem críticas.
- [x] Aplicar resistência dos atributos secundários para reduzir o decaimento.
- [x] Emitir sinal quando o pet entra ou sai de estado crítico.
