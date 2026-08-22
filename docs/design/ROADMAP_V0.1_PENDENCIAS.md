# AuroraPet — Roadmap de Pendências e Ajustes para V0.1

**Documento de planejamento:** 21 de agosto de 2026
**Versão atual:** V0.0 — protótipo web jogável
**Próxima meta:** V0.1 — protótipo refinado, mais legível, expressivo e consistente

> A V0.1 deve priorizar estabilidade, leitura e coerência visual antes da expansão de novas mecânicas. O objetivo é transformar o protótipo funcional em uma experiência inicial mais clara e apresentável.

## Critérios gerais da V0.1

> **Janela de entrega:** segunda-feira, 24/08/2026. Até essa data, o escopo está congelado. O fundo animado e o Guarda-Roupas Cósmico não serão incluídos. O áudio só entra depois dos fluxos, da legibilidade e da exportação estarem estáveis.

A versão V0.1 será considerada pronta quando o fluxo inicial puder ser concluído sem confusão visual, as animações principais não apresentarem desalinhamentos perceptíveis, as telas de pet e batalha tiverem leitura adequada no console e os efeitos de áudio e feedback estiverem integrados de forma consistente. A exportação web deverá funcionar em computador e celular, sem arquivos temporários ou plugins locais publicados no repositório.

## Lista priorizada

| Prioridade | Área | Pendência | Critério de conclusão | Status |
|---:|---|---|---|---|
| 1 | Introdução | Ajustar as animações da cena de abertura | EVA entra, muda de lado, mantém idle e finaliza no close sem saltos, cortes ou desalinhamentos entre frames | Corrigido estruturalmente; validação visual pendente |
| 2 | Pet | Ajustar as animações do pet | Idle, ações, crescimento e reações respeitam escala, origem, camadas modulares e posição da plataforma | Sem bloqueio conhecido; ajuste fino pós-entrega |
| 3 | Batalha | Ajustar a cena de batalha | Pet e Eco permanecem visíveis acima do palco, UI legível, log compacto e botões sem sobreposição | Camada corrigida; validação visual pendente |
| 4 | Feedback | Incluir reações para os pets | Alimentação, cuidado, sono, brincadeiras, treino, dano, vitória e recusa apresentam sinais visuais coerentes | Base integrada; polimento opcional |
| 5 | Cenário | Criar animações para o fundo | Deepworld mantém a plataforma fixa e recebe camadas animadas, partículas ou efeitos sem deformar a composição | Fora da entrega de 24/08 |
| 6 | Áudio | Incluir música e efeitos sonoros | BIOS, menus, ações, eclosão, batalha e minijogos possuem áudio controlável e sem volume agressivo | Última prioridade da entrega |
| 7 | Personalização | Criar o Guarda-Roupas Cósmico | Acesso pelo Quarto Cósmico, slots modulares, preview, aplicação visual e regras de custo funcionam sem quebrar o pet | Fora da entrega de 24/08 |
| 8 | Técnico | Fazer a vistoria e os polimentos técnicos | Fluxos testados, warnings críticos tratados, telas responsivas, cache web revisado, saves preservados e projeto sem artefatos temporários | Em andamento |
| 9 | Release | Atualizar para a build V0.1 | Build web exportada, testada em desktop e celular, documentada e publicada com identificação clara de versão | Após validação final |

## 1. Ajustar as animações da cena de abertura

A spritesheet completa da EVA já está integrada como atlas de 240 quadros. O próximo ajuste deve estabilizar o recorte, a escala visual e a posição por estado. A entrada deve usar o voo, o final deve entrar em idle, as trocas de tela devem alternar o lado de chegada e a tela de status deve reservar espaço para o close. Também será necessário revisar o tempo da transição e impedir que a EVA seja cortada pelo painel ou pela moldura do console.

## 2. Ajustar as animações do pet

Revisar a origem e a escala de cada peça modular, garantindo que base, orelhas, cauda, olhos e asas permaneçam alinhados durante idle, ações e evolução. As animações devem respeitar a cascata `main > console_frame > deepworld > pet` e continuar editáveis diretamente nas cenas do Godot.

## 3. Ajustar a cena de batalha

Refinar o `BattleStage`, as posições do pet e do Eco, a escala dos combatentes, o contraste da UI e o espaço reservado para log e botões. A batalha deve ser validada dentro da moldura real do console em desktop e mobile, preservando os requisitos já definidos: combatentes visíveis, Eco espelhado e interface sem overexplainer.

## 4. Incluir reações para os pets

Criar um sistema visual de feedback que possa receber animações reais posteriormente. Enquanto elas não estiverem prontas, usar partículas, shake, brilho, balões e ícones específicos para fome, energia, humor, saúde, sono, sujeira, brincadeira, treino, batalha, vitória, dano e recusa do pet.

## 5. Criar animações para o fundo

Separar o fundo do Deepworld em camadas editáveis, mantendo a plataforma fixa e ativa. Adicionar movimentos sutis de estrelas, nebulosas, partículas e elementos de facção, com intensidade baixa o suficiente para não prejudicar a leitura das barras, menus e textos.

## 6. Incluir música e efeitos sonoros

Definir uma identidade sonora cósmica para a BIOS, menu, exploração, Quarto Cósmico, minijogos e batalha. Implementar efeitos de navegação, confirmação, cancelamento, alimentação, cuidado, eclosão, evolução, ataque, dano e vitória. Incluir controle de volume e garantir que o jogo continue utilizável sem áudio.

## 7. Criar o Guarda-Roupas Cósmico

Implementar a área do Quarto Cósmico com slots visuais, preview do pet, categorias, custo em pontos e confirmação de compra/equipamento. A arquitetura deve continuar modular, permitindo trocar peças no editor e futuramente adicionar cosméticos, efeitos, cenários, animações e plataformas.

## 8. Fazer a vistoria e os polimentos técnicos

Executar uma rodada de testes nos fluxos de primeiro jogo, continue, modo DEV, eclosão, evolução, necessidades, minijogos, Quarto Cósmico e batalha. Revisar responsividade, escalas, legibilidade, foco de botões, persistência do save v3, carregamento dos assets, cache do GitHub Pages e mensagens de erro.

## 9. Atualizar para V0.1

Depois dos ajustes prioritários, gerar uma nova exportação web, atualizar a identificação visual e a documentação, revisar o changelog, testar o fluxo em tamanhos diferentes e publicar a versão V0.1 no GitHub Pages. A V0.0 deve permanecer identificável como marco anterior do protótipo.

## Ordem recomendada de execução

A primeira frente deve ser a estabilização visual da introdução e das animações do pet, pois esses elementos aparecem no primeiro contato do jogador. Em seguida, devem ser corrigidas batalha e reações, que aumentam a clareza das ações. Depois entram os efeitos do fundo e o áudio. O Guarda-Roupas Cósmico pode ser implementado após a base visual e de feedback estar estável. A vistoria técnica deve preceder a publicação da V0.1.

## Registro de decisões

As animações atuais da EVA estão funcionais, porém ainda apresentam desalinhamentos e variações de escala entre quadros. Esse comportamento foi aceito temporariamente para manter o fluxo jogável e será tratado como a prioridade visual número 1 da V0.1. A integração futura deve continuar usando o `ScreenContent` lógico de 1080 × 650 px e as medidas registradas em `CONSOLE_SCREEN_REFERENCE.md`. A migração estrutural do canvas já foi aplicada; permanecem pendentes os ajustes finos de animação, composição e leitura dentro desse contrato comum.
