# AuroraPet — Roadmap de Implementação Técnica

**Referência técnica:** protótipo do Google AI Studio  
**Engine:** Godot 4.7.1  
**Regra visual:** usar o plugin `at-icons` apenas como placeholder técnico; os ícones definitivos continuarão sendo assets pixel art do AuroraPet.  
**Regra de arquitetura:** preservar `main.tscn → console_frame.tscn → deepworld.tscn → pet.tscn` e evitar criação/remoção de peças do pet por código.

## Lista priorizada de tarefas

### 1. Persistência completa do estado do pet — prioridade máxima — CONCLUÍDA

Criar uma camada de serialização para salvar e carregar identidade, necessidades, sono, doença, sujeira, vontades, progressão, habilidades, atributos, evolução, pontos de exploração, valor acumulado da loja, compras, diário e conquistas em `user://aurorapet_save.json`.

**Critério de conclusão:** fechar e reabrir o jogo deve restaurar o mesmo pet, nível, XP, status, identidade, pontos e itens adquiridos. O fluxo `Continue` deve carregar o estado completo, não apenas regenerar a identidade. **Validado:** round-trip determinístico restaurou identidade, fome/energia, progressão, aparência modular, paleta, pontos de exploração e valor acumulado da Loja.

### 2. Verificador central de ações e recusas objetivas — CONCLUÍDA

Adicionar ao `PetStats` um verificador único para ações. Ele deverá tratar ovo não eclodido, sono, fome cheia, fome crítica, energia insuficiente, saúde crítica, doença e ações incompatíveis com o estado atual. O resultado deve informar se a ação foi aceita, recusada ou apenas informativa, junto com a mensagem do sistema e a fala do pet.

**Critério de conclusão:** treino, minijogos, alimentação, remédio, sono e batalha consultam a mesma regra, sem duplicar limites em cada cena. **Validado:** teste determinístico confirmou recusa por fome cheia, remédio desnecessário, doença, energia/fome baixa, saúde crítica, sono com energia cheia e aceitação de treino em condições adequadas.

### 3. Separação de Obediência e Ousadia — CONCLUÍDA

Adicionar `obediencia` e `ousadia` como estados persistentes do pet, mantendo `disciplina` como histórico/regra de cuidado se necessário. Integrar decaimento, elogio, repreensão, treino, minijogos, batalha e comportamento.

**Critério de conclusão:** o pet pode ficar equilibrado, disciplinado ou rebelde; esses estados influenciam a aceitação das ordens e aparecem na ficha técnica. **Validado:** Obediência/Ousadia são persistentes, aparecem no resumo e influenciam treino, minijogos e eventos.

### 4. Eventos comportamentais e respostas do pet

Adaptar os eventos do protótipo: bagunça, pirraça com comida, desafio, afeto espontâneo, meditação e achados estelares. Usar os sinais existentes de reação, balão de fala, painel de sistema, tremor e placeholders visuais.

**Critério de conclusão:** eventos são disparados com frequência controlada, podem alterar necessidades/recompensas e não interrompem a navegação do console.

### 5. Atributos RPG ampliados — CONCLUÍDA

Adicionar inicialmente `resistencia` como atributo próprio, pois já influencia decaimento e HP de batalha. Avaliar `sorte` e `carisma` depois que existirem mecânicas reais para consumi-los. Atualizar árvore de habilidades, ficha e save.

**Critério de conclusão:** cada atributo exibido possui função técnica verificável e não é apenas um número decorativo. **Validado:** Resistência foi adicionada ao PetSkills, ao save, à árvore e ao cálculo de HP/EN/decaimento.

### 6. Custos de EN e expansão da Batalha de Exploração — CONCLUÍDA

Transportar da estrutura do protótipo os custos de energia, poder-base, precisão, habilidades de status/defesa, Intuição Cósmica, críticos condicionados por atributos, rebeldia em combate e habilidades variadas do Eco.

**Critério de conclusão:** cada ação de batalha possui custo, resultado e log; a batalha usa os atributos reais do pet sem criar um segundo sistema de identidade. **Validado:** habilidades possuem EN, poder e precisão; a batalha recupera EN por turno, aplica Guarda com custo, registra falhas e bloqueia ações sem energia.

### 7. Metadados de evolução — CONCLUÍDA

