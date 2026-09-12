{
  config,
  hostname,
  inputs,
  pkgs,
  system,
  user,
  overlays,
  hosts,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./hosts/${hostname}.nix
    ./apps/blender
    ./apps/calibre
    ./apps/chromium
    # TODO: (30.6.26) find out how and why vesktop still uses pnpm 10.29.2 although nixpkgs vesktkop uses a different version since 29.6.26 (probably fixed in a week, but I want to understand how this works)
    # ./apps/discord
    ./apps/fzf
    ./apps/gammastep
    ./apps/git
    ./apps/helix
    ./apps/lazygit
    ./apps/librewolf
    ./apps/lutris
    ./apps/neomutt
    ./apps/niri
    ./apps/nushell
    # ./apps/papis
    # ./apps/pipewire_noise_cancelling
    # ./apps/radicale
    ./apps/ripgrep
    ./apps/rmpc
    ./apps/rnote
    ./apps/ssh
    ./apps/st
    ./apps/taskwarrior
    ./apps/wezterm
    ./apps/xdg
    ./apps/xdot
    ./apps/yazi
    ./sops.nix
  ];

  stylix = (import ../stylix.nix) pkgs // {
    autoEnable = true;
    targets = {
      gtk.enable = true;
      qt.enable = true;
      blender.enable = true;
      librewolf = {
        profileNames = [ "default" ];
        colorTheme.enable = true;
        firefoxGnomeTheme.enable = true;
      };
      firefox = {
        profileNames = [ "default" ];
        firefoxGnomeTheme.enable = true;
      };
    };
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    sessionVariables = {
      BROWSER = "librewolf";
      DISPLAY = ":0";
      DISABLE_QT5_COMPAT = "0";
      EDITOR = "hx";
      HOST = "${hostname}";
      TERMINAL = "wezterm";
    };
    packages =
      with pkgs;
      let
        script_folder = ./scripts;
        scripts = builtins.map (
          script_name:
          pkgs.writeScriptBin ("my-" + script_name) (builtins.readFile (script_folder + "/${script_name}"))
        ) (builtins.attrNames (builtins.readDir script_folder));
      in
      scripts
      ++ [
        (python3.withPackages (p: (with p; [ oathtool ])))
        android-studio
        blender
        brightnessctl
        cura-appimage
        delta
        (
          (inputs.freecad-daily.packages.${system}.freecad-daily.overrideAttrs (
            final: prev: {
              patches = builtins.filter (
                patch: !(builtins.match ".*e3e56059865849c6b1c85161f69183ad872414e3.*" (toString patch) != null)
              ) prev.patches;
              dontVersionCheck = true;
            }
          )).customize
          {
            modules =
              let
                addonManager = fetchFromGitHub {
                  owner = "FreeCAD";
                  repo = "AddonManager";
                  rev = "6aeea2d01d36c026ef969a6e6d4d652386eccac3";
                  hash = "sha256-zKMOMJFPvT7JK8pcdLHmBHx8JNHbQ9kjaQzDFJLkzo4=";
                };
                fasteners = fetchFromGitHub {
                  owner = "shaise";
                  repo = "FreeCAD_FastenersWB";
                  rev = "4b7a71cf0782d61d42f36afe515b2880e49dea80";
                  hash = "sha256-4yCDz26gufpNzGfEj8CkGCToHznC7IUXEffLvlG+DXk=";
                };
                sheetMetal = fetchFromGitHub {
                  owner = "shaise";
                  repo = "FreeCAD_SheetMetal";
                  rev = "2a7710e27da3ff91852a8e678df2160d2a0dbe87";
                  hash = "sha256-nFc43p1E9v6nkd58tWcscF6soKh/3sZzZGeBaGQSU8s=";
                };
              in
              [
                addonManager
                fasteners
                sheetMetal
              ];
            pythons = [
              (
                ps: with ps; [
                  requests
                  pyjwt
                  tzlocal
                  defusedxml

                  # for gears
                  numpy
                  scipy
                ]
              )
            ];
          }
        )
        gimp
        gnumake
        go
        graphviz
        htop
        inkscape
        inputs.additional-fonts.packages.${system}.astetica
        inputs.additional-fonts.packages.${system}.audley-ipswitch
        inputs.additional-fonts.packages.${system}.leafery
        inputs.additional-fonts.packages.${system}.lovely-home
        jq
        kdePackages.okular
        kicad
        killall
        lazygit
        libreoffice
        qt5.qtwayland
        lightburn
        localsend
        mplayer
        mpv
        nautilus
        ngspice
        nixfmt
        obs-cmd
        openscad
        pastel
        qt6.qtwayland
        scooter
        songrec
        speedtest-cli
        supercollider
        swayimg
        termdown
        translatelocally
        unzip
        urlscan
        # TODO: use known configuration
        vim # for vimdiff and as backup
        wev
        wl-clipboard
        yt-dlp
        zathura
        zenith
      ];
  };

  services.tomat = {
    enable = true;
    settings = {
      notification = {
        enabled = false;
      };
      sound = {
        enabled = true;
      };
      timer = {
        auto_advance = false;
        break = 5;
        work = 25;
      };
    };
  };

  fonts.fontconfig.enable = true;

  # TODO: why is this an evaluation warning when the following is missing, when I don't even use it?
  wayland.windowManager.hyprland.configType = "lua";

  # NOTE: src: https://github.com/gepbird/dotfiles/blob/82902d8e5681c42411ed6125f8e9a9322ac3c6c1/modules/gtk-qt.nix#L10 (there the colortheme also gets set, but lets use the default)
  gtk =
    let
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-error-bell = false;
      };
    in
    {
      enable = true;
      gtk2.configLocation = "${config.home.homeDirectory}/.local/share/gtk-2.0/gtkrc";
      gtk2.extraConfig = pkgs.lib.foldlAttrs (
        a: n: v:
        "${a}\n${n} = ${pkgs.lib.trivial.boolToString v}"
      ) "" extraConfig;
      gtk3.extraConfig = extraConfig;
      gtk4 = {
        extraConfig = extraConfig;
      };
    };

  xdg.configFile."cat_installer/ca.pem" = {
    force = true;
    text = ''
      -----BEGIN CERTIFICATE-----
      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
      63ZTGI0RmLo=
      -----END CERTIFICATE-----
    '';
  };

  services.shpool = {
    enable = true;
  };

  programs.vdirsyncer = {
    enable = true;
    statusPath = "/home/${user}/.cache/vdirsyncer/status/";
  };
  services.vdirsyncer = {
    enable = true;
    frequency = "*:0/5";
  };

  programs.khard = {
    enable = true;
  };
  programs.khal = {
    enable = true;
  };
  programs.todoman = {
    enable = true;
  };
  accounts =
    let
      passwordCommand = [
        "awk"
        "-F:"
        "-v"
        "u=${user}"
        # TODO: somehow a space gets added to htpasswd secret which is not there in the secret which is why its +2
        "$1==u{match($0,/:/);print substr($0,RSTART+2)}"
        "${config.sops.secrets.vdirsyncer_htpasswd.path}"
      ];
    in
    {
      calendar = {
        basePath = ".calendar";
        accounts = {
          synced = {
            local = {
              path = "/home/${user}/.calendar/";
              type = "filesystem";
              fileExt = ".ics";
            };
            remote = {
              type = "caldav";
              userName = "${user}";
              passwordCommand = passwordCommand;
              url = "https://radicale.greenlad.net/";
            };
            vdirsyncer = {
              enable = true;
              collections = [
                "from a"
                "from b"
              ];
              conflictResolution = [
                "command"
                "vimdiff"
              ];
              metadata = [ "displayname" ];
            };
            khal = {
              enable = true;
              type = "discover";
            };
          };
        };
      };
      contact.accounts = {
        synced = {
          local = {
            path = "/home/${user}/.contacts/";
            type = "filesystem";
            fileExt = ".vcf";
          };
          remote = {
            type = "carddav";
            userName = "${user}";
            passwordCommand = passwordCommand;
            url = "https://radicale.greenlad.net/";
          };
          vdirsyncer = {
            enable = true;
            collections = [
              "from a"
              "from b"
            ];
            conflictResolution = [
              "command"
              "vimdiff"
            ];
            metadata = [ "displayname" ];
          };
          khard = {
            enable = true;
            type = "discover";
          };
        };
      };
    };
}
