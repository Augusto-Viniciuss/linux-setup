# Augusto's Linux environment

| Ubuntu | Architecture | Status |
| --- | --- | --- |
| 22.04 Jammy | AMD64 | [![Jammy](https://github.com/Augusto-Viniciuss/linux-setup/actions/workflows/jammy.yml/badge.svg)](https://github.com/Augusto-Viniciuss/linux-setup/actions/workflows/jammy.yml) |
| 24.04 Noble | AMD64 | Perfil Hyprland em preparacao para teste |
| 20.04 Focal | AMD64 | Perfil antigo |

## Perfil novo: Hyprland e Kitty

O perfil para Ubuntu 22.04 e 24.04 conserva Vim, plugins, Python, tmux, Ranger, SSH e ferramentas escolhidas, e troca i3/urxvt por Hyprland/Kitty. O guia lista os aplicativos, as dependencias novas, os atalhos adaptados e os recursos sem equivalente direto: [guia de migracao e instalacao](docs/migracao-hyprland-ubuntu.md).

O comando `./install.sh` na raiz instala esse perfil novo. Se Nix ainda nao estiver instalado, o script prepara o Nix multiusuario usando o instalador oficial; depois instala as dependencias APT, Flatpak e Nix do perfil. Isso exige `sudo`, acesso a internet e systemd. O instalador nao instala nem configura ROS; Humble (22.04) ou Jazzy (24.04) so e carregado pelo shell se voce o instalar separadamente em `/opt/ros`.

## Legacy

Este repositorio tambem contem a configuracao antiga baseada em i3 e urxvt. Para executar explicitamente o instalador legado, use `./install.sh --legacy`; ele instala o conjunto antigo, incluindo aplicativos removidos do perfil novo.

# How to? -> [wiki](https://github.com/Klaxalk/linux-setup/wiki)

Refer to the project's [wiki](https://github.com/Klaxalk/linux-setup/wiki) (work in progress).

# Credits

I thank the following sources for inspiration:

* Tomáš Báča (Klaxalk), https://github.com/klaxalk
* All guys behind [thoughtbot](https://www.youtube.com/user/ThoughtbotVideo) and namely following presenters:
  * Mike Coutermarsh, https://www.youtube.com/watch?v=_NUO4JEtkDw
  * Chris Toomey, https://www.youtube.com/watch?v=wlR5gYd6um0
  * Aaron Bieber, https://www.youtube.com/watch?v=JWD1Fpdd4Pc
* Nick Nisi, https://www.youtube.com/channel/UCbNhLf99gKKXdXm0aFfQFKw
* Luke Smith, https://www.youtube.com/channel/UC2eYFnH61tmytImy1mTYvhA
* Alex Booker, https://www.youtube.com/watch?v=_kjbj-Ez1vU
* Chris Hunt, https://www.youtube.com/watch?v=9jzWDr24UHQ
* Gaël Ecorchard, https://github.com/galou

# Troubleshooting

It is possible and probable that after you update using ```git pull```, something might not work anymore.
This usually happens due to new programs, plugins, and dependencies that might not be satisfied anymore.
I suggest re-running **install.sh**, after each update.

# Disclaimer

This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.
