# Mapa de áudio do AuroraPet

Este arquivo registra a função dos áudios usados no fluxo principal. Os nomes históricos dos arquivos são mantidos para não quebrar referências existentes.

| Arquivo | Função | Player ou uso |
|---|---|---|
| `aurorapet_sfx_intro_eva.wav` | Efeito curto da BIOS AuroraPet, reproduzido junto da logo AuroraPet. | `OpeningFlow/IntroEvaAudio` |
| `aurorapet_sfx_welcome.wav` | Trilha longa da apresentação, em loop após `START` até a ficha de status. | `OpeningFlow/WelcomeAudio` |
| `aurorapet_lobby_theme.wav` | Trilha contínua do lobby depois que a ficha de status é fechada. | `ConsoleFrame/LobbyMusic` |
| `aurorapet_confirm_beep.wav` | Confirmação do botão verde. | `ConsoleFrame/ConfirmAudio` |
| `aurorapet_sfx_green_button.wav` | Clique/movimento do D-pad. O nome é histórico e não indica a função atual. | `ConsoleFrame/DPadAudio` |
| `aurorapet_sfx_positive.wav` | Feedback positivo de ações e progressão. | `ConsoleFrame/PositiveAudio` |
| `aurorapet_sfx_refusal.wav` | Feedback de recusa ou ação bloqueada. | `ConsoleFrame/RefusalAudio` |
| `aurorapet_sfx_open.wav` | Abertura de submenu ou painel. | `ConsoleFrame/OpenOptionsAudio` |
| `aurorapet_sfx_levelup.wav` | Feedback de evolução ou subida de nível. | `ConsoleFrame/LevelUpAudio` |
| `aurorapet_sfx_poop.wav` | Feedback do evento de sujeira/coco. | `ConsoleFrame/PoopAudio` |

## Sequência esperada

1. A logo do usuário aparece sem iniciar a trilha da apresentação.
2. A BIOS AuroraPet entra e reproduz `aurorapet_sfx_intro_eva.wav`.
3. O menu entra e a música da BIOS é interrompida.
4. Ao confirmar `START`, `aurorapet_sfx_welcome.wav` começa em loop.
5. A mesma trilha acompanha história, controles, seleção do ovo, eclosão e ficha de status.
6. Ao fechar a ficha, a trilha para e o lobby inicia `aurorapet_lobby_theme.wav`.
