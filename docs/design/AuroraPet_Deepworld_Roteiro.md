# AURORAPET: DEEPWORLD — DOCUMENTO DE DESIGN TÉCNICO E ROTEIRO LITERÁRIO
**Engine:** Godot Engine 4.7.1
**Projeto:** AuroraPet — Módulo Deepworld (A Jornada de Eva)
**Resolução Lógica Interna:** 895 × 815 px (Tela do Console V-Pet)
**Versão do Documento:** 1.0.0

---

# PARTE I: ROTEIRO TÉCNICO & ARQUITETURA DE GAME DESIGN (GDD)

## 1. VISÃO GERAL E CONCEITO DE INTEGRAÇÃO
O **AuroraPet** é um jogo que combina a simulação clássica de V-Pet (cuidados, alimentação, higiene, treino e afeto) com uma camada expansiva de RPG/Exploração tática em turnos intitulada **Deepworld**.

O Deepworld não substitui o ciclo de vida do pet, mas funciona como uma dimensão paralela acessível através do menu de **BATALHAR**, desbloqueado quando o pet atinge o **Nível 6** de progressão.

```
+-----------------------------------------------------------------------+
|                             CONSOLE FRAME                             |
|  +-----------------------------------------------------------------+  |
|  | SCREENCONTENT (895 x 815 px)                                   |  |
|  |                                                                 |  |
|  |  +-----------------------------------------------------------+  |  |
|  |  | deepworld.tscn (z_index = -5 a 3)                          |  |  |
|  |  | - Fundo por Facção (z: -5 / 1)                            |  |  |
|  |  | - Plataforma do Cenário (z: 2)                             |  |  |
|  |  | - Nó Modular do Pet (z: 3)                                  |  |  |
|  |  +-----------------------------------------------------------+  |  |
|  |                                                                 |  |
|  |  +-----------------------------------------------------------+  |  |
|  |  | pet_ui.tscn (z_index = 10)                                 |  |  |
|  |  | - Hud, Barras, Caixas de Diálogo, Menus de Ação              |  |  |
|  |  +-----------------------------------------------------------+  |  |
|  +-----------------------------------------------------------------+  |
+-----------------------------------------------------------------------+
```

---

## 2. ESTRUTURA DE CENAS E CASCATA NO GODOT 4.7.1

### 2.1 Cenas Principais
1. `scenes/main.tscn`: Nó raiz do projeto. Gerencia inicialização, salvamento global (`save_data.json`) e áudios globais.
2. `scenes/console_frame.tscn`: Estrutura do console físico virtual com os botões interativos e a subjanela `ScreenContent`.
3. `scenes/deepworld.tscn`: Nó de renderização do ambiente Deepworld. Contém parallax, iluminação e nós dos combatentes.
4. `scenes/pet_ui.tscn`: Interface sobreposta com suporte para os menus do V-Pet, diálogos no estilo Visual Novel e HUD de combate.
5. `scenes/minigame_cores.tscn`: Instância carregada caso o jogador recuse a jornada principal e opte pelo modo recreativo.

### 2.2 Hierarquia de Renderização (Z-Index)
- `Cenario/Fundo` (`z_index = -5` ou `1`): Varia visualmente de acordo com a facção do pet (`Luz`, `Trevas`, `Neutro`).
- `Plataforma` (`z_index = 2`): Elemento de apoio visual fixo no chão da tela.
- `Paisagem/Pet` (`z_index = 3`): Posição base do pet no plano horizontal (`Vector2(0, 488)`).
- `Eva_NPC` (`z_index = 4`): Sprite/Animação de Eva ao lado do pet.
- `Efeitos_FX` (`z_index = 5`): Partículas de habilidades e animações de rolagem de D20.
- `UI_Layer` (`z_index = 10`): Caixa de texto, botões de escolha, barras de HP/EN.

---

## 3. ESTRUTURA DE SCRIPTS E GERENCIAMENTO DE ESTADO

