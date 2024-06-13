return {
	{
		"folke/zen-mode.nvim",
		event = "VeryLazy",
		dependencies = {
			"folke/twilight.nvim",
			opts = {
				context = 25,
			},
		},
		keys = {
			{
				"<leader>z",
				function()
					require("zen-mode").toggle({ window = { width = 0.9 } })
				end,
				desc = "Zen Mode",
			},
		},
		opts = {
			plugins = {
				options = {
					enabled = true,
				},
				twighlight = { enabled = true },
				wezterm = {
					enabled = true,
					font = "+6",
				},
			},
		},
	},
}
