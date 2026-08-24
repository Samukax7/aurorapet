# Auditoria Técnica: Protótipo Google AI Studio × AuroraPet Godot

**Data da auditoria:** 20 de agosto de 2026  
**Escopo:** comparação técnica de sistemas, estados, dados, progressão, combate, persistência e integrações.  
**Fora do escopo:** reprodução visual do protótipo em HTML/SVG. O design final continua sendo o pixel art modular do Godot.

## 1. Conclusão executiva

O protótipo do Google AI Studio não é apenas uma referência visual. Ele funciona como um **overview técnico bastante avançado**, contendo aproximadamente a estrutura de dados, os fluxos e as regras principais de um V-Pet completo. O AuroraPet Godot já possui a fundação correta e várias partes importantes foram adaptadas, mas a cobertura atual é desigual: identidade procedural, abertura, necessidades básicas, progressão inicial, minijogos, loja e uma primeira batalha já existem; entretanto, o protótipo ainda é mais completo em personalidade, persistência, economia de cuidados, atributos de combate, evolução descritiva e eventos comportamentais.

A principal conclusão é que não devemos copiar o protótipo como uma segunda aplicação. Devemos transportar suas **regras e contratos de dados** para os nós atuais do Godot, mantendo a cascata `main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn`, o `PetStats` como núcleo de necessidades, o `PetSkills` como núcleo de progressão e o `ConsoleController` como encaminhador de ações.

## 2. Modelo de dados central

| Sistema | Protótipo Google AI Studio | AuroraPet Godot atual | Cobertura |
|---|---|---|---|
| Identidade | Seed, nome, gênero, facção, elemento, raça, chave de acesso | Seed, nome, gênero, facção, linhagem, elemento, traços, paletas e chave de acesso | **Alta**, com nomenclaturas próprias do projeto |
| Necessidades | Fome, energia, saúde, felicidade, higiene, obediência e ousadia | Fome, energia, saúde, humor, higiene e disciplina | **Parcial** |
| Atributos RPG | Força, defesa, agilidade, inteligência, resistência, sorte e carisma | Força, defesa, agilidade e inteligência | **Parcial** |
| Progressão | Nível, XP, idade em horas, estágio 0–7 e diário cósmico | Nível, XP, XP total e sete estágios aprovados | **Parcial** |
| Estado fisiológico | Sono, tipo de sono, doença, desmaio, penalidade por acordar cedo e sujeira | Sono bloqueante, doença, sujeira, recuperação até 100% e vontades especiais | **Parcial/alta** |
| Economia | Moedas do pet usadas em alimentos e recompensas | Pontos de Exploração usados principalmente na Loja Cósmica | **Parcial**, por decisão de design econômico |
| Memória | Diário cósmico, conquistas e registros de eventos | Não há diário ou conquistas persistentes | **Ausente** |

O `PetIdentity` do Godot já cobre a parte mais importante da geração determinística: seed, facção, linhagem, elemento, nome, gênero, traços, paletas e pesos para as peças modulares. Essa solução é mais adequada que o renderizador SVG do protótipo porque mantém a liberdade de edição direta no `pet.tscn`.

## 3. Identidade, raça, facção e geração procedural

O protótipo possui três facções, nove tipos elementais, uma lista ampla de raças e nomes gerados a partir de prefixos, raízes e sufixos. A aparência é determinada por uma função que escolhe orelhas, olhos, asas, cauda, ornamentos, padrões e cores.

O Godot possui três facções, linhagens associadas, elementos, traços, nomes procedurais, pesos de partes e paletas preferenciais. A diferença é intencional: no Godot, a identidade fornece contexto e viés, enquanto o `PetRandomizer` controla as peças reais do pet modular. Portanto, a lógica de aparência do protótipo deve ser usada como **referência de identidade genética**, não como código de renderização.

| Item técnico | Situação no Godot |
|---|---|
| Seed reproduzível | Implementado |
| Chave de acesso de três caracteres | Implementado e compatível com o algoritmo do protótipo |
| Facção escolhida pelo jogador | Implementado |
| Nome procedural | Implementado |
| Raça/linhagem | Implementado com taxonomia própria do AuroraPet |
| Elemento e traços | Implementado |
| Visual gerado por SVG | Não deve ser copiado |
| Peças modulares editáveis no editor | Implementado no modelo aprovado do Godot |

## 4. Necessidades, personalidade e recusas

O protótipo possui um sistema de personalidade mais desenvolvido. Além de verificar se o pet está com fome, cansado ou doente, ele usa **Obediência** e **Ousadia** para decidir se o pet aceita uma ordem. O pet pode recusar treino por baixa obediência, recusar minijogos quando está rebelde e falhar uma ordem durante a batalha.

O Godot já possui um núcleo de necessidades tecnicamente sólido. O `PetStats` controla decaimento tranquilo, estado crítico, doença por higiene, sono até energia total, sujeira, vontades especiais, disciplina, tutorial de recém-nascido, histórico de erros e sinais de reação. Ele também já possui o sinal `action_blocked`, que o `ConsoleController` encaminha para uma mensagem de sistema.