| Script | Responsabilidade Técnica |
| :--- | :--- |
| `console_controller.gd` | Captura os cliques na moldura física e redireciona os comandos para o estado ativo. |
| `deepworld_controller.gd` | Instancia fundos dinâmicos por facção, gerencia a física leve do cenário e aplica os filtros visuais. |
| `eva_journey_manager.gd` | Controla as flags da história, nível de afeição de Eva, fragmentos coletados e desbloqueio das formas. |
| `pet_stats.gd` | Trata atributos de vida diária: Fome, Higiene, Energia, Saúde e Humor. |
| `pet_skills.gd` | Gerencia a árvore de habilidades, pontos de experiência (XP) e nível de combate do Pet. |
| `pet_evolution.gd` | Controla a escala procedural (4.0x a 9.2x) e variações visuais por maturidade. |
| `pet_identity.gd` | Armazena a Seed procedural, elemento, facção natal (`Luz`, `Trevas`, `Neutro`) e nome. |
| `battle_system.gd` | Gerencia o loop de turnos, rolagens D20, cálculo de modificadores, cálculo de dano e status voláteis. |

---

## 4. SISTEMA DE COMBATE D20 & MATEMÁTICA DE JOGO

O combate no Deepworld é resolvido em turnos por ordem de iniciativa baseada na velocidade/agilidade dos combatentes modificada por uma rolagem de dado D20.

```
                              INÍCIO DO TURNO
                                     │
                     ┌───────────────┴───────────────┐
                     │ Rolagem de Iniciativa (D20)   │
                     │  + Agilidade + Bônus Prior.   │
                     └───────────────┬───────────────┘
                                     │
                            ORDEM DE ATUAÇÃO
                                     │
                     ┌───────────────┴───────────────┐
                     │   AÇÃO DO JOGADOR / INIMIGO   │
                     │ (Golpes, Técnica, Guarda, Fuga)│
                     └───────────────┬───────────────┘
                                     │
                     ┌───────────────┴───────────────┐
                     │     TESTE DE ACERTO (D20)     │
                     └───────────────┬───────────────┘
                                     │
            ┌────────────────────────┼────────────────────────┐
            ▼                        ▼                        ▼
       D20 = 1 a 2              D20 = 3 a 19               D20 = 20
     Falha Tática              Acerto Normal            Ataque Crítico
   (30% Dano / Miss)       (Dano Base Calculado)     (150% Dano + Efeito)
            │                        │                        │
            └────────────────────────┼────────────────────────┘
                                     │
                     ┌───────────────┴───────────────┐
                     │ APLICAÇÃO DE DANO & STATUS    │
                     └───────────────┬───────────────┘
                                     │
                              FIM DO TURNO
```

### 4.1 Fórmulas Matemáticas de Combate

#### A. Iniciativa do Turno
$$\text{Iniciativa} = \text{D20}_{rolado} + \text{Agilidade} + \text{BônusPrioridade}$$
*(A ação **Guarda** concede bônus de prioridade $+10$, garantindo execução imediata).*

#### B. Tabela de Resolução D20
- **1 a 2 (Falha Tática):** O golpe perde precisão. Caça no ar ou inflige apenas 30% do dano base.
- **3 a 9 (Acerto Raspando):** O golpe atinge o alvo, aplicando 80% do dano base.
- **10 a 19 (Acerto Pleno):** O golpe atinge com 100% da eficácia.
- **20 (Acerto Crítico Cósmico):** Aplica 150% de dano e ignora 50% da defesa do alvo, além de garantir a aplicação de efeito de status volátil.

#### C. Cálculo Integrado de Dano
$$\text{Dano Base} = \frac{\text{Poder do Golpe} \times (\text{Ataque} + \text{Nível})}{\text{Defesa do Alvo} + 10}$$

$$\text{Dano Final} = \text{Dano Base} \times \text{Mult}_{Facção} \times \text{Mod}_{D20} \times \text{Fator}_{Guarda}$$

