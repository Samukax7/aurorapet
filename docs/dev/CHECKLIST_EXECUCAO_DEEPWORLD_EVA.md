# AuroraPet — Checklist de Execução: Deepworld e Jornada da EVA

**Status:** documento operacional editável
**Projeto:** AuroraPet V0.1
**Última revisão:** 28 de agosto de 2026
**Escopo:** loop de cuidado, exploração de Deepworld, Jornada da EVA, pet modular, facções, interface, áudio e PvP

## Como usar este documento

- Marque uma tarefa com `[x]` somente depois de completar todo o protocolo de execução.
- Use `[~]` para trabalho em andamento e `[ ]` para trabalho ainda não iniciado.
- Se uma validação falhar, mantenha a tarefa como `[~]`, registre a falha e volte à etapa necessária.
- Não avance para a próxima tarefa enquanto a atual não estiver validada, salvo quando houver um bloqueio registrado.
- Mudanças não aprovadas não devem ser transferidas para outra versão do projeto.

## Protocolo obrigatório de execução

Este ciclo deve ser repetido para cada tarefa do checklist.

### 1. Edição

- [ ] Confirmar a tarefa e seu critério de conclusão.
- [ ] Identificar cenas, scripts, assets, saves e documentos afetados.
- [ ] Preservar a cascata `main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn`.
- [ ] Implementar a alteração no projeto principal `aurorapet-main`.
- [ ] Registrar os arquivos alterados no histórico da tarefa.

### 2. Teste local

- [ ] Verificar carregamento e parsing do projeto.
- [ ] Executar o fluxo diretamente afetado.
- [ ] Testar entrada, saída, repetição e retorno ao Lobby.
- [ ] Verificar erros, warnings relevantes e regressões aparentes.
- [ ] Quando aplicável, testar teclado, D-pad, toque, save e carregamento.

### 3. Validação local

- [ ] Confirmar que o critério de conclusão foi atendido.
- [ ] Validar funcionamento dentro da moldura real do console.
- [ ] Validar legibilidade, escala, animação, áudio e feedback.
- [ ] Obter aprovação visual do responsável quando houver mudança visual ou narrativa.
- [ ] Registrar o resultado e as pendências restantes.

### 4. Sincronia

- [ ] Conferir `git diff` e garantir que somente arquivos esperados foram alterados.
- [ ] Atualizar documentação relacionada, quando necessário.
- [ ] Criar commit descritivo.
- [ ] Sincronizar a branch `main` com o repositório remoto.
- [ ] Confirmar que local e `origin/main` apontam para o commit esperado.

### 5. Teste após sincronia

- [ ] Testar novamente a versão sincronizada.
- [ ] Se houver exportação web, validar a build publicada sem depender do cache local.
- [ ] Testar o fluxo principal em desktop.
- [ ] Quando aplicável, testar navegador e celular.
- [ ] Confirmar que save existente continua carregando.

### 6. Validação final

- [ ] Confirmar que o comportamento sincronizado corresponde ao aprovado localmente.
- [ ] Confirmar ausência de erros críticos de script, carregamento ou importação.
- [ ] Registrar evidências: commit, build, captura, vídeo ou observação de teste.
- [ ] Registrar limitações conhecidas que ficaram fora do escopo.

### 7. Sinalizar o checklist

- [ ] Alterar a tarefa principal de `[~]` para `[x]`.
- [ ] Preencher o histórico de execução da tarefa.
- [ ] Atualizar a data de revisão deste documento.
- [ ] Registrar novas tarefas descobertas durante a implementação.

### 8. Avançar para a próxima tarefa

- [ ] Selecionar a próxima tarefa não bloqueada de maior prioridade.
- [ ] Confirmar suas dependências e seu critério de conclusão.
- [ ] Reiniciar o protocolo a partir de **Edição**.

## Regra rápida do ciclo

