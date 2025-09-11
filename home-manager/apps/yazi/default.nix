{ ... }:
{
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      mgr = {
        linemode = "mtime";
        ratio = [
          1
          2
          4
        ];
      };
      preview = {
        wrap = "yes";
      };
    };
  };
}