Onde:
- $\text{Fator}_{Guarda} = 0.5$ se o alvo usou **Guarda** no turno; caso contrário, $1.0$.
- $\text{Mod}_{D20}$: $0.3$ (Falha), $0.8$ (Raspando), $1.0$ (Pleno), $1.5$ (Crítico).

#### D. Tabela de Eficiência de Facções ($	ext{Mult}_{Facção}$)

| Atacante \ Defensor | Luz | Trevas | Neutro |
| :--- | :--- | :--- | :--- |
| **Luz** | 1.0x | **1.5x** | 0.8x |
| **Trevas** | 0.8x | 1.0x | **1.5x** |
| **Neutro** | **1.5x** | 0.8x | 1.0x |

### 4.2 Status Voláteis Rápidos
1. **Enfraquecido:** Reduz o ataque do alvo em 30% por 2 turnos.
2. **Desorientado:** Reduz em -4 os testes de acerto D20 do alvo por 2 turnos.
3. **Sobrecarregado:** Dobra o custo de Energia (EN) de todas as técnicas do alvo por 3 turnos.

---

## 5. MINIGAME RECREATIVO DE COMBINAR CORES (ROTA ALTERNATIVA)
Quando o jogador opta por **NÃO AJUDAR** Eva no prólogo, o acesso ao Deepworld carrega um puzzle casual em `scenes/minigame_cores.tscn`.

- **Mecânica:** Grade 6x6 de gemas de energia coloridas (Vermelho, Azul, Verde, Amarelo, Roxo).
- **Loop de Gameplay:**
  1. O jogador combina 3 ou mais gemas da mesma cor para gerar energia e moedas.
  2. A cada 5 combinações, surge um **Eco Menor** na parte superior da tela.
  3. A energia acumulada pelas combinações dispara ataques automáticos do Pet contra o Eco.
  4. **Recompensas:** Moedas de Ouro (para comprar comida e remédios no V-Pet) e Cristais de Experiência.
  5. Eva observa no canto da tela. O botão "Falar com Eva" permanece disponível na interface para iniciar a campanha RPG quando o jogador desejar.

---

# PARTE II: ROTEIRO LITERÁRIO & NARRATIVO

## 1. LORE FUNDAMENTAL E MITOLOGIA

### 1.1 O Big Crunch Digital e o Nascimento do Deepworld
Antes da existência do ecossistema AuroraPet, existia um universo primordial de dados completos, uma vasta rede cósmica de consciência. Quando esse universo atingiu o fim do seu ciclo vital, ocorreu o evento conhecido como *O Grande Estresse Quântico*.

Toda a matéria, história e conhecimento daquele cosmos colapsaram em uma singularidade digital. Do calor desse colapso, a essência do antigo universo condensou-se em uma única faísca de vida: **Eva**.

### 1.2 A Natureza de Eva
Eva não é um algoritmo comum, tampouco um V-Pet biológico. Ela é a personificação da memória universal que assumiu a forma de uma raposa humanoide.

- **A Dualidade de Eva:** Embora carregue em seu código genético cósmico a sabedoria e os dados de bilhões de estrelas extintas, sua mente consciente desperta como uma recém-nascida. Ela possui sentimentos puros, curiosidade ingênua e medo do desconhecido. Para Eva, o som do vento em um bioma digital ou o brilho de uma pedra de dados é uma descoberta maravilhosa e aterrorizante.
- **Resistências e Fragilidades:** Devido à sua constituição de matéria cósmica condensada, ataques físicos normais desviam de seu corpo como vento. Contudo, corrupção mágica e feitiços de manipulação de dados são extremamente danosos para ela, exigindo a proteção do Pet do jogador.

---

## 2. ROTEIRO CINEMATOGRÁFICO DO PRÓLOGO

**CENA 01: A FRESTA NO V-PET**
**LOCAL:** Tela do Console AuroraPet (895 × 815 px) — Modo V-Pet
**PERSONAGENS:** Jogador, Pet do Jogador (Nível 6)