```text
EDIÇÃO
  ↓
TESTE LOCAL
  ↓
VALIDAÇÃO LOCAL
  ↓
SINCRONIA
  ↓
TESTE SINCRONIZADO
  ↓
VALIDAÇÃO FINAL
  ↓
SINALIZAR CHECKLIST
  ↓
PRÓXIMA TAREFA
```

## Checklist mestre por ordem de execução

As prioridades abaixo representam dependências. Cada bloco deve ser tratado como uma unidade testável e seguir o protocolo completo antes do avanço.

### P0 — Decisões canônicas

- [x] Confirmar as seis formas oficiais da EVA: `Bebê`, `Criança`, `Adolescente`, `Adulta`, `Anciã` e `Deusa Cósmica`.
- [x] Definir a ilha oficial de Gorgon Glitch: Cidade dos Dados.
- [x] Adotar placeholders territoriais para os Guardiões até o design definitivo: `Guardião da Cidade dos Dados`, `Guardião da Floresta de Cristal`, `Guardião das Ruínas Cristalinas` e `Guardião do Núcleo Vulcânico`.
- [x] Definir a relação entre o Guardião real e Gorgon Glitch: Gorgon é seu Eco corrompido.
- [x] Definir Prisma Guard como Eco do Guardião da Floresta de Cristal.
- [x] Definir Core Overlord como Eco do Guardião das Ruínas Cristalinas.
- [x] Definir Ignis Vectis como Eco do Guardião do Núcleo Vulcânico, o mais forte e territorialista.
- [x] Definir o Abismo Elétrico como passagem e origem de manifestação dos Ecos, sem Boss territorial entre os quatro primeiros.
- [x] Separar Arquivista e Eco Absoluto do conjunto de Guardiões territoriais.
- [x] Definir a ordem canônica dos seis Bosses: Gorgon Glitch → Prisma Guard → Core Overlord → Ignis Vectis → Arquivista → Eco Absoluto.
- [x] Aprovar o arco do capítulo 1: EVA Bebê derrota Gorgon, recupera o primeiro cristal e evolui para Criança.
- [x] Corrigir a identidade canônica: existe uma única EVA narrativa; a EVA do modo `DEV` é apenas ferramenta de depuração.
- [x] Definir o Eco Absoluto como Cópia-Eco corrompida da EVA, absorvida no final para completar a evolução em Deusa Cósmica.
- [x] Consolidar as facções oficiais `LUZ`, `TREVAS` e `NEUTRA`; características visuais detalhadas pertencem ao P8.
- [x] Representar hostilidade por uma nuvem sobre a ilha que se dissipa conforme a influência dos Ecos diminui.
- [x] Definir derrota: retorno ao Lobby, perda de 50% dos ganhos da expedição e aumento temporário da necessidade de treino; sem cronômetro de expedição.
- [x] Definir Deepmons ambientais pacíficos como variações visuais do pet modular.
- [x] Remover fabricação do escopo e enviar itens e recursos coletados ao inventário do Guarda-Roupas Cósmico.
- [x] Definir PvP futuro online por código de sala, comandos confirmados e resolução compartilhada de turnos.
  - Critério do bloco: decisões registradas sem contradições entre narrativa, progressão e escopo técnico.

### P1 — Arquitetura, dados e compatibilidade

- [ ] Unificar os dados de fases, encontros, Bosses e capítulos da EVA em uma fonte única.
- [ ] Criar estrutura persistente por ilha para estado, hostilidade, encontros, eventos e Boss.
- [ ] Corrigir o desbloqueio automático de ilhas por vitória comum.
- [ ] Corrigir scripts, cenas e índices que ainda presumem sete formas da EVA.
- [ ] Separar EVA narrativa, EVA de desenvolvimento e EVA pet especial.
- [ ] Criar migração para saves com a progressão antiga da campanha.
- [ ] Criar migração para saves com sete índices de forma da EVA.
- [ ] Criar migração para saves anteriores aos estados territoriais.
- [ ] Garantir valores padrão seguros para saves novos e antigos.
- [ ] Criar testes de ida e volta do save após as migrações.
  - Critério do bloco: dados possuem uma fonte de verdade e saves existentes carregam sem perda de progresso.

