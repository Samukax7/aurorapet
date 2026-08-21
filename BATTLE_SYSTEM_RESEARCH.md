# AuroraPet — pesquisa e proposta de combate

## 1. O que é essencial em Pokémon

A referência oficial de Pokémon Brilliant Diamond e Shining Pearl confirma que a batalha individual é baseada em turnos e apresenta quatro comandos de alto nível: Battle, Pokémon, Bag e Run. O comando Battle leva à escolha do movimento; Pokémon troca o membro ativo e consome o turno; Bag permite um item por turno e também consome o turno; Run tenta escapar de encontros selvagens e pode falhar [1].

Uma referência técnica independente descreve que a ordem de execução considera primeiro a prioridade do movimento e, quando a prioridade é igual, a Speed decide quem age primeiro [2]. A mesma referência separa variáveis de movimento como categoria, poder, alvo, precisão, prioridade, crítico e chance de efeito [2].

A referência de dano da Bulbapedia mostra que o resultado combina nível, poder do movimento, atributo ofensivo, defesa do alvo, crítico, efetividade e um fator aleatório [3]. Não é necessário copiar a fórmula completa nem o sistema de tipos da série para obter a sensação de combate estratégico.

As condições de status da série também são separadas entre não voláteis, que persistem até serem curadas, e voláteis, que terminam após turnos, troca ou fim da batalha [4]. Para o AuroraPet, estados voláteis curtos são suficientes na primeira versão.

## 2. Comparação com a Batalha de Exploração atual

| Elemento | Estado atual | Ajuste recomendado |
|---|---|---|
| Turnos | Já existe alternância jogador/Eco | Manter a estrutura e adicionar iniciativa por Agilidade + D20 |
| Aleatoriedade | D20 já participa de acerto, crítico e falha tática | Tornar o D20 o dado central de iniciativa, acerto, crítico e efeitos |
| Opções | Há cinco entradas planas: golpe fraco, golpe forte, golpe de status, defesa e fugir | Passar para quatro comandos de alto nível, com submenus quando necessário |
| Velocidade | Agilidade afeta precisão, mas não define quem age primeiro | Usar Agilidade como desempate/parte da iniciativa |
| Precisão | Já existe por habilidade | Manter, mas fazer o D20 produzir resultado compreensível |
| Dano | Já combina força, poder, defesa e multiplicador de facção | Simplificar a leitura do cálculo e preservar os atributos existentes |
| Crítico | D20 20 gera dano ampliado | Manter como resultado natural do D20 |
| Guarda | Já existe e reduz dano | Manter como comando tático de um turno |
| Status | Golpe de Status enfraquece o próximo golpe do Eco | Formalizar como condição volátil de duração curta |
| Energia | EN é consumida e recuperada por turno | Manter; ela substitui parte do papel de recursos da Bag |
| Fuga | Existe como entrada selecionável e encerra imediatamente | Fazer uma tentativa de fuga com chance baseada em Agilidade + D20 |
| Facções | Já existe vantagem de facção | Manter como multiplicador simples, sem copiar tipos e STAB |
| Troca de Pokémon | Não faz sentido para um único pet | Não implementar agora |
| Itens de batalha | O Quarto e a Loja ainda estão em level design | Não implementar agora |
| Equipe múltipla | O AuroraPet acompanha um pet principal | Não implementar agora |

## 3. Recorte recomendado para quatro comandos

A proposta mais coerente é manter quatro comandos de alto nível, inspirados na estrutura de Pokémon, mas adaptados ao único pet do AuroraPet:

1. **GOLPES** — abre os golpes desbloqueados do pet, como Golpe Fraco, Golpe Forte e Golpe de Status.
2. **TÉCNICA** — abre ações especiais não puramente ofensivas; na primeira versão pode conter Recuperação/Intuição quando houver habilidades correspondentes.
3. **GUARDA** — reduz o próximo dano recebido e consome o turno.
4. **FUGIR** — tenta abandonar o encontro; se falhar, o Eco age normalmente.

O comando **GOLPES** funciona como o comando Battle de Pokémon: ele é uma opção de alto nível e leva a uma segunda seleção. Isso permite manter quatro opções visíveis sem perder os golpes individuais já implementados. A entrada Técnica pode começar com um único item ou permanecer bloqueada até existir uma habilidade correspondente; ela não deve receber uma função artificial apenas para preencher a interface.

Se a direção desejada for quatro ações diretas, a alternativa é usar Golpe Fraco, Golpe Forte, Guarda e Fugir, deixando Golpe de Status dentro de Golpes. A opção com submenu é mais próxima da arquitetura de Pokémon e preserva melhor a expansão futura.

## 4. D20 e ordem de turno

Para cada rodada, cada lado rola iniciativa:

```text
iniciativa = D20 + Agilidade + bônus de prioridade
```

