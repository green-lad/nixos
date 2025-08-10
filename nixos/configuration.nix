{
  config,
  pkgs,
  inputs,
  user,
  hostname,
  ...
}:
{
  imports = [
    ./harware-configuration.nix
    # ${hostname}
  ];
  nixpkgs.overlays = [ inputs.nix-your-shell.overlays.default ];

  environment = {
    # Remove unecessary preinstalled packages
    defaultPackages = [ ];
    systemPackages = with pkgs; [
      age
      home-manager
      nodejs
      sops
      xf86_input_wacom
    ];
    sessionVariables = {
      BROWSER = "librewolf";
      DIRENV_LOG_FORMAT = "";
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
      timeout = 0;
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
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
    config = {
      common = {
        default = "termfilechooser";
      };
    };
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    steam.enable = true;
    # hyprland = {
    #   enable = true;
    #   xwayland.enable = true;
    # };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    niri.enable = true;
  };

  # TODO: for miniflux use separte config file and OAUTH2 (see: https://github.com/felschr/nixos-config/blob/41307308527cdf7a352e87e2ff36d91546eb29a4/services/miniflux.nix#L12)
  users.groups.miniflux_secrets = { };

  systemd = {
    services = {
      mpd.environment = {
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      miniflux.serviceConfig.SupplementaryGroups = [ "miniflux_secrets" ];
    };
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "markus.schoetz@fau.de";
  # certs."jellyfin.nuc.link" = {
  #   listenHTTP = true;
  # };
  # };
  services = {
    mpd = {
      enable = true;
      musicDirectory = "/home/${user}/music/songs";
      user = "${user}";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "Pipewire Output"
        }
      '';
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety";
        };
        initial_session = {
          user = user;
          command = "niri-session wezterm";
        };
      };
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    ollama = {
      enable = true;
      loadModels = [
        "deepseek-r1:latest"
        "codellama:latest"
      ];
    };
    nginx = {
      enable = true;
      virtualHosts."papis.${hostname}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8888";
        };
      };
      virtualHosts."${hostname}".locations."/" = {
        root = pkgs.writeTextDir "index.html" (builtins.readFile ../home-manager/apps/librewolf/index.html);
        extraConfig = "try_files /index.html =404;";
      };
      virtualHosts."jellyfin.${hostname}.link" = {
        # useACMEHost = "jellyfin.${hostname}.link";
        # forceSSL = true;
        # kTLS = true;
        # enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          # proxyWebsockets = true;
        };
      };
    };
    miniflux = {
      enable = true;
      createDatabaseLocally = true;
      adminCredentialsFile = pkgs.writeTextFile {
        name = "miniflux.conf";
        text = ''
          ADMIN_USERNAME=${user}
          ADMIN_PASSWORD_FILE=${config.sops.secrets."miniflux/password".path}
        '';
      };
      config = {
        BASE_URL = "https://${hostname}/";
        PORT = 8002;
        FETCH_YOUTUBE_WATCH_TIME = "true";
        CERT_FILE = "${config.sops.secrets."miniflux/certificate".path}";
        KEY_FILE = "${config.sops.secrets."miniflux/key".path}";
      };
    };
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

    # xserver = {
    #   enable = true;
    #   # xkb = {
    #   #   layout = "de(us)";
    #   #   options = "eurosign:e,caps:swapescape";
    #   # };
    #   desktopManager = { xterm.enable = false; };
    #   modules = [ pkgs.xf86_input_wacom ];
    #   windowManager.i3 = { enable = true; };
    #   # displayManager = {
    #   #   startx.enable = true;
    #   # };
    # };

    # displayManager = {
    #   defaultSession = "none+i3";
    #   autoLogin = {
    #     enable = true;
    #     user = user;
    #   };
    # };

    # only used for wayland
    # kanata = {
    #   enable = true;
    #   keyboards = {
    #     internalKeyboard = {
    #       devices = [
    #         # Replace the paths below with the appropriate device paths for your setup.
    #         # Use `ls /dev/input/by-path/` to find your keyboard devices.
    #         "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    #       ];
    #       extraDefCfg = "process-unmapped-keys yes";
    #       config = ''
    #         (defsrc
    #          caps tab d h j k l ; [ ' - e
    #         )
    #         (defvar
    #          tap-time 200
    #          hold-time 200
    #         )
    #         (defalias
    #          caps (tap-hold 200 200 esc lctl)
    #          tab (tap-hold $tap-time $hold-time tab (layer-toggle arrow))
    #          del del  ;; Alias for the true delete key action

    #          ;; umlaute
    #          Ae (unicode Ä)
    #          Ue (unicode Ü)
    #          Oe (unicode Ö)
    #          ae (unicode ä)
    #          ue (unicode ü)
    #          oe (unicode ö)
    #          _ae (fork @ae @Ae (lsft rsft))
    #          _ue (fork @ue @Ue (lsft rsft))
    #          _oe (fork @oe @Oe (lsft rsft))
    #          sz (unicode ß)
    #          eu (unicode €)

    #         )
    #         (deflayer base
    #          @caps @tab d h j k l ; [ ' - e
    #         )
    #         (deflayer arrow
    #          _ _ @del left down up right @oe @ue @ae @sz @eu
    #         )
    #       '';
    #     };
    #   };
    # };
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
    settings.auto-optimise-store = true;
    settings.allowed-users = [ user ];
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
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
    modemmanager.enable = true;
    hostName = hostname;
    networkmanager = {
      enable = true;
      ensureProfiles = import ./network_profiles.nix config.sops.secrets.home_wlan.path;
    };
    # needed for zfs
    hostId = "8425e349";
    wireless.iwd.enable = true;
    nftables.ruleset = ''
      # Check out https://wiki.nftables.org/ for better documentation.
      # Table for both IPv4 and IPv6.
      table inet filter {
        # Block all incoming connections traffic except SSH and "ping".
        chain input {
          type filter hook input priority 0;

          # accept any localhost traffic
          iifname lo accept

          # accept traffic originated from us
          ct state {established, related} accept

          # ICMP
          # routers may also want: mld-listener-query, nd-router-solicit
          ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
          ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept

          # allow "ping"
          ip6 nexthdr icmpv6 icmpv6 type echo-request accept
          ip protocol icmp icmp type echo-request accept

          tcp dport {ssh,http,https} accept

          tcp dport 30000-60000 accept

          # count and drop any other traffic
          counter drop
        }

        # Allow all outgoing connections.
        chain output {
          type filter hook output priority 0;
          accept
        }

        chain forward {
          type filter hook forward priority 0;
          accept
        }
      }
    '';
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
          "wheel"
          "networkmanager"
          "adbusers"
        ];
        packages = [ ];
        openssh.authorizedKeys.keys = authorizedKeys;
      };
      root = {
        openssh.authorizedKeys.keys = authorizedKeys;
      };
    };

  # don't touch
  system.stateVersion = "24.11"; # Did you read the comment?
}
