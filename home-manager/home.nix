{
  pkgs,
  inputs,
  user,
  hostname,
  config,
  ...
}:
{
  imports = [
    inputs.stylix.homeModules.stylix
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix
    inputs.nixvim.homeManagerModules.nixvim
    # ./apps/blender
    ./apps/fzf
    ./apps/gammastep
    ./apps/git
    ./apps/helix
    ./apps/librewolf
    ./apps/moc
    ./apps/neomutt
    ./apps/nushell
    ./apps/niri
    ./apps/papis
    ./apps/pipewire_noise_cancelling
    ./apps/ripgrep
    ./apps/rmpc
    ./apps/rnote
    ./apps/ssh
    ./apps/taskwarrior
    ./apps/wezterm
    ./apps/xdg
    ./apps/yazi
  ];

  stylix = {
    enable = true;
    targets.librewolf.profileNames = [ "default" ];
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    base16Scheme = {
      system = "base16";
      name = "iceberg-adjacent";
      author = "Markus Schoetz";
      variant = "dark";

      palette = {
        base00 = "#11121d";
        base01 = "#1A1B2A";
        base02 = "#212234";
        base03 = "#2f3446";
        base04 = "#3b414e";
        base05 = "#cdd6f4";
        base06 = "#85a0c7";
        base07 = "#e27878";
        base08 = "#c6c8d1";
        base09 = "#a093c8";
        base0A = "#85a0c7";
        base0B = "#b5bf82";
        base0C = "#89b9c2";
        base0D = "#c6c8d1";
        base0E = "#91acd1";
        base0F = "#e27878";
      };
    };
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    sessionVariables = {
    };
    packages = with pkgs; [
      blender
      brightnessctl
      cura-appimage
      delta
      ffmpeg_6
      gnumake
      gimp
      graphviz
      htop
      inkscape
      jq
      killall
      lazygit
      libreoffice
      lightburn
      mplayer
      obs-cmd
      obs-studio
      openscad
      pastel
      pulseaudio
      pulsemixer
      python3
      rustup
      songrec
      unzip
      wl-clipboard
      yt-dlp
      zathura
    ];
  };

  # src: https://github.com/gepbird/dotfiles/blob/82902d8e5681c42411ed6125f8e9a9322ac3c6c1/modules/gtk-qt.nix#L10 (there the colortheme also gets set, but lets use the default)
  gtk = {
    enable = true;
    gtk2.configLocation = "${config.home.homeDirectory}/.local/share/gtk-2.0/gtkrc";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-error-bell = false;
    };
    gtk4.extraConfig = {
      gtk-error-bell = false;
    };
  };
}
