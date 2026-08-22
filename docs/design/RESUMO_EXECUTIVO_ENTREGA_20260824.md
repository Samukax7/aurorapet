# AuroraPet V0.1 — Resumo Executivo e Checklist Final

**Data da auditoria:** 22 de agosto de 2026  
**Entrega prevista:** segunda-feira, 24 de agosto de 2026  
**Versão:** AuroraPet V0.1  
**Commit de referência:** `5106a56` — `Restrict lobby music and use instant confirm beep`

## 1. Resumo executivo

A V0.1 está organizada como uma versão de teste jogável, com foco em estabilidade do fluxo inicial, leitura dentro do console, coerência da navegação e preservação da arquitetura modular do pet. A cadeia `main → console_frame → ScreenContent → Deepworld → Pet` permanece intacta, e o contrato lógico das telas continua sendo `1080×650`.

O fluxo de abertura está ativo desde a BIOS até a criação do Deepmon: menu inicial, apresentação do Deepworld, controles, escolha da aura/ovo, chocagem e ficha de status. A EVA possui os blocos de animação de voo, giro e idle definidos por tela. A posição visual ainda merece conferência manual na Godot, especialmente nas transições e na ficha de status, mas não há erro de script ou falha de carregamento na validação automatizada.

O lobby é a tela principal depois da abertura. O menu de cuidados, os minijogos, o treino, o sistema de batalha, os mapas e o Quarto Cósmico são acessados a partir dele ou por transições controladas. O Quarto só deve abrir quando o lobby estiver ativo, o menu estiver fechado e o jogador fizer `↑` seguido de verde. A música tema agora toca exclusivamente no lobby; ela para em treino, batalha, mapas, minijogos e Quarto e retorna quando o jogador volta ao lobby.

A entrega também inclui uma trilha cósmica em loop e um beep PCM curto de confirmação. O beep substituiu o efeito anterior e possui duração de `0,18 s`, sem silêncio inicial perceptível. A trilha e o beep são recursos compatíveis com Godot e foram incluídos na exportação web.

O fundo animado e o Guarda-Roupas Cósmico continuam deliberadamente fora do escopo desta entrega. O Quarto Cósmico permanece ativo como área navegável, mas sem a implementação do Guarda-Roupas.

## 2. Estado técnico da build

| Item | Estado | Observação |
|---|---|---|
| Projeto Godot | Aprovado | `main.tscn` carrega em validação headless |
| Código GDScript | Aprovado | Nenhum `SCRIPT ERROR`, `Parse Error` ou falha de carregamento detectado |
| ScreenContent | Aprovado | Contrato lógico `1080×650` preservado |
| Cascata modular do pet | Aprovado | `main → console_frame → deepworld → pet` preservada |
| Introdução/EVA | Aprovado estruturalmente | Requer confirmação visual manual das posições na Godot |
| Lobby | Aprovado | Detecção centralizada por `_is_lobby_active()` |
| Quarto Cósmico | Aprovado | Acesso condicionado ao lobby fechado |
| Música do lobby | Aprovado | Autoplay desligado; loop ativado no import do WAV |
| Beep verde | Aprovado | PCM, estéreo, 44,1 kHz, `0,18 s` |
| Batalha | Aprovado estruturalmente | BattleStage atrás da UI; leitura visual deve ser conferida manualmente |
| Save | Aprovado estruturalmente | Sistema versionado e preservado |
| Exportação Web | Aprovado | Exportação V0.1 gerada em `docs/` |
| GitHub | Aprovado | Repositório limpo no commit de referência |
| Fundo animado | Fora do escopo | Não será incluído até segunda-feira |
| Guarda-Roupas | Fora do escopo | Não será incluído até segunda-feira |

## 3. Resultado da verificação do console da Godot

A validação headless do commit `5106a56` terminou com:

```text
GODOT_HEADLESS_STATUS=0
```

A busca por erros críticos não encontrou ocorrências de `SCRIPT ERROR`, `ERROR:`, `Parse Error`, `Failed to load script`, `No loader`, `Could not load` ou `UID duplicate`.