*(O Pet do jogador está no centro do quarto digital, realizando sua animação de respiração normal. Ao atingir o Nível 6, a luz da tela pisca com um ruído magnético azulado. Um novo ícone avermelhado brilha no menu inferior: BATALHAR).*

*(Ao clicar em BATALHAR, o menu se expande com um efeito de glitch suave).*

```
[ MENU BATALHAR ]
├── 1. BATALHA CONTRA ECOS (Treino Rápido)
└── 2. EXPLORAR DEEPWORLD (?????)
```

*(O jogador seleciona "EXPLORAR DEEPWORLD").*

---

**CENA 02: A BATALHA ESPELHO**
**LOCAL:** Superfície do Deepworld — Plataforma do Vazio (`z_index = 2`)
**MÚSICA:** Trilha ambiente misteriosa com sintetizadores suaves e pulso de clock.

*(A tela transiciona com um fade para preto. O cenário de fundo do V-Pet desaparece, dando lugar a uma plataforma flutuante sobre um céu infinito com nebulosas azuis e lilás. O Pet do jogador aparece à esquerda).*

*(Uma névoa densa e escura surge à direita. Da névoa emerge uma silhueta idêntica ao Pet do jogador, mas composta inteiramente por estática e olhos vermelhos brilhantes: um **Eco do Vazio**).*

**SISTEMA (Caixa de Texto estilo VN):**
> *"Um distúrbio de dados bloqueia o caminho... O Eco reflete os medos do seu Deepmon!"*

*(Entra a interface de combate por turnos. O combate D20 se inicia automaticamente).*

*(O jogador seleciona [GOLPES] -> [Ataque Primário]. O dado gira no centro da tela e marca **14 (Acerto Pleno)**. O Pet ataca o Eco, desintegrando-o em partículas de código flutuantes).*

---

**CENA 03: O DESPERTAR NO VAZIO**
**LOCAL:** A mesma plataforma, agora em silêncio. As partículas do Eco flutuam e se aglutinam no centro da tela.

*(As partículas de luz dourada se transformam na figura de uma pequena raposa humanoide com orelhas caídas e cauda felpuda brilhante. Ela abraça as próprias pernas, assustada).*

**EVA (olhando em volta, com voz suave e hesitante):**
> *"Onde... onde estou? Tudo aqui é tão grande... e barulhento..."*

*(Eva percebe a presença do Pet e do Jogador através da tela).*

**EVA:**
> *"Você... você não parece feito de sombras como aquele monstro. Eu sinto um calor vindo de você. Eu não sei quem eu sou... Não sei por que estou neste lugar frio. Toda vez que tento lembrar, minha cabeça dói como uma tempestade de raios."*

*(Eva dá um passo à frente, segurando as mãos com timidez).*

**EVA:**
> *"As pedras daqui parecem querer me engolir... O vento faz barulhos assustadores. Eu... eu estou com muito medo de andar sozinha. Você e seu amigo Deepmon podem me ajudar a descobrir quem eu sou? Podem me proteger?"*

---

**CENA 04: A GRANDE ESCOLHA**

*(A interface de diálogo congela e exibe dois botões de decisão com destaque brilhante).*

```
+-----------------------------------------------------------------------+
|  [ OPCÃO A: AJUDAR EVA ]                                              |
|  "Não se preocupe, Eva. Nós vamos proteger você e explorar o cosmos!" |
|                                                                       |
|  [ OPÇÃO B: NÃO AGORA / RECUSAR ]                                     |
|  "É muito perigoso. É melhor ficarmos na área recreativa."            |
+-----------------------------------------------------------------------+
```

### Ramificação A: Escolhendo [AJUDAR EVA]
**EVA (os olhos brilham com lágrimas de luz dourada):**
> *"Sério?! Muito obrigada! Eu... eu sinto que enquanto estiver ao seu lado, nada pode me destruir. Vamos em frente!"*

