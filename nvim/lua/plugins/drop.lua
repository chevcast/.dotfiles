local function pickTheme()
	-- Check if we are in a work directory.
	local filepath = vim.fn.getcwd() or ""
	if string.match(filepath, "work") then
		return {
			symbols = {
				-- work emojis
			},
			colors = {
				-- company colors
			},
		}
	else
		-- Default theme when it's not a holiday and not work.
		return {
			symbols = { "🐱", "🧔", "💻" },
			colors = { "#00ff00", "#ffff00", "#ff00ff" },
		}
	end
end

return {
	{
		"catdadcode/drop.nvim",
		lazy = false,
		enabled = false,
		opts = function(_, opts)
			local thanksgiving_day = require("drop").calculate_us_thanksgiving(os.date("%Y"))
			opts.theme = pickTheme()
			opts.holidays = {
				halloween = {
					start_date = { month = 10, day = 1 },
					end_date = { month = 10, day = 31 },
				},
				us_thanksgiving = {
					start_date = { month = 11, day = 10 },
					end_date = thanksgiving_day,
				},
				xmas = {
					start_date = { month = 12, day = 1 },
					end_date = { month = 12, day = 25 },
				},
			}
			-- opts.filetypes = { "dashboard" }
			opts.filetypes = {}
			opts.screensaver = (1000 * 60) * 20 --minutes
		end,
	},
}
