{ ... }:
{
  services.gammastep = {
    enable = true;
    latitude = 49.0;
    longitude = 11.0;
    settings = {
      general = {
        adjustment-method = "wayland";
      };
    };
  };
}
