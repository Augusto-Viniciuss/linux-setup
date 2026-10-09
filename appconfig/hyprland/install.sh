#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

if [ "${EUID}" -eq 0 ]; then
  printf 'Execute este script como seu usuario normal; ele usa sudo quando precisa.\n' >&2
  exit 1
fi
if ! command -v apt-get >/dev/null 2>&1 || ! command -v sudo >/dev/null 2>&1; then
  printf 'Este instalador requer Ubuntu e sudo.\n' >&2
  exit 1
fi
if ! command -v nix >/dev/null 2>&1; then
  printf 'Nix nao encontrado. Instale-o e habilite nix-command e flakes antes de continuar.\n' >&2
  printf 'Este perfil nao instala Nix nem altera a configuracao global do Nix.\n' >&2
  printf 'Instrucoes: https://nixos.org/download/\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
ubuntu_version="$(. /etc/os-release && printf '%s' "$VERSION_ID")"
case "$ubuntu_version" in
  22.04|24.04) ;;
  *) printf 'Ubuntu %s nao esta nesta configuracao (suportados: 22.04 e 24.04).\n' "$ubuntu_version" >&2; exit 1 ;;
esac
if [ "$(uname -m)" != x86_64 ]; then
  printf 'Este perfil foi preparado para Ubuntu AMD64 (x86_64).\n' >&2
  exit 1
fi

if [ ! -d "$repo_root/.git" ] && [ ! -f "$repo_root/.git" ]; then
  printf 'Clone linux-setup com Git; o perfil usa alguns submodulos selecionados.\n' >&2
  exit 1
fi

export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"

# Keep the previously selected editor and development tools, plus only the
# runtime dependencies for the Wayland session and Ranger's existing previews.
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe
sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer
sudo apt-get update

apt_packages=(
  kitty waybar rofi swaylock grim slurp wl-clipboard brightnessctl
  pulseaudio-utils pavucontrol network-manager-gnome xwayland
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr
  pipewire wireplumber dbus-user-session libnotify-bin
  fonts-inconsolata fonts-font-awesome fonts-terminus fonts-powerline
  ranger python3-pil python3-gi python3-gi-cairo
  vim-gtk3 git tig cmake cmake-curses-gui build-essential autoconf automake
  autogen pkg-config libtool libncurses-dev libc++-dev clangd clang-format
  python3 python3-dev python3-pip python3-setuptools python3-venv python3-git
  python3-isort python3-autopep8 python3-black python3-flake8
  zsh zsh-syntax-highlighting fzf silversearcher-ag ruby universal-ctags
  openssh-client openssh-server nmap net-tools autossh gparted jq tree ncdu
  iputils-ping
  flatpak vlc ffmpeg gstreamer1.0-libav gstreamer1.0-gtk3
  pdf-presenter-console zathura zathura-pdf-poppler pandoc grub-customizer
  file highlight w3m caca-utils libimage-exiftool-perl poppler-utils
  atool libarchive-tools 7zip unzip unrar-free mediainfo transmission-cli
  odt2txt
)
sudo apt-get install -y "${apt_packages[@]}"

# Download only source submodules used by this profile; the legacy full
# installer initializes many unrelated components, including removed apps.
git -C "$repo_root" submodule update --init --depth 1 -- \
  submodules/vim-plug submodules/tmuxinator submodules/vimiv

# Keep the existing image viewer without relying on an obsolete Ubuntu package.
if [ -f "$repo_root/submodules/vimiv/Makefile" ]; then
  sudo make -C "$repo_root/submodules/vimiv" install
fi

# Use one tagged Hyprland/NixGL stack and Node.js version on both Ubuntu LTSes.
nix --extra-experimental-features 'nix-command flakes' profile install nixpkgs#cachix
"$HOME/.nix-profile/bin/cachix" use hyprland
nix --extra-experimental-features 'nix-command flakes' profile install --impure github:nix-community/nixGL#nixGLIntel
nix --extra-experimental-features 'nix-command flakes' profile install --impure github:nix-community/nixGL#nixGLNvidia
nix --extra-experimental-features 'nix-command flakes' profile install --impure github:nix-community/nixGL#nixGLNvidiaBumblebee
nix --extra-experimental-features 'nix-command flakes' profile install github:hyprwm/Hyprland/v0.55.4
nix --extra-experimental-features 'nix-command flakes' profile install nixpkgs#tmux
nix --extra-experimental-features 'nix-command flakes' profile install nixpkgs#nodejs_22

