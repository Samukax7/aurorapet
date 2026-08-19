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

## Efeitos das opções atuais

| Categoria | Opção | Efeito de necessidade | XP de habilidades |
|---|---|---|---:|
| Comer | Fruta Estelar | +18 fome, +2 humor, +1 saúde, +1 peso | +5 |
| Comer | Néctar Cósmico | +28 fome, +4 energia, +2 saúde, +2 peso | +5 |
| Comer | Banquete Nebulosa | +42 fome, +6 humor, +3 saúde, +4 peso | +5 |
| Cuidar | Dar Remédio | Cura doença e restaura +24 saúde; se saudável, apenas +2 saúde; -1 humor e -2 energia | +5 |
| Cuidar | Limpar Sujeira | +35 higiene, +14 saúde, +8 humor, -3 energia | +5 |
| Cuidar | Dormir | Entra em sono por 12 s; recupera +2,4 energia/s e +0,25 humor/s; -7 fome e +2 saúde ao iniciar | +5 |
| Jogar | Jokenpô | +18 humor, -10 energia, -6 fome, -1 peso | +15 |
| Jogar | Jogo da Velha | +20 humor, -8 energia, -5 fome, -1 peso | +18 |
| Jogar | 2048 | +22 humor, -12 energia, -4 fome, -1 peso | +20 |
| Treinar | Treino | +10 humor, +4 disciplina, +3 saúde, -18 energia, -10 fome | +25 e +1 Força |
| Batalhar | Em breve | Nenhum efeito enquanto o combate PvE não estiver implementado | 0 |

A diferença entre os alimentos cria escolhas: a fruta é uma reposição leve, o néctar sustenta fome e energia, e o banquete resolve uma necessidade grande com maior custo de peso. Se a fome já estiver em 94 ou mais, uma nova refeição não é aplicada e registra uma refeição excessiva, evitando que o jogador maximize a barra sem consequência.

## Estados e chamadas

Uma necessidade abaixo do limite crítico ativa uma chamada de atenção com motivo. A janela de resposta padrão é de 15 minutos, inspirada no guia do Tamagotchi; no protótipo, ela fica exportada para ajuste rápido. Se expirar, o sistema registra um erro de cuidado, reduz disciplina e encerra a chamada até a próxima transição crítica.

Higiene baixa por tempo prolongado pode causar doença. Doença não mata o pet imediatamente: ela reduz saúde gradualmente e deve ser tratada com Dar Remédio. Dormir inicia um período de recuperação e evita que energia continue caindo enquanto o estado de sono estiver ativo.

## Regras de proteção e balanceamento

O decaimento permanece tranquilo: fome `0,025/s`, energia `0,018/s`, humor `0,012/s`, higiene `0,020/s` e disciplina `0,004/s`, antes da resistência dos atributos. A saúde continua protegida fora da criticidade; ela só cai quando uma necessidade está em estado crítico ou quando o pet está doente.

O AuroraPet não terá morte permanente nesta etapa. Necessidades críticas produzem feedback visual, chamadas, penalidades graduais e influência futura na evolução. O jogador deve ser incentivado a alternar alimentação, cuidado, jogos e treino, em vez de repetir uma única ação.

[1]: https://tamagotchi.fandom.com/wiki/Care "Tamagotchi Wiki — Care"
[2]: https://thaao.net/tama/p1/ "Thaao's Tamas — Tamagotchi P1 Care Guide"
