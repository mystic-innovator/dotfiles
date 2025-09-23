# Dotfiles Repository

This repository contains my personal configuration files (dotfiles) for Zsh, Tmux, Git, Vim, Oh My Posh, and other tools I use on a daily basis. These configurations are optimized for productivity and ease of use across different environments.

---

## Installation

### Quick Start (New Machine)
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```
2. Run the bootstrap script:
   ```bash
   ./initial-setup.sh
   ```
   The script installs required tooling (via `apt` or `brew`), copies Nerd Fonts, creates the necessary symlinks, triggers Zim/Vim/tmux plugin installs, and prints a short post-install checklist.
3. Open a fresh `zsh` session, launch `tmux`, and run `nvm install --lts` if you plan to use Node.js.

### Required Packages
The script handles installation automatically when `apt` (Debian/Ubuntu) or `brew` (macOS/Linuxbrew) is available. If you prefer manual setup, ensure the following tools are present before running the linking steps:
- **Shell & prompt**: `zsh`, `zoxide`, `curl`, `wget` (the script will download `oh-my-posh` automatically when available)
- **Terminal tooling**: `tmux`, `xclip` or `wl-clipboard` (Linux), `fzf`, `ripgrep`, `the_silver_searcher`
- **Editor support**: `vim` or `neovim`, `universal-ctags`
- **Language runtimes**: `python3`, `pipx`, `nvm` (install separately), `go` (for `goimports`), Android SDK + `openjdk-17` if you rely on the exported paths in `.zshrc`
- **Font assets**: Nerd Fonts (the script copies the bundled Meslo variants to `~/.local/share/fonts`)

If you are on another distribution, install the equivalents with your package manager, then re-run `./initial-setup.sh` to link files and set up plugins without re-installing packages.

---

## Project Structure

```plaintext
dotfiles/
├── .aliases                 # Custom shell aliases
├── .exports                 # Environment variables
├── .gitconfig               # Git configuration
├── .vimrc                   # Vim configuration
├── .wgetrc                  # Wget configuration
├── .config/
│   ├── tmux/
│   │   └── tmux.conf        # Tmux configuration
│   ├── oh-my-posh/
│   │   └── zen.omp.json     # Oh My Posh theme configuration
├── .zim/                    # Zim configuration for Zsh
│   └── zimrc                # Zim configuration file
├── .fonts/                  # Custom fonts
├── initial-setup.sh         # Bootstrap script for new machines
├── AGENTS.md                # Contributor guidelines
```

---

## Included Configurations

### Zsh
- **`.zshrc`**: Shell configuration, prompt setup, environment exports, and plugin bootstrap via Zim.
- **`.aliases`**: Useful command shortcuts (e.g., `ll` for `ls -l`, `gs` for `git status`).
- **`.exports`**: Environment variables and PATH adjustments, including Android and Java tooling.
- **`.zim/`**: Keeps Zim modules and initialization scripts synced.

### Git
- **`.gitconfig`**: Custom aliases, diffs, color settings, and preferred defaults.

### Tmux
- **`.config/tmux/tmux.conf`**: Tmux configuration, including TPM plugin setup, Catppuccin theme integration, and clipboard helpers.
- **`.config/tmux/custom_modules/`**: Catppuccin status-line modules for CPU and memory display.

### Oh My Posh
- **`.config/oh-my-posh/zen.omp.json`**: Theme definition for the terminal prompt with Git, Node, and Python segments.

### Vim
- **`.vimrc`**: Editor configuration covering indentation, search, mappings, and linting/autocomplete preferences.
- **`.vimrc.bundles`**: Plugin list managed by vim-plug (fzf, vim-test, ALE, language-specific helpers).
- **`.vim/ftplugin/`**: Filetype-specific overrides for Go, Markdown, CSS/Sass, and Git commit messages.

### Fonts & Themes
- **`.fonts/`**: Meslo Nerd Font family for terminal glyph support.
- **`.themes/`**: Additional GTK/desktop themes (e.g., Nordic darker variant).

---

## Symlink & Update Workflow

- `./initial-setup.sh` links files automatically; re-run it after pulling significant updates if you want to ensure plugins and fonts stay current.
- To refresh only the symlinks without reinstalling packages, run:
  ```bash
  ./initial-setup.sh --skip-install
  ```
- If you prefer GNU Stow, you can still run `stow --target="$HOME" .config .vim .zim .themes` and manually link the top-level dotfiles; the script is the recommended single-command approach.

---

## Docker Test Harness

To try the setup on an ephemeral Ubuntu host, use the provided Docker workflow:

```bash
./test/run.sh
```

The script builds `dotfiles-integration-test` using `test/Dockerfile`, runs `./initial-setup.sh` inside the image, and fails the build if critical symlinks or fonts are missing. After the build succeeds you can launch an interactive shell with:

```bash
docker run -it --rm dotfiles-integration-test
```

This is handy for verifying changes to `initial-setup.sh` or trying the dotfiles without touching your local machine. Docker must be available locally for the build to work.

---

## Usage with `stow`

You can still manage individual modules by hand:

```bash
stow --target="$HOME" .config
stow --target="$HOME" .vim
stow --target="$HOME" .zim
```

For standalone files (like `.zshrc` or `.gitconfig`), create the symlink manually:

```bash
ln -s "$(pwd)/.zshrc" ~/.zshrc
```

---

## Optional: `~/.extra` for Sensitive Data

To store sensitive information like Git credentials or machine-specific overrides without committing them to version control, create a `~/.extra` file. This file is sourced by `.zshrc` if present.

Example `~/.extra` file:

```bash
# Git credentials
GIT_AUTHOR_NAME="Your Name"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="your.email@example.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You can also use `~/.extra` to override environment variables, set host-specific aliases, or export API tokens without tracking them in Git.