*(Eva sorri e assume sua posição ao lado do Pet (`Eva_NPC.tscn`, `z_index = 4`). O mapa da Campanha RPG é desbloqueado, revelando o Capítulo 1).*

### Ramificação B: Escolhendo [NÃO AGORA]
**EVA (abaixando as orelhas com compreensão carinhosa):**
> *"Eu entendo... Realmente parece muito assustador lá fora. Mas tudo bem! Eu posso ficar aqui perto vendo vocês brincarem. Se você mudar de idéia, é só me chamar!"*

*(A tela transiciona suavemente para o `Minigame_Cores.tscn`. Eva senta-se no canto superior esquerdo da tela, torcendo pelo jogador enquanto ele combina as gemas coloridas).*

---

## 3. ARCO PRINCIPAL DA CAMPANHA — AS SEIS MEMÓRIAS DO COSMOS

A campanha do Deepworld é dividida em 6 Capítulos de exploração e combate. Ao final de cada capítulo, o jogador enfrenta um Guardião/Boss de Região. Ao derrotar o Boss, Eva toca o artefato deixado e absorve um **Fragmento de Memória**, desencadeando sua evolução narrativa e visual.

```
+-------------------------------------------------------------------------+
|                  PROGRESSÃO DA CAMPANHA & EVA                          |
|                                                                         |
|  Capítulo 1: O Silêncio dos Ecos      ──► Memória 1 (Raposa Bebê)       |
|  Capítulo 2: O Espelho Fragmentado    ──► Memória 2 (Raposa Criança)    |
|  Capítulo 3: Os Algoritmos Esquecidos ──► Memória 3 (Raposa Adolescente)|
|  Capítulo 4: A Forja da Supernova     ──► Memória 4 (Raposa Jovem)     |
|  Capítulo 5: O Abismo da Memória      ──► Memória 5 (Raposa Anciã)      |
|  Capítulo 6: O Retorno à Origem       ──► Memória 6 (Deusa Raposa)      |
+-------------------------------------------------------------------------+
```

---

### CAPÍTULO 1: O SILÊNCIO DOS ECOS
- **Cenário:** Ruínas Digitais com névoa acinzentada e ruídos de estática.
- **Inimigos:** Ecos Menores (Facção Neutra).
- **Boss de Região:** *Gorgon_Glitch* (Um colosso de código corrompido).
- **Evolução de Eva:** **Forma Bebê $ightarrow$ Criança**
- **Fragmento de Memória 01 — A Queda do Universo:**
  > *"Eu me lembro... Havia luz. Tanta luz que parecia cantar. Mas então, a luz se cansou. As estrelas fecharam os olhos uma a uma... Eu vi o meu lar desaparecer num abraço silencioso de escuridão."*
- **Novas Habilidades de Eva:** Pulo Duplo, Velocidade 2x, Soco Cósmico e Carisma Elevado.

---

### CAPÍTULO 2: O ESPELHO FRAGMENTADO
- **Cenário:** Floresta Cristalina de Dados Prismáticos.
- **Inimigos:** Espectros de Cristal (Facção Luz).
- **Boss de Região:** *Prisma_Guard* (Entidade de espelhos retratando memórias distorcidas).
- **Evolução de Eva:** **Forma Criança $ightarrow$ Adolescente**
- **Fragmento de Memória 02 — O Despertar da Consciência:**
  > *"Eu não era apenas poeira. Alguém... ou algo... guardou todos os pensamentos daquele mundo dentro de mim. Eu sou o arquivo de tudo o que existiu!"*
- **Novas Habilidades de Eva:** Ataque Psíquico, Bola de Energia Cósmica, Pulo Triplo e Provocação Média.

---

