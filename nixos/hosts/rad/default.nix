{ pkgs, ... }:
{
  boot.kernelModules = [ "uinput" "amdgpu" ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };
}
