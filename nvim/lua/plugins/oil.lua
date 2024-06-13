return {
	"stevearc/oil.nvim",
	-- Don't lazy load since oil is the first thing to load when invoking nvim with a directory.
	lazy = false,
	keys = {
		{ "-", "<CMD>Oil<CR>", desc = "Open File Directory", mode = "n" },
	},
	opts = {
		-- Show hidden files by default.
		view_options = {
			show_hidden = true,
		},
		-- Customize keymaps to play nice with lazyvim and other plugin keymaps.
		use_default_keymaps = false,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["s"] = "actions.select_vsplit",
			["S"] = "actions.select_split",
			["t"] = "actions.select_tab",
			["P"] = "actions.preview",
			["q"] = "actions.close",
			["R"] = "actions.refresh",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
		},
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
