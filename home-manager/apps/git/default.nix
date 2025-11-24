{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Markus Schoetz";
        email = "markus.schoetz@fau.de";
      };
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        enable = true;
        navigate = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };
    };
  };
}