### P2 — Correções da campanha atual

- [ ] Adicionar `eva_ch6_01`, `eva_ch6_02` e `eva_ch6_03` ao mapa da campanha.
- [ ] Fazer os três encontros desbloquearem em sequência e persistirem no save.
- [ ] Ocultar a identidade do Eco Absoluto até a revelação final.
- [ ] Usar um nome neutro para o último nó antes do confronto.
- [ ] Corrigir progressão, repetição e retorno de todos os nós da campanha.
- [ ] Padronizar os nomes das seis formas na interface e documentação.
- [ ] Atualizar documentos que declaram como ausentes sistemas já implementados.
  - Critério do bloco: campanha atual navegável do primeiro nó ao último, sem revelar antecipadamente o twist final.

### P3 — Fundação visual e animações do pet

- [ ] Revisar a aparência base do pet no Lobby.
- [ ] Ajustar escala, pivô, posição e alinhamento de corpo, olhos, orelhas, asas e cauda.
- [ ] Garantir consistência visual entre Lobby, minigames e batalha.
- [ ] Revisar contraste, contorno, paleta e leitura sobre os cenários.
- [ ] Ajustar a animação `idle`.
- [ ] Ajustar animações de comer, cuidar, brincar, treinar e dormir.
- [ ] Ajustar animações de recusa, doença, sujeira, dano, vitória e evolução.
- [ ] Evitar separação ou salto entre as camadas durante animações.
- [ ] Validar todas as escalas e estágios de evolução do Deepmon.
- [ ] Criar fallback para módulos sem animação própria.
- [ ] Documentar dimensões, pivôs e regras para novos módulos.
  - Critério do bloco: pet modular estável e pronto para receber novas peças sem retrabalho estrutural.

### P4 — Interface funcional

- [ ] Corrigir foco e seleção em todas as telas existentes.
- [ ] Garantir navegação coerente por teclado, D-pad e toque.
- [ ] Corrigir textos cortados, sobreposições e elementos fora da moldura.
- [ ] Padronizar feedback de bloqueio, sucesso, erro, recompensa e confirmação.
- [ ] Revisar a legibilidade na resolução lógica de `1080 × 650`.
- [ ] Validar HUD, mapas, batalha, Visual Novel, loja e guarda-roupas.
- [ ] Validar responsividade mínima em desktop, navegador e celular.
  - Critério do bloco: todos os fluxos atuais podem ser usados e compreendidos antes da criação de novas telas.

### P5 — Vertical slice da primeira ilha e Gorgon Glitch

- [ ] Implementar `hostil`, `em_limpeza`, `estável` e `crise` para a primeira ilha.
- [ ] Registrar hostilidade, encontros e eventos no save.
- [ ] Fazer vitórias comuns avançarem a limpeza sem liberar indiscriminadamente novas ilhas.
- [ ] Aplicar custo de energia e fome durante a exploração.
- [ ] Aplicar efeito leve e aviso de cansaço moderado.
- [ ] Bloquear novos encontros quando o Deepmon estiver exausto.
- [ ] Garantir retorno seguro ao Lobby sem prender o jogador no mapa.
- [ ] Integrar encontro inicial da EVA, capítulo 1 e batalha contra Gorgon.
- [ ] Criar apresentação da memória recuperada e evolução correspondente da EVA.
- [ ] Vincular a derrota de Gorgon à restauração permanente da ilha.
- [ ] Criar apresentação visual hostil e restaurada.
- [ ] Criar a cena de retorno do Guardião real.
- [ ] Criar uma área natural simples com dois ou três Deepmons ambientais.
- [ ] Criar loops ambientais de caminhar, comer, dormir ou brincar.
- [ ] Implementar uma crise com alerta, glitch, fuga e batalha.
- [ ] Restaurar a rotina ambiental após a crise.
- [ ] Alterar encontros, recompensas e música conforme o estado territorial.
  - Critério do bloco: ciclo completo `cuidar → explorar → encontrar EVA → vencer Gorgon → restaurar ilha → revisitar` funciona e persiste.

