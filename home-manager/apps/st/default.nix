{ pkgs, ... }:
let
  patch = ''
    diff --git a/config.def.h b/st.config.def.h
    index 2cd740a..7bf80f5 100644
    --- a/config.def.h
    +++ b/st.config.def.h
    @@ -5,7 +5,7 @@
      *
      * font: see http://freedesktop.org/software/fontconfig/fontconfig-user.html
      */
    -static char *font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";
    +static char *font = "SauceCodePro Nerd Font Propo,SauceCodePro NFP:style=Regular:pixelsize=16;0";
     static int borderpx = 2;
     
     /*
  '';
  patchFile = pkgs.writeText "st_set_font.patch" patch;
in
{
  home.packages = with pkgs; [
    (st.overrideAttrs (oldAttrs: rec {
      patches = [
        patchFile
      ];
    }))
  ];
}
