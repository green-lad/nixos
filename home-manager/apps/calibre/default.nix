{ config, pkgs, ... }:
{
  config.home.packages = with pkgs; [
    calibre
  ];
  config.programs.calibre = {
    enable = true;
    # NOTE: using the existing plugins makes no sense, since plugins have to be loaded manually anyways, all this does is link the given stuff to ~/.config/calibre/plugins which has no effect on calibre, itself seems to use the folder to move plugins there after they got added
    # plugins =
    #   let
    #     # TODO: build from source
    #     crosspointPlugin = pkgs.fetchurl {
    #       url = "https://github.com/crosspoint-reader/calibre-plugins/releases/download/v0.2.5/crosspoint_reader-v0.2.5.zip";
    #       sha256 = "sha256-G+/NgtC25ULe0NmCBbhZ47dN9k8kZiO+E9zVaEdutck=";
    #       # sha256 = "sha256-fiXFI0+ZpbrqApEIetUtm4U1fD2bo8O691XvA40V/EM=";
    #     };
    #   in
    #   [
    #     "${pkgs.stdenvNoCC.mkDerivation rec {
    #       pname = "calibre-crosspoint-plugin";
    #       version = "0.2.5";
    #       buildCommand = ''
    #         mkdir -p $out
    #         cp -R ${crosspointPlugin} $out/${pname}-v${version}.zip
    #       '';
    #     }}"
    #   ];

    # TODO: make calibre configureable, see https://github.com/nix-community/home-manager/issues/8380
  };
}
