# 🌌 AuroraPet Wiki

> Wiki-base oficial do projeto AuroraPet, construída a partir do estado real do repositório e do protótipo Godot.

**Estado de referência:** protótipo Godot validado em agosto de 2026  
**Engine:** Godot 4.7.1  
**Cena principal:** `scenes/main.tscn`

---

## 🏠 Sobre o AuroraPet

AuroraPet é um V-Pet cósmico em pixel art, focado em **cuidado, interação, progressão e criação modular de criaturas**. O protótipo atual combina um console virtual, um mundo cósmico chamado Deepworld, um pet modular e uma interface inspirada em dispositivos V-Pet clássicos.

O ciclo central atual é:

**Cuidar → Brincar → Treinar → Ganhar XP → Desbloquear habilidades**

> **Fonte de verdade:** quando um conceito/documento divergir do comportamento existente no jogo, o código e as cenas do repositório devem ser considerados a referência do estado implementado.

---

# 🟢 Estado atual

### Implementado

- Console virtual com tela e controles.
- Deepworld com cenário e plataforma.
- Pet modular.
- Identidade procedural.
- Randomização visual de peças e paleta.
- Barras de fome, energia, humor e saúde.
- Necessidades adicionais como higiene, disciplina, peso e doença.
- Ações de comer, cuidar, jogar, treinar e dormir.
- Sistema local de XP.
- Nível e atributos RPG.
- Árvore inicial de habilidades.
- Sistema de evolução com sete estágios.
- Feedback visual e reações às ações.
- Menu e submenus navegáveis pelo D-pad/teclado.

### 🟡 Parcial / preparado

- Fundos específicos por facção.
- Animações finais das reações.
- Conteúdo dos estágios avançados de evolução.
- Sistema de eventos e vontades do pet.
- Estrutura de combate.

### 🔵 Planejado

- Combate PvE contra um Eco.
- Persistência local completa.
- Geração procedural mais ampla.
- Minigames adicionais/expandidos.
- Sistema online/Firebase.
- Conteúdo visual final para evolução, aura, roupas e acessórios.

---

# 🌌 Deepworld

Deepworld é o cenário cósmico onde o pet existe no protótipo atual.

O cenário padrão é independente da facção. Os fundos de **Luz, Trevas e Neutro** já possuem preparação estrutural, mas a seleção automática por facção permanece desativada para preservar a validação artística.

### Camadas atuais

| Camada | Estado |
|---|---|
| Cenário padrão | 🟢 Ativo |
| Luz | 🟡 Preparado |
| Trevas | 🟡 Preparado |
| Neutro | 🟡 Preparado |
| Plataforma | 🟢 Ativa |
| Pet | 🟢 Ativo |
| UI | 🟢 Ativa |

---

# 🐾 Pet

O pet é construído de forma modular. A cena `pet.tscn` mantém as partes como nós independentes, permitindo alterar a aparência sem criar ou remover nós dinamicamente.

### Componentes visuais

- CorpoBase
- Cauda
- Asas
- Orelhas
- Olhos

O `PetRandomizer` modifica texturas e modulação das peças existentes.

---

# 🧬 Identidade procedural

A identidade do pet é separada de sua aparência visual.

| Campo | Valores / função |
|---|---|
| Facção | Luz, Trevas ou Neutro |
| Linhagem | Serafim, Fada Estelar, Sombra, Corvo Espectral, Espírito ou Guardião Elemental |
| Elemento | Determinado conforme a linhagem |
| Gênero | Feminino, Masculino ou Neutro |
| Nome | Prefixo + sufixo da linhagem |
| Traços | Dois traços distintos |
| Atributos | Força, Defesa, Agilidade e Inteligência |
| Seed | Permite repetibilidade da identidade |

A tecla `R` refaz o sorteio **visual**, mantendo a identidade. Uma nova identidade completa deve ser gerada explicitamente pelo sistema de identidade.

---

# 🎨 Aparência e paleta

O protótipo possui cinco variantes para olhos, orelhas, asas e caudas.

A paleta cósmica possui vinte cores organizadas em dez pares complementares.

- Corpo, orelhas e cauda → cor principal.
- Olhos e asas → cor complementar.

A revisão final de saturação, luminosidade e composição permanece uma decisão artística.

---

# ❤️ Sistema de necessidades

`PetStats` controla as necessidades e o estado físico/emocional do pet.

### Necessidades principais

- Fome
- Energia
- Humor
- Saúde
- Higiene
- Disciplina
- Peso
- Doença
- Sono

O decaimento ocorre em intervalos configuráveis e foi projetado para ser tranquilo. O protótipo não possui morte permanente.

### Ações atuais

| Categoria | Ação | XP |
|---|---|---:|
| Comer | Fruta Estelar | 8 |
| Comer | Néctar Cósmico | 8 |
| Comer | Banquete Nebulosa | 8 |
| Cuidar | Dar Remédio | 8 |
| Cuidar | Limpar Sujeira | 8 |
| Cuidar | Dormir | 8 |
| Jogar | Jokenpô | 15 base |
| Jogar | Jogo da Velha | 20 base |
| Jogar | 2048 | 20 |
| Treinar | Treino | 25 |
| Batalhar | Em desenvolvimento | 0 |

---

# 🎮 Menu e controles

O menu principal possui cinco categorias:

1. Comer
2. Cuidar
3. Jogar
4. Treinar
5. Batalhar

### Controles

| Entrada | Função |
|---|---|
| D-pad / setas | Navegação |
| Botão verde / `ui_accept` | Confirmar |
| Botão amarelo | Mostrar/ocultar status |
| Botão rosa / `ui_cancel` | Abrir, fechar ou voltar |
| `R` | Refazer sorteio visual |

