{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    # ungoogled breaks extensions, see: https://github.com/nix-community/home-manager/issues/2216#issuecomment-917507881
    # package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--ozone-platform=wayland"
      # chrome:flags does not show these values correctly
      "--enable-experimental-web-platform-features"
      "--enable-web-bluetooth-new-permissions-backend"
      "--password-store=basic"
    ];
    extensions = [
      # dark reader
      "eimadpbcbfnmbkopoojfekhnkhdbieeh"
      # refined github
      "hlepfoohegkhhmjieoechaddaejaokhf"
      # espruino web IDE
			"bleoifhkdalbjfbobjackfdifdneehpo"
			# uBlock Origin Lite
      "ddkjiahejlhfcafbddmgiahcphecmpfh"
    ];
  };
}
