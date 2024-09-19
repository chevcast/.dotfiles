return {
	{ "nvim-neotest/neotest-plenary" },
	{ "marilari88/neotest-vitest" },
	{ "thenbe/neotest-playwright" },
	{
		"nvim-neotest/neotest",
		opts = {
			adapters = {
				"neotest-plenary",
				"neotest-playwright",
				"neotest-vitest",
			},
		},
	},
}
