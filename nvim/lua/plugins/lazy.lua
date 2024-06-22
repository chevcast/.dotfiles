return {
	"folke/lazy.nvim",
	optional = true,
	init = function()
		-- Run script on LazySync event.
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazySync",
			callback = function()
				os.execute("bun update-readme.ts")
			end,
		})
	end,
}