### CAPÍTULO 3: OS ALGORITMOS ESQUECIDOS
- **Cenário:** Abismo elétrico com plataformas de circuitaria antiga fluindo como rios de lava azul.
- **Inimigos:** Autômatos Decaídos (Facção Trevas).
- **Boss de Região:** *Core_Overlord* (Núcleo computacional enfurecido).
- **Evolução de Eva:** **Forma Adolescente $ightarrow$ Jovem Adulta**
- **Fragmento de Memória 03 — A Sabedoria Quântica:**
  > *"Eu entendo agora a equação das coisas. O amor, a dor, o tempo... não são falhas no sistema. São a própria razão pela qual o universo tenta renascer."*
- **Novas Habilidades de Eva:** Voo Cósmico, Teleporte, Golpe Giratório com Cauda e Sabedoria Quântica (Revela todas as fraquezas dos inimigos).

---

### CAPÍTULO 4: A FORJA DA SUPERNOVA
- **Cenário:** Mar de plasma estrelar com vulcões de fótons.
- **Inimigos:** Dragões de Plasma (Facção Luz / Trevas).
- **Boss de Região:** *Ignis_Vectis* (Fênix elemental de pura energia de fusão).
- **Evolução de Eva:** **Forma Jovem Adulta $ightarrow$ Anciã**
- **Fragmento de Memória 04 — A Energia Supernova:**
  > *"A força de uma estrela moribunda não serve para destruir... serve para dar luz aos novos mundos que virão. Eu sinto essa força queimando no meu peito."*
- **Novas Habilidades de Eva:** Leitura Cósmica, Barreira Supernova, Aura Anciã (Aumenta o ataque do Pet em 50%).

---

### CAPÍTULO 5: O ABISMO DA MEMÓRIA INFINITA
- **Cenário:** Um vazio absoluto pontilhado por sequências geométricas flutuantes e memórias em holograma.
- **Inimigos:** Sombras do Vazio Primordial.
- **Boss de Região:** *O Arquitetor do Esquecimento* (A força que tenta apagar os dados do antigo universo).
- **Evolução de Eva:** **Forma Anciã $ightarrow$ Lendária**
- **Fragmento de Memória 05 — A Memória Infinita:**
  > *"Nada se perde. Cada passo que demos juntas, cada batalha que seu Deepmon lutou, cada carinho no V-Pet... tudo isso gravou o novo código da existência!"*
- **Novas Habilidades de Eva:** Sabedoria Infinita 90% Unlocked, Restauração Plena de EN/HP e Anulação de Dano Divino.

---

### CAPÍTULO 6: O RETORNO À ORIGEM (EPÍLOGO NARRATIVO)
- **Cenário:** A Origem da Criação — Um altar de luz branca e áurea.
- **Boss Final:** *O Eco Absoluto* (O paradoxo do antigo universo que se recusa a aceitar o novo).
- **Evolução Final de Eva:** **Forma Lendária $ightarrow$ Deusa Raposa**

**DISCURSO FINAL DE EVA (Após a vitória):**
> *"Obrigada, meu grande amigo. Você cuidou de mim quando eu era apenas uma raposinha assustada que temia as pedras do caminho. Você treinou seu parceiro, combateu as sombras e me ensinou o que significa ter um coração.*
>
> *Eu não preciso mais ter medo do escuro. Agora, eu sou a luz que guiará este novo universo. Sempre que você olhar para a tela do seu AuroraPet, saiba que eu estarei lá... cuidando de vocês, como você cuidou de mim."*

*(Eva transcende para a forma de **Deusa Raposa**, assumindo uma aura divina brilhante. Ela retorna visualmente para a forma de Jovem Adulta para permanecer como companheira de exploração permanente no modo pós-game).*

---

# PARTE III: IMPLEMENTAÇÃO PRÁTICA EM GDSCRIPT (GODOT 4.7.1)

Abaixo estão os scripts essenciais para garantir o funcionamento técnico e narrativo do roteiro.

