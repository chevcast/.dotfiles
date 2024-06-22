return {
	-- https://github.com/lewis6991/satellite.nvim
	-- {
	-- 	"lewis6991/satellite.nvim",
	-- 	event = "LazyFile",
	-- 	dependencies = {
	-- 		{ "lewis6991/gitsigns.nvim" },
	-- 	},
	-- 	opts = {
	-- 		current_only = false,
	-- 		winblend = 50,
	-- 		zindex = 40,
	-- 		excluded_filetypes = { "dashboard" },
	-- 		handlers = {
	-- 			cursor = {
	-- 				enable = false,
	-- 				overlap = true,
	-- 				priority = 100,
	-- 			},
	-- 			search = {
	-- 				enable = true,
	-- 				overlap = true,
	-- 				priority = 100,
	-- 			},
	-- 			diagnostic = {
	-- 				enable = true,
	-- 				overlap = true,
	-- 				priority = 100,
	-- 			},
	-- 			gitsigns = {
	-- 				enable = true,
	-- 				overlap = true,
	-- 				priority = 100,
	-- 			},
	-- 			marks = {
	-- 				enable = true,
	-- 				overlap = true,
	-- 				priority = 100,
	-- 			},
	-- 			quickfix = {
	-- 				enable = true,
	-- 				overlap = true,
	-- 				priority = 100,
	-- 			},
	-- 		},
	-- 	},
	-- },

	-- https://github.com/petertriho/nvim-scrollbar
	{
		"petertriho/nvim-scrollbar",
		dependencies = {
			{ "kevinhwang91/nvim-hlslens" },
			{ "lewis6991/gitsigns.nvim" },
		},
		event = "VeryLazy",
		opts = {
			handlers = {
				cursor = true,
				diagnostic = true,
				gitsigns = true,
				handle = true,
				search = true,
			},
		},
	},

	-- https://github.com/echasnovski/mini.map
	-- {
	-- 	"echasnovski/mini.map",
	-- 	dependencies = {
	-- 		{ "echasnovski/mini.diff" },
	-- 		{ "lewis6991/gitsigns.nvim" },
	-- 	},
	-- 	event = "VeryLazy",
	-- 	config = function(_, opts)
	-- 		local map = require("mini.map")
	-- 		opts.integrations = {
	-- 			map.gen_integration.builtin_search(),
	-- 			map.gen_integration.diff(),
	-- 			map.gen_integration.gitsigns(),
	-- 			map.gen_integration.diagnostic(),
	-- 		}
	-- 		opts.window = {
	-- 			width = 10,
	-- 		}
	-- 		map.setup(opts)
	-- 		vim.api.nvim_create_autocmd("BufEnter", {
	-- 			callback = function()
	-- 				map.open()
	-- 			end,
	-- 		})
	-- 	end,
	-- },

	-- https://github.com/gorbit99/codewindow
	-- {
	-- 	"gorbit99/codewindow.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		auto_enable = true,
	-- 		minimap_width = 10,
	-- 		screen_bounds = "background",
	-- 		width_multiplier = 1,
	-- 		window_border = "none",
	-- 	},
	-- 	config = function(_, opts)
	-- 		local codewindow = require("codewindow")
	-- 		codewindow.setup(opts)
	-- 		local visual_hl = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
	-- 		local string_hl = vim.api.nvim_get_hl(0, { name = "String", link = false })
	-- 		vim.api.nvim_set_hl(0, "CodewindowBorder", {
	-- 			fg = visual_hl.bg,
	-- 		})
	-- 		-- vim.api.nvim_set_hl(0, "CodewindowBackground", { bg = rgba(0,0,0,0.5) })
	-- 		vim.api.nvim_set_hl(0, "CodewindowBoundsBackground", {
	-- 			fg = visual_hl.fg,
	-- 			bg = visual_hl.bg,
	-- 		})
	-- 		-- codewindow.apply_default_keybinds()
	-- 	end,
	-- },
}
