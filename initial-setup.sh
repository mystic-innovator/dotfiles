#!/usr/bin/env bash
set -euo pipefail

# Simple log helpers
info() { printf "\033[32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[31m[ERR]\033[0m %s\n" "$*" >&2; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_MANAGER=""
SKIP_INSTALL=0
INSTALL_NEOVIM=0
: "${TZ:=Etc/UTC}"
export TZ

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-install)
        SKIP_INSTALL=1
        shift
        ;;
      --with-neovim|--with-nvim)
        INSTALL_NEOVIM=1
        shift
        ;;
      --help|-h)
        cat <<'USAGE'
Usage: ./initial-setup.sh [options]

Options:
  --skip-install    Skip package installation and only use stow to link dotfiles.
  --with-neovim     Opt-in to installing Neovim and linking LazyVim configs.
  -h, --help        Show this help message.

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
        btop build-essential curl fontconfig fzf git net-tools
        pipx python3 python3-pip ripgrep silversearcher-ag stow tmux
        universal-ctags unzip wget wl-clipboard xclip zoxide zsh
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
        btop curl fastfetch fzf git lazydocker neovim oh-my-posh pipx ripgrep stow
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

ensure_fastfetch() {
  # On mac with Homebrew this will already be installed
  if command -v fastfetch >/dev/null 2>&1; then
    return 0
  fi

  case "$PACKAGE_MANAGER" in
    apt)
      # Try installing via PPA for Ubuntu/Debian
      info "Installing fastfetch via PPA"
      local apt_cmd=(env DEBIAN_FRONTEND=noninteractive apt-get)
      if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
          apt_cmd=(sudo -E env DEBIAN_FRONTEND=noninteractive apt-get)
        else
          warn "sudo not available; skipping fastfetch installation"
          return 0
        fi
      fi
      
      # Add PPA and install
      if command -v add-apt-repository >/dev/null 2>&1; then
        if [ "$(id -u)" -ne 0 ]; then
          sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch || warn "Failed to add fastfetch PPA"
        else
          add-apt-repository -y ppa:zhangsongcui3371/fastfetch || warn "Failed to add fastfetch PPA"
        fi
        "${apt_cmd[@]}" update
        "${apt_cmd[@]}" install -y fastfetch || warn "Failed to install fastfetch from PPA"
      else
        warn "add-apt-repository not available; cannot add fastfetch PPA. Install software-properties-common first."
      fi
      ;;
    brew)
      # Already handled in install_dependencies
      brew install fastfetch || warn "Failed to install fastfetch via brew"
      ;;
    *)
      warn "No package manager detected; skipping fastfetch installation"
      ;;
  esac
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
change_default_shell() {
  if ! command -v zsh >/dev/null 2>&1; then
    warn "zsh not found; cannot change default shell"
    return 0
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"
  
  # Check if already using zsh
  if [ "$SHELL" = "$zsh_path" ]; then
    info "Default shell is already zsh"
    return 0
  fi

  # Ensure zsh is in /etc/shells
  if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
    info "Adding ${zsh_path} to /etc/shells"
    if [ "$(id -u)" -eq 0 ]; then
      echo "$zsh_path" >> /etc/shells
    elif command -v sudo >/dev/null 2>&1; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    else
      warn "Cannot add zsh to /etc/shells without sudo; run manually: echo '${zsh_path}' | sudo tee -a /etc/shells"
      return 0
    fi
  fi

  # Change default shell
  info "Changing default shell to zsh"
  if command -v chsh >/dev/null 2>&1; then
    if chsh -s "$zsh_path" 2>/dev/null; then
      info "Default shell changed to zsh (logout and login to take effect)"
    else
      warn "chsh failed; you may need to run: chsh -s ${zsh_path}"
    fi
  else
    warn "chsh not found; change shell manually with: chsh -s ${zsh_path}"
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

  # Bootstrap Neovim with LazyVim only when requested
  if [ "${INSTALL_NEOVIM:-0}" -eq 0 ]; then
    info "Skipping Neovim bootstrap (--with-neovim not set)"
  elif command -v nvim >/dev/null 2>&1; then
    info "Bootstrapping Neovim with LazyVim"
    
    # Ensure undo directory exists
    mkdir -p "${HOME}/.config/nvim/undo"
    
    # LazyVim will auto-install on first launch
    # Just create the symlink if it doesn't exist
    if [ ! -L "${HOME}/.config/nvim" ] && [ ! -d "${HOME}/.config/nvim" ]; then
      info "Creating Neovim config symlink"
      ln -sf "$(pwd)/.config/nvim" "${HOME}/.config/nvim"
    fi
    
    info "Neovim setup complete. Plugins will auto-install on first 'nvim' launch"
  else
    warn "Neovim not found; skipping nvim configuration"
  fi
}


post_install_notes() {
  cat <<'MSG'

Next steps:
  - Open a new zsh session (or run `exec zsh`) to pick up prompt and PATH tweaks.
  - Launch tmux once so TPM can finish cloning plugins.
  - If you enable Neovim (`./initial-setup.sh --with-neovim`), launch `nvim` once to pull plugins and run `:checkhealth`.
  - Verify Node.js via `nvm install --lts` and install Android tooling if required.
  - Run `stow .` in this directory to refresh symlinks after making changes.
  - Use `stow --simulate .` to preview what would be linked without making changes.
MSG
}

ensure_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    local nvim_version=$(nvim --version | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | cut -c2-)
    # LazyVim requires >= 0.10.0 (actually 0.11+ for latest, but let's check for at least 0.10)
    # Simple version check: if starts with 0.9 or 0.8, it's too old
    if [[ "$nvim_version" == 0.9.* ]] || [[ "$nvim_version" == 0.8.* ]]; then
      warn "Neovim version $nvim_version is too old for LazyVim. Upgrading..."
    else
      info "Neovim version $nvim_version detected."
      return 0
    fi
  fi

  info "Installing latest Neovim..."
  # Download AppImage
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x nvim.appimage
  
  # Move to local bin
  mkdir -p "$HOME/.local/bin"
  mv nvim.appimage "$HOME/.local/bin/nvim"
  
  # Ensure it's in path for this session
  export PATH="$HOME/.local/bin:$PATH"
  
  if command -v nvim >/dev/null 2>&1; then
    info "Neovim installed successfully: $(nvim --version | head -n1)"
  else
    warn "Failed to install Neovim"
  fi

  # Fix common LazyVim health issues
  
  # 1. Fix 'fd' not found (Ubuntu installs it as 'fdfind')
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    info "Symlinking fdfind to fd for Telescope compatibility"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  # 2. Install pynvim for Python provider support
  if command -v pip3 >/dev/null 2>&1; then
    if ! pip3 list 2>/dev/null | grep -q pynvim; then
      info "Installing pynvim for Neovim Python support"
      pip3 install --user pynvim || warn "Failed to install pynvim"
    fi
  fi
}

main() {
  parse_args "$@"
  ensure_package_manager
  if [ "$SKIP_INSTALL" -eq 0 ]; then
    install_dependencies
  else
    info "Skipping package installation (--skip-install)"
  fi

  if [ "$INSTALL_NEOVIM" -eq 1 ]; then
    ensure_neovim
  else
    info "Skipping Neovim install (--with-neovim not set)"
  fi
  ensure_oh_my_posh
  ensure_lazydocker
  ensure_fastfetch
  install_fonts
  stow_dotfiles
  change_default_shell
  bootstrap_shell_tools
  post_install_notes
  info "Initial setup completed"
}

main "$@"