### P6 — Narrativa, vínculo e evolução da EVA

- [ ] Incorporar o tema “memória não é identidade”.
- [ ] Manter o Arquivista ambíguo nos capítulos iniciais.
- [ ] Reinterpretar os Bosses como Guardiões, não como capangas.
- [ ] Fazer cada cristal responder uma pergunta e criar outra.
- [ ] Inserir pistas graduais da assinatura duplicada da EVA.
- [ ] Evoluir a voz da EVA através das seis formas oficiais.
- [ ] Criar diálogos e apresentação das memórias após os Bosses.
- [ ] Conectar `record_care()` às ações reais de cuidado.
- [ ] Conectar `record_shared_activity()` a exploração, batalha, treino, brincadeira e sono.
- [ ] Definir e aplicar o efeito da afeição nos diálogos e progressão.
- [ ] Mapear as seis formas para capítulos e marcos narrativos.
- [ ] Criar apresentações de evolução e impedir transformação automática sem contexto.
- [ ] Implementar o confronto final contra a Cópia-Eco Absoluta da EVA.
- [ ] Implementar a absorção da Cópia-Eco e dos fragmentos restantes após a vitória.
- [ ] Apresentar a evolução final para Deusa Cósmica.
- [ ] Garantir que a Cópia-Eco não seja confundida com uma segunda EVA canônica nem com a EVA DEV.
- [ ] Usar a forma Deusa Cósmica principalmente na conclusão narrativa e como conteúdo especial de pós-game.
- [ ] Implementar a EVA como pet especial desbloqueável no pós-game.
- [ ] Definir atributos, habilidades, necessidades e limites da EVA pet.
- [ ] Persistir desbloqueio, forma, atributos e estado da EVA pet.
- [ ] Testar troca entre Deepmon principal e EVA pet sem corromper o save.
- [ ] Criar manifestações humanoides dos quatro Guardiões como bônus de pós-game.
- [ ] Definir se as manifestações humanoides serão jogáveis, narrativas, companheiras ou cosméticas.
- [ ] Definir condição de desbloqueio individual para cada Guardião humanoide.
- [ ] Preservar na forma humanoide elementos reconhecíveis da criatura e de seu território.
  - Critério do bloco: Jornada e pós-game usam as seis formas de maneira coerente, visual e persistente.

### P7 — Expansão da exploração territorial

- [ ] Criar tabela de encontros específica para cada ilha.
- [ ] Implementar pontos de batalha, recursos, sinais e eventos.
- [ ] Criar recursos coletáveis persistentes.
- [ ] Implementar a utilidade aprovada dos recursos.
- [ ] Diferenciar Ecos comuns, raros e encontros de crise.
- [ ] Criar recompensas territoriais além de XP, pontos e moedas.
- [ ] Permitir revisita funcional a ilhas restauradas.
- [ ] Exibir resumo da expedição ao retornar ao Lobby.
- [ ] Aplicar a consequência aprovada para derrota.
- [ ] Garantir retorno seguro em todas as ilhas.
  - Critério do bloco: cada ilha oferece uma expedição reconhecível e conectada ao cuidado do Deepmon.

### P8 — Novos módulos e identidade das facções

- [ ] Definir quantidade mínima de corpos, olhos, orelhas, asas e caudas para a próxima versão.
- [ ] Padronizar dimensões, transparência, pivôs, nomenclatura e importação.
- [ ] Criar novas variações comuns de cada categoria modular.
- [ ] Criar uma paleta exclusiva para cada facção.
- [ ] Criar corpos e módulos exclusivos para cada facção.
- [ ] Criar animações ou movimentos exclusivos por facção.
- [ ] Criar partículas, auras e efeitos de ação exclusivos por facção.
- [ ] Criar identidade visual de golpes e batalha por facção.
- [ ] Definir regras de mistura entre peças comuns e exclusivas.
- [ ] Integrar as peças ao randomizador sem criar ou remover nós dinamicamente.
- [ ] Testar combinações extremas, animações e evoluções.
- [ ] Validar leitura das facções no Lobby, exploração e batalha.
  - Critério do bloco: facção altera identidade visual e comportamento, não apenas a cor do pet.

