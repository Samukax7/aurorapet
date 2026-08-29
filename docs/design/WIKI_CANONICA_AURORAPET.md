# AuroraPet — Wiki Canônica

**Status:** referência oficial de design e lore
**Versão:** 0.1
**Atualização:** 28 de agosto de 2026
**Regra:** código e cenas confirmam o estado implementado; esta Wiki define o cânone de design aprovado e separa o que ainda será construído.

## Como ler esta Wiki

- **Implementado:** existe e pode ser encontrado nas cenas ou scripts locais.
- **Em consolidação:** existe parcialmente ou possui estrutura preparada, mas ainda precisa de integração.
- **Planejado:** decisão aprovada para implementação futura.
- **Histórico:** aparece apenas em documentos antigos e não deve ser usado como regra atual.

Documentos anteriores continuam preservados para comparação e validação. Eles não são fontes oficiais quando divergirem desta Wiki.

## O que é o AuroraPet?

AuroraPet é um V-Pet cósmico em pixel art. O jogador cuida de um Deepmon, cria vínculo, treina, brinca, explora o Deepworld, enfrenta Ecos e acompanha a Jornada da EVA.

O jogo combina:

- rotina de cuidado;
- pet modular e identidade procedural;
- progressão por XP, atributos e habilidades;
- exploração territorial PvE;
- campanha narrativa em Visual Novel;
- evolução da EVA;
- personalização no Guarda-Roupas Cósmico;
- batalhas de turno;
- conteúdo futuro de PvP.

O objetivo não é transformar o pet em uma sequência de telas desconectadas. O cuidado altera o preparo; o preparo permite explorar; a exploração revela o mundo; a Jornada dá significado às consequências.

## Loop principal

```text
cuidar → brincar → treinar → ganhar XP
        ↓
explorar Deepworld → enfrentar Ecos → obter recursos
        ↓
voltar ao Lobby → recuperar o Deepmon
        ↓
Jornada da EVA → restaurar territórios → evoluir
```

O Lobby é o coração do jogo. Exploração e campanha retornam ao Lobby para que o jogador alimente, limpe, trate, divirta e prepare o pet.

## O que é o Deepworld?

Deepworld é um universo digital nascido depois do fim de um universo anterior. Ele parece um espelho do mundo real, mas combina elementos digitais, cósmicos, vibrantes, sombrios e misteriosos.

Algumas regiões são coloridas e vivas; outras são tomadas por glitches, ruínas, silêncio e instabilidade. O mundo possui regras próprias, mas sua consistência pode ser rompida por transbordamentos cósmicos.

## Habitantes

Os habitantes nativos são os Deepmons. Eles são criaturas do Deepworld e utilizam o mesmo princípio modular do pet do jogador.

No mapa de Exploração, os Deepmons nativos são pacíficos. Eles podem caminhar, comer, dormir, brincar e fugir quando um Eco aparece. Captura e adoção não fazem parte do primeiro ciclo aprovado.

## Os dois mapas

### Mapa de Exploração

É o mapa territorial horizontal do Deepworld. Ele possui cinco ilhas ou regiões:

1. Cidade dos Dados;
2. Floresta de Cristal;
3. Ruínas Cristalinas;
4. Núcleo Vulcânico;
5. Abismo Elétrico.

Cada ilha possui estado próprio, hostilidade, encontros, recursos, Deepmons e consequências persistentes.

### Mapa vertical da Jornada da EVA

É uma camada alternativa formada por plataformas e ilhas flutuantes ligadas às memórias da EVA.

Sua composição aprovada é:

- uma base neutra;
- quinze ilhas menores de travessia, encontros e memórias;
- seis ilhas maiores, cada uma alinhada a um Boss da Jornada.

As seis ilhas maiores seguem a ordem:

1. Gorgon Glitch;
2. Prisma Guard;
3. Core Overlord;
4. Ignis Vectis;
5. Arquivista das Memórias;
6. Eco Absoluto.

O mapa vertical não é uma cópia física do mapa de Exploração. Ele representa o espaço de memória e interferência acessado através do Abismo Elétrico.

## Relação entre as ilhas e os Bosses

| Ilha de Exploração | Guardião territorial | Eco/Boss na Jornada |
|---|---|---|
| Cidade dos Dados | Guardião da Cidade dos Dados | Gorgon Glitch |
| Floresta de Cristal | Guardião da Floresta de Cristal | Prisma Guard |
| Ruínas Cristalinas | Guardião das Ruínas Cristalinas | Core Overlord |
| Núcleo Vulcânico | Guardião do Núcleo Vulcânico | Ignis Vectis |
| Abismo Elétrico | Não possui um dos quatro Guardiões territoriais | Corredor de manifestação dos Ecos |

