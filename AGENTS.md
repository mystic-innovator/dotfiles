# Repository Guidelines

## Project Structure & Module Organization
Configurations live at the repository root and mirror the target dotfile paths. Core files such as `.zshrc`, `.aliases`, `.exports`, `.gitconfig`, `.vimrc`, and `.config/tmux/tmux.conf` should stay in their canonical locations so that `stow` can symlink them correctly. Group new tooling under dedicated folders inside `.config/` (for example `.config/oh-my-posh/`) and keep supplemental assets—fonts, themes, snippets—in similarly named directories.

## Build, Apply, and Development Commands
- `stow .` — symlink every configuration into `$HOME`; rerun after edits to refresh links.
- `stow zsh` / `stow tmux` — apply a single module when iterating on a specific tool.
- `stow -D <module>` — remove a module’s symlinks before restructuring files to avoid orphaned links.

## Coding Style & Naming Conventions
Adopt POSIX-friendly syntax in shell scripts and alias files. Prefer lowercase, hyphenated directory names under `.config/`, and keep dot-prefixed files at the root. Use two-space indentation for shell snippets and JSON, four spaces for Vimscript blocks, and include concise comments only when a non-obvious tweak needs context. Keep proprietary or machine-specific values isolated in `~/.extra` rather than committed files.

## Testing Guidelines
Before committing, run `stow --simulate .` to confirm symlink targets, `zsh -n .zshrc` to catch syntax issues, and `tmux source-file ~/.config/tmux/tmux.conf` within an active session to validate tmux changes. For theme updates, launch a new shell to verify prompt rendering, and open Vim with `vim -u ~/.vimrc` to ensure plugins and options load without warnings.

## Commit & Pull Request Guidelines
Follow the imperative, Capitalized style visible in `git log` (e.g., “Update tmux.conf for improved plugin management”). Commits should focus on one logical tweak and include context for configuration diffs. Pull requests must explain the motivation, outline manual verification steps performed (stow, shell reload, editor check), and link any related issues. Provide before/after screenshots for prompt or UI changes when feasible.

## Security & Configuration Tips
Avoid committing secrets, tokens, or host-specific paths. Use placeholders in shared configurations and document any required environment variables in comments or the README so contributors can reproduce the setup safely.
