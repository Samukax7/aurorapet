# Base narrativa e visual da introdução

## Sequência oficial

A introdução do AuroraPet seguirá esta ordem:

1. BIOS com a logo AuroraPet.
2. Menu inicial.
3. Boas-vindas e explicação sobre o Deepworld.
4. Explicação dos botões.
5. Seleção dos ovos, com a descrição dinâmica da aura escolhida abaixo das opções.
6. Eclosão do ovo.
7. Tela de status do pet.

A antiga tela separada de explicação das facções foi removida. A escolha da aura agora acontece no mesmo momento visual da escolha do ovo, reduzindo uma etapa redundante e permitindo que o jogador compare Luz, Trevas e Neutro diretamente antes de confirmar.

## Conteúdo narrativo de Deepworld e EVA

O Deepworld é um espelho do mundo real com elementos digitais. Ele pode ser vibrante e colorido em algumas regiões e sombrio e misterioso em outras. Seus habitantes são os Deepmons, seres próprios desse mundo.

EVA é um ser cósmico que nasceu depois do fim de um universo. Ela carrega a sabedoria e a inteligência cósmica de um sistema universal inteiro, mas ainda não consegue acessar tudo por causa da própria inexperiência. Cada passo de evolução desperta uma parte dessa consciência. Ela depende de atenção e cuidados e deseja descobrir novas sensações, emoções e sabores do universo.

Na apresentação inicial, a linguagem deve ser curta e legível. O texto completo pode ser dividido em páginas com poucos parágrafos, usando a EVA como guia visual no canto inferior esquerdo e uma caixa ampla para leitura.

## Conteúdo das auras e facções

As facções são forças cósmicas que influenciam o destino do pet:

| Facção | Tema | Direção de apresentação |
|---|---|---|
| Aurora da Luz | Harmonia, cura e defesa | Uma origem ligada ao equilíbrio e à proteção |
| Aurora das Trevas | Caos, poder e dano bruto | Uma origem ligada à força e à intensidade |
| Aurora Neutra | Equilíbrio, adaptação e versatilidade | Uma origem flexível, capaz de se adaptar |

Cada pet nasce dentro de uma aura/facção, recebe uma raça única, bônus iniciais e estética própria. Na seleção do ovo, a descrição deve permanecer curta e contextual, apresentando a característica principal da aura selecionada sem interromper o fluxo. Exemplos de raças são anjinhos, serafins e fadas estelares na Luz; demônios, sombras e corvos espectrais nas Trevas; e espíritos, animais cósmicos e guardiões elementais na facção Neutra.

## Tela de controles

A explicação das teclas deve usar instruções curtas e visuais, sem parágrafos técnicos extensos. A tela deve preservar a área central para a EVA apontando e uma coluna de leitura para os controles. O texto será dimensionado para o ScreenContent e conferido contra a moldura visual do console.

## Regras visuais

A tela deve usar o fundo padrão do Deepworld sem plataforma, manter a EVA separada em sprite animado e reservar uma área limpa para a caixa de texto. A composição deve ser dimensionada pelo ScreenContent de 895 × 815 px e conferida na moldura da cena `console_frame.tscn`, sem aplicar escalas arbitrárias baseadas apenas na janela.
