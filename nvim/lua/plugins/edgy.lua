return {
	"folke/edgy.nvim",
	opts = function(_, opts)
		if opts.animate == nil then
			opts.animate = {}
		end
		-- Disable Edgy animations. They are annoying.
		opts.animate.enabled = false
		opts.animate.fps = 144

		-- Find the copilot-chat sidebar and adjust its default size.
		for _, element in ipairs(opts.right) do
			if element.ft == "copilot-chat" then
				element.title = "🐝 Bumblebee"
				element.size = { width = 0.5 }
			end
		end
		-- local index = 1
		-- while index <= #opts.right do
		-- 	if opts.right[index].ft == "copilot-chat" then
		-- 		table.remove(opts.right, index)
		-- 	else
		-- 		index = index + 1
		-- 	end
		-- end

		return opts
	end,
}
