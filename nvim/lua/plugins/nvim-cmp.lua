return {
	"hrsh7th/nvim-cmp",
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
