local wezterm = require("wezterm")
local config = require("config")

local section_separators = {
	left = "",
	right = "",
	-- left = utf8.char(tonumber("25A9", 16)),
	-- right = utf8.char(tonumber("25A9", 16)),
	-- left = wezterm.nerdfonts.pl_left_hard_divider,
	-- right = wezterm.nerdfonts.pl_right_hard_divider,
}

wezterm.on("format-tab-title", function(tab)
	local pane_title = tab.active_pane.title
	local user_title = tab.active_pane.user_vars.panetitle
	if user_title ~= nil and #user_title > 0 then
		pane_title = user_title
	end
	local colors = config.color_schemes[config.color_scheme].tab_bar
	if not tab.is_active then
		return {
			{ Background = { Color = colors.active_tab.fg_color } },
			{ Foreground = { Color = colors.inactive_tab.bg_color } },
			-- { Text = " " },
			{ Text = section_separators.right },
			{ Background = { Color = colors.inactive_tab.bg_color } },
			{ Foreground = { Color = colors.inactive_tab.fg_color } },
			{ Text = " " .. pane_title .. " " },
			{ Background = { Color = colors.active_tab.fg_color } },
			{ Foreground = { Color = colors.inactive_tab.bg_color } },
			{ Text = section_separators.left },
			{ Text = " " },
		}
	end
	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = colors.active_tab.fg_color } },
		{ Foreground = { Color = colors.active_tab.bg_color } },
		-- { Text = " " },
		{ Text = section_separators.right },
		{ Background = { Color = colors.active_tab.bg_color } },
		{ Foreground = { Color = colors.active_tab.fg_color } },
		{ Text = " " .. pane_title .. " " },
		{ Background = { Color = colors.active_tab.fg_color } },
		{ Foreground = { Color = colors.active_tab.bg_color } },
		{ Text = section_separators.left },
		{ Text = " " },
	}
end)