A lacuna principal é que, hoje, a recusa do Godot é predominantemente **estrutural**, especialmente durante o sono. Ainda não existe um verificador central que recuse ações objetivamente por fome cheia, energia baixa, saúde crítica ou personalidade. O protótipo contém as seguintes regras que faltam ou estão apenas parcialmente representadas: comida recusada acima de 95% de fome; remédio recusado quando a saúde está perfeita; treino bloqueado por doença, energia abaixo de 20% ou fome abaixo de 20%; minijogos bloqueados por doença, energia abaixo de 15% ou rebeldia; batalha bloqueada por saúde abaixo de 25% ou energia abaixo de 15%; sono recusado quando a energia já está acima de 95%; e eventos aleatórios de bagunça, pirraça, desafio, afeto e achados estelares.

A recomendação técnica é criar posteriormente um método central, por exemplo `can_perform_action(action)`, dentro de `PetStats`. Esse método deve devolver um resultado estruturado com `allowed`, `reason`, `message` e eventualmente `reaction_id`. Assim, o menu, os minijogos, o treino e a batalha consultam a mesma regra, evitando divergência entre cenas.

## 5. Progressão, estágios e evolução

O protótipo define oito estágios: Ovo Primordial, Bebê Cósmico, Criança Cósmica, Adolescente Cósmica, Jovem Adulta, Anciã Cósmica, Raposa Lendária e Deusa Raposa. Cada estágio possui nível mínimo, média mínima de atributos, multiplicador de poder, número de caudas e descrição narrativa.

O Godot usa corretamente a nomenclatura aprovada pelo usuário: Bebê, Criança, Juvenil, Jovem, Adulto, Forma Máxima e Entidade Cósmica. São sete estágios, com evolução determinada por nível e aplicação de escala/variação visual. Essa diferença deve ser preservada: **os nomes do Godot são a decisão oficial do projeto**.

O que falta transportar do protótipo não é trocar os nomes, e sim enriquecer os metadados da evolução. O Godot pode futuramente adicionar média mínima de atributos, descrição de estágio, multiplicador de poder e dados de forma sem substituir a tabela oficial. O número de caudas deve permanecer ligado ao design modular e aos assets que o usuário criar, não ser gerado automaticamente por código.

## 6. Treino, atributos e habilidades

O protótipo apresenta cinco regimes de treino: força, inteligência, defesa, agilidade e resistência. Cada treino tem custo de energia e fome, ganho de XP e bônus secundário. O combate também usa sorte e carisma como atributos técnicos auxiliares.

O Godot atualmente possui uma árvore de oito habilidades, quatro atributos treináveis e desbloqueios por nível, XP total, pré-requisitos e valor mínimo de atributo. A tela de treino já exibe os quatro atributos existentes e alimenta a Batalha de Exploração.

| Elemento | Protótipo | Godot |
|---|---|---|
| Força | Treino dedicado e impacto no dano | Implementado |
| Defesa | Treino dedicado e redução de dano | Implementado |
| Agilidade | Treino dedicado e dados/iniciativa | Implementado parcialmente |
| Inteligência | Treino dedicado e Intuição Cósmica | Implementado parcialmente |
| Resistência | Treino dedicado e HP máximo | Ausente como atributo próprio |
| Sorte | Atributo técnico | Ausente |
| Carisma | Atributo técnico | Ausente |
| Custo de energia por habilidade | Explícito | Campos abstratos na árvore, sem consumo de EN no combate |
| Cinco regimes de treino | Implementados no protótipo | A tela atual expõe um fluxo de treino geral |

A incorporação segura deve começar por resistência, pois ela já é usada conceitualmente no decaimento e no HP de batalha. Sorte e carisma podem ser adiados até existirem mecânicas que realmente consumam esses atributos.

## 7. Batalha de Exploração

A batalha do protótipo cria um Eco procedural de facção oposta, usa HP, EN, nível, atributos, habilidades, guarda, D20, críticos, vantagem de facção, Intuição Cósmica, rebeldia, registro de turnos e recompensa de XP/moedas.

A Batalha de Exploração do Godot já é uma adaptação funcional: possui lobby, encontro Eco, HP do pet e do inimigo, D20, vantagem triangular de facções, guarda com redução de 60%, golpe fraco, golpe forte, golpe de status, defesa, fuga, logs, vitória/derrota, XP e pontos para o Quarto Cósmico. Essa é uma das áreas com maior aproveitamento do protótipo.

Ainda faltam, em relação ao overview técnico: EN real e custos de habilidades; lista de habilidades com poder-base e precisão; uso de agilidade na iniciativa ou rolagem; uso de resistência como atributo independente; Intuição Cósmica com a fórmula completa do protótipo; críticos condicionados por atributos altos; rebeldia que pode desperdiçar a ordem; inimigos com habilidades próprias variadas; desmaio/penalidade de derrota; e integração de moedas caso a economia do projeto decida adotar os dois tipos de recurso.

## 8. Minijogos

Os três minijogos do protótipo já existem conceitualmente no Godot. O Jokenpô possui escolha e resultado; o Jogo da Velha possui tabuleiro e IA; e o 2048 possui grade 4×4, fusão, controles por D-pad, marcos e recompensa de XP.

