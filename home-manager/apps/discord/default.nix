{ config, ... }: {
  config.programs.vesktop = {
    enable = true;
  };

  config.xdg.desktopEntries = {
    discord = {
      name = "discord";
      genericName = "vesktop client for discord";
      exec = "vesktop";
      terminal = false;
      categories = [ "Application" ];
      mimeType = [ ];
    };
  };
}
