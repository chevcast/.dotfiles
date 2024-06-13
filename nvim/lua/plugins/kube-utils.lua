return {
	{
		"h4ckm1n-dev/kube-utils-nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		lazy = true, -- Enable lazy loading for this plugin
		event = "VeryLazy", -- Load the plugin when Neovim starts
		opts = {},
	},
}
