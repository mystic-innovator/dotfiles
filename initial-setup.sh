#!/usr/bin/env bash
set -euo pipefail

# Simple log helpers
info() { printf "\033[32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[31m[ERR]\033[0m %s\n" "$*" >&2; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_MANAGER=""
SKIP_INSTALL=0
: "${TZ:=Etc/UTC}"
export TZ

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-install)
        SKIP_INSTALL=1
        shift
        ;;
      --help|-h)
        cat <<'USAGE'
Usage: ./initial-setup.sh [options]

Options:
  --skip-install   Skip package installation and only use stow to link dotfiles.
  -h, --help       Show this help message.

This script installs dependencies, sets up oh-my-posh and lazydocker, installs
fonts, and uses GNU stow to symlink dotfiles from this repository to $HOME.
USAGE
        exit 0
        ;;
      *)
        warn "Unknown argument: $1"
        shift
        ;;
    esac
  done
}

ensure_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    PACKAGE_MANAGER="apt"
  elif command -v brew >/dev/null 2>&1; then
    PACKAGE_MANAGER="brew"
  else
    PACKAGE_MANAGER=""
  fi
}

install_dependencies() {
  case "$PACKAGE_MANAGER" in
    apt)
      local packages=(
        build-essential curl fontconfig fzf git neovim net-tools
        pipx python3 python3-pip ripgrep silversearcher-ag stow tmux
        universal-ctags wget wl-clipboard xclip zoxide zsh
      )
      info "Using apt-get to install base packages"
      local apt_cmd=(env DEBIAN_FRONTEND=noninteractive apt-get)
      if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
          apt_cmd=(sudo -E env DEBIAN_FRONTEND=noninteractive apt-get)
        else
          warn "sudo not available; skipping package installation"
          return 0
        fi
      fi
      "${apt_cmd[@]}" update
      "${apt_cmd[@]}" install -y "${packages[@]}"
      ;;
    brew)
      local packages=(
        curl fzf git lazydocker neovim oh-my-posh pipx ripgrep stow
        the_silver_searcher tmux wget zoxide zsh
      )
      info "Using Homebrew to install base packages"
      brew update
      brew install "${packages[@]}"
      if ! brew list --cask >/dev/null 2>&1; then
        warn "Skipping cask installations (not available in this environment)"
      fi
      ;;
    *)
      warn "No supported package manager detected. Install dependencies manually."
      return 0
      ;;
  esac
}

backup_existing() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$2" ]; then
      return 0
    fi
    local backup="${target}.bak.$(date +%s)"
    mv "$target" "$backup"
    warn "Backed up existing ${target} to ${backup}"
  fi
}

stow_dotfiles() {
  if ! command -v stow >/dev/null 2>&1; then
    warn "stow not found; cannot symlink dotfiles automatically"
    return 1
  fi

  info "Using stow to symlink dotfiles"
  cd "$REPO_DIR" || return 1
  
  # Run stow with --no-folding to avoid symlinking entire directories
  # This allows individual file management and easier updates
  if stow --no-folding --verbose=1 . 2>&1 | grep -E '(LINK|UNLINK|NOTE)'; then
    info "Dotfiles symlinked successfully via stow"
  else
    warn "stow encountered an issue (this may be normal if files are already linked)"
  fi
  
  cd - >/dev/null || true
}

ensure_oh_my_posh() {
  if command -v oh-my-posh >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl unavailable; cannot install oh-my-posh automatically"
    return 0
  fi

  local install_dir
  if [ "$(id -u)" -eq 0 ]; then
    install_dir="/usr/local/bin"
  else
    install_dir="${HOME}/.local/bin"
    mkdir -p "$install_dir"
  fi

  info "Installing oh-my-posh via upstream install script"
  local installer
  installer="$(mktemp)"
  if curl -fsSL https://ohmyposh.dev/install.sh -o "$installer"; then
    if ! bash "$installer" -d "$install_dir"; then
      warn "oh-my-posh install script reported an error"
    fi
  else
    warn "Unable to download oh-my-posh installer"
  fi
  rm -f "$installer"

  if ! command -v oh-my-posh >/dev/null 2>&1 && [ -x "${install_dir}/oh-my-posh" ]; then
    export PATH="${install_dir}:${PATH}"
  fi
}