O item selecionado recebe escala, modulação e efeito de glow.

---

# ⭐ XP e progressão

`PetSkills` mantém:

- Nível.
- XP atual.
- XP total.
- Força.
- Defesa.
- Agilidade.
- Inteligência.

O sistema de nível utiliza o requisito `nível × 100` de XP atual.

Ações de cuidado, minigames e treino concedem XP. Ao subir de nível, o sistema sincroniza a evolução e verifica habilidades disponíveis.

---

# 🌳 Habilidades

A árvore atual possui oito habilidades:

- 4 habilidades iniciais.
- 4 habilidades avançadas.

O desbloqueio considera:

- nível;
- XP total;
- atributo mínimo;
- pré-requisito.

A tela de Treinar também funciona como ficha RPG, exibindo nome, linhagem, elemento, nível, XP e os quatro atributos.

---

# 🧬 Evolução

`PetEvolution` possui sete estágios:

1. Bebê
2. Criança
3. Juvenil
4. Jovem
5. Adulto
6. Forma Máxima
7. Entidade Cósmica

As escalas atuais são aproximadamente:

`4.0 → 4.6 → 5.2 → 6.0 → 7.0 → 8.0 → 9.2`

Os perfis visuais de olhos, orelhas, asas e cauda podem variar por estágio. Assets exclusivos de aura, roupas, acessórios e efeitos para os estágios finais ainda fazem parte da expansão visual.

---

# 🖥️ Arquitetura

O projeto utiliza uma cascata de cenas:

```text
main.tscn
└── console_frame.tscn
    └── ScreenContent
        ├── deepworld.tscn
        │   └── Paisagem
        │       └── Pet [pet.tscn]
        ├── pet_ui.tscn
        └── arvore_de_habilidades.tscn
```

### Cenas principais

| Cena | Responsabilidade |
|---|---|
| `main.tscn` | Entrada e composição final |
| `console_frame.tscn` | Corpo do console e controles |
| `deepworld.tscn` | Mundo, cenário e pet |
| `pet.tscn` | Corpo modular e sistemas do pet |
| `pet_ui.tscn` | Interface e menus |
| `arvore_de_habilidades.tscn` | Treino e progressão |

---

# ⚙️ Scripts principais

```text
scripts/
├── console_controller.gd
├── deepworld_controller.gd
├── pet_identity.gd
├── pet_randomizer.gd
├── pet_stats.gd
├── pet_skills.gd
├── pet_evolution.gd
├── pet_ui.gd
└── arvore_de_habilidades.gd
```

### Responsabilidades

**PetIdentity** — identidade procedural e dados da criatura.

**PetRandomizer** — aparência modular, texturas e paleta.

**PetStats** — necessidades, decaimento, cuidado e reações.

**PetSkills** — XP, nível, atributos e habilidades.

**PetEvolution** — estágios de crescimento.

**PetUI** — interface, menus e feedback.

**ConsoleController** — integração entre controles, UI e sistemas.

**DeepworldController** — composição e controle do cenário.

---

# 📁 Estrutura resumida

```text
assets/
├── console/
├── fundo/
├── pet_modular/
└── UI/

scenes/
├── main.tscn
├── console_frame.tscn
├── deepworld.tscn
├── pet.tscn
├── pet_ui.tscn
└── arvore_de_habilidades.tscn

scripts/
└── sistemas do AuroraPet

shaders/
└── menu_selection_glow.gdshader
```

---

# 🛠️ Desenvolvimento

O projeto possui duas frentes principais:

### Lógica

Implementação de regras, necessidades, identidade, progressão, evolução, habilidades e integração dos sistemas.

### Level Design

Composição visual, enquadramento, escala, paleta, ícones, fundos, plataforma e direção artística.

Alterações visuais devem ser validadas artisticamente antes de serem fixadas como regra do sistema.

---

# 🗺️ Roadmap inicial

### Próximo ciclo

- Finalizar visual da árvore de habilidades.
- Preparar integração com combate PvE.
- Criar o primeiro inimigo Eco.

### Depois

- Persistência local.
- Emoções visuais definitivas.
- Geração procedural ampliada.
- Minigames completos/adicionais.
- Expansão visual das evoluções.
- Firebase/recursos online.

---

# 📚 Documentação relacionada

O repositório contém documentos técnicos que servem como fonte complementar desta Wiki:

- `AURORAPET_GUIA_DESENVOLVIMENTO.md`
- `SCENE_STRUCTURE.md`
- `DEEPWORLD_LAYERS.md`
- `DEEPWORLD_EVA_SCOPE_AUDIT.md`
- `NEEDS_SYSTEM.md`
- `PROCEDURAL_IDENTITY.md`
- `BATTLE_SYSTEM_RESEARCH.md`
- `IMPLEMENTATION_ROADMAP.md`
- `CONSOLE_SCREEN_REFERENCE.md`
- `MOBILE_V0_1.md`
- `V0_0_WEB_EXPORT.md`
- `PROTOTYPE_COMPARISON.md`
- `QUARTO_COSMICO.md`

---

# 📜 Regra da Wiki

A Wiki deve distinguir claramente entre **implementado**, **parcial**, **planejado** e **descartado**.

Novos conceitos criados durante o desenvolvimento não devem ser apresentados como funcionalidades existentes até que sejam implementados e validados no projeto.

> **AuroraPet não é apenas o que está planejado. É também o registro de tudo que conseguiu sobreviver ao protótipo.**
