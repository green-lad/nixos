# TODO: pdfjs is not working
{ pkgs, ... }:
let
  pdfjs = let version = "5.2.133";
  in pkgs.fetchzip {
    url =
      "https://github.com/mozilla/pdf.js/releases/download/v${version}/pdfjs-${version}-dist.zip";
    hash = "sha256-7kfT3+ZwoGqZ5OwkO9h3DIuBFd0v8fRlcufxoBdcy8c=";
    stripRoot = false;
  };
  papis_patch = pkgs.writeText "papis.patch" (builtins.readFile
    ./override_empty_bibtex_ref_and_fix_fzf_using_nushell.patch);
in {
  programs.papis = {
    # TODO: fix tests failing (caused by patch?)
    enable = false;
    package = pkgs.papis.overrideAttrs (old: { patches = [ papis_patch ]; });
    libraries = {
      twins_themis = {
        name = "twins_themis";
        isDefault = true;
        settings = { dir = "~/Documents/twins_themis"; };
      };
      books = {
        name = "books";
        settings = { dir = "~/Documents/books"; };
      };
      nyt = {
        name = "nyt";
        settings = { dir = "~/Documents/nyt"; };
      };
    };
    settings = rec {
      picktool = "fzf";
      ref-format = "{doc[author_list][0][family]} {doc[year]} {doc[title]:.15}";
      add-folder-name = ref-format;
      add-file-name = ref-format;
    };
  };

  # Dummy `scripts` directory to silence `papis`'s message
  # about creating the `scripts` directory on first run
  # Unfortunately, `home-manager` cannot create empty directories:
  # https://github.com/nix-community/home-manager/issues/2104#issuecomment-861676751
  xdg.configFile."papis/scripts/.keep".source = builtins.toFile "keep" "";

  xdg.configFile."papis/web/pdfjs".source = pdfjs;

  systemd.user.services.papis = {
    Install.WantedBy = pkgs.lib.mkForce [ "graphical-session-i3.target" ];
    Unit = {
      After = [ "graphical-session-i3.target" ];
      Description = "Serve papis web app";
    };
    Service = {
      ExecStart = "${pkgs.papis}/bin/papis serve";
      Restart = "on-failure";
    };
  };
}
