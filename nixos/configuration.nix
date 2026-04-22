{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  stylix,
  user,
  domain,
  ...
}:
{
  imports = [
    ./harware-configuration.nix
    ./hosts/${hostname}.nix
    ./sops.nix
  ];

  # some modules only support stylix in nixos (for example chromium)
  stylix = (import ../stylix.nix) pkgs;

  environment = {
    defaultPackages = [ ];
    systemPackages =
      with pkgs;
      let
        ffmpeg_with_rubberband = ffmpeg.override (old: {
          withRubberband = true;
        });
      in
      [
        age
        android-tools
        beancount
        dig
        ffmpeg_with_rubberband
        home-manager
        input-remapper
        libinput
        nmap
        nodejs
        pciutils
        rustdesk
        sops
        tk-safe
        usbutils
        zip
      ];
    sessionVariables = {
      BROWSER = "librewolf";
      DISPLAY = ":0";
      DISABLE_QT5_COMPAT = "0";
      EDITOR = "hx";
      HOST = "${hostname}";
      TERMINAL = "wezterm";
    };
    variables = {
    };
  };

  boot = {
    kernelModules = [ "uinput" ];
    loader = {
      timeout = 5;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    uinput.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
    config = {
      common = {
        default = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
      };
    };
  };

  programs = {
    dconf.enable = true;
    steam.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    niri.enable = true;
    chromium = {
      enable = true;
      # extraOpts work with /etc/chromium/policies which is why home-manager can't configure them (see: https://github.com/nix-community/home-manager/issues/3677)
      # see: https://chromeenterprise.google/policies
      extraOpts = {
        BrowserSignin = 0;
        PasswordManagerEnabled = false;
        RestoreOnStartup = 1;
        SavingBrowserHistoryDisabled = true;
        DefaultBrowserSettingEnabled = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = "DuckDuckGo";
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        SearchSuggestEnabled = false;
      };
    };
  };

  systemd = {
    services = {
      mpd.environment = {
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      ModemManager = {
        enable = lib.mkForce true;
        path = [ pkgs.libqmi ];
        wantedBy = [
          "multi-user.target"
          "network.target"
        ];
      };
    };
  };

  systemd.services.mouseless =
    let
      config_file = pkgs.writeText "mouseless_config.yaml" ''
        # the default speed for mouse movement and scrolling
        baseMouseSpeed: 1000.0
        baseScrollSpeed: 20.0

        # the rest of the config defines the layers with their bindings
        layers:
          # the first layer is active at start
          - name: initial
            bindings:
              # when tab is held and another key pressed, activate mouse layer
              tab: tap-hold-next tab ; toggle-layer mouse ; 500
          - name: moaaause
            # when true, keys that are not mapped keep their original meaning
            passThrough: true
            bindings:
              # quit mouse layer
              q: layer initial
              # keep the mouse layer active
              space: layer mouse
              l: move  1  0
              h: move -1  0
              j: move  0  1
              k: move  0 -1
              p: scroll up
              n: scroll down
              leftshift: speed 0.3
              f: button left
              d: button middle
              s: button right
      '';
    in
    {
      description = "Mouseless key remapping service";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        # ExecStartPre = "sleep 2";
        ExecStart = "${pkgs.mouseless}/bin/mouseless --config ${config_file}";
        Restart = "always";
        RestartSec = "5s";
      };
    };

  security = {
    rtkit.enable = true;
    sudo = {
      extraConfig = "%wheel ALL=(ALL) NOPASSWD: ALL";
    };
  };

  virtualisation.waydroid = {
    enable = true;
  };

  virtualisation.docker.enable = true;

  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "${hostname}".locations = {
          "/" = {
            root = pkgs.writeTextDir "index.html" (builtins.readFile ../home-manager/apps/librewolf/index.html);
            extraConfig = "try_files /index.html =404;";
          };
        };
        "${hostname}.${domain}".locations = {
          "/" = {
            root = pkgs.writeTextDir "index.html" (builtins.readFile ../home-manager/apps/librewolf/index.html);
            extraConfig = "try_files /index.html =404;";
          };
        };
      };
    };
    # jack = {
    #   jackd.enable = true;
    #   # support ALSA only programs via ALSA JACK PCM plugin
    #   alsa.enable = false;
    #   # support ALSA only programs via loopback device (supports programs like Steam)
    #   loopback = {
    #     enable = true;
    #     # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
    #     #dmixConfig = ''
    #     #  period_size 2048
    #     #'';
    #   };
    # };

    input-remapper.enable = true;

    mpd = {
      enable = true;
      user = "${user}";
      settings = {
        music_directory = "/home/${user}/music/songs";
      };
      # TODO: separate data from structure and create this via function
      # settings = ''
      #   filter {
      #     plugin "ffmpeg"
      #     name   "semitone+2"
      #     graph  "rubberband=pitch=1.12246204829593419095:tempo=1.12246204829593419095"
      #   }
      #   filter {
      #     plugin "ffmpeg"
      #     name   "semitone+4"
      #     graph  "rubberband=pitch=1.25992104986470410019:tempo=1.25992104986470410019"
      #   }
      #   filter {
      #     plugin "ffmpeg"
      #     name   "semitone+6"
      #     graph  "rubberband=pitch=1.41421356232229960378:tempo=1.41421356232229960378"
      #   }
      #   filter {
      #     plugin "ffmpeg"
      #     name   "semitone-2"
      #     graph  "rubberband=pitch=0.89089871814033931107:tempo=0.89089871814033931107"
      #   }
      #   filter {
      #     plugin "ffmpeg"
      #     name   "semitone-4"
      #     graph  "rubberband=pitch=0.79370052598409974867:tempo=0.79370052598409974867"
      #   }
      #   filter {
      #     plugin "ffmpeg"
      #     name   "semitone-6"
      #     graph  "rubberband=pitch=0.70710678118654753949:tempo=0.70710678118654753949"
      #   }

      #   audio_output {
      #     type "pipewire"
      #     name "Pipewire Output"
      #     enabled "true"
      #   }
      #   audio_output {
      #     type    "pipewire"
      #     name    "pipewire (+2 semitone)"
      #     filters "semitone+2"
      #   }
      #   audio_output {
      #     type    "pipewire"
      #     name    "pipewire (+4 semitone)"
      #     filters "semitone+4"
      #   }
      #   audio_output {
      #     type    "pipewire"
      #     name    "pipewire (+6 semitone)"
      #     filters "semitone+6"
      #   }
      #   audio_output {
      #     type    "pipewire"
      #     name    "pipewire (-2 semitone)"
      #     filters "semitone-2"
      #   }
      #   audio_output {
      #     type    "pipewire"
      #     name    "pipewire (-4 semitone)"
      #     filters "semitone-4"
      #   }
      #   audio_output {
      #     type    "pipewire"
      #     name    "pipewire (-6 semitone)"
      #     filters "semitone-6"
      #   }
      # '';
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd}/bin/agreety";
        };
        initial_session = {
          user = user;
          command = "niri-session wezterm";
        };
      };
    };
    # ollama = {
    #   enable = true;
    #   loadModels = [
    #     "deepseek-r1:latest"
    #     "codellama:latest"
    #   ];
    # };

    udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="intel_backlight", \
        RUN+="${pkgs.coreutils}/bin/chgrp users %S%p/brightness", \
        RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"
    '';

    openssh = {
      enable = true;
      #settings.PermitRootLogin = "prohibit-password";
      settings.PermitRootLogin = "yes";
    };

    libinput.enable = true;

    getty.autologinUser = user;

    printing.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;

      # source: https://github.com/TLATER/dotfiles
      # Disable the HFP bluetooth profile, because I always use external
      # microphones anyway. It sucks and sometimes devices end up caught
      # in it even if I have another microphone.
      wireplumber.extraConfig = {
        "50-bluez" = {
          "monitor.bluez.rules" = [
            {
              matches = [ { "device.name" = "~bluez_card.*"; } ];
              actions = {
                update-props = {
                  "bluez5.auto-connect" = [
                    "a2dp_sink"
                    "a2dp_source"
                  ];
                  "bluez5.hw-volume" = [
                    "a2dp_sink"
                    "a2dp_source"
                  ];
                };
              };
            }
          ];
          "monitor.bluez.properties" = {
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
            ];

            "bluez5.codecs" = [
              "ldac"
              "aptx"
              "aptx_ll_duplex"
              "aptx_ll"
              "aptx_hd"
              "opus_05_pro"
              "opus_05_71"
              "opus_05_51"
              "opus_05"
              "opus_05_duplex"
              "aac"
              "sbc_xq"
              "sbc"
            ];

            "bluez5.hfphsp-backend" = "none";
          };
        };
      };
    };
  };

  # Install fonts
  fonts = {
    packages = with pkgs; [ nerd-fonts.sauce-code-pro ];

    fontconfig = {
      hinting.autohint = true;
      defaultFonts = {
        emoji = [ "OpenMoji Color" ];
      };
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = [ user ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # cache settings
      substituters = [
        "https://binarycache.${domain}"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "binarycache.${domain}:liR8oYwic0ybpff/qRfvuHJHhqxeFlF2Vz0Oxc/oXbs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  networking = {
    firewall = {
      enable = false;
      logRefusedPackets = true;
      allowedTCPPorts = [
        53
        80
        443
        5230
        5232
        8096
      ];
    };
    modemmanager = {
      enable = true;
      fccUnlockScripts = [
        rec {
          id = "2c7c:030a";
          path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/${id}";
        }
      ];
    };
    hostName = hostname;
    networkmanager = {
      enable = true;
      ensureProfiles = import ./network_profiles.nix config.sops.secrets.network_keys.path;
      dispatcherScripts = [
        {
          source = pkgs.writeText "write_network_info" ''
            #!/usr/bin/env -S ${pkgs.nushell}/bin/nu

            def main [interface, action] {
              let file = "/var/network.json"
              let old = if ($file | path exists) {
                open $file
              } else {
                {}
              }
              if ($old | get -o $interface | is-empty) {
                $old | insert $interface $action | save -f $file
              } else {
                $old | update $interface $action | save -f $file
              }
            }
          '';
          type = "basic";
        }
      ];
    };
    # needed for zfs
    hostId = "8425e349";
    # nftables.ruleset = ''
    #   # Check out https://wiki.nftables.org/ for better documentation.
    #   # Table for both IPv4 and IPv6.
    #   table inet filter {
    #     # Block all incoming connections traffic except SSH and "ping".
    #     chain input {
    #       type filter hook input priority 0;

    #       # accept any localhost traffic
    #       iifname lo accept

    #       # accept traffic originated from us
    #       ct state {established, related} accept

    #       # ICMP
    #       # routers may also want: mld-listener-query, nd-router-solicit
    #       ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
    #       ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept

    #       # allow "ping"
    #       ip6 nexthdr icmpv6 icmpv6 type echo-request accept
    #       ip protocol icmp icmp type echo-request accept

    #       tcp dport {ssh,http,https} accept

    #       tcp dport 30000-60000 accept

    #       # count and drop any other traffic
    #       counter drop
    #     }

    #     # Allow all outgoing connections.
    #     chain output {
    #       type filter hook output priority 0;
    #       accept
    #     }

    #     chain forward {
    #       type filter hook forward priority 0;
    #       accept
    #     }
    #   }
    # '';
    # interfaces.enp0s25 = {
    #   ipv4.addresses = [{
    #     address = "10.10.10.1";
    #     prefixLength = 24;
    #   }];
    # };
  };

  users.groups.uinput = { };
  users.users =
    let
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAP46k4CU/BnDnnrXA4NZKUXm00Exc3yEyZ4J4dIFPIf markus.schoetz@fau.de" # x230
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINFEIGdKfvmy7cfhjnE6RAi2fw0qaUApBTRgTuLCI5Ji markus.schoetz@fau.de" # nuc
      ];
    in
    {
      "${user}" = {
        shell = pkgs.nushell;
        isNormalUser = true;
        hashedPassword = "$6$igRbgm5cDL1ZG0Zc$tmrJZPcQtk7sul2Zumk7XidoVta8xE4sSZvPCCmRIbyDmw7b9bx5BG6XlXUfcOVVPh/wor.YirIZ3Sw5zB.tN0";
        home = "/home/${user}";
        extraGroups = [
          "adbusers"
          "audio"
          "docker"
          "jackaudiio"
          "networkmanager"
          "wheel"
        ];
        packages = [ ];
        openssh.authorizedKeys.keys = authorizedKeys;
      };
      root = {
        shell = pkgs.nushell;
        openssh.authorizedKeys.keys = authorizedKeys;
      };
    };

  # don't touch
  system.stateVersion = "24.11"; # Did you read the comment?
}