### P9 — Música e efeitos sonoros

- [ ] Implementar controles separados de música e efeitos.
- [ ] Garantir fallback silencioso e funcionamento sem áudio.
- [ ] Normalizar volumes, formatos e importação dos arquivos.
- [ ] Criar ou selecionar tema do Lobby.
- [ ] Criar temas de exploração por ilha ou estado territorial.
- [ ] Criar identidade musical para a Jornada da EVA.
- [ ] Criar temas ou introduções dos Bosses.
- [ ] Criar música de vitória, derrota, evolução e restauração.
- [ ] Adicionar efeitos de navegação, confirmação, cancelamento e menus.
- [ ] Adicionar efeitos de cuidado, treino, sono, doença e recusa.
- [ ] Adicionar efeitos de golpes, defesa, dano, crítico, status e derrota.
- [ ] Criar efeitos exclusivos das facções quando aplicável.
- [ ] Validar loops e transições entre Lobby, mapas, narrativa e batalha.
  - Critério do bloco: áudio reforça cada estado sem ser obrigatório para compreender ou jogar.

### P10 — Bosses e campanha completa

- [ ] Completar o pacote de Prisma Guard.
- [ ] Completar o pacote de Core Overlord.
- [ ] Completar o pacote de Ignis Vectis.
- [ ] Completar o pacote do Arquiteto do Esquecimento.
- [ ] Completar secretamente o pacote do Eco Absoluto.
- [ ] Associar cada Boss ao Guardião e à ilha correspondentes.
- [ ] Criar memória, evolução e restauração territorial após cada Boss.
- [ ] Validar a campanha completa do encontro da EVA ao pós-game.
  - Critério do bloco: todos os capítulos possuem apresentação, batalha, memória, consequência territorial e progressão persistente.

### P11 — PvP simples

- [ ] Confirmar o modelo de PvP aprovado em P0.
- [ ] Reutilizar o sistema de batalha existente sempre que possível.
- [ ] Criar seleção simples do Deepmon e confirmação dos jogadores.
- [ ] Definir regras de turno, vitória, empate, fuga e desconexão.
- [ ] Normalizar nível e atributos para evitar vantagem impossível.
- [ ] Definir habilidades, facções e efeitos permitidos no protótipo.
- [ ] Criar uma arena e interface mínima.
- [ ] Isolar partidas de PvP do save principal.
- [ ] Criar uma partida completa e repetível.
- [ ] Testar retorno ao Lobby e tratamento de interrupções.
- [ ] Manter ranking, temporadas e matchmaking fora do primeiro protótipo.
  - Critério do bloco: uma partida simples pode ser concluída e repetida sem afetar a campanha ou o save principal.

### P12 — Polimento, qualidade e publicação

- [ ] Revisar hierarquia visual, espaçamento, margens e alinhamentos.
- [ ] Padronizar tipografia, cores, botões, painéis e estados de foco.
- [ ] Fazer rodada final de acessibilidade e contraste.
- [ ] Testar recusa e reencontro da EVA.
- [ ] Testar exploração com necessidades críticas.
- [ ] Testar restauração e revisita das ilhas.
- [ ] Testar progressão completa da campanha e pós-game.
- [ ] Testar migração de saves antigos em versão final.
- [ ] Testar desktop, web e celular.
- [ ] Validar cache e publicação web.
- [ ] Atualizar roadmap, documentação técnica e changelog.
  - Critério do bloco: build publicada reproduz o comportamento validado localmente, sem erros críticos ou regressões conhecidas não registradas.

## Decisões pendentes do responsável

