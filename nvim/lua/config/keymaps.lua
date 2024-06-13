-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle center scrolling.
vim.keymap.set("n", "<leader>uS", function()
	vim.opt.scrolloff = 999 - vim.o.scrolloff
end, { desc = "Toggle Center Scrolling" })
