# Checklist real — Vertical Slice até Gorgon Glitch

**Objetivo:** preparar o projeto local para executar o Primeiro Ato até a primeira evolução da EVA.
**Divisão:** arte e decisões criativas ficam com o autor; código, integração e testes ficam com a implementação técnica.
**Regra:** uma tarefa só é concluída após edição → teste → validação → sincronia → novo teste → nova validação → marcar checklist.

## O que já existe no projeto

### Artístico

- [x] Mapa visual de exploração.
- [x] Mapa visual da campanha da EVA.
- [x] Fundos do Deepworld e facções.
- [x] Sprites de EVA para introdução, idle e evolução.
- [x] Arte e sprites de Gorgon Glitch.
- [x] Introdução, idle, dano, defesa, ataque e derrota de Gorgon.
- [x] Fundo de batalha de Gorgon.
- [x] Áudio de introdução de Gorgon.
- [x] Sequência base da queda de EVA.
- [x] Estrutura de Visual Novel.
- [x] Arte-base de EVA Bebê e Criança.
- [x] Música cósmica inicial e feedback básico de interface.
- [x] Módulos visuais básicos do pet.
- [x] Ícones e elementos principais da interface.

### Desenvolvimento técnico

- [x] Cascata principal `main → console_frame → ScreenContent`.
- [x] Lobby, necessidades, cuidados, treino e XP do pet.
- [x] Pet modular com identidade procedural.
- [x] Batalha PvE por turnos reutilizável.
- [x] Cena de batalha, atores do pet, Eco e Boss.
- [x] Mapa de exploração e mapa da Jornada carregáveis.
- [x] Visual Novel e NPC da EVA.
- [x] `EvaJourneyManager` e `AuroraPetSave` existentes.
- [x] Ferramenta inicial de validação headless criada.

## O que falta — frente artística e criativa

### Prioridade P0: adaptação e integração

- [ ] Adaptar a queda existente para culminar no encontro com o Deepmon e a microtela-Cuidador.
- [ ] Definir a Base Neutra usando a plataforma existente.
- [ ] Selecionar a pose da EVA Criança e criar somente a transição do cristal.
- [ ] Confirmar a leitura da composição atual da caverna para a entrada de Gorgon.
- [ ] Inserir a nuvem de hostilidade no mapa existente.

### Criação artística realmente necessária

- [ ] Criar o Guardião restaurado da Cidade dos Dados.
- [ ] Criar o primeiro Eco comum corrompido.
- [ ] Criar o Cristal de Memória 01 e seu efeito.
- [ ] Criar a Ultimate da EVA Bebê.
- [ ] Criar a Ultimate da EVA Criança.
- [ ] Criar os três estados visuais da nuvem: hostil, limpeza e estável.
- [ ] Fechar os textos definitivos e a direção de voz do Ato 1.
- [ ] Criar ou selecionar FX e músicas específicos ainda ausentes.

### P1: acabamento após o slice funcionar

- [ ] Polir interface da Jornada e transições entre mapas.
- [ ] Criar padrão visual das facções Luz, Trevas e Neutra.
- [ ] Criar mais módulos do pet.
- [ ] Ajustar aparência geral do pet.
- [ ] Ajustar animações do pet.
- [ ] Planejar visuais dos Guardiões humanoides para o pós-game.

## O que falta — frente técnica

### P0: caminho jogável até Gorgon

- [ ] Criar o gatilho de encontro com EVA dentro do fluxo de exploração.
- [ ] Registrar no save se o jogador aceitou ou recusou ajudá-la.
- [ ] Fazer a Jornada abrir a partir do encontro, sem parecer um menu desconectado.
- [ ] Implementar a plataforma inicial como nó narrativo da campanha.
- [ ] Separar Deepmon comum de Eco narrativo; não exibir “Eco” antes do gatilho.
- [ ] Criar dados centrais para encontro, ressonância, cristal, forma e boss.
- [ ] Adicionar o primeiro Eco comum com dificuldade acima do início da exploração.
- [ ] Implementar ressonâncias sem evolução automática.
- [ ] Implementar progressão gradual dos Ecos menores.
- [ ] Conectar a Ultimate da EVA Bebê ao turno de batalha.
- [ ] Fazer a batalha de Gorgon usar definição central de Boss, não nome textual isolado.
- [ ] Conectar introdução, batalha, derrota, desfragmentação e retorno ao mapa.
- [ ] Registrar restauração da Cidade dos Dados e dissipação da nuvem.
- [ ] Conceder o primeiro cristal e evoluir EVA Bebê → Criança.
- [ ] Atualizar sprite, voz, Ultimate e estado salvo após a evolução.
- [ ] Garantir retorno funcional ao mapa de Exploração e ao Lobby.

### P0: correções estruturais necessárias

- [ ] Substituir as sete formas antigas do código por Ovo + seis formas oficiais.
- [ ] Remover o limite fixo antigo de 21 nós do save.
- [ ] Criar migração de save para a estrutura atual.
- [ ] Unificar os dados duplicados entre `EvaJourneyManager`, `MapaCampanhaEva`, `EvaVisualNovel` e `ConsoleController`.
- [ ] Definir IDs únicos para base, ilhas menores, ilhas maiores, Bosses e cristais.
- [ ] Fazer o mapa vertical suportar base neutra + 15 ilhas menores + 6 maiores.
- [ ] Impedir desbloqueio territorial por vitória comum.
- [ ] Registrar estado de hostilidade/restauração da Cidade dos Dados.
- [ ] Conectar funções de vínculo da EVA narrativa às atividades aprovadas.
- [ ] Garantir que a EVA DEV não grave progresso narrativo.
- [ ] Atualizar o save com cristais, forma, Jornada, território e inventário.

### P1: validação e robustez

- [ ] Executar carregamento headless do projeto.
- [ ] Corrigir erros de script, recursos e UIDs encontrados.
- [ ] Testar fluxo completo em Godot: Lobby → exploração → EVA → Eco → Gorgon → cristal → retorno.
- [ ] Testar recusa e reentrada no encontro com EVA.
- [ ] Testar save/load antes e depois do Boss.
- [ ] Testar derrota, retorno ao Lobby e perda de 50% dos ganhos da expedição.
- [ ] Testar regressão da exploração após a restauração.
- [ ] Marcar cada tarefa somente depois da validação visual na Godot.

## Decisões que preciso receber do autor

1. Qual arte provisória será usada para o Guardião restaurado?
2. Qual será o visual do primeiro Eco comum?
3. A plataforma inicial será um nó da base neutra ou a primeira ilha menor?
4. Quantos Ecos menores acontecem antes de Gorgon?
5. Qual música e quais FX entram no primeiro slice?
6. Qual será a Ultimate da EVA Bebê e da EVA Criança?
7. Você fornecerá os sprites finais ou devo integrar placeholders técnicos?
8. Quais falas do Ato 1 serão consideradas definitivas para orientar a dublagem?
