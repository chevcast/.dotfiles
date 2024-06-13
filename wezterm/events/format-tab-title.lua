local wezterm = require("wezterm")

wezterm.on("format-tab-title", function(tab)
	local pane_title = tab.active_pane.title
	local user_title = tab.active_pane.user_vars.panetitle
	if user_title ~= nil and #user_title > 0 then
		pane_title = user_title
	end
	return { { Text = " " .. pane_title .. " " } }
end)
