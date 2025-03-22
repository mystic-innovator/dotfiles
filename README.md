
# Dotfiles Repository

This repository contains my personal configuration files (dotfiles) for Zsh, Tmux, Git, Vim, Oh My Posh, and other tools I use on a daily basis. These configurations are optimized for productivity and ease of use across different environments.

## Table of Contents
1. [Installation](#installation)
2. [File Structure](#file-structure)
3. [Included Configurations](#included-configurations)
   - [Zsh](#zsh)
   - [Git](#git)
   - [Tmux](#tmux)
   - [Oh My Posh](#oh-my-posh)
   - [Vim](#vim)
   - [Fonts](#fonts)
4. [Usage with `stow`](#usage-with-stow)
5. [Optional: `~/.extra` for Sensitive Data](#optional-extra-for-sensitive-data)
6. [License](#license)

---

## Installation

### Prerequisites
Ensure you have `stow` installed. It is a powerful symlink manager that will help you easily apply the configuration files in this repository to your system.

#### Install `stow` (if not already installed):

```bash
sudo apt-get install stow   # For Ubuntu/Debian
brew install stow           # For macOS
```

### Clone the repository

Clone this repository to your home directory or a location of your choice:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## File Structure

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
```

## Included Configurations

### Zsh
- **`.zshrc`**: Contains configurations for the Zsh shell, including custom prompt settings, aliases, and environment variables.
- **`.aliases`**: This file defines useful command shortcuts (e.g., `ll` for `ls -l`, `gs` for `git status`).
- **`.exports`**: Environment variables, such as custom `$PATH` settings, are defined here.
- **`.zimrc`**: Zim is a Zsh configuration framework, and this file manages its setup.

### Git
- **`.gitconfig`**: Includes custom Git aliases, user information, and advanced settings for diff, merge, and signing commits.

### Tmux
- **`.config/tmux/tmux.conf`**: Configuration for the Tmux terminal multiplexer, including custom key bindings, status bar settings, and behavior tweaks.

### Oh My Posh
- **`.config/oh-my-posh/zen.omp.json`**: Configuration for the Oh My Posh prompt theme, which customizes how the terminal prompt looks.

### Vim
- **`.vimrc`**: Vim editor configuration, which includes settings for syntax highlighting, line numbers, and performance tweaks.

### Fonts
- **`.fonts/`**: Contains custom fonts that can be used in terminal emulators or code editors.

## Usage with `stow`

You can easily manage and apply these dotfiles using `stow`. The `stow` command creates symbolic links to the appropriate locations in your home directory. This makes it easy to keep your dotfiles organized and under version control.

### Applying Configurations

To apply all configurations, run:

```bash
stow .
```

Or, to apply a specific configuration (e.g., just Zsh or Tmux), run:

```bash
stow zsh
stow tmux
```

This will create symlinks in your home directory for each of the specified files.

### Restoring Configurations

To remove a configuration applied by `stow`, you can simply run the following command:

```bash
stow -D zsh
```

This will remove the symlink and leave your original files untouched.

## Optional: `~/.extra` for Sensitive Data

To store sensitive information like Git credentials or to override specific settings without committing them to version control, you can create a `~/.extra` file. This file is not included in the repository to avoid accidentally committing sensitive data.

### Example `~/.extra` File

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Your Name"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="your.email@example.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions, and aliases from this repository, but it's better to fork this repository for larger modifications.
