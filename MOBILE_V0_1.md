# AuroraPet mobile V 0.1

A variante mobile reutiliza a mesma cascata de gameplay da versão desktop, mas usa uma casca de apresentação própria. A moldura do console, a tela física desenhada e os sprites dos botões físicos não são renderizados nessa versão.

| Item | Configuração |
|---|---|
| Cena de entrada | `res://scenes/mobile_main.tscn` |
| Preset | `Web Mobile V 0.1` |
| Exportação publicada | `docs/mobile/index.html` |
| Identificação web | AuroraPet mobile V 0.1 |
| Orientação | Horizontal |
| Canvas lógico | 1080×650, sem deformação uniforme |
| Controles | D-pad touch, VERDE, ROSA e AMARELO |
| Versão desktop | Mantida no preset `Web V 0.1` e em `res://scenes/main.tscn` |

Os controles touch encaminham os comandos para os mesmos handlers usados pelo teclado e pelos botões físicos. Dessa forma, o pet modular, o lobby, a introdução, os minigames, a batalha, o quarto cósmico e a progressão continuam compartilhando a mesma lógica.

Para testar no editor, abra `scenes/mobile_main.tscn`. Para acessar a versão web publicada pelo GitHub Pages, use o caminho `/aurorapet/mobile/` após a atualização do Pages. Em celulares, a experiência foi configurada para orientação horizontal; em telas com proporção diferente, o conteúdo lógico é preservado e pode haver margens laterais ou verticais para evitar estiramento.
