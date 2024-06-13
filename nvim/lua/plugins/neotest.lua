return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/neotest-plenary",
			"marilari88/neotest-vitest",
			"thenbe/neotest-playwright",
		},
		opts = function(_, opts)
			table.insert(opts.adapters, require("neotest-plenary"))
			table.insert(opts.adapters, require("neotest-vitest"))
			table.insert(
				opts.adapters,
				require("neotest-playwright").adapter({
					options = {
						persist_project_selection = true,
						enable_dynamic_test_discovery = true,
					},
				})
			)
		end,
	},
}
