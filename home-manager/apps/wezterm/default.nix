{
  config,
  inputs,
  pkgs,
  ...
}:
{
  programs.wezterm = {
    enable = true;
    # currently, font rendering is broken in the new wezterm versions https://github.com/NixOS/nixpkgs/issues/336069
    package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig = ''
        local wezterm = require("wezterm")
        local config = wezterm.config_builder()

        config.enable_kitty_keyboard=true
        -- config.color_scheme = 'iceberg-dark'
        config.font = wezterm.font({ family = "SauceCodePro Nerd Font Propo", weight = "Regular" })
        config.window_close_confirmation = "NeverPrompt"
        config.window_decorations = "NONE"
        config.automatically_reload_config = true
        config.swallow_mouse_click_on_window_focus = true
        config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

        config.use_fancy_tab_bar = false
        config.hyperlink_rules = wezterm.default_hyperlink_rules()
        table.insert(config.hyperlink_rules, {
          regex = '[/.A-Za-z0-9_-]+\\.[A-Za-z0-9-_]+(:\\d+)*(?=\\s*|$)',
          format = '$EDITOR://$0',
      	})

        wezterm.on('gui-startup', function(cmd)
          local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
          if cmd and cmd.args and string.find(cmd.args[1], "cliphist%_fzf%_sixel.nu$") then
            window:gui_window():set_config_overrides {
              font_size = 8,
            }
          end
        end)

        wezterm.on('open-uri', function(window, pane, uri)
          -- wezterm.log_info('uri: ', uri)
          local p = '$EDITOR://'
          if string.sub(uri, 1, string.len(p)) == p then
            uri = uri:gsub(p, "")
            local editor = os.getenv("EDITOR")
            pane:send_text(wezterm.shell_join_args {
                editor,
                uri,
              } .. '\r'
            )
          else
            pane:send_text(wezterm.shell_join_args {
                'xdg-open',
                uri,
              } .. '\r'
            )
          end
          return false
        end)

        config.adjust_window_size_when_changing_font_size = false
        wezterm.add_to_config_reload_watch_list("${config.xdg.configHome}/wezterm")

        config.keys = {
          -- workaround for paste not working, see https://github.com/wezterm/wezterm/issues/3968
          {
              key="v",
              mods="CTRL|SHIFT",
              action=wezterm.action_callback(function(window, pane)
                  local success, stdout = wezterm.run_child_process({"wl-paste", "--no-newline"})
                  if success then
                      pane:paste(stdout)
                  end
              end),
          },
        	{ key = "F11", action = wezterm.action.ToggleFullScreen },
        	{ key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
        	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
        	{ key = "]", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
        	{ key = "[", mods = "CTRL", action = wezterm.action.ActivateTabRelative(-1) },
        	{ key = "X", mods = "CTRL", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
        	{ key = "=", mods = "CTRL", action = wezterm.action.ResetFontSize },
        	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
        	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
        	{ key = "\\", mods = "CTRL", action = wezterm.action.ActivateCopyMode },
        	{ key = "Backspace", mods = "CTRL", action = wezterm.action.SendKey({ mods = "CTRL", key = "w" }) },

        	{ key = "n", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
        	{ key = "p", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
        	{
        		key = "Enter",
        		mods = "ALT",
        		action = wezterm.action.DisableDefaultAssignment,
        	},
        	{
        		key = "Enter",
        		mods = "SHIFT",
        		action = wezterm.action.DisableDefaultAssignment,
        	},
        }

        -- config.tab_bar_at_bottom = true

        config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│┃*…$"
        config.audible_bell = "Disabled"
        config.hide_tab_bar_if_only_one_tab = true

        return config
    '';
  };
}
