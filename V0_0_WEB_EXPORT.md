# AuroraPet V 0.0 — Exportação Web

## Objetivo

A versão **AuroraPet V 0.0** é um protótipo Web jogável em navegadores de computador e celular. Ela foi configurada para funcionar sem áudio, com layout adaptável, orientação horizontal e identificação visual de protótipo incompleto.

> Esta versão é uma demonstração inicial de fluxo, interface e progressão. O sistema de combate, parte das animações, o áudio e diversos conteúdos ainda não estão implementados.

O navegador precisa oferecer WebAssembly e WebGL 2.0 para executar o export Web do Godot. A documentação oficial recomenda o modo de exportação em uma única thread, pois ele reduz as exigências do servidor e é mais compatível com hospedagens comuns e dispositivos móveis.[1]

## O que já está configurado

| Item | Configuração V 0.0 |
|---|---|
| Preset | `Web V 0.0` |
| Arquivo inicial | `index.html` |
| Nome do projeto | `AuroraPet V 0.0` |
| Versão | `0.0` |
| Áudio | Nenhum recurso ou nó de áudio presente; o menu informa `SEM ÁUDIO` |
| Redimensionamento | Adaptativo ao navegador (`html/canvas_resize_policy=2`) |
| Viewport lógico | `1080 × 650` para composição inicial |
| Canvas Web | `100vw × 100vh`, preenchendo a janela inteira |
| Console | Escala proporcional calculada dinamicamente em `main_responsive.gd` |
| Orientação sugerida | Paisagem, adequada ao formato do console |
| Threads | Desativadas para facilitar hospedagem e compatibilidade móvel |
| PWA | Ativado para permitir instalação na tela inicial |
| Ícone da página | `assets/UI/aurorapet_icon.png` |
| Ícones PWA | 144, 180 e 512 pixels |
| Preset salvo em | `export_presets.cfg` |
| Saída padrão | `build/web/V_0_0/index.html` |

O canvas Web agora ocupa `100vw × 100vh`. A cena Main calcula a escala usando a menor proporção entre a janela e o design de `1080 × 650`, centralizando o console e preservando suas proporções. Em telas mais largas ou mais altas, o fundo azul-marinho preenche as áreas extras sem deixar o canvas cinza ou branco. Em celulares, a orientação paisagem evita que o console seja cortado; a escala reduz proporcionalmente para caber na menor dimensão.

A exportação Web usa `html/export_icon=true`, portanto o ícone do projeto é incluído como favicon. Os três tamanhos quadrados também foram configurados para o manifesto PWA; o Godot usa esses arquivos quando o jogador adiciona a versão à tela inicial do celular.[2]

## Instalar os templates de exportação

A máquina que fará a exportação precisa ter os templates da mesma versão do editor Godot. Este projeto utiliza o **Godot 4.7.1 stable**. No editor, abra **Editor > Manage Export Templates**, selecione os templates Standard e instale-os.

Também é possível baixar o pacote oficial diretamente na página de arquivo do Godot:

[Download dos templates Standard do Godot 4.7.1](https://downloads.godotengine.org/?version=4.7.1&flavor=stable&slug=export_templates.tpz&platform=templates)

Depois do download, no gerenciador de templates escolha **Install from File** e selecione o arquivo `.tpz`. A documentação oficial confirma que os templates precisam estar instalados antes de exportar um projeto.[3]

## Exportação pelo editor

Abra o projeto no Godot e selecione **Project > Export**. O arquivo `export_presets.cfg` já contém o preset **Web V 0.0**. Se o editor mostrar o preset, selecione-o e clique em **Export Project**.

Use como destino:

```text
build/web/V_0_0/index.html
```

O Godot deverá gerar, no mesmo diretório, o HTML, o JavaScript de inicialização, o WebAssembly, o PCK e a imagem de inicialização. Os arquivos devem permanecer juntos e com os nomes gerados pelo Godot; o HTML deve ser chamado `index.html` para funcionar como entrada padrão na maioria dos servidores.[1]

## Exportação pela linha de comando

Dentro da pasta do projeto, depois de instalar os templates, execute:

```bash
godot --path . --export-release "Web V 0.0" build/web/V_0_0/index.html
```

No Windows, substitua `godot` pelo caminho do executável instalado, por exemplo:

```powershell
& "C:\Godot\Godot_v4.7.1-stable_win64.exe" --path . --export-release "Web V 0.0" "build/web/V_0_0/index.html"
```

A documentação do Godot recomenda que o nome do arquivo exportado para Web seja `index.html` e que os arquivos gerados sejam servidos juntos, sem renomear o `.wasm`, o `.pck` ou o `.js`.[1]

## Testar localmente

Não abra o `index.html` diretamente pelo explorador de arquivos. O navegador pode bloquear o carregamento do WebAssembly e dos recursos devido às regras de segurança. Entre na pasta exportada e inicie um servidor local:

```bash
cd build/web/V_0_0
python -m http.server 8060
```

Depois abra `http://localhost:8060` no navegador. No celular, o telefone e o computador precisam estar na mesma rede; para um teste local na rede, use o endereço IP do computador no lugar de `localhost`.

## Compartilhar a versão

Para compartilhar com outras pessoas, compacte o conteúdo da pasta `build/web/V_0_0` em um arquivo ZIP. O pacote deve conter `index.html` na raiz do ZIP, não dentro de uma subpasta adicional.

A opção mais simples para um protótipo é publicar o ZIP como **HTML Game** em uma plataforma de hospedagem de jogos, como itch.io. Outra opção é hospedar os arquivos em GitHub Pages ou em um servidor HTTPS próprio. O Web export precisa ser servido por um servidor HTTP; para instalação PWA e persistência local, HTTPS é a opção recomendada.[1]

Em celulares, o usuário abre a página no navegador, escolhe **Adicionar à tela inicial** e pode executar o AuroraPet como uma aplicação Web instalada. A instalação PWA depende do navegador e do sistema operacional, mas o preset já fornece o nome, o ícone, a orientação e os tamanhos de imagem necessários.

## Passe de legibilidade após testes

Os primeiros testes externos apontaram três problemas convergentes: textos difíceis de ler por causa da escala e das cores, falta de instrução clara no Jogo da Velha e ausência de objetivos visuais diretos durante a progressão inicial.

Para esta rodada, as labels principais da PetUI foram ampliadas e receberam uma hierarquia mais uniforme. Os textos de menu usam branco com contorno escuro, enquanto as cores saturadas ficam reservadas para barras de status e acentos de seleção. As mensagens de sistema continuam em painéis escuros com borda ciano, e as falas do pet permanecem em balões claros, mantendo a diferença entre informação e reação.

A abertura também recebeu aumento tipográfico nos títulos, botões, instruções, história, seleção de facção, ovo e ficha RPG. O tutorial inicial foi encurtado para objetivos diretos: `OBJETIVO 1/2: FOME EM 100%`, `OBJETIVO 2/2: CUIDAR > DORMIR` e `NÍVEL 2: JOGO DA VELHA LIBERADO`.

O Jogo da Velha agora mostra permanentemente o objetivo `3 EM LINHA`, informa que o jogador usa `O`, exibe o turno atual com instrução acionável e mantém um painel inferior com `D-PAD: MOVER`, `VERDE: MARCAR` e `ROSA: SAIR`. Mensagens de casa ocupada, pensamento da Aurora e fim da partida também foram esclarecidas.

## Limitações conhecidas da V 0.0

A versão não possui áudio, combate implementado, persistência completa de todos os sistemas, animações finais de reação ou conteúdo final da história. O estado salvo usa `user://`, que no navegador depende do armazenamento local do próprio navegador. Navegação privada, bloqueio de cookies ou limpeza dos dados do site podem apagar esse estado.[1]

O navegador também pode pausar o processamento quando a aba fica em segundo plano. Por isso, durante testes de sono e decaimento, mantenha a página ativa.[1]

## Estado deste preparo

O projeto já contém:

1. O preset `Web V 0.0`.
2. O ícone principal e os ícones quadrados do PWA.
3. O nome e a versão `0.0` no `project.godot`.
4. O aviso visual `V 0.0 • PROTÓTIPO EM DESENVOLVIMENTO • SEM ÁUDIO` no menu inicial.
5. Threads Web desativadas para simplificar a hospedagem.

A exportação Web V 0.0 foi validada com o Godot 4.7.1. O pacote responsivo foi testado em uma viewport de `1280 × 1100`: o console ficou centralizado, ampliado e ocupou aproximadamente 90% da largura, enquanto o fundo preencheu toda a área restante.

## Referências

[1]: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html "Godot 4.7 — Exporting for the Web"

[2]: https://docs.godotengine.org/en/4.7/classes/class_editorexportplatformweb.html "Godot 4.7 — EditorExportPlatformWeb"

[3]: https://docs.godotengine.org/en/latest/tutorials/export/exporting_projects.html "Godot — Exporting projects"