tmux_conf="$HOME/.tmux.conf"
tmux_version="$("$HOME/.nix-profile/bin/tmux" -V | awk '{print $2}')"
if dpkg --compare-versions "$tmux_version" ge 3.3; then
  if [ -L "$tmux_conf" ]; then
    mv "$tmux_conf" "$tmux_conf.backup.$(date +%Y%m%d-%H%M%S)"
  elif [ -e "$tmux_conf" ] && ! cmp -s "$repo_root/appconfig/tmux/dottmux.conf" "$tmux_conf"; then
    cp -a "$tmux_conf" "$tmux_conf.backup.$(date +%Y%m%d-%H%M%S)"
  fi
  install -m 0644 "$repo_root/appconfig/tmux/dottmux.conf" "$tmux_conf"
fi

install -d "$config_home/hypr" "$config_home/kitty/themes" \
  "$config_home/waybar" "$config_home/ranger" "$config_home/zathura" \
  "$config_home/xdg-desktop-portal" "$config_home/fzf" "$HOME/.local/bin" \
  "$HOME/.local/share/linux-setup-hyprland"

backup_and_copy() {
  local source="$1" destination="$2" mode="${3:-0644}"
  if [ -L "$destination" ]; then
    mv "$destination" "$destination.backup.$(date +%Y%m%d-%H%M%S)"
  elif [ -d "$destination" ]; then
    mv "$destination" "$destination.backup.$(date +%Y%m%d-%H%M%S)"
  elif [ -e "$destination" ] && ! cmp -s "$source" "$destination"; then
    cp -a "$destination" "$destination.backup.$(date +%Y%m%d-%H%M%S)"
  fi
  install -D -m "$mode" "$source" "$destination"
}

backup_and_link() {
  local source="$1" destination="$2"
  if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
    return
  fi
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    mv "$destination" "$destination.backup.$(date +%Y%m%d-%H%M%S)"
  fi
  ln -s "$source" "$destination"
}

backup_and_copy "$repo_root/appconfig/hyprland/hyprland.lua" "$config_home/hypr/hyprland.lua"
backup_and_copy "$repo_root/appconfig/kitty/kitty.conf" "$config_home/kitty/kitty.conf"
backup_and_copy "$repo_root/appconfig/hyprland/waybar/config.jsonc" "$config_home/waybar/config.jsonc"
backup_and_copy "$repo_root/appconfig/hyprland/waybar/style.css" "$config_home/waybar/style.css"
backup_and_copy "$repo_root/appconfig/hyprland/uav-status.sh" "$config_home/waybar/uav-status.sh" 0755
backup_and_copy "$repo_root/appconfig/ranger/rc.conf_git" "$config_home/ranger/rc.conf"
backup_and_copy "$repo_root/appconfig/ranger/commands.py" "$config_home/ranger/commands.py"
backup_and_copy "$repo_root/appconfig/ranger/rifle.conf" "$config_home/ranger/rifle.conf"
backup_and_copy "$repo_root/appconfig/ranger/scope.sh" "$config_home/ranger/scope.sh" 0755
backup_and_copy "$repo_root/appconfig/zathura/zathurarc" "$config_home/zathura/zathurarc"

for theme in DARK LIGHT GRUN; do
  backup_and_copy "$repo_root/appconfig/kitty/themes/$theme.conf" "$config_home/kitty/themes/$theme.conf"
done
if [ ! -e "$config_home/kitty/current-theme.conf" ]; then
  install -m 0644 "$config_home/kitty/themes/DARK.conf" "$config_home/kitty/current-theme.conf"
fi

for helper in apply-layout.sh layout-menu.sh gpu-menu.sh apply-theme.sh theme-menu.sh toggle-touchpad.sh screenshot.sh; do
  backup_and_copy "$repo_root/appconfig/hyprland/$helper" "$config_home/hypr/$helper" 0755
done
backup_and_copy "$repo_root/appconfig/hyprland/system-menu.sh" "$config_home/hypr/system-menu.sh" 0755
backup_and_copy "$repo_root/appconfig/hyprland/start-hyprland.sh" "$HOME/.local/bin/linux-setup-start-hyprland" 0755
backup_and_copy "$repo_root/appconfig/hyprland/nixGL" "$HOME/.local/share/linux-setup-hyprland/nixGL" 0755
backup_and_copy "$repo_root/appconfig/hyprland/linux-setup-clipboard" "$HOME/.local/bin/linux-setup-clipboard" 0755
backup_and_copy "$repo_root/scripts/ros2_compile_commands.py" "$HOME/.local/bin/linux-setup-ros2-compile-commands" 0755
backup_and_copy "$repo_root/appconfig/fzf/config/fzf.zsh" "$config_home/fzf/fzf.zsh"
backup_and_copy "$repo_root/appconfig/fzf/config/fzf.bash" "$config_home/fzf/fzf.bash"

