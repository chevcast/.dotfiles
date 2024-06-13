return {
	-- First disable built-in mini.pairs.
	{
		"echasnovski/mini.pairs",
		enabled = false,
	},
	-- Enable nvim-autopairs instead.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
}