Foram encontrados **14 avisos de UID inválido**. Eles aparecem em `pet.tscn`, `deepworld.tscn`, `quarto_cosmico.tscn`, `console_frame.tscn` e `pet_ui.tscn`. Em todos os casos, a Godot informa que utilizou o caminho textual do recurso como fallback. Isso significa que os recursos foram localizados e a cena carregou, mas o projeto ainda possui UIDs antigos ou regenerados entre cópias.

| Classificação | Quantidade | Impacto na entrega | Decisão |
|---|---:|---|---|
| Erros críticos | 0 | Bloqueariam a execução | Nenhuma ação necessária |
| Warnings de UID inválido | 14 | Não bloquearam a execução nem a exportação | Registrar e não regenerar manualmente antes da entrega |
| Colisões de classes globais | 0 | Erro corrigido anteriormente ao retirar backups executáveis do projeto | Nenhuma ação necessária |
| Falhas de áudio | 0 | O beep e a trilha foram importados | Confirmar volume manualmente |

A validação automatizada foi executada sobre a cópia publicada em `/home/ubuntu/aurorapet-github`. A conexão automatizada com o processo do editor Godot aberto no Windows não estava disponível nesta rodada; portanto, o painel **Saída** da Godot local deve ser conferido manualmente durante o teste final. O projeto local recebeu os mesmos scripts, cenas, recursos de áudio, arquivos `.import` e configurações da build.

## 4. Checklist final de telas ativas

Marque cada item somente depois de testar dentro da moldura física do console, não apenas abrindo a subcena isoladamente.

| OK | Tela/fluxo | Critério de aprovação |
|---|---|---|
| [ ] | BIOS | Logo AuroraPet aparece centralizada, sem erro visual e sem travar o avanço. |
| [ ] | Menu inicial | Primeiro jogo mostra `START` e `OPTIONS`; jogo salvo mostra `START`, `CONTINUE` e `OPTIONS`. |
| [ ] | Boas-vindas ao Deepworld | Texto permanece dentro da caixa, a EVA não atravessa o painel e o botão `PRÓXIMA` responde. |
| [ ] | Controles | Ícones e textos estão legíveis; `VOLTAR` e `PRÓXIMA` não ficam fora da tela. |
| [ ] | Escolha do ovo | As três opções Luz, Trevas e Neutro aparecem na área correta; a descrição da aura acompanha a seleção. |
| [ ] | Chocagem | EVA fica no lado reservado, apontando para o ovo; diálogo fica acima dela e texto permanece dentro da caixa; o ovo recebe shake ao pressionar verde. |
| [ ] | Ficha de status | EVA permanece visível sem esconder os dados; identidade, facção, nível e atributos estão legíveis; vermelho retorna ao lobby. |
| [ ] | Lobby fechado | Pet, Deepworld, barras e fundo aparecem alinhados ao console; ↑ não abre nada enquanto o menu estiver aberto. |
| [ ] | Menu principal do lobby | Menu abre somente no lobby, seleção ciano acompanha o ícone e os submenus abrem sem deslocar a tela. |
| [ ] | Submenus de cuidado/comida/jogos | A navegação respeita os desbloqueios; rosa fecha primeiro o submenu; as mensagens não escapam da área útil. |
| [ ] | Sono e necessidades | Dormir fica disponível desde o início; enquanto dorme, ações bloqueadas exibem resposta coerente; energia recupera. |
| [ ] | Árvore de habilidades | Treino e atributos RPG aparecem sem cobrir pet, barras ou texto; habilidades possuídas ficam destacadas. |
| [ ] | Jogo da velha | Grade, turno, vitória/derrota e retorno funcionam; a tela informa claramente onde jogar. |
| [ ] | Pedra, papel e tesoura | Três opções aparecem, seleção funciona e o retorno não deixa o minijogo visível. |
| [ ] | 2048 | Grade e comandos cabem na tela; conclusão retorna ao lobby com XP registrado. |
| [ ] | Menu Batalhar | `SALA DE TREINOS`, `EXPLORAR DEEPWORLD` e, quando desbloqueada, `AVENTURA COM EVA` aparecem corretamente. |
| [ ] | Sala de treinos | Batalha contra Eco abre; pet, Eco, log, ações e HP permanecem visíveis e legíveis. |
| [ ] | Mapa Explorar Deepworld | Ilha inicial está liberada; seleção e retorno funcionam; encontros são encaminhados corretamente. |
| [ ] | Batalha de exploração | Combate D20 executa turnos e ações; recompensa e retorno ao mapa/lobby funcionam. |
| [ ] | Encontro com EVA | Modal bloqueia entradas externas; verde aceita, rosa recusa; nenhuma tecla atravessa para outro modo. |
| [ ] | Mapa Campanha da EVA | Caminho vertical é exibido; fases bloqueadas e desbloqueadas respeitam o progresso. |
| [ ] | Batalha de campanha | Boss correto aparece; batalha termina com recompensa/progresso ou retorno seguro após derrota. |
| [ ] | Quarto Cósmico | No lobby fechado, ↑ mostra confirmação; verde entra; rosa cancela; música para dentro do Quarto. |
| [ ] | Loja Cósmica | Navegação, verde, rosa e amarelo funcionam; valores e ofertas permanecem dentro da tela. |
| [ ] | Retorno ao lobby | Rosa/amarelo saem corretamente; pet UI retorna; música tema reinicia no lobby. |
| [ ] | Código DEV | `DEV` pula introdução e escolha do ovo, usa pet de teste e libera progressão sem corromper o save. |
| [ ] | Continue | Salvar, fechar/reabrir e continuar restauram identidade, status, progresso, pontos e estado de mundo. |
| [ ] | Web desktop | Console ocupa a viewport, textos são legíveis e áudio funciona após interação do usuário. |
| [ ] | Web celular | Orientação e toque não cortam a tela; botões virtuais respondem; áudio respeita a política de interação do navegador. |

