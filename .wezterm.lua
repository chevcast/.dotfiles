local wezterm = require("wezterm")
local config = wezterm.config_builder()
config:set_strict_mode(true)

config.font = wezterm.font_with_fallback({
	-- { family = "BigBlueTermPlus Nerd Font", weight = "Regular" },
	-- { family = "Cartograph CF", weight = "Bold" },
	{ family = "ComicShannsMono Nerd Font", weight = "Bold" },
	-- { family = "FiraCode Nerd Font", weight = "Regular" },
	-- { family = "ProggyClean Nerd Font", weight = "Regular" },
	-- { family = "ShureTechMono Nerd Font", weight = "Regular" },
	-- { family = "Terminess Nerd Font", weight = "Bold" },
	-- { family = "UbuntuMono Nerd Font", weight = "Regular" },
})
config.font_size = 12

config.color_schemes = { ["Catppuccin Pink Mocha"] = require("catppuccin_pink_mocha") }
config.color_scheme = "Catppuccin Pink Mocha"
-- local color_scheme = config.color_schemes[config.color_scheme]
-- config.colors = {
-- 	tab_bar = color_scheme.tab_bar,
-- }

config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "BrightAndBold"
config.default_cursor_style = "BlinkingBlock"
config.enable_scroll_bar = false
config.enable_wayland = true
config.exit_behavior_messaging = "Verbose"
config.front_end = "WebGpu"
config.hide_mouse_cursor_when_typing = true
config.hide_tab_bar_if_only_one_tab = false
config.macos_window_background_blur = 50
config.max_fps = 144
config.mouse_wheel_scrolls_tabs = false
config.native_macos_fullscreen_mode = true
config.scrollback_lines = 100000
config.show_tab_index_in_tab_bar = true
config.tab_bar_at_bottom = true
config.term = "wezterm"
config.use_fancy_tab_bar = false
config.webgpu_power_preference = "HighPerformance"
config.window_close_confirmation = "NeverPrompt"
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { left = 15, right = 15, top = 15, bottom = 15 }

if wezterm.target_triple:match("windows") then
	config.default_domain = "WSL:Arch"
	config.default_cwd = "/home/catdad"
	config.win32_system_backdrop = "Disable" -- ["Auto", "Acrylic", "Mica", "Tabbed" "Disable"]
end

config.mouse_bindings = {
	-- Copy and paste with right click depending on selection.
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(wezterm.action.ClearSelection, pane)
			else
				window:perform_action(wezterm.action({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

config.keys = {
	-- Show Debug Overlay
	{ key = "D", mods = "CTRL|SHIFT|ALT", action = wezterm.action.ShowDebugOverlay },

	-- Move Tabs
	{ key = "[", mods = "CTRL|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = "]", mods = "CTRL|SHIFT", action = wezterm.action.MoveTabRelative(1) },

	-- Split panes
	{ key = "|", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigate panes
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:mux_window():active_tab()
			if tab:get_pane_direction("Left") ~= nil then
				window:perform_action(wezterm.action.ActivatePaneDirection("Left"), pane)
			else
				window:perform_action(wezterm.action.ActivateTabRelative(-1), pane)
			end
		end),
	},
	{ key = "J", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "K", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:mux_window():active_tab()
			if tab:get_pane_direction("Right") ~= nil then
				window:perform_action(wezterm.action.ActivatePaneDirection("Right"), pane)
			else
				window:perform_action(wezterm.action.ActivateTabRelative(1), pane)
			end
		end),
	},

	-- Resize panes
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },

	-- Rotate panes
	{ key = ">", mods = "CTRL|SHIFT", action = wezterm.action.RotatePanes("CounterClockwise") },
	{ key = "<", mods = "CTRL|SHIFT", action = wezterm.action.RotatePanes("Clockwise") },
}

-- Show the workspace name in the right status bar.
wezterm.on("update-right-status", function(window)
	local workspace = window:active_workspace()
	if workspace ~= "default" then
		window:set_right_status("Workspace: " .. workspace .. "   ")
	end
end)

-- Allow Neovim ZenMode to adjust Wezterm font size.
-- https://github.com/folke/zen-mode.nvim/blob/main/README.md#wezterm
-- https://github.com/wez/wezterm/discussions/2550
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

wezterm.on("format-tab-title", function(tab)
	local pane_title = tab.active_pane.title
	local user_title = tab.active_pane.user_vars.panetitle
	if user_title ~= nil and #user_title > 0 then
		pane_title = user_title
	end
	return { { Text = " " .. pane_title .. " " } }
end)

return config
