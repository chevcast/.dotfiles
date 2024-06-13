-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_prettier_needs_config = true

vim.opt.linebreak = true
vim.opt.expandtab = false
vim.opt.formatoptions:remove({ "r", "o" })
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.scrolloff = 10
vim.opt.jumpoptions = "stack,view"
vim.opt.relativenumber = false
vim.opt.showbreak = "↪ "
vim.opt.listchars = {
	tab = " ➞ ",
	multispace = "·",
	trail = "·",
	extends = "»",
	precedes = "«",
}

vim.opt.guifont = "ComicShannsMono Nerd Font:h12"

if vim.fn.has("wsl") == 1 then
	vim.g.clipboard = {
		name = "WslClipboard",
		copy = {
			["+"] = "clip.exe",
			["*"] = "clip.exe",
		},
		paste = {
			["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
			["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
		},
		cache_enabled = 0,
	}
end