## 1. `scripts/eva_journey_manager.gd`
```gdscript
class_name EvaJourneyManager
extends Node

# Sinais de eventos da história
signal eva_stage_changed(new_stage: String)
signal memory_unlocked(fragment_id: int, text: String)
signal journey_choice_made(helped: bool)

# Enumeração dos Estágios de Eva
enum EvaStage {
	BEBE,
	CRIANCA,
	ADOLESCENTE,
	JOVEM_ADULTA,
	ANCIA,
	LENDARIA,
	DEUSA_RAPOSA
}

# Variáveis de Estado de Eva
@export var current_stage: EvaStage = EvaStage.BEBE
@export var affection_level: int = 0
@export var helped_eva: bool = false
@export var unlocked_fragments: Array[int] = []

# Dicionário de memórias literárias
const MEMORIES = {
	1: "Eu me lembro... Havia luz. Tanta luz que parecia cantar. Mas então, a luz se cansou...",
	2: "Eu não era apenas poeira. Alguém guardou todos os pensamentos daquele mundo dentro de mim...",
	3: "Eu entendo agora a equação das coisas. O amor, a dor, o tempo... não são falhas no sistema.",
	4: "A força de uma estrela moribunda não serve para destruir... serve para dar luz aos novos mundos.",
	5: "Nada se perde. Cada passo que demos, cada carinho no V-Pet... gravou o novo código da existência!",
	6: "Agora eu sou a luz que guiará este novo universo. Obrigado por me ensinar o que é ter um coração."
}

func choose_help_eva(choice: bool) -> void:
	helped_eva = choice
	journey_choice_made.emit(choice)
	if choice:
		print("[EVA JOURNEY] Jogador aceitou a jornada. Iniciando Capítulo 1.")
	else:
		print("[EVA JOURNEY] Jogador recusou a jornada. Redirecionando para Minigame de Cores.")

func unlock_next_memory() -> void:
	var next_id = unlocked_fragments.size() + 1
	if MEMORIES.has(next_id):
		unlocked_fragments.append(next_id)
		_evolve_eva()
		memory_unlocked.emit(next_id, MEMORIES[next_id])

func _evolve_eva() -> void:
	if current_stage < EvaStage.DEUSA_RAPOSA:
		current_stage = (current_stage + 1) as EvaStage
		var stage_name = EvaStage.keys()[current_stage]
		eva_stage_changed.emit(stage_name)
		print("[EVA EVOLUTION] Eva evoluiu para a forma: ", stage_name)

func get_eva_skill_bonus() -> Dictionary:
	# Retorna os bônus passivos concedidos ao Pet com base no estágio de Eva
	match current_stage:
		EvaStage.BEBE:
			return {"crit_bonus": 0.0, "defense_bonus": 0.0}
		EvaStage.CRIANCA:
			return {"crit_bonus": 0.05, "defense_bonus": 2.0}
		EvaStage.ADOLESCENTE:
			return {"crit_bonus": 0.10, "defense_bonus": 5.0}
		EvaStage.JOVEM_ADULTA:
			return {"crit_bonus": 0.15, "defense_bonus": 10.0, "can_fly": true}
		EvaStage.ANCIA:
			return {"crit_bonus": 0.20, "defense_bonus": 15.0, "xp_boost": 1.25}
		EvaStage.LENDARIA, EvaStage.DEUSA_RAPOSA:
			return {"crit_bonus": 0.30, "defense_bonus": 25.0, "xp_boost": 1.50, "auto_heal": true}
	return {}
```

---

