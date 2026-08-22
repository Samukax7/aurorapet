# Relatório de auditoria de bugs e consertos — AuroraPet

**Data:** 22 de agosto de 2026  
**Escopo:** abertura com EVA, ficha de status, lobby, menu principal, acesso ao Quarto Cósmico, minijogos, batalha, mapas, persistência e composição visual sob o `ScreenContent`.

## 1. Resumo executivo

A auditoria confirmou a inconsistência visual relatada na ficha de status: a `PetStatusPanel` estava em `z_index = 6` enquanto o `StatusSprite` da EVA estava em `z_index = 5`. Como o fluxo inteiro da abertura está acima do Deepworld, a EVA podia ficar atrás da ficha ou desaparecer parcialmente quando ocupava a mesma área. A camada da EVA foi elevada para `z_index = 7` e sua posição passou a ser aplicada explicitamente durante todo o ciclo de status.

Também foi confirmada uma falha de contexto no acesso ao Quarto Cósmico. A regra anterior verificava apenas se o menu e o submenu estavam fechados. Isso não era suficiente para provar que o jogador estava no lobby, porque outras telas também podem ocultar o `PetUI` ou manter suas variáveis internas em estado permissivo. A entrada foi reorganizada para exigir o lobby real: abertura encerrada, `PetUI` visível, Deepworld normal visível, nenhum minijogo, mapa, batalha, árvore de habilidades, encontro modal ou Quarto já aberto.

> **Regra implementada:** o Quarto Cósmico só pode ser solicitado quando o jogador está no lobby, com o menu principal fechado, pressionando `↑` e confirmando com o botão verde.

A varredura também encontrou e corrigiu uma indentação excedente no bloco de restauração do progresso do Quarto dentro do save. O projeto continua carregando em validação headless com status zero. Permanecem avisos não fatais de UIDs antigos em alguns recursos; o Godot usa o caminho textual como fallback, mas esses avisos foram registrados como pendência técnica.

## 2. Arquitetura auditada

A cascata modular foi preservada. O `ScreenContent` continua sendo a área lógica comum de todas as telas, enquanto a transformação física calibrada encaixa essa área na tela do console.

| Camada | Responsabilidade | Resultado da auditoria |
|---|---|---|
| `main.tscn` | Inicia o projeto e centraliza o console físico | Mantida |
| `main_responsive.gd` | Aplica escala externa conforme a viewport | Mantido; não deve ser usado para ajustar elementos internos |
| `console_frame.tscn` | Contém o console, o `ScreenContent` e todas as telas | Mantido |
| `ScreenContent` | Espaço lógico comum | `1080×650`, com calibração física `position = (-560,-651)` e `scale = (1.022,1.498)` |
| `Deepworld` | Lobby visual, plataforma e pet modular | Mantido como instância sob `ScreenContent` |
| `OpeningFlow` | BIOS, menu, história, controles, ovos, chocagem e status | Mantido acima do Deepworld |
| `ConsoleController` | Distribui teclado e botões físicos | Corrigido para reconhecer o lobby e bloquear entradas indevidas |

As cenas do pet continuam em cascata dentro do Deepworld. Nenhuma alteração removeu ou duplicou a relação `Deepworld → Paisagem → Pet`.

## 3. Bugs corrigidos

### BUG-01 — EVA atrás da ficha de status

**Sintoma:** na tela de status, a ficha branca cobria a EVA, fazendo a personagem aparecer atrás ou desaparecer parcialmente.

**Causa:** `PetStatusPanel` usava `z_index = 6`, enquanto `StatusSprite` usava `z_index = 5`. A posição do status também era mantida por valores espalhados entre a cena e o script.

**Correção:** `StatusSprite` passou para `z_index = 7`. Foram criadas as constantes `STATUS_EVA_POSITION = Vector2(1015, 520)` e `STATUS_EVA_EXIT_X = 1242.905`. O script aplica a posição da EVA ao entrar na tela, durante o ciclo completo e durante o voo de saída. A posição fica à direita e abaixo da ficha, sem cobrir os textos centrais.

**Arquivos:** `scripts/opening_flow.gd` e `scenes/opening_flow.tscn`.

### BUG-02 — Entrada do Quarto Cósmico dependia apenas de flags do menu

**Sintoma:** pressionar `↑` com o menu fechado podia tentar abrir o Quarto a partir de uma tela que não era o lobby, principalmente pelo D-pad físico, porque a verificação anterior não confirmava qual tela estava ativa.

