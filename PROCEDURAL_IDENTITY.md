# Identidade procedural híbrida — AuroraPet

## Objetivo

O AuroraPet agora separa **identidade** de **aparência**. A identidade define o contexto do pet — nome, gênero, facção, linhagem, elemento, traços e bônus iniciais — enquanto o `PetRandomizer` continua usando os Sprite2D modulares já existentes. Essa divisão preserva a liberdade de prototipagem e acrescenta coerência de mundo.

A arquitetura segue os documentos do projeto, que definem geração por atributos, facções Luz/Trevas/Neutro, raças associadas, elementos, nomes baseados na raça e aparência modular por camadas.[1] [2] [3]

## Estrutura aprovada

| Facção | Linhagens | Tendência |
|---|---|---|
| Aurora da Luz | Serafim; Fada Estelar | Proteção, cura, energia e estética luminosa. |
| Aurora das Trevas | Sombra; Corvo Espectral | Dano, resistência, intensidade e estética sombria. |
| Aurora Neutra | Espírito; Guardião Elemental | Equilíbrio, adaptação e combinações variadas. |

Cada linhagem possui elementos possíveis, banco de nomes, traços, bônus de Força/Defesa/Agilidade/Inteligência, paletas preferidas e pesos para olhos, orelhas, asas e cauda. Os pesos não eliminam variantes; eles apenas aumentam ou reduzem sua probabilidade.

## Seeds e sorteios

`identity_seed` identifica a criatura e é usada para repetir a mesma identidade procedural. O método `generate_new_identity(seed)` cria uma nova identidade determinística a partir de uma seed fornecida. A tecla `R` continua sendo um resorteio visual: ela troca peças e paleta dentro das preferências da identidade, sem trocar nome, facção, linhagem, elemento ou traços.

A aparência pode ser completamente refeita no protótipo sem destruir a identidade do pet. Uma futura tela de nascimento poderá chamar `generate_new_identity()` para criar um novo pet completo, enquanto a personalização deverá usar apenas `PetRandomizer.reroll()` ou `set_part_variant()`.

## Integração com os sistemas existentes

O nó permanente `PetIdentity` foi adicionado a `scenes/pet.tscn`, respeitando a regra de que módulos editáveis devem existir na cena. O `PetRandomizer` consulta esse nó para escolher variantes ponderadas e paletas preferidas, mas continua sem criar ou remover Sprite2D.

O `PetSkills` aplica uma única vez os bônus iniciais da linhagem. A árvore de habilidades e o `PetEvolution` permanecem compatíveis; a evolução continua controlando os estágios visuais, enquanto a identidade fornece contexto para futuras variações por facção/linhagem.

O console exibe uma mensagem de nascimento no formato `NASCEU: NOME • LINHAGEM`. O snapshot disponível em `PetIdentity.get_identity_snapshot()` contém todos os campos necessários para persistência local futura.

## Próximas extensões

A base já permite acrescentar filtros de habilidade por facção/elemento, efeitos de combate, acessórios exclusivos, auras e persistência JSON sem alterar a cascata de cenas. Esses recursos devem ser implementados depois da validação criativa das peças específicas de cada linhagem.

## Referências

[1]: /home/ubuntu/projects/aurorapet2-5b1dbf22/GDD – AuroraPet (Versão Laboratório Completa).txt
[2]: /home/ubuntu/projects/aurorapet2-5b1dbf22/# 🌅 AuroraPet - Game Design Document (Versão Completa) (2).txt
[3]: /home/ubuntu/projects/aurorapet2-5b1dbf22/projetoaurorapet.txt
