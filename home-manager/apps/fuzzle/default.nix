{ ... }: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "wezterm -e";
      };
    };
  };
}
