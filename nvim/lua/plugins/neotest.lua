return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/neotest-plenary",
			"marilari88/neotest-vitest",
			"thenbe/neotest-playwright",
		},
		opts = {
			adapters = {
				"neotest-plenary",
				"neotest-vitest",
				"neotest-playwright",
			},
		},
	},
}
