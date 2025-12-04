-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Terminal mode: Easy escape (double Esc to exit terminal mode)
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Terminal: Open in splits (like tmux)
map("n", "<leader>th", ":split | terminal<CR>", { desc = "Terminal horizontal split" })
map("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Terminal vertical split" })
map("n", "<leader>tt", ":terminal<CR>", { desc = "Terminal in current buffer" })

-- Quick save (like :w from your .vimrc habits)
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })

-- Better window navigation (Ctrl-hjkl already set by LazyVim)
-- NOTE: vim-tmux-navigator plugin will make these work seamlessly with tmux

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Keep search results centered
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Better paste (don't lose clipboard content when pasting over selection)
map("x", "<leader>p", '"_dP', { desc = "Paste without losing clipboard" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Quick list navigation
map("n", "<leader>j", ":cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<leader>k", ":cprev<CR>zz", { desc = "Previous quickfix item" })

-- Clear search highlighting
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlighting" })