**Causa:** `_is_quarto_global_access_available()` verificava apenas `opening_flow.active`, `pet_ui.menu_visible`, `pet_ui.submenu_visible` e a visibilidade do próprio Quarto.

**Correção:** foi criada `_is_lobby_active()`. Ela exige `PetUI` visível, Deepworld normal visível e ausência de árvore de habilidades, minijogos, mapas, batalha, menu de batalha, encontro modal e Quarto. A condição de menu fechado permanece em `_is_quarto_global_access_available()`.

### BUG-03 — Teclado podia responder ao menu quando ele não estava visível

**Sintoma:** a rota de fallback do teclado enviava movimentos e confirmações diretamente ao `PetUI`, sem exigir que o menu ou submenu estivesse visível.

**Causa:** o fallback chamava `pet_ui.move_selection()` e `pet_ui.confirm_selected()` apenas verificando se `pet_ui` existia.

**Correção:** a rota agora exige o lobby e, para navegar ou confirmar, exige `menu_visible` ou `submenu_visible`. O botão rosa fecha primeiro o submenu; somente depois alterna o menu principal.

### BUG-04 — Encontro da EVA podia consumir confirmação no modo errado

**Sintoma:** quando o encontro com a EVA ficava pendente durante uma transição de batalha, o teclado podia ser consumido pelo modo de batalha antes de resolver a escolha de ajudar ou recusar.

**Causa:** `eva_encounter_pending` era tratado depois de alguns despachantes de telas externas.

**Correção:** o modal de encontro agora é tratado imediatamente após a abertura, antes de minijogos, mapas ou batalhas. `Enter/Verde` ajuda e `Esc/Rosa` recusa, sem deixar outra tela consumir o input.

### BUG-05 — Restauração do save com indentação excedente

**Sintoma:** o bloco que restaura `shop_total_value`, `owned_items` e pontos do Quarto possuía uma indentação maior que o `if quarto_cosmico != null`.

**Causa:** três tabulações foram usadas dentro de um bloco que exigia duas. O carregamento headless ainda passava por fallback, mas o código ficava frágil e difícil de manter.

**Correção:** o bloco foi normalizado para a indentação GDScript esperada e sincronizado nas duas cópias.

**Arquivo:** `scripts/aurorapet_save.gd`.

## 4. Fluxos verificados

| Fluxo | Verificação | Estado |
|---|---|---|
| BIOS → menu inicial | `OpeningFlow` recebe o controle enquanto `active = true` | Aprovado |
| Menu → história/controles/ovos/status | Botões e estados continuam centralizados no `OpeningFlow` | Aprovado |
| Chocagem → status | Ovo desaparece, pet reaparece e ficha é aberta | Aprovado |
| Status → lobby | Vermelho fecha a ficha e chama `_finish_flow()` | Aprovado |
| Lobby com menu aberto | D-pad navega o menu e verde confirma | Aprovado |
| Lobby com menu fechado + `↑` | Abre somente o aviso de entrada do Quarto | Aprovado |
| Aviso do Quarto + verde | Entra no Quarto | Aprovado |
| Aviso do Quarto + rosa | Cancela e permanece no lobby | Aprovado |
| Quarto aberto | D-pad navega; verde confirma; rosa cancela; amarelo volta na loja | Aprovado |
| Quarto fora do lobby | Entrada bloqueada | Aprovado |
| Batalha/mapas/minijogos | `↑` não abre o Quarto | Aprovado por guarda de contexto |
| Batalha derrotada | Retorna ao lobby com mensagem da EVA | Aprovado |
| Compra no Quarto | Pontos, itens possuídos e valor acumulado são salvos | Aprovado estruturalmente |

## 5. Varredura visual e de camadas

A inspeção dos prints enviados foi cruzada com os retângulos e camadas das cenas. O console físico aparece reduzido porque `main_responsive.gd` escala o aparelho inteiro; isso é diferente da área lógica interna. O `ScreenContent` continua com `1080×650`, enquanto a calibração física aplicada em `console_frame.tscn` é `(-560,-651)` com escala `(1.022,1.498)`.

Na abertura, os painéis principais estão acima do Deepworld. A ficha de status permanece em `z_index = 6`; a EVA de status agora fica em `z_index = 7`; o balão de fala usa `z_index = 7`; e os sprites do Deepworld não são alterados. Essa ordem permite que a EVA seja visível sem cobrir os textos centrais da ficha.

