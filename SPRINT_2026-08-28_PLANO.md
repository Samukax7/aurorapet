# Sprint AuroraPet — prazo de 28 de agosto de 2026

## Objetivo

Este sprint será desenvolvido primeiro no projeto principal local `aurorapet-main`. O projeto `AuroraPetMobileVersion` permanecerá congelado durante a criação e os testes. Somente mudanças aprovadas visualmente e funcionalmente serão selecionadas para transferência posterior ao mobile.

A base técnica preservada é `main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn`, com a lógica compartilhada separada da apresentação. A viewport de referência continua em **1080×650**, e os assets definitivos devem manter o estilo pixel art cósmico, transparência real e escala compatível com o console.

## Prioridades e entregas

| Prioridade | Bloco | Entrega até o prazo | Critério de aprovação |
|---:|---|---|---|
| 1 | Animações do pet | Refinar idle, reações de comer, cuidar, brincar, treinar, dormir, recusa e dano; manter o sistema modular | O pet reage de forma legível sem alterar a composição das peças nem interromper o HUD |
| 2 | Campanha visual novel da EVA | Tela de diálogo, retratos/poses, escolhas, memória, transição para batalha e retorno ao mapa | O jogador consegue acompanhar um capítulo com escolha, diálogo e entrada/saída de batalha |
| 3 | Fases da EVA | Conectar os seis capítulos ao mapa, aos bosses, às recompensas e à evolução narrativa | Fases desbloqueiam em ordem, podem ser repetidas e salvam o progresso |
| 4 | EVA como pet modular | Criar uma cena/definição separada da EVA jogável, com estágios Bebê até Deusa Cósmica | Cada estágio usa identidade visual própria e não confunde EVA narrativa, EVA DEV e pet do jogador |
| 5 | Guarda-Roupas Cósmico | Criar assets equipáveis de cabeça, corpo, costas/asa, cauda, aura e efeitos | Itens podem ser visualizados, equipados, removidos e persistidos sem duplicar `pet.tscn` |
| 6 | Assets estéticos do pet | Produzir cosméticos compatíveis com as cinco camadas modulares e com as evoluções | Transparência, pivôs, escala e leitura visual funcionam no console e na batalha |
| 7 | Golpes temáticos | Definir nomes, ícones e efeitos para golpes fracos, fortes, status, recuperação e supremas | Cada golpe possui identidade cósmica, custo/efeito coerente e feedback visual/audio próprio |
| 8 | Bosses | Criar entrada, idle, ataque, dano, derrota e vitória para os seis bosses | A animação comunica o estado do encontro e funciona na Batalha de Exploração e na campanha |
| 9 | Áudio | Adicionar sons de ações, golpes, recusas, bosses, campanha e ambientes sem tornar o áudio obrigatório | Cada evento importante tem feedback curto, volume equilibrado e fallback silencioso |

## Ordem de execução

Primeiro serão fechadas as animações reutilizáveis do pet e a infraestrutura de feedback de combate. Em seguida será implementado um vertical slice da campanha da EVA: uma fase narrativa completa, com diálogo, escolha, mapa, batalha, boss, memória e recompensa. Depois que esse slice for aprovado, a mesma arquitetura será expandida para os demais capítulos e para a evolução da EVA.

Os cosméticos, o guarda-roupas e os efeitos de golpes serão produzidos em lotes compatíveis com a infraestrutura, evitando criar sprites que não possam ser equipados ou persistidos. Os seis bosses receberão uma biblioteca de estados reaproveitável, em vez de seis controladores independentes. O áudio será adicionado por evento e permanecerá opcional para preservar a execução offline.

## Escopo mínimo obrigatório do prazo

Se houver pressão de tempo, a entrega mínima aprovada será: pet com reações principais funcionais; um capítulo da campanha da EVA em formato visual novel; mapa com fases desbloqueáveis; uma versão modular da EVA com todos os sete estágios visuais representados; primeiro lote do guarda-roupas; pelo menos cinco golpes temáticos com efeitos; animações de entrada/ataque/dano/derrota dos bosses; e um pacote inicial de sons.

A expansão dos seis capítulos completos, todos os cosméticos e todos os efeitos poderá continuar no mesmo projeto principal sem bloquear o primeiro marco jogável, desde que a arquitetura do save, do mapa e da batalha esteja fechada no vertical slice.