A diferença relevante é de integração. O protótipo aplica bônus de Obediência, Humor, moedas e atributos diferentes conforme o resultado. O Godot usa seu próprio balanceamento aprovado: XP por ação, progressão por nível e sinais de conclusão. Portanto, a mecânica base foi transportada, mas as fórmulas de recompensa do protótipo ainda não foram reproduzidas integralmente.

## 9. Economia e Loja Cósmica

O protótipo usa `coins` como parte do estado persistente do pet. As moedas são recebidas em batalhas, minijogos e eventos e usadas para comprar alimentos pagos.

O Godot adotou uma economia diferente e coerente com o level design atual: pontos são obtidos na Batalha de Exploração e usados no Quarto Cósmico/Loja Cósmica. A loja possui três categorias, 17 ofertas, níveis mínimos, preços, paginação e mensagens de bloqueio por nível ou pontos insuficientes.

A Loja atual não possui inventário, posse permanente ou serialização das compras. O protótipo também não tem um sistema completo de inventário, mas possui alimentos e moedas como parte do save. A futura implementação deve decidir se Pontos de Exploração e Moedas Estelares serão recursos distintos ou se o projeto manterá apenas os pontos atuais.

## 10. Persistência e backup

Esta é a maior lacuna técnica atual. O protótipo salva o objeto completo do pet no `localStorage`, incluindo identidade, necessidades, progressão, estado de sono/doença, moedas, habilidades, diário e conquistas. O DebugPanel ainda permite exportar e importar esse objeto em JSON.

O Godot possui `user://aurorapet_save.json`, mas o `opening_flow.gd` atualmente salva principalmente metadados da identidade: seed, chave, facção, nome, linhagem e data. Ao continuar, ele regenera a identidade, mas não restaura integralmente PetStats, PetSkills, evolução, pontos, compras ou estado de batalha.

A prioridade técnica mais alta depois desta auditoria é criar um `AuroraPetSave` ou um método de serialização central que registre, no mínimo, identidade, PetStats, PetSkills, PetEvolution, pontos de exploração, valor acumulado da loja e compras. O carregamento deve ocorrer antes de liberar o console, sem criar nós por código e sem quebrar a cascata de cenas.

## 11. Backend e pensamentos cósmicos

O protótipo tem um endpoint `/api/cosmic-thought` que usa Gemini quando disponível e fallback local quando não há chave ou quando ocorre limite de cota. Isso é uma integração de diálogo, não uma regra de gameplay. O Godot atual funciona como versão Web V 0.0 sem áudio e sem backend de pensamentos dinâmicos.

A integração não deve ser copiada automaticamente para o protótipo Web atual. Se for desejada no futuro, deve ser feita como camada opcional, mantendo fallback local, sem impedir o funcionamento offline e sem colocar chave de API no cliente.

## 12. Ordem recomendada de implementação

| Prioridade | Bloco | Motivo |
|---:|---|---|
| 1 | Save completo em JSON | Evita perder progressão, necessidades, habilidades, pontos e compras |
| 2 | Verificador central de ações | Permite implementar recusas sem duplicar regras nas cenas |
| 3 | Obediência/Ousadia | Completa a personalidade e habilita recusas comportamentais |
| 4 | Resistência e custos de EN | Fecha a ligação entre treino e combate |
| 5 | Expansão da Batalha de Exploração | Aproveita o combate já criado e aproxima-o do overview técnico |
| 6 | Metadados de evolução | Adiciona descrições, médias e multiplicadores sem trocar os nomes oficiais |
| 7 | Diário e conquistas | Dá persistência narrativa e objetivos de longo prazo |
| 8 | Economia secundária ou inventário | Só depois de decidir a relação entre moedas e pontos de exploração |
| 9 | Pensamentos dinâmicos | Camada opcional posterior, sem bloquear a versão sem áudio |

## 13. Decisões de arquitetura

A incorporação deve permanecer dentro dos nós já existentes. `PetStats` deve ser responsável por necessidades, personalidade, sono, doença, sujeira, limites e recusas; `PetSkills` deve controlar progressão, atributos e habilidades; `PetEvolution` deve controlar estágios e metadados; `PetIdentity` deve controlar seed, facção, linhagem e viés; `BatalhaDeExploracao` deve consumir esses dados sem duplicá-los; `LojaCosmica` deve receber a economia por uma interface do Quarto; e `ConsoleController` deve apenas encaminhar sinais e controles.

O renderizador procedural SVG, a moldura HTML, o CSS, o Web Audio e o endpoint Gemini não devem ser copiados como componentes visuais. O valor reaproveitável do protótipo está nos **contratos de dados, regras de estado, fórmulas, bloqueios, recompensas, persistência e fluxo técnico**.

## Estado desta auditoria

Esta etapa apenas documenta a comparação. Não foram alterados os sistemas de gameplay do Godot. O arquivo foi criado como referência para a próxima fase de implementação e para separar claramente a parte técnica herdada do protótipo da direção criativa pixel art aprovada para o AuroraPet.
