return {
	{
		"neovim/nvim-lspconfig",
		optional = true,
		opts = {
			setup = {
				-- Hack to suppress encoding error with clangd.
				clangd = function(_, opts)
					opts.capabilities.offsetEncoding = { "utf-16" }
				end,
			},
		},
	},
}
