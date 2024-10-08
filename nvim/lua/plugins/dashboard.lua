return {
	"nvimdev/dashboard-nvim",
	optional = true,
	opts = function(_, opts)
		-- Find the color of strings in the current theme and use it as dashboard header color.
		local string_hl = vim.api.nvim_get_hl(0, { name = "String", link = false })
		vim.api.nvim_set_hl(0, "DashboardHeader", { fg = string_hl.fg })

		-- Define function to pick logo based on working directory.
		local function pickLogo()
			local filepath = vim.fn.getcwd() or ""
			local hostname = vim.fn.hostname() or ""
			if string.match(filepath .. hostname, "limble") then
				return [[
██╗     ██╗███╗   ███╗██████╗ ██╗     ███████╗
██║     ██║████╗ ████║██╔══██╗██║     ██╔════╝
██║     ██║██╔████╔██║██████╔╝██║     █████╗  
██║     ██║██║╚██╔╝██║██╔══██╗██║     ██╔══╝  
███████╗██║██║ ╚═╝ ██║██████╔╝███████╗███████╗
╚══════╝╚═╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚══════╝
				]]
			else
				return [[
 ██████╗██╗  ██╗███████╗██╗   ██╗
██╔════╝██║  ██║██╔════╝██║   ██║
██║     ███████║█████╗  ██║   ██║
██║     ██╔══██║██╔══╝  ╚██╗ ██╔╝
╚██████╗██║  ██║███████╗ ╚████╔╝ 
 ╚═════╝╚═╝  ╚═╝╚══════╝  ╚═══╝  
				]]
			end
		end

		-- Retrieve relevant logo and set it as dashboard header.
		local logo = pickLogo()
		logo = string.rep("\n", 5) .. logo .. "\n\n"
		opts.config.header = vim.split(logo, "\n")
	end,
}
