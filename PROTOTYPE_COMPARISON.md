# Comparação do protótipo Google AI Studio

## Objetivo

O arquivo `aurorapet.zip` foi analisado como referência de design e lógica. Ele contém uma aplicação React/Vite em TypeScript com introdução Game Boy, cuidados, evolução, status, três minijogos, batalha contra um Eco procedural, gerador de identidade/aparência, efeitos sonoros e um endpoint opcional de pensamento cósmico via Gemini.

A adaptação foi feita respeitando a arquitetura do AuroraPet Godot: `main.tscn > console_frame.tscn > deepworld.tscn > pet.tscn`. Nenhum renderizador SVG substituiu o pet modular editável no editor e nenhum plugin local foi incluído.

## Comparação

| Área | Protótipo | AuroraPet Godot | Decisão |
|---|---|---|---|
| Identidade procedural | Facção, raça, elemento, nome, gênero e seed | Facção, linhagem, elemento, nome, traços, paletas e pesos de peças | Mantido o sistema Godot; foi adicionada chave de acesso de três caracteres |
| Aparência | SVG gerado em código com corpo, asas, caudas e ornamentos | Peças modulares editáveis em `pet.tscn` e randomização por camadas | Não copiar o SVG, pois conflita com a modularidade definida para o projeto |
| Introdução | Menu, pet salvo, novo pet e carregamento por chave | Logo, Start/Continue/Options, história, facção, ovo e ficha | Mantido o fluxo Godot e adicionada tela de chave em Options |
| Necessidades | Fome, energia, saúde, humor, higiene, disciplina, ousadia, sono e cocô | Mesmo núcleo já implementado, com decaimento tranquilo, sono, cocô e vontades especiais | Apenas adicionada a ação de batalha ao consumo de necessidades |
| Evolução | Timeline com oito estágios e nomes próprios | Sete estágios com a nomenclatura aprovada: Bebê, Criança, Juvenil, Jovem, Adulto, Forma Máxima e Entidade Cósmica | Mantidos os nomes e requisitos do AuroraPet, sem importar nomenclatura conflitante |
| Treino e atributos | Cinco regimes vinculados a Força, Defesa, Agilidade, Inteligência e Resistência | Árvore de habilidades e atributos RPG já existentes | O combate usa os atributos existentes; regimes adicionais ficam para futura validação de level design |
| Minijogos | Jokenpô, Jogo da Velha e 2048 | Os três já estavam implementados | Não duplicados |
| Batalha | Combate de turnos contra Eco procedural, HP, D20, vantagem de facção, críticos, guarda e log | Área de exploração anteriormente vazia | Incorporada como primeira implementação lógica da Batalha de Exploração |
| Economia | Moedas estelares e recompensas em jogos/batalha | Pontos de exploração destinados ao Quarto Cósmico | Batalha adaptada para conceder 10 pontos; o XP foi ajustado ao balanceamento Godot |
| Áudio | Efeitos Web Audio sintetizados em código | Versão Web V 0.0 sem áudio | Não copiar nesta etapa |
| Pensamento cósmico | Endpoint `/api/cosmic-thought` dependente de Gemini | Mensagens locais do sistema e do pet | Não copiar, para manter o protótipo Godot local e sem dependência externa |
| Debug | Painel de reset, simulação de tempo e importação/exportação JSON | Ferramentas de desenvolvimento separadas do fluxo do jogador | Não copiar para a interface final |

## Incorporações realizadas

### Batalha de Exploração

A cena deixou de exibir apenas um placeholder e agora inicia encontros contra um Eco procedural. O adversário recebe nível, facção, HP, força, defesa e agilidade derivados do pet. O fluxo possui turnos, Golpe Fraco, Golpe Forte, Golpe de Status, Defesa, Fuga, Guarda Estelar, guarda do Eco, rolagens D20, críticos, falhas táticas, vantagem triangular entre facções, registros de combate e resultado de vitória ou derrota.

A interface foi adaptada para os controles existentes: D-pad escolhe a ação, verde confirma e rosa encerra ou foge. Uma vitória gera `+50 XP` e `+10 pontos de exploração`; a derrota gera `+10 XP`. O valor de XP foi mantido compatível com a fórmula atual de progressão do Godot, em vez de importar diretamente a recompensa mais alta do protótipo React.

### Chave de acesso

A identidade do Godot agora gera uma chave determinística de três caracteres a partir da seed, seguindo o formato do protótipo. A chave aparece na ficha pós-eclosão, é registrada no save local e pode ser informada na nova opção `OPTIONS > CHAVE DE ACESSO CÓSMICA` para gerar novamente uma identidade procedural e iniciar o fluxo do ovo.

Como no protótipo, a chave possui apenas três caracteres e representa uma seed codificada em base 36 limitada a três posições. Ela reproduz o comportamento de geração do protótipo, mas não garante recuperar todos os dígitos de uma seed original muito grande.

### Integração com necessidades

A ação `batalhar` agora possui feedback e custo no `PetStats`: reduz energia e fome, aumenta humor e registra a ação. Isso evita que a batalha fique desconectada do sistema de necessidades existente.

### Encaminhamento de controles

Durante a integração foi corrigido o encaminhamento do teclado para a Batalha de Exploração. O modo de batalha agora é tratado como um estado independente antes do 2048 e do Quarto Cósmico, sem ficar preso dentro do bloco de outro minijogo.

## Elementos deliberadamente não copiados

O renderizador `PetLayeredSprite.tsx` e o gerador de aparência SVG não foram copiados porque criariam uma segunda arquitetura visual e removeriam a liberdade de editar peças diretamente no Godot. Os efeitos sonoros Web Audio não foram incorporados porque a V 0.0 foi definida como uma versão sem áudio. O endpoint Gemini não foi incorporado porque exigiria backend e credenciais externas. O painel de debug não foi colocado na interface do jogador. A timeline de evolução do protótipo também não substituiu os sete estágios aprovados no AuroraPet.

## Validação

A validação headless do Godot 4.7.1 terminou sem erros de script, parse, propriedades inválidas ou nós ausentes. Também foram executados testes determinísticos para iniciar e concluir uma batalha, confirmar a recompensa de 10 pontos, registrar a ação `batalhar` em `PetStats` e gerar a chave `1WX` para a seed de referência `777123`, decodificada pelo mesmo algoritmo do protótipo.

A batalha incorporada é a primeira camada lógica. Mapas, inimigos definitivos, balanceamento final, equipamentos e direção visual da exploração continuam disponíveis para validação criativa antes de serem tratados como conteúdo final.
