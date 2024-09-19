return {
	{
		"nvim-neotest/neotest",
		lazy = false,
		dependencies = {
			-- Actual Dependencies
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",

			-- Test Adapters
			"nvim-neotest/neotest-plenary",
			"marilari88/neotest-vitest",
			"thenbe/neotest-playwright",
		},
		opts = function(_, opts)
			opts.adapters["neotest-vitest"] = {}
			opts.adapters["neotest-playwright"] = {
				options = {
					persist_project_selection = true,
					enable_dynamic_test_discovery = true,
				},
			}
			opts.adapters["neotest-plenary"] = {}
			return opts
		end,
	},
}
