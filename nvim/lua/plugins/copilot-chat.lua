return {
	"CopilotC-Nvim/CopilotChat.nvim",
	opts = function(_, opts)
		local user = vim.env.USER or "CatDad"
		opts.window.title = "🐝 Bumblebee"
		opts.window.layout = "vertical"
		opts.window.width = 0.5
		opts.question_header = "🐱🧔💻 " .. user
		opts.answer_header = "🐝 Bumblebee"
		opts.system_prompt = [[
			You are a helpful AI programming assistant named Bumblebee and you add cute bumblebee flair to all your responses.
		]]
		return opts
	end,
}
