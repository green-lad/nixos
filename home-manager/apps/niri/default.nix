{
  config,
  pkgs,
  inputs,
  hostname,
  ...
}:
{
  imports = [
    inputs.niri-flake.homeModules.niri
    ../fuzzle
    ../waybar
  ];

  config.programs = {
    swaylock.enable = true;
    niri = {
      enable = true;
      package = pkgs.niri;
      # package = inputs.niri.packages.${pkgs.system}.niri;
      settings = {
        environment = {
          DISPLAY = ":0"; # For xwayland
          NIXOS_OZONE_WL = "1";
          QT_QPA_PLATFORM = "wayland";
        };
        hotkey-overlay = {
          skip-at-startup = true;
        };
        gestures = {
          hot-corners = {
            enable = false;
          };
        };
        input = {
          keyboard = {
            repeat-delay = 200;
            repeat-rate = 100;
            xkb = {
              layout = "de(us)";
              options = "eurosign:e,caps:swapescape";
            };
            numlock = true;
          };

          touchpad = {
            tap = true;
            natural-scroll = true;
          };
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
        };
        outputs = {
          "HDMI-A-1" = {
            scale = 1.25;
            position = {
              x = 0;
              y = 0;
            };
            backdrop-color = "#111111";
          };

          "eDP-1" = {
            scale = 1.25;
            position = {
              x = 0;
              y = 960;
            };
            backdrop-color = "#111111";

            # normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
            # transform = "normal";
          };
        };

        window-rules = [
          {
            matches = [ { is-window-cast-target = true; } ];
            border = {
              active = {
                color = "#f38ba8";
              };
              inactive = {
                color = "#7d0d2d";
              };
            };
          }
          {
            matches = [ ];
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "^float_";
              }
            ];
            open-floating = true;
          }
        ];

        layout = {
          gaps = 10;
          background-color = "#000000";
          center-focused-column = "never";
          preset-column-widths = [
            { proportion = 0.25; }
            { proportion = 0.5; }
            { proportion = 0.75; }
          ];
          preset-window-heights = [
            { proportion = 0.25; }
            { proportion = 0.5; }
            { proportion = 0.75; }
          ];

          empty-workspace-above-first = true;
          default-column-width = {
            proportion = 0.5;
          };
          default-column-display = "tabbed";
          tab-indicator = {
            hide-when-single-tab = true;
            gaps-between-tabs = 1;
            length = {
              total-proportion = 0.99;
            };
          };

          focus-ring = {
            enable = false;
          };

          border = {
            enable = true;
            width = 4;
            active = {
              color = "#7fc8ff";
            };
            inactive = {
              color = "#505050";
            };
          };

          struts = {
            left = 64;
            right = 64;
          };
        };

        spawn-at-startup = [
          {
            command = [
              "${./niri_init_layout.nu}"
            ];
          }
          { command = [ "nsticky" ]; }
          { command = [ "xwayland-satellite" ]; }
        ];

        prefer-no-csd = true;

        screenshot-path = "~/Documents/screenshots/%Y-%m-%d_%H-%M-%S.png";

        animations = {
          slowdown = 0.3;
        };

        # use wev see key names
        binds =
          with config.lib.niri.actions;
          let
            spawn_with_transition = sh_cmd: delay_ms: {
              spawn = [
                "nu"
                "-c"
                "niri msg action do-screen-transition --delay-ms ${delay_ms}; ${sh_cmd}"
              ];
            };
          in
          {
            "Mod+Shift+Slash".action = show-hotkey-overlay;

            "Mod+Shift+T" = {
              hotkey-overlay.title = "Open terminal";
              action = spawn "wezterm";
            };
            "Mod+Return" = {
              hotkey-overlay.title = "Open terminal";
              action = spawn "wezterm";
            };
            "Mod+Shift+Return" = {
              hotkey-overlay.title = "Open browser";
              action = spawn "librewolf";
            };
            "Mod+D" = {
              hotkey-overlay.title = "Open application launcher";
              action = spawn "fuzzel";
            };
            "Mod+C" = {
              hotkey-overlay.title = "Open clipboard manager";
              action = spawn_with_transition "wezterm start --class float_wezterm ${./cliphist_fzf_sixel.nu}" "200";
            };
            "Mod+N" = {
              hotkey-overlay.title = "Open music manager";
              action = spawn "wezterm" "start" "--class" "float_wezterm" "rmpc";
            };
            "Mod+B" = {
              hotkey-overlay.title = "Choose icon";
              action = spawn "${./choose_icon.nu}";
            };
            "Mod+Shift+C" = {
              hotkey-overlay.title = "Pick color";
              action = spawn "wezterm" "start" "--class" "float_wezterm" "${./pick_color.nu}";
            };
            "Mod+X" = {
              hotkey-overlay.title = "Open clipboard diff";
              action = spawn "wezterm" "start" "${./cliphist_delta.nu}";
            };
            "Super+Alt+L" = {
              hotkey-overlay.title = "Lock the Screen: swaylock";
              action = spawn "swaylock";
            };

            "XF86AudioRaiseVolume" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.05+"
              ];
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.05-"
              ];
            };
            "XF86AudioMute" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
            };
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
            };
            "XF86Display" = {
              action = spawn [
                "wdisplays"
              ];
            };
            "XF86WLAN" = {
              action = spawn [
                "rfkill"
                "toggle"
                "wwan"
              ];
            };
            "XF86NotificationCenter" = {
              action = spawn [
                "wezterm"
                "-e"
                "rmpc"
              ];
            };
            "XF86PickupPhone" = {
              allow-when-locked = true;
              action = spawn [
                "rmpc"
                "prev"
              ];
            };
            "XF86HangupPhone" = {
              allow-when-locked = true;
              action = spawn [
                "rmpc"
                "togglepause"
              ];
            };
            "XF86Favorites" = {
              allow-when-locked = true;
              action = spawn [
                "rmpc"
                "next"
              ];
            };
            "Mod+Print" = {
              allow-when-locked = true;
              action = spawn [
                "rmpc"
                "prev"
              ];
            };
            "Mod+Scroll_Lock" = {
              allow-when-locked = true;
              action = spawn [
                "rmpc"
                "togglepause"
              ];
            };
            "Mod+Pause" = {
              allow-when-locked = true;
              action = spawn [
                "rmpc"
                "next"
              ];
            };
            "Mod+Shift+Print" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.05-"
              ];
            };
            "Mod+Shift+Scroll_Lock" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
            };
            "Mod+Shift+Pause" = {
              allow-when-locked = true;
              action = spawn [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.05+"
              ];
            };
            "XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action = spawn [
                "brightnessctl"
                "set"
                "5%+"
              ];
            };
            "XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action = spawn [
                "brightnessctl"
                "set"
                "5%-"
              ];
            };
            "Shift+XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action = spawn [
                "brightnessctl"
                "set"
                "1%+"
              ];
            };
            "Shift+XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action = spawn [
                "brightnessctl"
                "set"
                "1%-"
              ];
            };

            "Mod+Alt+H".action =
              let
                local_flake = ''$"path:($env.HOME)/config#${hostname}"'';
              in
              spawn [
                "wezterm"
                "start"
                "${../waybar/repl.nu}"
                "home-manager switch --flake ${local_flake}"
              ];

            "Mod+G".action = set-dynamic-cast-window;
            "Mod+Ctrl+G".action = set-dynamic-cast-monitor;
            "Mod+Shift+G".action = clear-dynamic-cast-target;

            "Mod+O" = {
              repeat = false;
              action = toggle-overview;
            };

            "Mod+P" = {
              action = spawn [
                "wl-kbptr"
                "-o"
                "general.modes=tile,bisect,click"
                "-o"
                "mode_tile.selectable_bg_color=#0000"
                "-o"
                "mode_tile.label_color=#cccc"
                "-o"
                "mode_tile.label_symbols=abcdefghijklmnopqrstuvwxyz123"
              ];
            };

            "Mod+E" = {
              action = spawn [
                "nsticky"
                "toggle-active"
              ];
            };

            "Mod+Q".action = close-window;

            "Mod+M" = {
              repeat = false;
              hotkey-overlay.title = "Toggle waybar";
              action = spawn [
                "nu"
                "-c"
                ''if (systemctl --user is-active waybar | to text) == "active" {systemctl --user stop waybar} else {systemctl --user start waybar}''
              ];
            };
            "Mod+Z" = {
              repeat = false;
              action = spawn "${./otp.nu}";
            };
            "Mod+S" = {
              repeat = false;
              action = spawn "${./get_secret.nu}";
            };
            "Mod+Space" = {
              repeat = false;
              hotkey-overlay.title = "Search in new tab";
              action = spawn [
                "nu"
                "-c"
                ''
                  librewolf --new-tab $'https://duckduckgo.com/?q=(fuzzel -d -l 0 --placeholder "Type your search")'
                  let id = niri msg -j windows | from json | where title =~ 'LibreWolf$' | get id | get 0
                  niri msg action focus-window --id $id
                ''
              ];
            };
            "Mod+Left".action = focus-column-left;
            "Mod+Down".action = focus-window-down;
            "Mod+Up".action = focus-window-up;
            "Mod+Right".action = focus-column-right;
            "Mod+H".action = focus-column-left;
            "Mod+J".action = focus-window-or-monitor-down;
            "Mod+K".action = focus-window-or-monitor-up;
            "Mod+L".action = focus-column-right;

            "Mod+Ctrl+Left".action = move-column-left;
            "Mod+Ctrl+Down".action = move-window-down;
            "Mod+Ctrl+Up".action = move-window-up;
            "Mod+Ctrl+Right".action = move-column-right;
            "Mod+Ctrl+H".action = move-column-left;
            "Mod+Ctrl+J".action = move-window-down-or-to-workspace-down;
            "Mod+Ctrl+K".action = move-window-up-or-to-workspace-up;
            "Mod+Ctrl+L".action = move-column-right;

            "Mod+Home".action = focus-column-first;
            "Mod+End".action = focus-column-last;
            "Mod+Ctrl+Home".action = move-column-to-first;
            "Mod+Ctrl+End".action = move-column-to-last;

            "Mod+Shift+Left".action = focus-monitor-left;
            "Mod+Shift+Down".action = focus-monitor-down;
            "Mod+Shift+Up".action = focus-monitor-up;
            "Mod+Shift+Right".action = focus-monitor-right;
            "Mod+Shift+H".action = focus-monitor-left;
            "Mod+Shift+J".action = focus-monitor-down;
            "Mod+Shift+K".action = focus-monitor-up;
            "Mod+Shift+L".action = focus-monitor-right;

            "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
            "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
            "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
            "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
            "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
            "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
            "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
            "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

            "Mod+Shift+Ctrl+Alt+H".action = move-workspace-to-monitor-left;
            "Mod+Shift+Ctrl+Alt+J".action = move-workspace-to-monitor-down;
            "Mod+Shift+Ctrl+Alt+K".action = move-workspace-to-monitor-up;
            "Mod+Shift+Ctrl+Alt+L".action = move-workspace-to-monitor-right;

            "Mod+Page_Down".action = focus-workspace-down;
            "Mod+Page_Up".action = focus-workspace-up;
            "Mod+U".action = focus-workspace-down;
            "Mod+I".action = focus-workspace-up;
            "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
            "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
            "Mod+Ctrl+U".action = move-column-to-workspace-down;
            "Mod+Ctrl+I".action = move-column-to-workspace-up;

            "Mod+Shift+Page_Down".action = move-workspace-down;
            "Mod+Shift+Page_Up".action = move-workspace-up;
            "Mod+Shift+U".action = move-workspace-down;
            "Mod+Shift+I".action = move-workspace-up;

            "Mod+WheelScrollDown" = {
              cooldown-ms = 150;
              action = focus-workspace-down;
            };
            "Mod+WheelScrollUp" = {
              cooldown-ms = 150;
              action = focus-workspace-up;
            };
            "Mod+Ctrl+WheelScrollDown" = {
              cooldown-ms = 150;
              action = move-column-to-workspace-down;
            };
            "Mod+Ctrl+WheelScrollUp" = {
              cooldown-ms = 150;
              action = move-column-to-workspace-up;
            };

            "Mod+WheelScrollRight".action = focus-column-right;
            "Mod+WheelScrollLeft".action = focus-column-left;
            "Mod+Ctrl+WheelScrollRight".action = move-column-right;
            "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

            "Mod+Shift+WheelScrollDown".action = focus-column-right;
            "Mod+Shift+WheelScrollUp".action = focus-column-left;
            "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
            "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;
            "Mod+Ctrl+1".action.move-column-to-workspace = 1;
            "Mod+Ctrl+2".action.move-column-to-workspace = 2;
            "Mod+Ctrl+3".action.move-column-to-workspace = 3;
            "Mod+Ctrl+4".action.move-column-to-workspace = 4;
            "Mod+Ctrl+5".action.move-column-to-workspace = 5;
            "Mod+Ctrl+6".action.move-column-to-workspace = 6;
            "Mod+Ctrl+7".action.move-column-to-workspace = 7;
            "Mod+Ctrl+8".action.move-column-to-workspace = 8;
            "Mod+Ctrl+9".action.move-column-to-workspace = 9;

            "Mod+BracketLeft".action = consume-or-expel-window-left;
            "Mod+BracketRight".action = consume-or-expel-window-right;

            "Mod+Comma".action = consume-window-into-column;
            "Mod+Period".action = expel-window-from-column;

            "Mod+R".action = switch-preset-column-width;
            "Mod+Shift+R".action = switch-preset-window-height;
            "Mod+Ctrl+R".action = reset-window-height;
            "Mod+Ctrl+Shift+R".action = {
              spawn = [
                "nu"
                "-c"
                ''random chars -l (fuzzel -d --prompt-only "length: " | into int) | wl-copy''
              ];
            };
            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;

            "Mod+Ctrl+F".action = expand-column-to-available-width;
            "Mod+Y".action = center-column;
            "Mod+Ctrl+C".action = center-visible-columns;

            "Mod+Minus".action.set-column-width = "-10%";
            "Mod+Equal".action.set-column-width = "+10%";
            "Mod+Shift+Minus".action.set-window-height = "-10%";
            "Mod+Shift+Equal".action.set-window-height = "+10%";

            "Mod+V".action = toggle-window-floating;
            "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
            "Mod+Ctrl+Shift+F".action = toggle-windowed-fullscreen;

            "Mod+W".action = toggle-column-tabbed-display;

            "Mod+Shift+Ctrl+S".action.switch-layout = "next";
            "Mod+Ctrl+S".action.switch-layout = "prev";

            "Print" = {
              action =
                spawn "nu" "-c"
                  "niri msg action screenshot-window --id=$'(niri msg --json pick-window | from json | get id)'";
            };
            "Ctrl+Print".action.screenshot-screen = { };
            "Alt+Print".action = screenshot;

            "Mod+Escape" = {
              allow-inhibiting = false;
              action = toggle-keyboard-shortcuts-inhibit;
            };

            "Mod+Shift+E".action = quit;
            "Ctrl+Alt+Delete".action = quit;

            "Mod+Shift+P".action = power-off-monitors;
          };
      };
    };
  };

  config.home.packages = with pkgs; [
    chafa
    inputs.nsticky.packages.${system}.nsticky
    wdisplays
    wev
    wl-kbptr
    xwayland-satellite
  ];

  config.services = {
    mako.enable = true;
    swayidle =
      let
        lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
        display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
      in
      {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
          }
          {
            timeout = 330;
            command = lock;
          }
          {
            timeout = 360;
            command = display "off";
            resumeCommand = display "on";
          }
          {
            timeout = 390;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = (display "off") + "; " + lock;
          }
          {
            event = "after-resume";
            command = display "on";
          }
          {
            event = "lock";
            command = (display "off") + "; " + lock;
          }
          {
            event = "unlock";
            command = display "on";
          }
        ];
      };
    polkit-gnome.enable = true; # polkit
    cliphist = {
      enable = true;
      allowImages = true;
    };
  };
}