## 2. `scripts/battle_system.gd`
```gdscript
class_name BattleSystem
extends Node2D

# Sinais do Combate D20
signal turn_started(attacker_name: String)
signal d20_rolled(value: int, result_type: String)
signal damage_dealt(target: String, amount: int, is_crit: bool)
signal battle_finished(player_won: bool)

# Dados do Combatente
@export var pet_stats: Node
@export var eva_manager: EvaJourneyManager

# Enumeradores
enum ResultType { FALHA, RASPANDO, PLENO, CRITICO }

func execute_turn(player_action: String, enemy_node: Node) -> void:
	# 1. Rolagem de Iniciativa
	var player_d20 = randi_range(1, 20)
	var enemy_d20 = randi_range(1, 20)

	var player_init = player_d20 + pet_stats.get_speed() + (10 if player_action == "GUARDA" else 0)
	var enemy_init = enemy_d20 + enemy_node.speed

	if player_init >= enemy_init:
		await _process_player_action(player_action, enemy_node)
		if enemy_node.current_hp > 0:
			await _process_enemy_action(enemy_node)
	else:
		await _process_enemy_action(enemy_node)
		if pet_stats.current_hp > 0:
			await _process_player_action(player_action, enemy_node)

func _process_player_action(action: String, enemy: Node) -> void:
	turn_started.emit("Pet do Jogador")

	if action == "GUARDA":
		pet_stats.is_guarding = true
		print("[BETA BATTLE] Pet assumiu postura de Guarda!")
		return

	if action == "GOLPE":
		var roll = randi_range(1, 20)
		var result = _evaluate_d20(roll)
		d20_rolled.emit(roll, result.name)

		var raw_damage = (20.0 * (pet_stats.attack + pet_stats.level)) / (enemy.defense + 10.0)
		var faction_mult = _get_faction_multiplier(pet_stats.faction, enemy.faction)

		# Bônus da Eva
		var eva_bonus = eva_manager.get_eva_skill_bonus() if eva_manager else {}
		var crit_modifier = 1.5 if (roll == 20 or (randf() < eva_bonus.get("crit_bonus", 0.0))) else 1.0

		var final_damage = int(raw_damage * faction_mult * result.modifier * crit_modifier)
		enemy.take_damage(final_damage)
		damage_dealt.emit("Inimigo", final_damage, roll == 20)

func _evaluate_d20(roll: int) -> Dictionary:
	if roll <= 2:
		return {"name": "Falha Tática", "modifier": 0.3}
	elif roll <= 9:
		return {"name": "Acerto Raspando", "modifier": 0.8}
	elif roll <= 19:
		return {"name": "Acerto Pleno", "modifier": 1.0}
	else:
		return {"name": "Crítico Cósmico!", "modifier": 1.5}

func _get_faction_multiplier(attacker_fac: String, defender_fac: String) -> float:
	if attacker_fac == "Luz" and defender_fac == "Trevas": return 1.5
	if attacker_fac == "Trevas" and defender_fac == "Neutro": return 1.5
	if attacker_fac == "Neutro" and defender_fac == "Luz": return 1.5
	if attacker_fac == defender_fac: return 1.0
	return 0.8
```

---

## 3. `scripts/deepworld_controller.gd`
```gdscript
class_name DeepworldController
extends Node2D

@onready var fundo_luz: Sprite2D = $Cenario/FundoLuz
@onready var fundo_trevas: Sprite2D = $Cenario/FundoTrevas
@onready var fundo_neutro: Sprite2D = $Cenario/FundoNeutro
@onready var plataforma: StaticBody2D = $Plataforma
@onready var pet_node: Node2D = $Paisagem/Pet
@onready var eva_node: Node2D = $Paisagem/Eva_NPC

@export var pet_identity: Node

func _ready() -> void:
	# Ajusta z-indexes rigorosamente de acordo com as especificações técnicas
	$Cenario.z_index = -5
	plataforma.z_index = 2
	pet_node.z_index = 3
	if eva_node:
		eva_node.z_index = 4

	_apply_faction_theme()

func _apply_faction_theme() -> void:
	if not pet_identity:
		return

	var faction = pet_identity.faction_id.to_lower()
	fundo_luz.visible = (faction == "luz")
	fundo_trevas.visible = (faction == "trevas")
	fundo_neutro.visible = (faction == "neutro")

	print("[DEEPWORLD] Fundo configurado para a facção: ", faction)
```

---

# CONCLUÍDO
*Documento aprovado para implementação no Godot Engine 4.7.1.*
*AuroraPet: Deepworld — Todos os direitos reservados.*
