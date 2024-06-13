return {
	-- {
	-- 	"subnut/nvim-ghost.nvim",
	-- 	enabled = not vim.g.started_by_firenvim,
	-- 	event = "VeryLazy",
	-- },
	{
		"glacambre/firenvim",
		lazy = not vim.g.started_by_firenvim,
		priority = 100,
		build = function()
			vim.fn["firenvim#install"](0)
		end,
		init = function()
			vim.g.firenvim_config = {
				localSettings = {
					[".*"] = {
						cmdline = "neovim",
						takeover = "never",
					},
				},
			}
		end,
		config = function()
			vim.api.nvim_create_autocmd("UIEnter", {
				callback = function()
					vim.fn.timer_start(1000, function()
						vim.opt.expandtab = true
						vim.opt.lines = 20
						vim.opt.scrolloff = 3
						vim.opt.shiftwidth = 4
						vim.opt.tabstop = 4
						vim.opt.wrap = true

						vim.diagnostic.enable(false)
						vim.g.autoformat = false
					end)
				end,
			})
		end,
	},
}
