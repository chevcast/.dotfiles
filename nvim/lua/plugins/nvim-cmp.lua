return {
	"hrsh7th/nvim-cmp",
	optional = true,
	opts = function()
		local cmp = require("cmp")
		cmp.setup.filetype({ "text", "markdown" }, {
			sources = {
				{ name = "path" },
				{ name = "buffer" },
			},
		})
	end,
}
