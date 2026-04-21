{ config, pkgs, ... }:
let
  browser = [ "librewolf.desktop" ];
  editor = [ "hx.desktop" ];
  filechooser = [ "yazi.desktop" ];

  # XDG MIME types
  # get filetype: xdg-mime query filetype <file>
  # get mime type (with a list of sourced files): XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default <mime type>
  # 
  # NOTE: specifying with * enables other apps to precede the application by matching more precisely
  #       example: "image/*" = [ "feh.desktop" ];
  associations = {
    "application/json" = browser;
    "application/pdf" = "org.pwmt.zathura.desktop";
    "application/rdf+xml" = browser;
    "application/rss+xml" = browser;
    "application/x-directory" = filechooser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-gnome-saved-search" = filechooser;
    "application/x-wine-extension-ini" = editor;
    "application/xhtml+xml" = browser;
    "application/xhtml_xml" = browser;
    "application/xml" = browser;
    "audio/*" = [ "mpv.desktop" ];
    "image/gif" = [ "feh.desktop" ];
    "image/jpeg" = [ "feh.desktop" ];
    "image/png" = [ "feh.desktop" ];
    "inode/directory" = filechooser;
    "text/*" = editor;
    "text/csv" = editor;
    "text/html" = browser;
    "text/markdown" = editor;
    "text/plain" = editor;
    "text/x-bibtex" = editor;
    "text/x-dbus-service" = editor;
    "text/xml" = editor;
    "video/*" = [ "mpv.dekstop" ];
    "x-directory/normal" = filechooser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/trash" = filechooser;
    "x-scheme-handler/unknown" = browser;
  };
in {
  imports = [ ./xdg-portals.nix ];

  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
  ];

  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    mimeApps = {
      enable = true;
      defaultApplications = associations;
    };

    userDirs = {
      enable = true;
      setSessionVariables = true;
      # createDirectories = true;
      extraConfig = {
        # TODO: this should also work without since "xdg-user-dir SCREENSHOTS" exists
        # XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.documents}/screenshots";
      };
    };
  };
}
