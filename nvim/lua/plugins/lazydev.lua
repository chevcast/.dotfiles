return {
	"folke/lazydev.nvim",
	opts = {
		library = {
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
			{ path = "LazyVim", words = { "LazyVim" } },
			{ path = "lazy.nvim", words = { "LazyVim" } },
			{ path = "wezterm-types", mods = { "wezterm" } },
		},
	},
}
