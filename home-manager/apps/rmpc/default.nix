{ ... }:
{
  programs.rmpc = {
    enable = true;
    config = ''
      (
        cache_dir: Some("~/.cache/rmpc/"),
        album_art: (
          method: Sixel,
        ),
      )
    '';
  };
}