## 5. Teste mínimo obrigatório antes da entrega

```text
Abrir a build
→ BIOS
→ START
→ Boas-vindas
→ Controles
→ Escolher ovo
→ Chocar ovo
→ Ficha de status
→ Vermelho
→ Lobby fechado
→ Abrir menu
→ Fechar menu
→ ↑
→ Verde
→ Quarto Cósmico
→ Rosa
→ Lobby
→ Abrir menu
→ Comer/Cuidar
→ Jogar
→ Treinar
→ Batalhar
→ Voltar ao lobby
→ Salvar
→ Continue
```

Durante esse caminho, confirmar quatro pontos de áudio: não há música na BIOS nem na introdução; a música começa no lobby; ela para imediatamente ao abrir treino, batalha, mapa, minijogo ou Quarto; e o beep do botão verde toca sem atraso perceptível.

## 6. Riscos aceitos para a entrega

Os desalinhamentos finos de alguns frames da EVA, a limpeza artística do alfa do spritesheet, os avisos de UID inválido e o polimento completo da batalha permanecem como riscos conhecidos e controlados. Nenhum deles apresentou erro de execução na validação headless. Não se deve regenerar UIDs, renomear arquivos em massa ou iniciar a refatoração do `ConsoleController` antes do congelamento da entrega.

A build deve ser considerada aprovada quando o caminho mínimo for concluído sem travamento, nenhuma tela ativa ficar fora da moldura, a música obedecer ao estado do lobby, o beep responder imediatamente e o painel **Saída** da Godot local não apresentar mensagens vermelhas durante o teste.

## Referências internas

[1]: `project.godot` — identificação e cena principal da V0.1  
[2]: `export_presets.cfg` — preset e exportação Web V0.1  
[3]: `scenes/console_frame.tscn` — cascata do console, ScreenContent e áudio  
[4]: `scripts/console_controller.gd` — estados, lobby, Quarto e reprodução sonora  
[5]: `scripts/opening_flow.gd` — sequência de abertura e animações da EVA  
[6]: `scenes/battle_stage.tscn` — camada dos combatentes em relação à UI  
[7]: `docs/design/ROADMAP_V0.1_PENDENCIAS.md` — prioridades e escopo congelado
