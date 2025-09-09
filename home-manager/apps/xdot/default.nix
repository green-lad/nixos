{ pkgs, ... }:
{
  config.home.packages = [ pkgs.xdot ];
  config.xdg.desktopEntries = {
    firefox = {
      name = "xdot";
      genericName = "dot graph viewer";
      exec = "xdot";
      terminal = false;
      categories = [ "Application" ];
      mimeType = [ "application/msword-template" ];
    };
  };
}
