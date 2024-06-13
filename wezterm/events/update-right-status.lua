local wezterm = require("wezterm")
-- Show the workspace name in the right status bar.
wezterm.on("update-right-status", function(window)
	local workspace = window:active_workspace()
	if workspace ~= "default" then
		window:set_right_status("Workspace: " .. workspace .. "   ")
	end
end)
