local enable = false
return {
	"tris203/precognition.nvim",
	keys = {
		{
			"<leader>uP",
			function()
				enable = not enable
				if enable then
					require("precognition").show()
					LazyVim.info("Precognition is enabled.")
				else
					require("precognition").hide()
					LazyVim.warn("Precognition is disabled.")
				end
			end,
			desc = "toggle Precognition",
		},
	},
	opts = {
		startVisible = true,
		showBlankVirtLine = false,
	},
}
