local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
  'Maple Mono NF CN',
})
config.color_scheme = 'Dracula'
config.font_size = 11.0
config.scrollback_lines = 5000
config.enable_scroll_bar = true
config.window_background_opacity = 0.9

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(-3),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(3),
  },
}

config.keys = {
  -- Pass Ctrl+E through to fish/PSReadLine.
  { key = 'e', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'E', mods = 'CTRL', action = act.DisableDefaultAssignment },

  -- Tabs inherit the current pane domain and working directory.
  { key = 'A', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'h', mods = 'ALT', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'ALT', action = act.ActivateTabRelative(1) },
  { key = '[', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
  { key = ']', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },

  -- Splits inherit the current pane domain.
  { key = 'P', mods = 'ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'V', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- Vim-style pane focus.
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
}

return config
