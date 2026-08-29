# AuroraPet mobile V 0.1

A variante mobile instancia diretamente `gameplay_root.tscn`, a mesma fonte de gameplay usada pelo console principal, mas aplica uma casca de apresentação própria. Assets e nós do aparelho físico não fazem parte da árvore mobile.

| Item | Configuração |
|---|---|
| Cena de entrada | `res://scenes/mobile_main.tscn` |
| Preset | `Web Mobile V 0.1` |
| Exportação publicada | `docs/mobile/index.html` |
| Identificação web | AuroraPet mobile V 0.1 |
| Orientação | Horizontal |
| Canvas lógico | 1080×650, sem deformação uniforme |
| Controles | Toque direto, atalhos contextuais e gestos de deslize |
| Versão desktop | Mantida no preset `Web V 0.1` e em `res://scenes/main.tscn` |

A apresentação mobile não renderiza o console, a moldura da tela, o D-pad ou os botões físicos. O conteúdo lógico compartilhado ocupa a área principal do aplicativo e recebe uma navegação própria:

- menu de ações na parte inferior, com toque direto nos ícones existentes;
- status no canto superior direito;
- Quarto Cósmico na lateral esquerda;
- voltar no canto superior esquerdo quando houver uma tela ou submenu aberto;
- confirmar no canto inferior direito apenas em telas que ainda usam seleção contextual;
- gestos de deslize para navegar em batalha, mapas, campanha e Quarto Cósmico.

O `ConsoleController` permanece apenas como roteador interno para preservar uma única lógica de gameplay e save entre desktop e mobile. `ScreenContent` é somente o espaço lógico interno de 1080×650; moldura, tela física e controles do aparelho pertencem exclusivamente ao console principal.

Para testar no editor, abra `scenes/mobile_main.tscn`. Para acessar a versão web publicada pelo GitHub Pages, use o caminho `/aurorapet/mobile/` após a atualização do Pages. Em celulares, a experiência foi configurada para orientação horizontal; em telas com proporção diferente, o conteúdo lógico é preservado e pode haver margens laterais ou verticais para evitar estiramento.