ensure_lazydocker() {
  # On mac with Homebrew this will already be installed
  if command -v lazydocker >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl unavailable; cannot install lazydocker automatically"
    return 0
  fi

  info "Installing lazydocker via upstream install script"
  local installer
  installer="$(mktemp)"
  if curl -fsSL \
    https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \
    -o "$installer"; then
    if ! bash "$installer"; then
      warn "lazydocker install script reported an error"
    fi
  else
    warn "Unable to download lazydocker installer"
  fi
  rm -f "$installer"
}

install_fonts() {
  local fonts_dir="${HOME}/.local/share/fonts"
  if [ -d "${REPO_DIR}/.fonts" ]; then
    mkdir -p "$fonts_dir"
    local target_file
    while IFS= read -r -d '' font_file; do
      target_file="${fonts_dir}/$(basename "$font_file")"
      if [ ! -e "$target_file" ]; then
        cp "$font_file" "$target_file"
      fi
    done < <(find "${REPO_DIR}/.fonts" -type f -name '*.ttf' -print0)
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f "$fonts_dir" >/dev/null 2>&1 || warn "fc-cache reported an issue"
    fi
    info "Installed Nerd Fonts to ${fonts_dir}"
  fi
}

ensure_vim_plug() {
  local vim_plug_path="${HOME}/.vim/autoload/plug.vim"
  if [ -f "$vim_plug_path" ]; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl unavailable; cannot install vim-plug automatically"
    return 0
  fi

  info "Installing vim-plug"
  mkdir -p "${HOME}/.vim/autoload"
  if curl -fsSLo "$vim_plug_path" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    info "vim-plug installed successfully"
  else
    warn "Failed to download vim-plug"
  fi
}

bootstrap_shell_tools() {
  if command -v zsh >/dev/null 2>&1; then
    info "Bootstrapping Zim modules via zsh"
    if ! zsh -lc 'command -v zimfw >/dev/null 2>&1'; then
      warn "zimfw not yet available; sourcing .zshrc to trigger download"
    fi
    if ! zsh -lc 'export GIT_TERMINAL_PROMPT=0 ZIMFW_INSTALLER=degit; source ~/.zshrc >/dev/null 2>&1; if command -v zimfw >/dev/null 2>&1; then zimfw install && zimfw upgrade; fi'; then
      warn "zimfw install/upgrade returned an error (check network access or credentials)"
    fi

    local zim_modules=(
      zsh-completions
      zsh-autosuggestions
      zsh-history-substring-search
      zsh-syntax-highlighting
    )
    local missing_modules=()
    for module in "${zim_modules[@]}"; do
      if [ ! -d "${HOME}/.zim/modules/${module}" ]; then
        missing_modules+=("${module}")
      fi
    done
    if [ ${#missing_modules[@]} -ne 0 ]; then
      warn "Missing Zim modules: ${missing_modules[*]} (run 'zimfw install' once network access is available)"
    fi
  else
    warn "zsh not found; skipping Zim bootstrap"
  fi

  local tpm_install="${HOME}/.config/tmux/plugins/tpm/bin/install_plugins"
  if [ -x "$tpm_install" ]; then
    info "Installing tmux plugins"
    "$tpm_install" || warn "tmux plugin install encountered an issue"
  else
    warn "TPM not yet cloned; open tmux and press <prefix> + I after first launch"
  fi

  ensure_vim_plug

  if command -v vim >/dev/null 2>&1; then
    info "Installing Vim plugins"
    vim +PlugInstall +qall || warn "vim plugin installation exited with a non-zero status"
  elif command -v nvim >/dev/null 2>&1; then
    info "Installing Vim plugins via Neovim"
    nvim +PlugInstall +qall || warn "PlugInstall via Neovim exited with a non-zero status"
  else
    warn "Neither vim nor nvim found; skip plugin installation"
  fi
}

post_install_notes() {
  cat <<'MSG'

Next steps:
  - Open a new zsh session (or run `exec zsh`) to pick up prompt and PATH tweaks.
  - Launch tmux once so TPM can finish cloning plugins.
  - Verify Node.js via `nvm install --lts` and install Android tooling if required.
  - Run `stow .` in this directory to refresh symlinks after making changes.
  - Use `stow --simulate .` to preview what would be linked without making changes.
MSG
}

main() {
  parse_args "$@"
  ensure_package_manager
  if [ "$SKIP_INSTALL" -eq 0 ]; then
    install_dependencies
  else
    info "Skipping package installation (--skip-install)"
  fi
  ensure_oh_my_posh
  ensure_lazydocker
  install_fonts
  stow_dotfiles
  bootstrap_shell_tools
  post_install_notes
  info "Initial setup completed"
}

main "$@"
