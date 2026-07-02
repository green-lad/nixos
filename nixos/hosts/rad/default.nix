{ pkgs, user, ... }:
{
  boot.kernelModules = [
    "uinput"
    "amdgpu"
  ];

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

  # environment.persistence."/persist" = {
  #   enable = true;
  #   hideMounts = true;
  #   directories = [
  #     "/var/log"
  #     "/var/lib/bluetooth"
  #     "/var/lib/nixos"
  #     "/var/lib/systemd/coredump"
  #     "/etc/NetworkManager/system-connections"
  #     {
  #       directory = "/var/lib/colord";
  #       user = "colord";
  #       group = "colord";
  #       mode = "u=rwx,g=rx,o=";
  #     }
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #   ];
  #   users."${user}" = {
  #     directories = [
  #       "config"
  #       {
  #         directory = ".gnupg";
  #         mode = "0700";
  #       }
  #       {
  #         directory = ".ssh";
  #         mode = "0700";
  #       }
  #     ];
  #     files = [
  #     ];
  #   };
  # };
}
