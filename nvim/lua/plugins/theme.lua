return {
	-- https://github.com/catppuccin/nvim/discussions/323#discussioncomment-3952454
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 10000,
		name = "catppuccin",
		opts = {
			flavour = "mocha",
			transparent_background = false,
			color_overrides = {
				mocha = {
					text = "#F4CDE9",
					subtext1 = "#DEBAD4",
					subtext0 = "#C8A6BE",
					overlay2 = "#B293A8",
					overlay1 = "#9C7F92",
					overlay0 = "#866C7D",
					surface2 = "#705867",
					surface1 = "#5A4551",
					surface0 = "#44313B",

					base = "#352939",
					mantle = "#211924",
					crust = "#1a1016",
				},
			},
		},
	},
	-- { "Scysta/pink-panic.nvim", dependencies = { "rktjmp/lush.nvim" } },
	-- { "lalitmee/cobalt2.nvim", dependencies = { "tjdevries/colorbuddy.nvim" }, init = function() require("colorbuddy").colorscheme("cobalt2") end },
	-- { "folke/tokyonight.nvim", opts = { style = "moon" } },
	-- { "yorik1984/newpaper.nvim", opts = { style = "dark" } },
	-- { "water-sucks/darkrose.nvim" },
	-- { "xero/miasma.nvim" },
	-- { "luisiacc/the-matrix.nvim" },
	-- { "iruzo/matrix-nvim" },
	-- { "fcpg/vim-farout" },
	-- { "nikolvs/vim-sunbather" },
	-- { "Alexis12119/nightly.nvim" },
	-- { "muchzill4/doubletrouble" },
	-- { "gremble0/yellowbeans.nvim" },

	-- { "Everblush/nvim", name = "everblush" },
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 10000,
		opts = {
			contrast = "hard",
			transparent_mode = false,
		},
	},

	-- Configure LazyVim to load gruvbox.
	{ "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
