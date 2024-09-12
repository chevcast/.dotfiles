require("color_schemes")
require("events")
require("keymaps")
require("mousemaps")

local wezterm = require("wezterm")
local config = require("config")

-- config.color_scheme = "Tokyo Night Storm"
-- config.color_scheme = "Tokyo Night Moon"
config.color_scheme = "Tokyo Night"
-- config.color_scheme = "Catppuccin Frappe"
-- config.color_scheme = "Catppuccin Macchiato"
-- config.color_scheme = "Catppuccin Mocha"
-- config.color_scheme = "Catppuccin Pink Mocha"
-- config.color_scheme = "Gruvbox Dark Hard"

config.font_size = 14
config.font = wezterm.font_with_fallback({
	-- { family = "BigBlueTermPlus Nerd Font", weight = "Regular" },
	-- { family = "Cartograph CF", weight = "Bold" },
	{ family = "ComicShannsMono Nerd Font", weight = "Bold" },
	-- { family = "FiraCode Nerd Font", weight = "Bold" },
	-- { family = "ProggyClean Nerd Font", weight = "Regular" },
	-- { family = "ShureTechMono Nerd Font", weight = "Regular" },
	-- { family = "Terminess Nerd Font", weight = "Bold" },
	-- { family = "UbuntuMono Nerd Font", weight = "Regular" },
})

config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "BrightAndBold"
config.default_cursor_style = "BlinkingBlock"
config.enable_scroll_bar = false
config.enable_wayland = true
config.exit_behavior_messaging = "Verbose"
config.front_end = "OpenGL" -- ["OpenGL", "Software", "WebGpu"]
config.hide_mouse_cursor_when_typing = true
config.hide_tab_bar_if_only_one_tab = false
-- config.macos_window_background_blur = 0
config.max_fps = 144
config.mouse_wheel_scrolls_tabs = false
config.native_macos_fullscreen_mode = true
config.scrollback_lines = 100000
config.show_tab_index_in_tab_bar = true
config.tab_bar_at_bottom = false
config.term = "wezterm"
config.use_fancy_tab_bar = true
config.webgpu_power_preference = "HighPerformance"
config.webgpu_preferred_adapter = wezterm.gui.enumerate_gpus()[2]
config.window_background_opacity = 0.9
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE" --"INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { left = 10, right = 10, top = 25, bottom = 10 }

if wezterm.target_triple:match("windows") then
	config.default_domain = "WSL:Arch"
	config.default_cwd = "/home/catdad"
	config.win32_system_backdrop = "Disable" -- ["Auto", "Acrylic", "Mica", "Tabbed" "Disable"]
elseif wezterm.target_triple:match("darwin") then
	-- OSX Does not like to show desktop backgorund behind fullscreen apps.
	-- Set a Wezterm background image instead.
	config.background = {
		{
			source = {
				Color = "#010101",
			},
			opacity = 1.0,
			width = "100%",
			height = "100%",
		},
		{
			source = {
				File = "/Users/alexford/.dotfiles/images/catbg.png",
			},
			opacity = 0.1,
			attachment = "Fixed",
			repeat_x = "NoRepeat",
			repeat_y = "NoRepeat",
			vertical_align = "Bottom",
			horizontal_align = "Center",
			height = "Cover",
			width = "Cover",
		},
	}
end

return config
