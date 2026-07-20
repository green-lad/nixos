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

  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    user = user;
    dataDir = "/home/${user}/syncthing";
    settings = {
      gui = {
        user = "markus";
        password = "daedalus";
      };
      devices = {
        "XQ-DC72" = {
          id = "V2U6ZI4-4UGUZ6C-AWCTGGX-OYHPOPF-42LDVV4-R6PS6AU-IPGZJ73-4ZCJJQ5";
        };
        "nuc" = {
          id = "5DEDXMW-FZ3XN7E-KAHFNEJ-SB76WZ6-UFNN6DH-NSZKR6G-OIZ7IZW-ZVG2AQ3";
        };
      };
      folders = {
        "logseq" = {
          id = "uscr9-hyowx";
          path = "/home/${user}/logseq";
          devices = [ "XQ-DC72" "nuc" ];
        };
        "songs" = {
          id = "uscr9-hyowz";
          path = "/home/${user}/music/songs";
          devices = [ "XQ-DC72" "nuc" ];
        };
      };
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
