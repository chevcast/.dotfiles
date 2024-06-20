return {
	"echasnovski/mini.files",
	optional = true,
	keys = function()
		return {
			{
				"<leader>m",
				function()
					require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
				end,
				desc = "Open mini.files (Directory of Current File)",
			},
			{
				"<leader>M",
				function()
					require("mini.files").open(vim.uv.cwd(), true)
				end,
				desc = "Open mini.files (cwd)",
			},
		}
	end,
}
