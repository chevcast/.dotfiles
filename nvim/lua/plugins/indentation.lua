return {
	-- Dynamically update vim options: expandtab, shiftwidth, and tabstop, based on current buffer.
	-- Respects .editorconfig files.
	{
		"NMAC427/guess-indent.nvim",
		event = "BufEnter",
		opts = {},
	},
	-- Configure indent-blankline to coordinate with rainbow-delimiters to match indent colors with bracket colors.
	{
		"lukas-reineke/indent-blankline.nvim",
		optional = true,
		dependencies = { "HiPhish/rainbow-delimiters.nvim" },
		enabled = true,
		config = function(_, opts)
			local hooks = require("ibl.hooks")
			local ibl = require("ibl")
			local rainbow_delimiters = require("rainbow-delimiters.setup")
			rainbow_delimiters.setup({})
			opts.indent = { char = "░", tab_char = "░" }
			local rainbowDelimiterHighlight = require("rainbow-delimiters.default").highlight
			-- Rainbow Delimiters does a good job at defining a default highlight group so we just use that for IBL's highlights as well.
			opts.scope.highlight = rainbowDelimiterHighlight
			ibl.setup(opts)
			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},
}
