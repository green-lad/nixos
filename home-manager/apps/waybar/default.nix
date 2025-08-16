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
          format = "{icon} {percent}%";
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
          format = "{icon} {capacity}%";
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
          format = " {status}";
          format-connected = " {num_connections}";
          on-click = "wezterm -e bluetoothctl";
          tooltip-format = "{controller_alias}	{controller_address}";
          tooltip-format-connected = "{controller_alias}	{controller_address}
      
              {device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}	{device_address}";
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
        };
        "custom/apps_placeholder" = {
          format = "<span color='#ffcc66'><b> 󰵆 </b></span>";
          interval = "once";
          tooltip = false;
        };
        "custom/connect_placeholder" = {
          format = "<span color='#ffcc66'> 󰀂 </span>";
          interval = "once";
          tooltip = false;
        };
        "custom/disk" = {
          exec = "${./read_zfs.nu}";
          format = " {}%";
          interval = 60;
          return-type = "json";
        };
        "custom/gammastep" = {
          exec = ''gammastep -p 2>&1 >/dev/null | grep -o -e '[0-9]\+K' '';
          format = "󱄄 {}";
          interval = 60;
        };
        "custom/lock" = {
          format = " 󰍁 ";
          tooltip-format = "lock";
          on-click = "swaylock";
        };
        "custom/mail" = {
          exec = "${./get_mail_count.nu}";
          # exec = "/home/markus/config/home-manager/apps/waybar/get_mail_count.nu";
          format = "{icon} {}";
          return-type = "json";
          format-icons = {
            opened = " ";
            opened_failed = "<span color='#e27878'> </span>";
            new = " ";
            new_failed = "<span color='#e27878'> </span>";
          };
          on-click = "wezterm -e neomutt";
        };
        "custom/opener_music" = {
          format = "<span color='#ffcc66'>  </span>";
          tooltip-format = "musicmenu";
        };
        "custom/opener_power" = {
          format = "<span color='#ffcc66'>    </span>";
          tooltip-format = "powermenu";
        };
        "custom/opener_hardware" = {
          format = "<span color='#ffcc66'>  </span>";
          tooltip-format = "powermenu";
        };
        "custom/power" = {
          format = "   ";
          tooltip-format = "power off";
          on-click = "shutdown now";
        };
        "custom/quit" = {
          format = " 󰗼 ";
          tooltip-format = "quit niri";
          on-click = "niri msg action quit";
        };
        "custom/reboot" = {
          format = " 󰜉 ";
          tooltip-format = "reboot";
          on-click = "reboot";
        };
        "custom/rebuild-home-manager" = {
          format = "  ";
          tooltip-format = "rebuild home-manager";
          on-click = "wezterm -e -- ${./repl.nu} 'home-manager switch --flake ${local_flake}'";
        };
        "custom/rebuild-nixos" = {
          format = "  ";
          tooltip-format = "rebuild nixos";
          on-click = "wezterm -e -- ${./repl.nu} 'sudo nixos-rebuild switch --flake ${local_flake}'";
        };
        "custom/separator" = {
          format = "<span color='#ffcc66'><b> | </b></span>";
          interval = "once";
          tooltip = false;
        };
        "custom/separator_minor" = {
          format = "<span color='#AAAAAA'> | </span>";
          interval = "once";
          tooltip = false;
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
            "network"
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
            "battery"
            "custom/separator_minor"
            "cpu"
            "custom/separator_minor"
            "temperature"
            "custom/separator_minor"
            "memory"
            "custom/separator_minor"
            "custom/disk"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/music" = {
          drawer = {
            transition-left-to-right = false;
            click-to-reveal = true;
          };
          modules = [
            "custom/opener_music"
            "mpd"
            "custom/separator_minor"
            "pulseaudio"
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
            "custom/lock"
            "custom/separator_minor"
            "custom/reboot"
            "custom/separator_minor"
            "custom/power"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        "group/rebuild" = {
          drawer = {
            transition-left-to-right = false;
          };
          modules = [
            "custom/rebuild-nixos"
            "custom/rebuild-home-manager"
            "custom/separator_minor"
          ];
          orientation = "horizontal";
        };
        height = 40;
        layer = "top";
        memory = {
          format = "󰍛 {}%";
          on-click = "wezterm -e htop";
        };
        modules-center = [
          "custom/separator"
          "clock"
          "custom/separator"
        ];
        modules-left = [
          "niri/workspaces"
          "custom/separator"
          "group/apps"
          "custom/separator"
          "niri/window"
        ];
        modules-right = [
          "custom/mail"
          "custom/separator"
          "custom/gammastep"
          "custom/separator"
          "systemd-failed-units"
          "custom/separator"
          "group/music"
          "custom/separator"
          "group/connections"
          "custom/separator"
          "group/hardware"
          "custom/separator"
          "backlight"
          "custom/separator"
          "group/rebuild"
          "custom/separator"
          "group/power"
        ];
        mpd = {
          on-click = "wezterm -e rmpc";
          format = "󰎇: ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
          format-disconnected = "󰎇:  ";
          format-stopped = "󰎇:  ";
          interval = 10;
          tooltip-format = "MPD (connected)";
          tooltip-format-disconnected = "MPD (disconnected)";
        };

        network = {
          interface = "wlan0";
          format = "{ifname}";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰊗";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
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
          scroll-step = 1;
          on-click = "wezterm -e pulsemixer";
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
        };

        temperature = {
          format = "{temperatureC}°C ";
        };

        position = "top";
      };
    };
  };
}
