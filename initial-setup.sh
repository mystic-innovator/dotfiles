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
  --skip-install   Skip package installation and only link dotfiles/plugins.
  -h, --help       Show this help message.
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
        build-essential curl fzf git neovim net-tools
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
        curl fzf git neovim oh-my-posh pipx ripgrep stow the_silver_searcher
        tmux wget zoxide zsh
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

link_item() {
  local source_path="$1"
  local target_path="$2"
  backup_existing "$target_path" "$source_path"
  ln -sfn "$source_path" "$target_path"
  info "Linked ${target_path} -> ${source_path}"
}

link_dotfiles() {
  local files=(
    .aliases
    .curlrc
    .exports
    .gitconfig
    .vimrc
    .vimrc.bundles
    .wgetrc
    .zimrc
    .zshrc
  )
  for file in "${files[@]}"; do
    local source_path="${REPO_DIR}/${file}"
    local target_path="${HOME}/${file}"
    if [ -e "$source_path" ] || [ -L "$source_path" ]; then
      link_item "$source_path" "$target_path"
    fi
  done
}

link_directories() {
  local dirs=(
    .vim
    .zim
    .themes
  )
  for dir in "${dirs[@]}"; do
    local source_path="${REPO_DIR}/${dir}"
    local target_path="${HOME}/${dir}"
    if [ -d "$source_path" ]; then
      link_item "$source_path" "$target_path"
    fi
  done

  mkdir -p "${HOME}/.config"
  for subdir in tmux oh-my-posh; do
    local source_path="${REPO_DIR}/.config/${subdir}"
    local target_path="${HOME}/.config/${subdir}"
    if [ -d "$source_path" ]; then
      link_item "$source_path" "$target_path"
    fi
  done
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
  install_fonts
  link_dotfiles
  link_directories
  bootstrap_shell_tools
  post_install_notes
  info "Initial setup completed"
}

main "$@"