Gorgon, Prisma, Core e Ignis são cópias corrompidas dos Guardiões de suas ilhas. Eles não são capangas simples; a campanha deve revelar por que receberam ordens para impedir EVA.

O Arquivista e o Eco Absoluto não são Guardiões de ilhas do mapa de Exploração. Eles pertencem ao conflito da memória e à camada alternativa.

## Abismo Elétrico

O Abismo Elétrico é uma região territorial e, ao mesmo tempo, uma falha de conexão entre camadas do Deepworld.

Ele funciona como:

- origem ou corredor de manifestação dos Ecos;
- passagem para o mapa vertical;
- região de crises e instabilidade;
- lugar onde EVA conduz o jogador e o pet à Jornada;
- espaço de eventos especiais e pós-game.

O Abismo Elétrico não adiciona um sétimo Boss territorial.

## Estados territoriais

Cada ilha de Exploração poderá assumir quatro estados:

| Estado | Aparência | Atividade |
|---|---|---|
| Hostil | Nuvem densa, glitches e pouca vida | Ecos e sobrevivência |
| Em limpeza | Nuvem reduzida, sinais e recursos | Combates, eventos e preparação |
| Estável | Céu aberto e Deepmons nativos | Observação, recursos e revisita |
| Crise | Nuvem concentrada e alerta | Eco detectado e batalha urgente |

A hostilidade será comunicada visualmente por uma nuvem que cobre a ilha e se dissipa conforme o jogador reduz a influência dos Ecos. Uma barra numérica permanente não é necessária.

## Guardiões

Cada uma das quatro ilhas territoriais possui um Guardião real. Durante a primeira fase de produção serão usados placeholders:

- Guardião da Cidade dos Dados;
- Guardião da Floresta de Cristal;
- Guardião das Ruínas Cristalinas;
- Guardião do Núcleo Vulcânico.

O Guardião do Núcleo Vulcânico é o mais forte e territorialista.

Depois da derrota de seu Eco, o Guardião real pode retornar e a ilha entra em restauração.

No pós-game, cada Guardião deverá possuir uma manifestação humanoide. Essa manifestação preserva elementos da criatura, do território e da facção. Sua função jogável ou cosmética ainda será definida.

## EVA

### Origem

EVA é uma entidade cósmica nascida depois do fim de um universo. Ela possui a sabedoria e a inteligência de um sistema universal, mas começa sem acesso consciente a esse conhecimento.

O Arquivista das Memórias enganou EVA, roubou suas memórias e separou seus fragmentos em cristais. O roubo reduziu EVA à forma de Bebê e interrompeu sua continuidade consciente.

O objetivo do Arquivista é provocar um transbordamento cósmico, colapsar a consistência universal do Deepworld, absorver o poder liberado e tornar-se uma entidade cósmica absoluta.

### Identidade no projeto

Existe uma única EVA na lore: a EVA narrativa da Jornada.

A EVA do modo `DEV` é uma ferramenta de depuração sem restrições de progressão. Ela não é clone, passado, Eco ou personagem independente da história.

A EVA desbloqueada no pós-game como pet especial continua sendo a mesma personagem narrativa em outro contexto de gameplay.

### Estados e formas

O ciclo total possui sete estados, contando o Ovo:

```text
Ovo → Bebê → Criança → Adolescente → Adulta → Anciã Cósmica → Deusa Cósmica
```

O Ovo pertence ao nascimento e não é uma forma de batalha.

### Progressão da Jornada

| Boss | Forma da EVA durante a batalha | Consequência |
|---|---|---|
| Gorgon Glitch | Bebê | Cristal 1 e evolução para Criança |
| Prisma Guard | Criança | Cristal 2 e evolução para Adolescente |
| Core Overlord | Adolescente | Cristal 3 e evolução para Adulta |
| Ignis Vectis | Adulta | Cristal 4 e evolução para Anciã Cósmica |
| Arquivista | Anciã Cósmica | Memórias finais e revelação do plano |
| Eco Absoluto | Anciã Cósmica | EVA absorve a cópia e evolui para Deusa Cósmica |

### Eco Absoluto

O Eco Absoluto é uma Cópia-Eco corrompida da EVA, criada pelo mesmo princípio que gerou os Ecos dos Guardiões.

Ele não é uma “EVA passada”, não é a EVA do modo `DEV` e não cria uma segunda protagonista canônica. EVA absorve essa cópia e os fragmentos finais para completar sua própria restauração.

A forma Deusa Cósmica é usada principalmente no encerramento narrativo e no pós-game.

## Pet do jogador

O pet do jogador é uma criatura modular com identidade separada da aparência.

Sua identidade pode conter:

- facção;
- linhagem;
- elemento;
- gênero;
- nome;
- traços;
- atributos;
- seed reproduzível.

