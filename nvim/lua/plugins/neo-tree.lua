return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		keys = {
			-- Remove keymaps for git and buffer explorers.
			{ "<leader>ge", false },
			{ "<leader>be", false },
		},
		opts = function(_, opts)
			-- Remove buffer and git sources.
			opts.sources = { "filesystem" }
			-- Show hidden items by default but still keep them gray.
			opts.filesystem.filtered_items = { visible = true }
			opts.filesystem.hijack_netrw_behavior = "disabled"

			return opts
		end,
	},
	{
		"folke/edgy.nvim",
		opts = function(_, opts)
			-- Remove neo-tree buffers window.
			table.remove(opts.left, 4)
			-- Remove neo-tree git window.
			table.remove(opts.left, 3)
			return opts
		end,
	},
}
