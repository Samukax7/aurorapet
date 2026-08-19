# Sistema de necessidades — AuroraPet

## Objetivo

O sistema adapta princípios observados em V-Pets do estilo Tamagotchi para o universo do AuroraPet. A referência separa fome e felicidade, usa chamadas de atenção, registra erros de cuidado, inclui sono, sujeira, doença, remédio e disciplina, e permite que o histórico de cuidado influencie a evolução.[1] [2]

## Necessidades persistentes

| Necessidade | Faixa | Decaimento | Ações principais |
|---|---:|---:|---|
| Fome | 0–100 | lento e contínuo | Fruta Estelar, Néctar Cósmico, Banquete Nebulosa |
| Energia | 0–100 | lento e contínuo | Dormir, treino e jogos alteram o valor |
| Humor | 0–100 | lento e contínuo | Jogos, comida especial e treino |
| Higiene | 0–100 | lento e contínuo | Limpar Sujeira |
| Saúde | 0–100 | protegida fora da criticidade | Remédio, limpeza, sono e alimentação |
| Disciplina/obediência | 0–100 | queda muito suave | Treino, chamadas perdidas e cuidado correto |

Peso também é persistido como contrapeso de alimentação e jogos. O sistema mantém contadores de chamadas perdidas, erros de cuidado, erros de disciplina e refeições excessivas para que a evolução futura possa considerar o histórico sem depender apenas dos valores atuais.

## Estados e chamadas

Uma necessidade abaixo do limite crítico ativa uma chamada de atenção com motivo. A janela de resposta padrão é de 15 minutos, inspirada no guia do Tamagotchi; no protótipo, ela fica exportada para ajuste rápido. Se expirar, o sistema registra um erro de cuidado, reduz disciplina e encerra a chamada até a próxima transição crítica.

Higiene baixa por tempo prolongado pode causar doença. Doença não mata o pet imediatamente: ela reduz saúde gradualmente e deve ser tratada com Dar Remédio. Dormir inicia um período de recuperação e evita que energia continue caindo enquanto o estado de sono estiver ativo.

## Princípio de balanceamento

O AuroraPet não terá morte permanente nesta etapa. Necessidades críticas produzem feedback visual, chamadas, penalidades graduais e influência futura na evolução. O ritmo permanece relaxado, mantendo os valores atuais de decaimento como base e adicionando apenas a higiene e a disciplina com taxas menores.

[1]: https://tamagotchi.fandom.com/wiki/Care "Tamagotchi Wiki — Care"
[2]: https://thaao.net/tama/p1/ "Thaao's Tamas — Tamagotchi P1 Care Guide"
