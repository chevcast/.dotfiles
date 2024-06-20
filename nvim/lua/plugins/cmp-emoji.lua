return {
	"hrsh7th/nvim-cmp",
	optional = true,
	dependencies = { "hrsh7th/cmp-emoji" },
	event = "VeryLazy",
	opts = function(_, opts)
		table.insert(opts.sources, { name = "emoji" })
		opts.completion.keyword_length = 0
	end,
}
