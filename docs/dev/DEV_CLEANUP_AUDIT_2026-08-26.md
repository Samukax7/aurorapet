# Auditoria da faxina de desenvolvimento — 2026-08-26

## Escopo

Esta rodada trata somente do projeto principal **AuroraPet**. O projeto `AuroraPetMobileVersion` permanece separado e congelado. Nenhuma alteração desta faxina deve ser copiada para o mobile sem aprovação posterior.

A cascata oficial continua sendo `Pet → Deepworld → Console Frame → Main`. A cena `main.tscn` continua sendo a frente de execução; não serão duplicadas ou removidas peças modulares do pet nas cenas superiores.

## Estado encontrado

O projeto tinha a cache `.godot/`, plugins locais `addons/at-icons` e `addons/godot_ai`, exports Web antigos na raiz, arquivos ZIP de sincronização, um build Android gerado, dois scripts temporários e UIDs órfãos. Os plugins foram preservados porque são ferramentas locais do usuário e não pertencem ao runtime do jogo.

Também foram encontrados artefatos de exportação Web versionados no histórico do repositório. Eles não são necessários para o fluxo de desenvolvimento atual; antes de removê-los do controle de versão, é necessário confirmar se a publicação atual do Pages continuará sendo feita a partir de `docs/`. O workflow local usa `./docs` como artefato de Pages.

## Ações seguras realizadas

Os exports antigos, os ZIPs de sincronização, o build Android gerado e os arquivos temporários foram movidos para o arquivo externo:

```text
C:\Users\samuk\OneDrive\Documentos\AuroraPetDevArchive_2026-08-26
```

A movimentação é reversível e não apagou os artefatos. O `.gitignore` foi ampliado para evitar o retorno de builds, `.pck`, `.wasm`, exports Web e ZIPs de desenvolvimento. A pasta `.godot/` não foi apagada nesta rodada para não interromper o cache do editor; ela continua ignorada pelo Git.

## Itens mantidos deliberadamente

Os plugins `addons/at-icons` e `addons/godot_ai` foram mantidos localmente. O arquivo `@icons picker.html` e `godot-ai-LICENSE.txt` também foram preservados. Assets, cenas, scripts, documentos do projeto e configurações do Godot não foram removidos durante a auditoria.

## Próxima etapa

A próxima etapa é reorganizar e polir o ciclo normal de cuidado. O foco será reduzir duplicações e logs técnicos desnecessários, consolidar respostas do pet, manter bloqueios de sono e necessidades previsíveis e preservar o feedback que é útil para o jogador. Depois disso será feita a validação no Godot antes de qualquer commit ou push.

## Primeira rodada de polimento do cuidado

O `PetUI` passou a manter tweens e temporizadores independentes para mensagens do sistema e falas do pet. Isso impede que uma reação do pet cancele a mensagem de necessidade, recusa ou progressão que acabou de ser exibida. Os temporizadores usam tokens de mensagem para que um texto antigo não esconda uma mensagem nova.

As respostas de reação foram normalizadas para reconhecer tanto ações de categoria quanto ações de submenu. Comer, cada alimento, brincar e cada minijogo, limpeza e remédio agora recebem a fala correspondente do pet.

O `PetStats` recebeu uma forma explícita de aplicar ações previamente validadas. Minijogos e batalhas validam a disponibilidade na entrada e usam essa confirmação na conclusão, evitando que uma pequena queda de energia durante a atividade faça a recompensa ser recusada ou o custo de cuidado fique inconsistente.

O fluxo legado `eva_encounter_pending` foi removido do `ConsoleController`, pois o encontro intermediário atual usa `eva_exploration_encounter_active` e a cena visual novel. Os prints técnicos de treino, ação, habilidade, nível e evolução também foram retirados do runtime final; os feedbacks destinados ao jogador continuam na `PetUI`.

A abertura deixou de anunciar `SEM ÁUDIO` no projeto V 0.1 e os players `WelcomeAudio` e `IntroEvaAudio` foram alinhados às trilhas corretas.

A validação headless do Godot 4.7.1 terminou com código 0. O teste específico do cuidado terminou com `CARE_CLEANUP_TEST_OK`, cobrindo recusa de treino por energia, início e término do sono, aceitação no limite de energia e aplicação de uma atividade externa previamente validada.
