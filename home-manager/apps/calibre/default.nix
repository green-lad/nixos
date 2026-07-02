{ config, pkgs, ... }:
{
  config.home.packages = with pkgs; [
    calibre
  ];
  config.programs.calibre = {
    enable = true;
    plugins = [];
  };
}