O Quarto Cósmico mantém uma compensação própria na subcena: o `Room` cobre `1080×650`, mas sua escala corrige a escala do Deepworld pai. Essa escala não foi removida durante a auditoria porque ela é uma compensação de composição, não uma segunda definição de viewport. O risco visual continua registrado: qualquer futuro ajuste do `ScreenContent` deve ser conferido também no Quarto.

## 6. Avisos técnicos ainda existentes

A validação headless terminou com `GODOT_STATUS=0`, sem erro de sintaxe ou falha fatal de carregamento. O log ainda registra UIDs antigos ou inválidos em cenas e recursos, por exemplo em `pet.tscn`, `deepworld.tscn`, `quarto_cosmico.tscn`, `console_frame.tscn` e `pet_ui.tscn`. O Godot informa que usa o caminho textual do recurso como fallback.

Esses avisos não bloquearam a execução, mas devem ser tratados em uma etapa técnica própria, preferencialmente abrindo o projeto na versão Godot 4.7.1 e salvando as cenas para que o editor regenere os UIDs. Não recomendo substituir esses identificadores manualmente sem uma cópia de segurança, porque eles atravessam várias cenas instanciadas.

Também existem logs `print()` de desenvolvimento em `console_controller.gd`. Eles não são exibidos ao jogador final; aparecem apenas no console de depuração. Foram mantidos nesta etapa para facilitar a investigação da progressão. A remoção pode ser feita no polimento V0.1.

## 7. Validação e sincronização

A versão publicada foi validada com o Godot 4.7.1 em modo headless. O processo terminou com status zero. As mensagens de UID foram classificadas como avisos conhecidos, não como falhas.

Os seguintes arquivos foram sincronizados entre o GitHub e o projeto local:

```text
scripts/console_controller.gd
scripts/opening_flow.gd
scripts/aurorapet_save.gd
scenes/opening_flow.tscn
```

Os scripts `console_controller.gd`, `opening_flow.gd` e `aurorapet_save.gd` ficaram byte a byte iguais nas duas cópias. A cena `opening_flow.tscn` mantém os `unique_id` locais gerados pela Godot, mas contém as mesmas alterações funcionais de camada e posicionamento.

O backup da auditoria está em:

```text
C:\Users\samuk\OneDrive\Documentos\aurorapet_backups\audit_before_lobby_quarto_status_20260822
```

## 8. Próximas pendências priorizadas

| Prioridade | Pendência | Motivo |
|---:|---|---|
| P1 | Testar manualmente a ficha de status com a EVA entrando, permanecendo na posição e saindo | A camada foi corrigida estruturalmente, mas a confirmação final é visual no console calibrado |
| P1 | Testar `↑` com menu aberto, menu fechado, submenu aberto, batalha, mapas e minijogos | Confirma a regra de lobby em todos os donos de input |
| P1 | Reabrir o projeto local e aceitar o recarregamento externo dos scripts/cenas | O editor pode manter versões antigas em memória |
| P2 | Regenerar UIDs antigos pelo editor Godot 4.7.1 | Limpa os avisos de fallback sem alterar a lógica |
| P2 | Revisar o tamanho do `Room` do Quarto após a calibração do ScreenContent | A compensação é intencional, mas sensível a mudanças futuras |
| P2 | Remover ou encapsular logs de desenvolvimento | Reduz ruído durante o polimento V0.1 |
| P3 | Recriar o atlas limpo da EVA | Os buracos transparentes pertencem ao alfa original dos frames e exigem tratamento artístico separado |
| P3 | Completar Guarda-Roupas e efeitos do Quarto | Atualmente o guarda-roupas é um placeholder funcional |

## Referências internas

[1]: ../../scripts/console_controller.gd "Roteador central de entradas e estados"
[2]: ../../scripts/opening_flow.gd "Fluxo de abertura e animações da EVA"
[3]: ../../scripts/aurorapet_save.gd "Persistência de progressão e Quarto"
[4]: ../../scenes/opening_flow.tscn "Camadas visuais da abertura"
[5]: ../../scenes/console_frame.tscn "ScreenContent e cascata do console"
[6]: ../../scripts/quarto_cosmico.gd "Estado interno do Quarto Cósmico"
[7]: ../../scenes/quarto_cosmico.tscn "Composição visual do Quarto Cósmico"
