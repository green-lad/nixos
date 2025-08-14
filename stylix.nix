pkgs: {
  enable = true;
  # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  base16Scheme = {
    system = "base16";
    name = "iceberg-adjacent";
    author = "Markus Schoetz";
    variant = "dark";

    palette = {
      base00 = "#11121d";
      base01 = "#1A1B2A";
      base02 = "#212234";
      base03 = "#2f3446";
      base04 = "#3b414e";
      base05 = "#cdd6f4";
      base06 = "#85a0c7";
      base07 = "#e27878";
      base08 = "#c6c8d1";
      base09 = "#a093c8";
      base0A = "#85a0c7";
      base0B = "#b5bf82";
      base0C = "#89b9c2";
      base0D = "#c6c8d1";
      base0E = "#91acd1";
      base0F = "#e27878";
    };
  };
  cursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 24;
  };
}
