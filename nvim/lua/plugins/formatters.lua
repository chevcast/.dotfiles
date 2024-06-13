return {
	"stevearc/conform.nvim",
	opts = function(_, opts)
		-- Custom confuration for PDK projects. Apparently they love standardjs.
		local filepath = vim.fn.getcwd() or ""
		local isPdk = string.match(filepath, "pdk")
		if isPdk then
			opts.format.lsp_fallback = false
			opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft, {
				javascript = { "standardjs" },
				typescript = { "standardjs" },
				javascriptreact = { "standardjs" },
				typescriptreact = { "standardjs" },
			})
			return opts
		end
		return opts
	end,
}