Enriquecer `PetEvolution` com descrição, média de atributos, multiplicador de poder e dados de estágio, preservando os nomes oficiais do AuroraPet: Bebê, Criança, Juvenil, Jovem, Adulto, Forma Máxima e Entidade Cósmica.

**Critério de conclusão:** a ficha e a árvore apresentam estágio atual, requisito, descrição e progresso sem alterar os nomes aprovados. **Validado:** STAGE_DATA possui descrição, média mínima, multiplicador e os sete nomes oficiais; a árvore exibe estágio e Resistência.

### 8. Diário cósmico e conquistas — CONCLUÍDA

Criar registros persistentes para nascimento, primeira refeição, primeiro jogo, primeira batalha, evolução, compras importantes, eventos e descobertas. Exibir futuramente na ficha/status.

**Critério de conclusão:** os registros sobrevivem ao save/load e podem ser consultados sem depender de logs temporários. **Validado:** o round-trip restaurou diário e conquista de batalha.

### 9. Economia e inventário persistentes — CONCLUÍDA

Definir a relação entre Moedas Estelares do protótipo e Pontos de Exploração atuais. Em seguida, criar posse de itens, compras únicas, equipamentos e integração futura com Guarda-Roupas.

**Critério de conclusão:** uma compra não pode ser repetida indevidamente após recarregar o save e a Loja deve diferenciar item comprado, bloqueado e disponível. **Validado:** itens adquiridos, valor acumulado e moedas estelares sobreviveram ao round-trip; o Quarto rejeita compra repetida.

### 10. Ferramentas de teste técnico

Criar uma superfície de debug apenas local para adicionar XP, simular tempo, forçar doença, restaurar status, gerar facções e exportar/importar JSON, inspirada no `DebugPanel` do protótipo. Não incluir essa ferramenta no fluxo normal do jogador.

**Critério de conclusão:** testar limites e recusas sem editar manualmente dezenas de propriedades no inspetor.

### 11. Pensamentos cósmicos dinâmicos — prioridade posterior

Avaliar uma camada opcional de falas dinâmicas com fallback local. Não inserir chave de API no cliente Web V 0.0 e não tornar a conexão externa necessária para o funcionamento do jogo.

**Critério de conclusão:** o jogo continua funcionando offline e sem áudio, mesmo que a camada dinâmica esteja desativada.

## Placeholders do plugin de ícones

Os ícones do `at-icons` serão usados somente durante a prototipagem técnica. O addon permanecerá local e não será enviado ao GitHub, conforme a regra do projeto.

| Função técnica | Placeholder sugerido | Substituição futura |
|---|---|---|
| Salvar/carregar | `floppy_disk.svg` | Ícone pixel art de save |
| Status/necessidades | `heart.svg` ou `activity.svg` | Ícone pixel art de status |
| Sono | `alarm_clock.svg` | Ícone pixel art de dormir |
| Saúde/doença | `medical_cross.svg` ou `first_aid.svg` | Ícone pixel art de remédio |
| Treino | `dumbbell.svg` ou `barbell.svg` | Ícone pixel art de treino |
| Batalha | `cutlass.svg` ou `sword.svg` | Ícone pixel art de batalha |
| Defesa | `shield.svg` | Ícone pixel art de defesa |
| Loja | `shopping_cart.svg` ou `store.svg` | Ícone pixel art da Loja Cósmica |
| Guarda-Roupas | `clothes_hanger.svg` ou `clothes_hanger` | Ícone pixel art do Guarda-Roupas |
| Diário | `book.svg` ou `library.svg` | Ícone pixel art do Diário Cósmico |
| Conquistas | `trophy.svg` ou `star.svg` | Ícone pixel art de conquistas |
| Configurações/debug | `gear.svg` ou `wrench.svg` | Ícone técnico local, sem uso no menu final |

Os nomes exatos serão confirmados na pasta local do addon antes de inserir qualquer referência em `.tscn`. Nenhum arquivo do addon será copiado para `assets/` do projeto nem incluído em commits.

## Critérios gerais de cada bloco

Cada bloco deve ser implementado no projeto local, validado com Godot Linux headless, testado com um script determinístico quando houver regras de estado e só então sincronizado com o clone GitHub. Arquivos temporários de teste devem permanecer fora da pasta do projeto.

A implementação deve alterar a menor quantidade possível de cenas. A lógica deverá permanecer nos nós especializados, enquanto o `ConsoleController` apenas encaminha sinais. Ajustes manuais de posição feitos pelo usuário no editor devem ser preservados.
