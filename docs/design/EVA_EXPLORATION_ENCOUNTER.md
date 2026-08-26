# Encontro intermediário da EVA na exploração

## Objetivo

O encontro da EVA acontece durante a exploração do Deepworld, entre as batalhas de Eco. A cena foi estruturada como uma camada reutilizável da visual novel, sem criar uma cena diferente para cada boss ou para cada ilha. O controlador troca o fundo, a pose da EVA, o texto e a escolha por dados.

## Gatilho normal

A cada vitória na exploração, o save incrementa `exploration_battles_completed` e um contador específico do encontro. Ao completar três vitórias, o contador volta para zero e o encontro fica disponível. A batalha concluída não precisa exibir a tela comum de vitória: o console fecha a batalha e abre diretamente o blackout narrativo.

Depois que o jogador aceita ajudar a EVA, `eva_encounter_seen` e `eva_adventure_unlocked` são gravados, o mapa da Jornada da EVA é aberto e o gatilho deixa de ser ativado na exploração. Depois de uma primeira recusa, a introdução é substituída por uma conversa curta com a EVA e a escolha retorna. Uma nova recusa encerra o encontro atual e retorna ao mapa de exploração; como o encontro não foi marcado como visto, ele poderá aparecer novamente após três novas vitórias.

## Sequência de apresentação

| Ordem | Fase | Apresentação | Avanço |
| --- | --- | --- | --- |
| 1 | Blackout | Tela preta com `O QUE FOI ISSO?`, overlay roxo, flicker e deslocamentos rápidos no título | Automático após 3 segundos |
| 2 | Queda 1 | Quadro aberto do céu com a silhueta | Automático |
| 3 | Queda 2 | Close da EVA em queda | Automático |
| 4 | Queda 3 | Retorno rápido ao quadro do céu | Automático |
| 5 | Queda 4 | Novo close da EVA em queda | Automático |
| 6 | Impacto | EVA no chão, com a composição de impacto fornecida | Automático |
| 7 | Diálogo | Fundo de campo do Deepworld, EVA centralizada e balão de diálogo | Botão verde |
| 8 | Escolha | Arte da EVA sem caixa de diálogo em tela cheia, com a caixa de decisão e os botões dentro do diálogo | D-pad + botão verde |

A duração dos cinco quadros da queda é controlada pela constante `FALL_SEQUENCE` em `scripts/eva_visual_novel.gd`. O blackout permanece fixo em três segundos para garantir o efeito de interrupção antes da queda.

## Reaproveitamento de poses e fundos

As poses são referências independentes e podem ser trocadas por linha de diálogo. O mapa `EVA_POSES` contém as chaves `cry`, `suspicious`, `confident`, `happy`, `neutral` e `angry`. Os fundos são escolhidos por `ENCOUNTER_BACKGROUNDS`; portanto, um futuro boss pode receber um fundo próprio apenas adicionando o asset e apontando a chave para o novo caminho.

No estado atual, `field` usa o fundo de cenário fornecido e `gorgon_glitch` usa a composição de caverna fornecida. As chaves dos demais bosses já existem como pontos de extensão e usam o campo até que seus fundos definitivos sejam entregues.

## Modo DEV

A sessão iniciada com o código `DEV` prepara um gatilho descartável por meio de `_dev_force_eva_encounter`. A primeira vitória registrada na área de exploração abre o encontro antes do contador normal de três batalhas. O gatilho é consumido uma vez e não é escrito no save real. O comportamento normal de produção não é afetado.

## Arquivos principais

| Arquivo | Responsabilidade |
| --- | --- |
| `scripts/eva_visual_novel.gd` | Estado da apresentação, sequência de queda, poses, diálogos, escolha e troca de fundo |
| `scenes/eva_visual_novel.tscn` | Camadas visuais do overlay dentro do `ScreenContent` |
| `scripts/console_controller.gd` | Abre o encontro após a vitória e direciona aceitação ou recusa para o mapa correto |
| `scripts/aurorapet_save.gd` | Contador de três batalhas, recorrência após recusa e gatilho DEV descartável |
| `assets/eva/encounter/` | Assets originais, fundos, aliases ASCII e recortes transparentes usados em runtime |

## Assets utilizados

Os arquivos originais fornecidos foram preservados na pasta de encontro. `eva_choice_full.webp` usa a arte da EVA sem a caixa de diálogo para preencher o `ScreenContent`; a caixa de escolha permanece como uma camada interna da moldura do diálogo. Para o runtime foram criados recortes PNG com base no canal alfa, evitando que as áreas transparentes da composição ocupem espaço visual desnecessário. As cenas dos dois mapas controlam suas próprias trilhas em loop e as interrompem ao sair para uma batalha. Nenhuma peça da cascata `Pet → Deepworld → Console Frame → Main` foi recriada ou removida.
