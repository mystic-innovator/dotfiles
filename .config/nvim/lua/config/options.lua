-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Clipboard integration (use system clipboard)
opt.clipboard = "unnamedplus"

-- Better colors for tmux
opt.termguicolors = true

-- Persistent undo
opt.undofile = true
opt.undodir = vim.fn.expand("~/.config/nvim/undo")

-- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.number = true -- Show current line number

-- Indentation (2 spaces like your .vimrc)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true -- Unless uppercase is used

-- UI
opt.signcolumn = "yes" -- Always show sign column
opt.colorcolumn = "80" -- Show column at 80 chars (like your .vimrc)
opt.cursorline = true -- Highlight current line
opt.scrolloff = 8 -- Keep 8 lines visible above/below cursor
opt.sidescrolloff = 8

-- Splits
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right

-- Performance
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 300 -- Faster which-key

-- Folding (using treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false -- Don't fold by default

-- Disable swap files (like your .vimrc)
opt.swapfile = false
opt.backup = false
opt.writebackup = false
