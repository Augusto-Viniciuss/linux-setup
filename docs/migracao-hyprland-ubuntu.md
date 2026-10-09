# Migracao de i3/urxvt para Hyprland/Kitty

Este perfil prepara uma sessao de teste em Ubuntu 22.04 ou 24.04, mantendo Vim e seus plugins, Python, Zsh, tmux, Ranger, SSH, PDFPC e as ferramentas auxiliares escolhidas. A sessao nova usa Hyprland 0.55.4 e Kitty. O comando `./install.sh` na raiz instala este perfil; `./install.sh --legacy` seleciona explicitamente o instalador antigo de i3/urxvt.

## Instalacao no computador de teste

Nao executei o instalador neste computador. Ele foi preparado para ser executado por um usuario normal, em uma maquina de teste, e pede `sudo` quando altera pacotes ou instala a sessao de login. Se Nix nao estiver presente, o script baixa o instalador oficial por HTTPS e instala Nix em modo multiusuario, incluindo o servico daemon; essa modalidade requer systemd e torna a remocao do Nix mais trabalhosa. O script tambem prepara `curl` e certificados CA para esse bootstrap. Os comandos Nix habilitam `nix-command` e `flakes` somente na chamada, sem alterar a configuracao global do Nix. Veja a [documentacao oficial de instalacao do Nix](https://nixos.org/download/) e a [orientacao do Hyprland para outras distribuicoes](https://wiki.hypr.land/nix/hyprland-on-any-distro-using-nix/).

Com o repositorio clonado no computador de teste:

```bash
cd linux-setup
./install.sh
```

O script aceita Ubuntu 22.04 e 24.04 AMD64, prepara a sessao **Hyprland (linux-setup)** e cria backups datados das configuracoes que substitui. Ao terminar, saia da sessao atual e escolha essa sessao na tela de login. O perfil seleciona Zsh como shell de login; o Bash continua configurado para uso interativo e para scripts. O instalador acrescenta o perfil e nao remove os programas que uma execucao antiga ja tenha instalado; para testar a lista enxuta sem residuos, use uma instalacao limpa do Ubuntu.

## Aplicativos e componentes

| Funcao | Mantido ou adaptado | Removido do perfil novo |
| --- | --- | --- |
| Janela e terminal | Hyprland no lugar do i3; Kitty GPU no lugar do urxvt; atalhos Alt e Super conservados onde possivel | i3, i3bar e urxvt |
| Desenvolvimento | Vim e todos os plugins ativos; clangd pelo CoC; Python 3 e ferramentas de formatacao; tmux e tmuxinator | YCM e vim-ros continuam desativados; nenhum ROS e instalado |
| Shell e arquivos | Zsh com tema agnoster, Ranger, busca fzf/ag, previews e atalhos de clipboard | Athame e controle de mouse pelo teclado do i3 |
| Acesso e sistema | OpenSSH client/server, autossh, nmap, net-tools, GParted, GRUB Customizer | Blueman, Xvfb e utilitarios exfat do perfil antigo |
| Apresentacao e midia | PDFPC, VLC, FFmpeg e OBS Studio | Shutter (captura substituida por grim/slurp); Screenkey, GIMP, Audacity, RawTherapee e Hugin |
| Utilitarios do setup | Scripts gerais em `~/.scripts`; perfis de tema, layout e GPU por menus | htop-vim, Vim Stream, `sl`, `figlet`, `toilet` e `indicator-multiload` |
| Documentos | Zathura e Pandoc; o Vim continua podendo abrir `.tex` como texto | Compilador e ferramentas locais de LaTeX; o plugin vimtex continua instalado, mas nao instala TeX |
| Biblioteca | Vimiv para imagens | Papis e Elgato Stream Deck |

O ROS fica instalado por voce, fora deste repositorio. Se encontrar `/opt/ros/humble`, o shell carrega o setup do Humble no Ubuntu 22.04; no Ubuntu 24.04 procura `/opt/ros/jazzy`. A ausencia desses arquivos nao interrompe o login. Os atalhos opcionais de Gazebo continuam presentes, mas so fazem algo se voce instalar essas ferramentas separadamente.

## Instalacoes novas em relacao ao ambiente antigo

Como combinado, estas sao as adicoes explicitas do perfil, alem da substituicao de i3/urxvt:

| Adicao | Pacotes/componentes | Motivo |
| --- | --- | --- |
| Gerenciador de janelas e terminal | Nix multiusuario (bootstrap automatico quando ausente), Hyprland 0.55.4, NixGL e Cachix via Nix; Kitty via APT | Mesma versao do compositor nos dois Ubuntus e terminal acelerado por GPU |
| Bootstrap do Nix | curl e certificados CA via APT quando Nix estiver ausente; instalador oficial do Nix via HTTPS | Permite executar o perfil completo em uma instalacao limpa; configura o servico `nix-daemon` multiusuario |
| Barra e captura Wayland | Waybar, Rofi, swaylock, grim, slurp, wl-clipboard, brightnessctl, XWayland e nm-applet | Substituem i3bar, Shutter, a area de transferencia X11 e os controles de rede/tela |
| OBS no Wayland | OBS Studio via Flatpak; Flatpak, PipeWire, WirePlumber, portais XDG GTK/WLR e GStreamer | Captura de tela e janela pelo protocolo PipeWire no Wayland. O OBS documenta essa fonte como dependente de Wayland ([documentacao de captura do OBS](https://obsproject.com/kb/display-capture-sources)). |
| C++ e ROS 2 no editor | clangd e clang-format pelo APT; Node.js 22 e tmux 3.3+ pelo Nix | O plugin CoC existente no Vim inicia o servidor clangd usando Node.js; tmux moderno permite previews Kitty |
| Formatacao Python no Vim | isort, autopep8, Black e Flake8 | Atendem os comandos e as configuracoes Python do Vim mantidos |
| Previews do Ranger | Pillow, PyGObject, file, highlight, w3m, caca-utils, ExifTool, poppler-utils, atool/libarchive, 7zip, unzip, unrar-free, mediainfo, transmission-cli e odt2txt | Mantem previews de imagens, codigo, PDF, arquivos compactados, torrents, documentos e metadados de midia |
| Tema e prompt Zsh | Oh My Zsh clonado pelo perfil e zsh-syntax-highlighting via APT | Permite usar o tema agnoster ja configurado e realce de comandos |

O cache Cachix do Hyprland e configurado globalmente com `sudo`, antes de instalar o compositor, e o daemon Nix e reiniciado, se estiver ativo, para carregar a configuracao. O script nao adiciona seu usuario a `trusted-users`, pois isso concede poderes equivalentes a root no Nix. O NixGL disponibiliza wrappers Mesa, NVIDIA e NVIDIA hibrida; nenhum driver NVIDIA e instalado por este perfil. O script tambem adiciona o PPA do GRUB Customizer para mante-lo disponivel nas duas versoes do Ubuntu.

## Atalhos

O modificador principal continua sendo **Alt**; **Super/tecla Windows** conserva os atalhos que ja usavam Mod4. Alt+Enter abre Kitty, Alt+Shift+Q fecha a janela e Alt+D abre o launcher. Alt+H/J/K/L move o foco; Alt+Shift+H/J/K/L move a janela. Alt+1..0 troca entre dez workspaces e Alt+Shift+1..0 move a janela atual. Alt+N/M percorre workspaces; Alt+X move o workspace para o monitor seguinte.

Alt+F ativa tela cheia, Alt+S escolhe o layout Master, Alt+W agrupa janelas em abas, Alt+Q percorre as abas do grupo e Alt+E alterna a orientacao da divisao atual. Alt+{ ou Alt+} escolhe a direcao da proxima divisao. Alt+A move a janela para a raiz da arvore de divisao, aproximando o antigo foco do container pai. Alt+Shift+Space alterna entre flutuante e mosaico; Alt+Space alterna o foco atual/anterior. Alt+R entra no modo de redimensionamento; Enter ou Escape sai. Alt+minus abre o scratchpad e Alt+Shift+minus envia a janela atual para ele.

Alt+Shift+C recarrega a configuracao; Alt+Shift+R tambem recarrega, como alternativa ao antigo reinicio do i3. Alt+B mostra ou esconde a Waybar; Alt+Shift+G abre os controles de espacamento.

Super+D abre o launcher; Super+F ou Super+Shift+X abre o menu de energia. Super+X escolhe a GPU da sessao e exige sair e entrar novamente para aplicar. Super+C troca entre os esquemas DARK, LIGHT e GRUN. Super+L alterna entre os layouts globais Dwindle e Master e guarda a escolha para o proximo login. Super+T alterna o touchpad quando um dispositivo com nome contendo “touchpad” estiver presente.

Print seleciona uma regiao, salva PNG em `~/Pictures/Screenshots` e copia a imagem; Super+Print copia a selecao sem criar arquivo. As teclas de audio e brilho preservam os atalhos Super+F1..F8 e as teclas multimidia do teclado.

Kitty mantem Ctrl+-/+/= para tamanho da fonte, Ctrl+Shift+V para colar e as sequencias Ctrl+Shift+P e Ctrl+0..9 usadas pelo tmux. O scrollback continua em 10.000 linhas. No Ranger, `yp`, `yd` e `yn` copiam caminho, diretorio e nome para a area de transferencia Wayland; previews de imagem usam o protocolo Kitty, inclusive no tmux.

## Funcionalidades sem equivalente direto

- O modo do i3 que movimentava o ponteiro e simulava cliques pelo teclado nao foi portado, conforme sua preferencia.
- O i3-layout-manager guardava e restaurava posicoes de aplicacoes. O menu Super+L troca o layout de mosaico global, mas nao recria esses arranjos de janelas.
- O profile_manager/Epigen alternava configuracoes e scripts especificos por computador; essa troca automatica nao foi portada. Os menus de tema, layout e GPU cobrem as escolhas comuns. Os scripts gerais continuam acessiveis em `~/.scripts`.
- Os scripts de monitor dependiam de nomes e arranjos especificos de cada maquina; a sessao inclui mover o workspace ao monitor seguinte. O indicador de ping dos UAVs na rede `192.168.69.x` foi mantido na Waybar.
- O overlay Screenkey, que exibe teclas digitadas durante uma gravacao, nao esta incluido. O OBS grava a tela, mas sem esse overlay.

As outras sessoes de login instaladas, inclusive i3 se ainda estiver presente, continuam disponiveis. O instalador novo nao remove nem desinstala o ambiente atual.
