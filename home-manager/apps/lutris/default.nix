{ config, pkgs, ... }:
{
  config.targets.genericLinux.nixGL.vulkan.enable = true;
  config.programs.lutris = {
    enable = true;
    extraPackages = with pkgs; [ 
        wine
        winetricks 
        mangohud
        vulkan-tools
        # vulkan-helper     # doesn't fix [ERROR:2025-06-28 19:15:32,566:system]: ['vulkaninfo', '--summary'] command failed
        # gamescope         # already defined in system/gaming
        # gamemode
        # protonup          # Proton GE
      ];
  };
}
