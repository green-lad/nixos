{ hostname, ... }:
let
  local_flake = ''$"path:($env.HOME)/config#${hostname}"'';
in
{
  programs.waybar = {
    enable = true;
    settings = {
      topbar = {
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%<span color='#ffcc66'><b> |</b></span>";
          format-icons = [
            " "
            "󰃞 "
            "󰃝 "
            "󰃟 "
            "󰃠 "
          ];
          on-click = "brightnessctl set 5%+";
          on-click-middle = "brightnessctl set 100%";
          on-click-right = "brightnessctl set 5%-";
          reverse-scrolling = true;
          smooth-scrolling-threshold = 1;
        };
        battery = {
          format = "{icon} {capacity}%<span color='#ffcc66'><b> |</b></span>";
          format-icons = {
            charging = [
              "󰢟"
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
            discharging = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            full = [
              "󰁹"
            ];
            plugged = [
              "󰂄"
            ];
          };
        };
        bluetooth = {
          format = "<span>  </span>";
          format-off = "<span color='#CCCCCC'> 󰂳 </span>";
          format-disabled = "<span color='#CCCCCC'> 󰂲 </span>";
          on-click = "rfkill toggle bluetooth";
          on-click-right = "wezterm -e bluetoothctl";
          tooltip-format = "{controller_alias}	{controller_address}";
          tooltip-format-connected = "{controller_alias}	{controller_address}
      
              {device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}	{device_address}";
          tooltip-format-off = "powered off";
          tooltip-format-disabled = "disabled";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        clock = {
          actions = {
            on-click-right = "mode";
            on-scroll-down = "shift_down";
            on-scroll-up = "shift_up";
          };
          calendar = {
            format = {
              days = "<span color='#ecc6d9'>{}</span>";
              months = "<span color='#ffead3'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            };
            mode = "year";
            mode-mon-col = 3;
            on-scroll = 1;
            weeks-pos = "right";
          };
          format = "  {:%T}";
          format-alt = "  {:%a, %d %b. %Y, (%T)}";
          interval = 1;
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "  {usage}%";
          on-click = "wezterm -e htop";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/apps_placeholder" = {
          format = "<span color='#ffcc66'><b> 󰵆 </b></span>";
          interval = "once";
          tooltip = false;
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/connect_placeholder" = {
          format = "<span color='#ffcc66'> 󰀂 </span>";
          interval = "once";
          tooltip = false;
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/disk" = {
          exec = "${./read_zfs.nu}";
          format = " {}%";
          interval = 60;
          return-type = "json";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/gammastep" = {
          exec = ''gammastep -p 2>&1 >/dev/null | grep -o -e '[0-9]\+K' '';
          format = "󱄄 {}";
          interval = 60;
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/lock_with_suspend" = {
          format = " 󰍁 ";
          tooltip-format = "lock";
          on-click = "${./lock.nu} true";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/lock_without_suspend" = {
          format = " 󰣮 ";
          tooltip-format = "lock";
          on-click = "${./lock.nu} false";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/mail" = {
          exec = "${./get_mail_count.nu}";
          format = "{icon} {text}";
          return-type = "json";
          format-icons = {
            opened = " ";
            opened_failed = "<span color='#e27878'> </span>";
            new = " ";
            new_failed = "<span color='#e27878'> </span>";
          };
          on-click = "wezterm -e neomutt";
          on-click-middle = "mbsync -a";
          on-click-right = "mbsync -a";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/niri_overview" = {
          format = "<span color='#ffcc66'>   󰕯 </span>";
          tooltip-format = "toggle niri overview";
          on-click = "niri msg action toggle-overview";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/opener_power" = {
          format = "<span color='#ffcc66'>    </span>";
          tooltip-format = "powermenu";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/opener_lock" = {
          format = "<span color='#ffcc66'> 󰣯 </span>";
          tooltip-format = "lockmenu";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/opener_nix_build" = {
          format = "<span color='#ffcc66'> 󱄅 </span>";
          tooltip-format = "nix_build_menu";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/opener_hardware" = {
          format = "<span color='#ffcc66'>  </span>";
          tooltip-format = "hardware_menu";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/power" = {
          format = "   ";
          tooltip-format = "power off";
          on-click = "shutdown now";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/quit" = {
          format = " 󰗼 ";
          tooltip-format = "quit niri";
          on-click = "niri msg action quit";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/reboot" = {
          format = " 󰜉 ";
          tooltip-format = "reboot";
          on-click = "reboot";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/rebuild-home-manager" = {
          format = "  ";
          tooltip-format = "rebuild home-manager";
          on-click = "wezterm -e -- ${./repl.nu} 'home-manager switch --flake ${local_flake}' $( ${./rebuild_check_send_mail.nu} false true )";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/rebuild-nixos" = {
          format = "  ";
          tooltip-format = "rebuild nixos";
          on-click = "wezterm -e -- ${./repl.nu} 'sudo nixos-rebuild switch --flake ${local_flake}' $( ${./rebuild_check_send_mail.nu} false true )";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/rebuild-send_mail" = {
          exec = "${./rebuild_check_send_mail.nu} false false";
          interval = "once";
          format = "{}{icon}";
          return-type = "json";
          format-icons = {
            enabled = "<span color='#CCCCCC'> 󰇮 </span>";
            disabled = "<span color='#CCCCCC'> 󱏣 </span>";
          };
          on-click = "${./rebuild_check_send_mail.nu} true false";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/separator" = {
          format = "<span color='#ffcc66'><b> | </b></span>";
          interval = "once";
          tooltip = false;
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/separator_minor" = {
          format = "<span color='#AAAAAA'> | </span>";
          interval = "once";
          tooltip = false;
          on-scroll-up = "";
          on-scroll-down = "";
        };
        "custom/rfkill_wwan" = {
          exec = "${./rfkill.nu} wwan";
          format = "{}{icon}";
          return-type = "json";
          format-icons = {
            open = "<span> 󰑔 </span>";
            blocked = "<span color='#CCCCCC'> 󰻄 </span>";
          };
          on-click = "rfkill toggle wwan";
          on-scroll-up = "";
          on-scroll-down = "";
        };

        "group/connections" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/connect_placeholder"
            "bluetooth"
            "custom/separator_minor"
            "network#wlan"
            "custom/separator_minor"
            "custom/rfkill_wwan"
            "custom/separator_minor"
            "network#eth"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/apps" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/apps_placeholder"
            "wlr/taskbar"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/hardware" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/opener_hardware"
            "cpu"
            "custom/separator_minor"
            "temperature"
            "custom/separator_minor"
            "memory"
            "custom/separator_minor"
            "custom/disk"
            "custom/separator_minor"
            "custom/gammastep"
            "custom/separator_minor"
            "systemd-failed-units"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/power" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/opener_power"
            "custom/quit"
            "custom/separator_minor"
            "custom/reboot"
            "custom/separator_minor"
            "custom/power"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/build_nix" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/opener_nix_build"
            "custom/rebuild-home-manager"
            "custom/separator_minor"
            "custom/rebuild-nixos"
            "custom/separator_minor"
            "custom/rebuild-send_mail"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/lock" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/opener_lock"
            "custom/lock_without_suspend"
            "custom/separator_minor"
            "custom/lock_with_suspend"
            "custom/separator_minor"
            "idle_inhibitor"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        height = 40;
        "idle_inhibitor" = {
          format = " {icon}";
          start-activated = false;
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
          tooltip-format-activated = "swayidle inactive";
          tooltip-format-deactivated = "swayidle active";
        };
        layer = "top";
        memory = {
          format = "󰍛 {}%";
          on-click = "wezterm -e htop";
          on-scroll-up = "";
          on-scroll-down = "";
        };
        modules-center = [
          "custom/separator"
          "clock"
          "custom/separator"
        ];
        modules-left = [
          "custom/niri_overview"
          "custom/separator"
          "niri/workspaces"
          "custom/separator"
          "group/apps"
          "custom/separator"
          "niri/window"
        ];
        modules-right = [
          "custom/mail"
          "custom/separator"
          "pulseaudio"
          "custom/separator"
          "group/connections"
          "custom/separator"
          "group/hardware"
          "custom/separator"
          "battery"
          "backlight"
          "group/build_nix"
          "custom/separator"
          "group/lock"
          "custom/separator"
          "group/power"
        ];

        "network#wlan" = {
          interface = "wlan*";
          format-wifi = " 󰖩 ";
          format-disconnected = "<span color='#CCCCCC'> 󱛆 </span>";
          format-disabled = "<span color='#CCCCCC'> 󰖪 </span>";
          tooltip-format-wifi = "{ifname} {ipaddr} {essid} ({signalStrength}%)";
          tooltip-format-disconnected = "disconnected";
          tooltip-format-disabled = "disabled";
          on-click = "rfkill toggle wlan";
          on-scroll-up = "";
          on-scroll-down = "";
        };

        "network#eth" = {
          interface = "en*";
          format-ethernet = " 󰈁 ";
          format-linked = "<span color='#CCCCCC'> 󰈂 </span>";
          format-disabled = "<span color='#CCCCCC'> 󰈂 </span>";
          tooltip-format-ethernet = "{ifname} {ipaddr}";
          tooltip-format-disabled = "disabled";
          tooltip-format = "disconnected";
          on-click = "${./toggle_ethernet.nu}";
          on-scroll-up = "";
          on-scroll-down = "";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "     ";
          format-icons = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            headphone = "";
            hands-free = "";
            headset = "󰋎";
            phone = "";
            phone-muted = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
            ];
          };
          reverse-scrolling = true;
          scroll-step = 0.5;
          on-click = "wezterm -e rmpc";
          on-click-right = "wezterm -e pulsemixer";
          on-click-middle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          ignored-sinks = [
            "Easy Effects Sink"
          ];
        };

        systemd-failed-units = {
          hide-on-ok = false;
          format = "✗ {nr_failed}";
          format-ok = "✓";
          system = true;
          user = true;
          on-scroll-up = "";
          on-scroll-down = "";
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 14;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          ignore-list = [
            "org.wezfurlong.wezterm"
          ];
          on-scroll-up = "";
          on-scroll-down = "";
        };

        temperature = {
          format = "{temperatureC}°C ";
          on-scroll-up = "";
          on-scroll-down = "";
        };

        position = "top";
      };
    };
  };
}
