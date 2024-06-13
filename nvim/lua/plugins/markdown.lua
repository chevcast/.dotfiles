return {
	{
		"MeanderingProgrammer/markdown.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {},
	},
	{
		"ellisonleao/glow.nvim",
		config = true,
		cmd = "Glow",
		opts = {
			border = "shadow",
			style = "dark",
			width = vim.o.columns,
			height = vim.o.lines,
			width_ratio = 0.5,
			height_ratio = 1,
		},
	},
}
