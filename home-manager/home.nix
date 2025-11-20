{
  config,
  hostname,
  inputs,
  pkgs,
  system,
  user,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./apps/blender
    ./apps/chromium
    ./apps/discord
    ./apps/fzf
    ./apps/gammastep
    ./apps/git
    ./apps/helix
    ./apps/librewolf
    ./apps/neomutt
    ./apps/niri
    ./apps/nushell
    ./apps/papis
    ./apps/pipewire_noise_cancelling
    ./apps/radicale
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
    packages = with pkgs; [
      (python3.withPackages (p: (with p; [ oathtool ])))
      blender
      brightnessctl
      cura-appimage
      delta
      gimp
      gnumake
      go
      graphviz
      htop
      inkscape
      inputs.additional-fonts.packages.${system}.astetica
      inputs.additional-fonts.packages.${system}.leafery
      jq
      kdePackages.okular
      kicad
      killall
      lazygit
      libreoffice
      libsForQt5.qt5.qtwayland
      lightburn
      mplayer
      mpv
      nautilus
      ngspice
      obs-cmd
      obs-studio
      openscad
      pastel
      pulseaudio
      pulsemixer
      qt6.qtwayland
      scooter
      songrec
      speedtest-cli
      supercollider
      swayimg
      termdown
      unzip
      wev
      wl-clipboard
      yt-dlp
      zathura
    ];
  };

  fonts.fontconfig.enable = true;

  wayland.windowManager.sway.enable = true;

  # src: https://github.com/gepbird/dotfiles/blob/82902d8e5681c42411ed6125f8e9a9322ac3c6c1/modules/gtk-qt.nix#L10 (there the colortheme also gets set, but lets use the default)
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
      gtk4.extraConfig = extraConfig;
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
}
