# Neovim Configuration (LazyVim)

A modern, AI-powered Neovim setup based on LazyVim with custom configurations for tmux integration and productivity.

## Features

### 🚀 Core Features
- **LazyVim Base**: Pre-configured modern Neovim distribution
- **LSP Support**: Built-in language servers for 20+ languages
- **Treesitter**: Advanced syntax highlighting and code understanding
- **Fuzzy Finding**: Telescope for files, buffers, and text search
- **Git Integration**: Gitsigns + vim-fugitive
- **Which-key**: Interactive keybinding hints

### 🤖 AI Coding
- **GitHub Copilot**: Intelligent code completion and suggestions
- **Copilot Chat**: Interactive AI pair programming
- **Alternative**: Codeium (completely free, uncomment in `ai-coding.lua`)

### 🎨 UI & Appearance
- **Theme**: Catppuccin Mocha (matching tmux theme)
- **Lualine**: Beautiful statusline
- **Neo-tree**: File explorer
- **Trouble**: Better diagnostics and quickfix list
- **True Color**: 24-bit RGB support for tmux

### 🔧 Tmux Integration
- **vim-tmux-navigator**: Seamless navigation between Neovim splits and tmux panes using Ctrl-hjkl
- **Clipboard**: System clipboard integration (xclip/wl-copy)
- **Terminal**: Built-in terminal with toggleterm.nvim

### 📝 Productivity
- **Auto-pairs**: Automatic bracket/quote closing
- **Surround**: Easily change surrounding characters
- **Comment**: Smart commenting with `gcc`
- **Markdown Preview**: Live preview for markdown files

## Installation

The configuration is already in your dotfiles at `.config/nvim/`. To activate:

1. **Create symlink** (if not already done):
   ```bash
   ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
   ```

2. **First launch** (plugins auto-install):
   ```bash
   nvim
   ```
   
   Wait for all plugins to install automatically.

3. **Health check**:
   ```vim
   :checkhealth
   ```

## Key Mappings

### Leader Key
The leader key is **Space**.

### Essential Keybindings

#### Navigation
- `Ctrl-h/j/k/l` - Navigate splits/panes (works with tmux!)
- `<leader>e` - Toggle file explorer
- `Ctrl-p` or `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `/` - Search in current file
- `<Esc>` - Clear search highlighting

#### Terminal
- `Ctrl-\` - Toggle terminal
- `<leader>th` - Terminal horizontal split
- `<leader>tv` - Terminal vertical split
- `Esc Esc` - Exit terminal mode

#### Editing
- `gcc` - Comment/uncomment line
- `gc` (visual) - Comment selection
- `ys` + motion + char - Surround text
- `cs` + old + new - Change surroundings
- `ds` + char - Delete surroundings
- `<leader>w` - Save file

#### LSP (Code Intelligence)
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `]d` / `[d` - Next/previous diagnostic
- `<leader>xx` - Open diagnostics (Trouble)

#### Git
- `<leader>gs` - Git status (fugitive)
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>gd` - Git diff
- `]h` / `[h` - Next/previous hunk (gitsigns)

#### AI Copilot
- `Alt-l` - Accept Copilot suggestion
- `Alt-w` - Accept word
- `Alt-]` / `Alt-[` - Next/prev suggestion
- `Ctrl-]` - Dismiss suggestion
- `<leader>aa` - Toggle Copilot Chat
- `<leader>aq` - Quick chat with Copilot

#### Which-key
Press **Space** and wait 300ms to see all available keybindings!

## Configuration Files

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/
│   │   ├── options.lua         # Vim settings (clipboard, colors, etc.)
│   │   ├── keymaps.lua         # Custom keybindings
│   │   ├── lazy.lua            # Plugin manager bootstrap
│   │   └── autocmds.lua        # Autocommands
│   └── plugins/
│       ├── tmux.lua            # Tmux integration
│       ├── ai-coding.lua       # Copilot configuration
│       ├── extras.lua          # Additional plugins
│       └── example.lua         # LazyVim starter example
```

## Customization

### Add a New Plugin

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/myplugin.lua
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({})
  end,
}
```

### Change Options

Edit `lua/config/options.lua`:

```lua
vim.opt.relativenumber = false  -- Disable relative numbers
vim.opt.colorcolumn = "120"     -- Change column marker
```

### Add Keybindings

Edit `lua/config/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Markdown preview" })
```

## Language Servers

LazyVim auto-installs language servers via Mason. To add more:

```vim
:Mason
```

Then search and install servers for your languages.

**Recommended servers** (auto-installed by LazyVim):
- Python: `pyright`, `ruff`
- JavaScript/TypeScript: `tsserver`, `eslint`
- Go: `gopls`
- Lua: `lua_ls`
- Rust: `rust_analyzer`
- JSON/YAML: `jsonls`, `yamlls`
- Bash: `bashls`
- Docker: `dockerls`

## Tmux Integration Setup

For seamless navigation between Neovim and tmux, add to your `~/.config/tmux/tmux.conf`:

```tmux
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
```

## GitHub Copilot Setup

1. **Authenticate**:
   ```vim
   :Copilot auth
   ```

2. **Check status**:
   ```vim
   :Copilot status
   ```

3. **Start coding** - suggestions appear automatically!

**Alternative: Use Codeium (Free)**

Edit `lua/plugins/ai-coding.lua` and uncomment the Codeium section, comment out Copilot.

## Troubleshooting

### Plugins not loading
```vim
:Lazy sync
```

### LSP not working
```vim
:checkhealth lsp
:Mason
```

### Copilot not working
- Ensure Node.js v18+ is installed: `node --version`
- Authenticate: `:Copilot auth`
- Check status: `:Copilot status`

### Clipboard not working
Ensure you have `xclip` or `wl-clipboard` installed:
```bash
sudo apt install xclip  # X11
sudo apt install wl-clipboard  # Wayland
```

## Learning Resources

1. **Start with basics**: See `nvim-basics-guide.md` in the artifacts
2. **Built-in tutorial**: Run `:Tutor` in Neovim
3. **Which-key**: Press Space and explore!
4. **LazyVim docs**: [lazyvim.org](https://lazyvim.org)
5. **Telescope**: Press `<leader>fh` to search help tags

## Daily Workflow

1. **Start tmux**: `tmux`
2. **Open Neovim**: `nvim`
3. **Find files**: `Ctrl-p`
4. **Search text**: `<leader>fg`
5. **Navigate**: `Ctrl-hjkl` (works across vim and tmux!)
6. **Code with AI**: Let Copilot suggest as you type
7. **Git operations**: `<leader>gs` for status
8. **Terminal**: `Ctrl-\` to toggle

## What's Next?

- [ ] Complete `:Tutor` for Vim basics
- [ ] Practice with which-key (`<Space>` + wait)
- [ ] Set up Copilot authentication
- [ ] Install language servers for your languages
- [ ] Customize colorscheme if desired
- [ ] Add project-specific configurations
- [ ] Create snippets for common patterns

Enjoy your supercharged Neovim setup! 🚀
