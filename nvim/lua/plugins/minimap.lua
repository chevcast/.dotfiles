return {
	"echasnovski/mini.map",
	dependencies = {
		{ "echasnovski/mini.diff" },
		{ "lewis6991/gitsigns.nvim" },
	},
	event = "VeryLazy",
	config = function(_, opts)
		local map = require("mini.map")
		opts.integrations = {
			map.gen_integration.builtin_search(),
			map.gen_integration.diff(),
			map.gen_integration.gitsigns(),
			map.gen_integration.diagnostic(),
		}
		opts.window = {
			width = 3,
		}
		map.setup(opts)
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function()
				map.open()
			end,
		})
	end,

	-- "gorbit99/codewindow.nvim",
	-- event = "VeryLazy",
	-- opts = {
	-- 	auto_enable = true,
	-- 	minimap_width = 10,
	-- 	screen_bounds = "background",
	-- 	width_multiplier = 1,
	-- 	window_border = "none",
	-- },
	-- config = function(_, opts)
	-- 	local codewindow = require("codewindow")
	-- 	codewindow.setup(opts)
	-- 	local visual_hl = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
	-- 	local string_hl = vim.api.nvim_get_hl(0, { name = "String", link = false })
	-- 	vim.api.nvim_set_hl(0, "CodewindowBorder", {
	-- 		fg = visual_hl.bg,
	-- 	})
	-- 	-- vim.api.nvim_set_hl(0, "CodewindowBackground", { bg = rgba(0,0,0,0.5) })
	-- 	vim.api.nvim_set_hl(0, "CodewindowBoundsBackground", {
	-- 		fg = visual_hl.fg,
	-- 		bg = visual_hl.bg,
	-- 	})
	-- 	-- codewindow.apply_default_keybinds()
	-- end,
}