for state in 'gpu:mesa' 'layout:dwindle' 'theme:DARK'; do
  name="${state%%:*}"
  value="${state#*:}"
  if [ ! -e "$config_home/hypr/$name" ]; then
    printf '%s\n' "$value" > "$config_home/hypr/$name"
  fi
done

portal_tmp="$(mktemp)"
cat > "$portal_tmp" <<'EOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
EOF
backup_and_copy "$portal_tmp" "$config_home/xdg-desktop-portal/portals.conf"
backup_and_copy "$portal_tmp" "$config_home/xdg-desktop-portal/hyprland-portals.conf"
rm -f "$portal_tmp"

backup_and_link "$repo_root/appconfig/vim/dotvim" "$HOME/.vim"
backup_and_link "$repo_root/appconfig/vim/dotvimrc" "$HOME/.vimrc"
backup_and_link "$repo_root/scripts" "$HOME/.scripts"
git config --global merge.tool vimdiff

backup_and_link "$repo_root/appconfig/tmuxinator/dottmuxinator" "$HOME/.tmuxinator"
sudo gem install --no-document tmuxinator -v 3.0.1

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

zshrc_tmp="$(mktemp)"
printf 'export REPO_PATH=%q\n' "$repo_root" > "$zshrc_tmp"
printf 'export GIT_PATH=%q\n' "$(dirname "$repo_root")" >> "$zshrc_tmp"
cat >> "$zshrc_tmp" <<'EOF'
export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"
export LINUX_SETUP_HYPRLAND_PROFILE=1
export RUN_TMUX=true
export USE_ATHAME=false
plugins=(git tmuxinator)
source "$REPO_PATH/appconfig/zsh/dotzshrc_git"
EOF
backup_and_copy "$zshrc_tmp" "$HOME/.zshrc"
rm -f "$zshrc_tmp"

bashrc="$HOME/.bashrc"
bashrc_tmp="$(mktemp)"
if [ -f "$bashrc" ]; then
  cat "$bashrc" > "$bashrc_tmp"
fi
if ! grep -Fq '# >>> linux-setup Hyprland profile >>>' "$bashrc_tmp"; then
  {
    printf '\n# >>> linux-setup Hyprland profile >>>\n'
    printf 'export REPO_PATH=%q\n' "$repo_root"
    printf 'export GIT_PATH=%q\n' "$(dirname "$repo_root")"
    cat <<'EOF'
export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"
export LINUX_SETUP_HYPRLAND_PROFILE=1
export RUN_TMUX=false
export USE_ATHAME=false
source "$REPO_PATH/appconfig/bash/dotbashrc_git"
# <<< linux-setup Hyprland profile <<<
EOF
  } >> "$bashrc_tmp"
fi
backup_and_copy "$bashrc_tmp" "$bashrc"
rm -f "$bashrc_tmp"

vim -Nu "$repo_root/appconfig/vim/dotvimrc" -i NONE -n -es \
  --cmd "let g:user_mode = '1'" -c 'PlugInstall --sync' -c 'qa!'

if command -v zsh >/dev/null 2>&1; then
  current_login_shell="$(getent passwd "$USER" | cut -d: -f7)"
  zsh_path="$(command -v zsh)"
  if [ "$current_login_shell" != "$zsh_path" ]; then
    if ! chsh -s "$zsh_path" "$USER"; then
      printf 'Nao consegui mudar o shell de login; voce pode iniciar o Zsh com: chsh -s %s\n' "$zsh_path" >&2
    fi
  fi
fi

session_file="$(mktemp)"
cat > "$session_file" <<EOF
[Desktop Entry]
Name=Hyprland (linux-setup)
Comment=Hyprland with linux-setup key bindings
Exec="$HOME/.local/bin/linux-setup-start-hyprland"
TryExec="$HOME/.local/bin/linux-setup-start-hyprland"
Type=Application
DesktopNames=Hyprland
EOF
if [ -e /usr/share/wayland-sessions/linux-setup-hyprland.desktop ]; then
  sudo cp -a /usr/share/wayland-sessions/linux-setup-hyprland.desktop \
    "/usr/share/wayland-sessions/linux-setup-hyprland.desktop.backup.$(date +%Y%m%d-%H%M%S)"
fi
sudo install -Dm 0644 "$session_file" /usr/share/wayland-sessions/linux-setup-hyprland.desktop
rm -f "$session_file"

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user --noninteractive --assumeyes flathub com.obsproject.Studio

printf '\nConfiguracao preparada no Ubuntu %s.\n' "$ubuntu_version"
printf 'Saia e entre pela sessao "Hyprland (linux-setup)". O perfil nao instala ROS.\n'
printf 'ROS 2 Humble/Jazzy sera carregado pelo shell somente se ja estiver instalado em /opt/ros.\n'
