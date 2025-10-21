{ pkgs, ... }:
{
  config.home.packages = [ pkgs.xdot ];
  config.xdg.desktopEntries = {
    xdot = {
      name = "xdot";
      genericName = "dot graph viewer";
      exec = "xdot";
      terminal = false;
      categories = [ "Application" ];
      mimeType = [ "application/msword-template" ];
    };
  };
}
