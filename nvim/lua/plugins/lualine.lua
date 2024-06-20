return {
	"nvim-lualine/lualine.nvim",
	optional = true,
	opts = function(_, opts)
		return vim.tbl_deep_extend("force", opts, {
			options = {
				disabled_filetypes = {
					"lazyterm",
					"dashboard",
				},
				component_separators = {
					left = "",
					right = "",
				},
				section_separators = {
					left = "",
					right = "",
				},
			},
			sections = {
				lualine_a = {
					{
						"mode",
						-- separator = {
						-- 	left = "",
						-- },
					},
				},
				lualine_z = {
					{
						"datetime",
						style = "  %I:%M:%S %p",
						-- separator = {
						-- 	right = "",
						-- },
					},
				},
			},
			winbar = {
				lualine_b = {
					{ "filename", path = 1 },
				},
				lualine_c = {
					{ "filetype" },
				},
			},
			inactive_winbar = {
				lualine_c = {
					{ "filename", path = 1 },
					{ "filetype" },
				},
			},
		})
	end,
}
