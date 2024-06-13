return {
	"Wansmer/treesj",
	event = "BufEnter",
	keys = {
		{ "<C-m>", "<CMD>TSJToggle<CR>", desc = "Toggle Inline/Block" },
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		use_default_keymaps = false,
		max_join_length = 10000,
	},
}