## Regra de aprovação e transferência

Cada bloco será validado no projeto principal local com Godot 4.7.1. A aprovação considera três dimensões: funcionamento, legibilidade no console e consistência visual com o AuroraPet. Nenhum arquivo será copiado para `AuroraPetMobileVersion` durante a prototipagem. Após a aprovação, será feita uma lista de arquivos alterados, seguida de uma transferência controlada e de nova validação no mobile.

## Arquitetura prevista

| Sistema | Responsabilidade |
|---|---|
| `pet.tscn` e `pet_randomizer.gd` | Camadas base, animações e reações do pet do jogador |
| `EvaNPC` / nova cena modular da EVA | Presença narrativa e versão jogável separadas |
| `EvaJourneyManager` | Capítulos, memórias, afeição, escolhas e estágios narrativos |
| `mapa_campanha_eva.gd` | Navegação, bloqueios e seleção das fases |
| `batalha_de_exploracao.gd` | Turnos, D20, custos, dano, status e resultado |
| `BattleStage` | Posicionamento, animações e efeitos visuais dos combatentes |
| `AuroraPetSave` | Persistência de campanha, itens, equipamentos e evolução |
| `loja_cosmica.gd` / Guarda-Roupas | Catálogo, compra, equipar, remover e preview |
| biblioteca de efeitos | Partículas, flashes, tween e sinais de ataque/dano |

## Pendências conhecidas da auditoria

O pet já possui uma `AnimationLibrary` com `idle`, `asas`, `cauda`, `olhos idle` e `orelhas idle`, e o randomizador já possui `play_reaction()`, tremor e pontos para partículas. O trabalho imediato é transformar esses ganchos em estados de animação claros e consistentes.

A campanha da EVA já possui `EvaJourneyManager`, seis capítulos, seis memórias, estágios narrativos, mapa com 25 nós e save persistente. Ainda falta a camada visual novel, a ligação completa entre fase selecionada e batalha e a apresentação das evoluções no fluxo.

O catálogo da Loja Cósmica já separa `visual`, `golpes` e `especiais`, mas os itens ainda são majoritariamente placeholders e não existe um sistema visual completo de equipamento. Os bosses já possuem sprites e encontros diferenciados, porém a apresentação ainda precisa de estados animados e efeitos.

## Referências internas

- `IMPLEMENTATION_ROADMAP.md`
- `DEEPWORLD_EVA_SCOPE_AUDIT.md`
- `docs/design/MODOS_BATALHAR_CAMPANHA_EVA.md`
- `docs/design/EVA_GIF_ANIMATION_PLAN.md`
- `PROTOTYPE_TECHNICAL_AUDIT.md`
- `SCENE_STRUCTURE.md`

## Status do primeiro marco — 25 de agosto de 2026

O primeiro marco foi implementado no projeto principal local e ainda não foi transferido para o mobile. O pet agora possui reações específicas por ação com movimento e partículas preservadas; a campanha ganhou a cena `eva_visual_novel.tscn`, diálogos, escolha moral, prólogo de fases e trilha opcional; a EVA modular foi isolada em `eva_modular_pet.tscn` com os sete estágios Bebê, Criança, Juvenil, Jovem, Adulto, Forma Máxima e Deusa Cósmica.

O Quarto Cósmico recebeu o painel `guarda_roupas_cosmico.tscn`, seis acessórios 64×64 com transparência e preview, equipagem pela camada `CosmeticOverlay` do pet e retorno pelos botões do console. A batalha recebeu cinco VFX temáticos (`Pulso Aurora`, `Fragmento Nebular`, `Maré de Plasma`, `Selo do Vazio` e `Impacto Estelar`), nomes temáticos para os golpes, animação idle/impacto dos bosses e áudio opcional de campanha, escolha e vitória.

A validação do editor e do runtime headless no Godot 4.7.1 para Windows passou com código de saída zero, sem `SCRIPT ERROR`, `Parse Error`, falha de carregamento ou erro de importação de áudio. Os WAVs foram normalizados para PCM porque os arquivos gerados inicialmente estavam identificados como MP3 apesar da extensão `.wav`. A aprovação visual em execução normal ainda depende da revisão do responsável pelo projeto; até essa aprovação, o mobile permanece congelado.