A maior iniciativa age primeiro. Em empate, o AuroraPet pode usar um segundo desempate determinístico pelo D20 já rolado e, persistindo o empate, favorecer o jogador somente para manter a sensação de controle. A prioridade deve ser simples: Guarda pode receber prioridade +1, enquanto golpes comuns e Técnica usam 0. Não é necessário reproduzir a tabela completa de prioridades de Pokémon.

Para ações ofensivas, o resultado do D20 deve ser legível:

| Resultado | Efeito recomendado |
|---|---|
| 1–2 | Falha tática; dano reduzido ou efeito não aplicado |
| 3–9 | Acerto normal possível, dependendo da precisão |
| 10–19 | Acerto normal |
| 20 | Crítico; dano ampliado e chance de efeito garantida quando fizer sentido |

A precisão da habilidade deve continuar influenciando a possibilidade de acerto, mas sem esconder o papel do D20. Um golpe com precisão alta deve ser confiável; um golpe forte ou de status pode ser mais arriscado.

## 5. Dano e status no AuroraPet

O dano pode continuar usando os atributos existentes, com uma fórmula curta e transparente:

```text
dano base = poder × (atributo ofensivo + nível) ÷ (defesa do alvo + constante)
dano final = dano base × multiplicador de facção × modificador do D20 × guarda
```

O sistema deve preservar Força, Defesa, Agilidade, Inteligência e Resistência. A Inteligência pode continuar alimentando a Intuição Cósmica, mas a Intuição deve ser apresentada como um modificador do D20 ou da precisão, não como uma segunda rolagem escondida.

Para o primeiro conjunto de status, usar no máximo três condições voláteis: **Enfraquecido**, que reduz o próximo golpe; **Desorientado**, que reduz a precisão no próximo turno; e **Sobrecarregado**, que aumenta o custo de EN no próximo turno. Cada condição dura um ou dois turnos e é removida automaticamente ao expirar ou ao fim do combate.

## 6. O que não copiar

Não é necessário implementar equipes de até seis criaturas, troca de membro, mochila com dezenas de itens, tipos elementais completos, STAB, habilidades passivas em grande escala, dupla batalha, prioridades complexas, breeding, captura ou fórmulas de dano por geração. Esses elementos aumentariam a complexidade sem melhorar o loop central do AuroraPet nesta fase.

## Referências

[1]: https://diamondpearl.pokemon.com/en-au/trainersguide/fundamentals/battling/ "Pokémon Official Website — Pokémon Battling"
[2]: https://www.dragonflycave.com/mechanics/battling-basics/ "The Cave of Dragonflies — Battling Basics"
[3]: https://bulbapedia.bulbagarden.net/wiki/Damage "Bulbapedia — Damage"
[4]: https://bulbapedia.bulbagarden.net/wiki/Status_condition "Bulbapedia — Status condition"

## 7. Implementação realizada nesta rodada

A Batalha de Exploração agora apresenta quatro comandos de alto nível: Golpes, Técnica, Guarda e Fugir. Golpes abre um submenu com Golpe Fraco, Golpe Forte e Golpe de Status; Técnica abre Intuição Cósmica. O botão rosa retorna do submenu para o menu principal antes de fechar a área.

A iniciativa de cada rodada usa D20 + Agilidade, com Guarda recebendo uma prioridade simples de +1. Quando o Eco vence a iniciativa, a ação escolhida pelo pet fica pendente e é executada depois do ataque do Eco. Golpes continuam usando custo de EN, precisão, dano por atributos, vantagem de facção e crítico no D20 20. Resultados 1–2 produzem falha tática. Golpe de Status aplica Enfraquecido por um ou dois turnos, reduzindo o dano do próximo ataque do Eco.

Fugir deixou de encerrar automaticamente o encontro: agora rola D20 + Agilidade contra um alvo baseado na Agilidade do Eco. A fuga pode ser bem-sucedida ou falhar, e uma tentativa falha permite a ação do Eco. A Guarda continua reduzindo o próximo dano recebido e consumindo o turno.

A interface passou a exibir a lista dos quatro comandos e os submenus diretamente na tela da batalha. A hierarquia `main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn` não foi alterada.

## 8. Assets visuais fornecidos e priorização

Os pacotes recebidos foram avaliados como referências de interface para a batalha. A prioridade foi dada às caixas de texto e às molduras de ação, porque elas resolvem diretamente o problema relatado de leitura. Foram preparados recortes pixel art de botões ciano e azul, uma moldura de log ciano e uma faixa de emoções. Esses elementos são carregados em runtime no Windows e na Web; o modo headless usa fallback sem textura para manter a validação técnica estável.

O spritesheet de HP contém exemplos completos com números e rótulos de outro jogo, por isso as barras do AuroraPet continuam sendo `ProgressBar` próprias, com cores verde, vermelho e azul e valores reais de HP/EN. Essa decisão evita misturar textos estranhos à interface e mantém o vínculo com o sistema de batalha. O pacote de ícones de área também não foi inserido nesta primeira versão, pois não melhora a leitura imediata dos comandos. As emoções foram usadas como faixa decorativa e ficam disponíveis para a próxima etapa de feedback visual de crítico, guarda, status e fuga.
