{ pkgs, ... }: {
  home.sessionVariables = { "GTK_USE_PORTAL" = 1; };

  # NOTE: currently in configuration.nix, but is better here; waiting for https://github.com/nix-community/home-manager/issues/6770
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gtk
  #     xdg-desktop-portal-termfilechooser
  #   ];
  #   config = { common = { default = "termfilechooser"; }; };
  # };

  systemd.user.services."xdg-desktop-portal-gtk" = {
    Install.WantedBy = pkgs.lib.mkForce [ "graphical-session-i3.target" ];
    Unit = {
      After = [ "graphical-session-i3.target" ];
      Description = "Portal service (GTK/GNOME implementation)";
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.gtk";
      ExecStart =
        "${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
      Restart = "on-failure";
    };
  };

  systemd.user.services."xdg-desktop-portal-termfilechooser" = {
    Install.WantedBy = pkgs.lib.mkForce [ "graphical-session-i3.target" ];
    Unit = {
      After = [ "graphical-session-i3.target" ];
      Description = "Portal service (terminal file chooser implementation)";
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.termfilechooser";
      ExecStart =
        "${pkgs.xdg-desktop-portal-termfilechooser}/libexec/xdg-desktop-portal-termfilechooser";
      Restart = "on-failure";
    };
  };

  systemd.user.services."xdg-desktop-portal" = {
    Install.WantedBy = pkgs.lib.mkForce [ "graphical-session-i3.target" ];
    Unit = {
      After = [ "graphical-session-i3.target" ];
      Description = "Portal service";
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.portal.Desktop";
      ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
      Restart = "on-failure";
    };
  };

  # src: https://discourse.nixos.org/t/how-to-install-xdg-desktop-portal-termfilechooser/62819/12
  xdg = {
    configFile."xdg-desktop-portal-termfilechooser/config".text = let
      launcherDeps = pkgs.buildEnv {
        name = "yazi-launcher-dependencies";
        paths = with pkgs; [ coreutils yazi gnused bashInteractive ];
      };
    in ''
      [filechooser]
      env=PATH='${launcherDeps}/bin'
      env=TERMCMD='${pkgs.wezterm}/bin/wezterm start --always-new-process'
      cmd='${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh'
      default_dir=$HOME
      open_mode=suggested
    '';
  };

}