As decisões abaixo bloqueiam tarefas específicas de P0. Ao serem respondidas, devem ser transferidas para o registro de decisões e marcadas aqui.

- [x] Cidade dos Dados definida como ilha de Gorgon Glitch.
- [~] Usar `Guardião da Cidade dos Dados` como placeholder; aparência definitiva fica para a produção visual.
- [x] Hostilidade representada por nuvem territorial que se dissipa com o progresso.
- [x] Derrota retorna ao Lobby, remove 50% dos ganhos da expedição e aumenta temporariamente a necessidade de treino.
- [x] Deepmons ambientais pacíficos reutilizam variações do pet modular.
- [x] Sem fabricação; recursos e itens são armazenados no Guarda-Roupas Cósmico.
- [ ] Missões secundárias entram no MVP ou ficam para expansão.
- [ ] Guardiões terão diálogo direto com o jogador.
- [ ] Escolhas narrativas alteram diálogos ou criam finais diferentes.
- [x] Remover o conceito de “EVA passada”; existe apenas a EVA narrativa, e a EVA DEV não faz parte da lore.
- [x] Eco Absoluto definido como Cópia-Eco corrompida da EVA, absorvida para a evolução final.
- [ ] Recompensas por restaurar cada ilha.
- [ ] Ordem oficial das ilhas, Guardiões e Bosses.
- [ ] Quantidade mínima de módulos por categoria.
- [x] Facções oficiais: `LUZ`, `TREVAS` e `NEUTRA`; características e peças serão desenvolvidas no P8.
- [x] PvP online por código de sala e resolução compartilhada de turnos confirmados.
- [ ] Regras de balanceamento e recompensas do PvP.
- [ ] Forma exata de desbloqueio da EVA pet no pós-game.
- [ ] Nomes, formas originais, personalidades e formas humanoides dos quatro Guardiões.
- [ ] Função das manifestações humanoides no pós-game.
- [ ] Condições de desbloqueio das manifestações humanoides.
- [ ] Natureza exata da passagem do Abismo Elétrico e origem dos Ecos.

## Histórico de execução

Copie este bloco para cada tarefa trabalhada.

```text
Tarefa:
Status: [ ] não iniciada | [~] em andamento | [x] concluída | [!] bloqueada
Responsável:
Data de início:
Data de conclusão:

Arquivos alterados:
- docs/design/CANONE_DEEPWORLD_EVA.md
- docs/dev/CHECKLIST_EXECUCAO_DEEPWORLD_EVA.md

Testes locais:
- Verificação estrutural do Markdown concluída com `git diff --check`.
- Relações entre mapas, ilhas, Bosses, formas da EVA e sistemas revisadas por busca cruzada.

Validação local:
- Todos os itens de P0 estão decididos e marcados.
- Cânone não confunde EVA narrativa, Cópia-Eco e EVA DEV.
- Ordem dos seis Bosses e progressão das seis formas estão registradas.

Commit/sincronia:
- Pendente.

Teste após sincronia:
-

Validação final:
-

Evidências:
- docs/design/CANONE_DEEPWORLD_EVA.md
- Bloco P0 deste checklist.

Pendências descobertas:
- Nomes e designs definitivos dos Guardiões foram conscientemente adiados; placeholders territoriais aprovados.
- Tecnologia do serviço online de PvP será escolhida no P11.

Próxima tarefa:
-
```

## Registro ativo

### Execução 001 — P0 Decisões canônicas

```text
Tarefa: Consolidar as decisões canônicas que desbloqueiam arquitetura, vertical slice e produção de assets
Status: [~] em andamento
Responsável: N.O.V.A. + responsável pelo projeto
Data de início: 28/08/2026
Data de conclusão:

Arquivos alterados:
-

Testes locais:
-

Validação local:
-

Commit/sincronia:
-

Teste após sincronia:
-

Validação final:
-

Evidências:
-

Pendências descobertas:
-

Próxima tarefa:
- P1 — Arquitetura, dados e compatibilidade
```