As camadas visuais são corpo, cauda, asas, orelhas e olhos. O sistema deve trocar texturas e modulação sem montar ou destruir nós dinamicamente.

## Facções

As facções oficiais são:

- Luz;
- Trevas;
- Neutra.

No futuro, cada facção terá peças, paleta, animações, partículas, auras e efeitos de golpes próprios. Facção não deve ser apenas uma troca de cor.

## Necessidades e derrota

O pet possui fome, energia, humor, saúde, higiene, disciplina, peso, doença e sono.

As necessidades criam ritmo, não punição brusca. Quando o pet está em condição crítica, o jogo deve evitar iniciar novos encontros e oferecer retorno seguro ao Lobby.

Ao perder uma expedição:

- o pet retorna ao Lobby;
- 50% dos ganhos da expedição atual são perdidos;
- progresso permanente anterior não é removido;
- a necessidade de treino aparece com maior frequência;
- não existe cronômetro artificial obrigatório.

## Exploração e recompensas

Vitórias comuns reduzem a hostilidade e podem conceder XP, moedas, pontos, recursos ou eventos. Elas não devem liberar automaticamente a próxima ilha.

Itens e recursos coletados são enviados ao inventário do Guarda-Roupas Cósmico. Não haverá fabricação no escopo atual.

## Combate

O combate é por turnos, com rolagem D20, posições em três faixas, ataques, defesa, status, fuga, efeitos e logs compactos.

A mesma base de batalha pode ser usada por:

- Sala de Treinos;
- Exploração Deepworld;
- Jornada da EVA;
- PvP futuro.

O contexto deve ser configurado sem duplicar o controlador.

## Sala de Treino e PvP

A Sala de Treino terá:

- `Treinar sozinho`;
- `Batalhar com amigo`.

No modo com amigo, um jogador cria uma sala e fornece um código. Cada jogador envia ações confirmadas — ataque, alvo, defesa e movimento — e o turno é resolvido quando ambos confirmam.

Um log local não conecta dispositivos sozinho. O PvP precisará de um serviço compartilhado para salas, transmissão de comandos, validação, resolução de turnos e desconexões.

Ranking, matchmaking, temporadas e recompensas competitivas ficam fora do primeiro protótipo.

## Arquitetura técnica

A cascata principal deve ser preservada:

```text
main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn
```

Responsabilidades principais:

- `PetStats`: necessidades, sono, doença, recusas e reações;
- `PetSkills`: XP, atributos e habilidades;
- `PetEvolution`: evolução do pet do jogador;
- `PetIdentity`: seed, facção, linhagem e identidade;
- `EvaJourneyManager`: capítulos, cristais, afeição e evolução narrativa;
- `EvaVisualNovel`: apresentação e diálogos;
- `MapaCampanhaEva`: navegação vertical;
- `MapaExploracao`: seleção territorial;
- `BatalhaDeExploracao`: loop de combate;
- `AuroraPetSave`: persistência e migrações;
- `ConsoleController`: roteamento de sinais e telas;
- `DeepworldController`: cenário, facção e palco de batalha.

Nenhum sistema novo deve duplicar o pet modular ou criar uma segunda cascata.

## Persistência

O save deve preservar identidade, necessidades, progressão, habilidades, evolução, pontos, moedas, compras, campanha, cristais, estados territoriais e EVA pet especial.

Toda mudança de estrutura deve aumentar a versão do schema e possuir migração segura. Saves antigos nunca devem perder identidade ou progresso silenciosamente.

## Estado de implementação local

Já existem no projeto:

- console, Lobby, menus e controles;
- pet modular e identidade procedural;
- necessidades, cuidados e sono;
- XP, habilidades e evolução do pet;
- minijogos;
- batalha PvE;
- mapas de exploração e campanha;
- Visual Novel da EVA;
- save local;
- Quarto e Guarda-Roupas Cósmicos;
- assets e áudio iniciais;
- modo `DEV` descartável.

Ainda precisam de integração ou expansão:

- fonte única de dados da campanha;
- seis formas oficiais da EVA no código final;
- estrutura territorial persistente;
- hostilidade e nuvem por ilha;
- restauração visual e Guardiões;
- quinze ilhas menores do mapa vertical;
- evolução completa da EVA na Jornada;
- EVA pet especial pós-game;
- novos módulos e identidade completa das facções;
- PvP com serviço compartilhado;
- atualização e classificação da documentação histórica.

## Regra de validação

Toda alteração deve ser conferida em três níveis:

1. parsing e carregamento headless;
2. execução visual na Godot dentro da moldura do console;
3. teste do fluxo completo, save, retorno e regressão.

Uma tarefa só pode ser marcada como concluída quando o comportamento observado na Godot corresponder ao cânone e ao critério do checklist.
