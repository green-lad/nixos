{ config, pkgs, ... }:
{
  config.services.mpd = {
    enable = true;
    package = pkgs.mpd.override {
      ffmpeg = pkgs.ffmpeg.override (old: {
        withRubberband = true;
      });
    };
    extraConfig =
      let
        speeds = [
          {
            name = "semitone-6";
            value = "0.70710678118654753949";
            enabled = "false";
          }
          {
            name = "semitone-4";
            value = "0.79370052598409974867";
            enabled = "false";
          }
          {
            name = "semitone-2";
            value = "0.89089871814033931107";
            enabled = "false";
          }
          {
            name = "semitone-0";
            value = "1";
            enabled = "true";
          }
          {
            name = "semitone+2";
            value = "1.12246204829593419095";
            enabled = "false";
          }
          {
            name = "semitone+4";
            value = "1.25992104986470410019";
            enabled = "false";
          }
          {
            name = "semitone+6";
            value = "1.41421356232229960378";
            enabled = "false";
          }
        ];
        filter_configs_string = builtins.concatStringsSep "" (
          builtins.map (e: ''
            filter {
              plugin "ffmpeg"
              name   "${e.name}"
              graph  "rubberband=pitch=${e.value}:tempo=${e.value}"
            }
          '') speeds
        );
        audio_output_configs_string = builtins.concatStringsSep "" (
          builtins.map (e: ''
            audio_output {
              type    "pipewire"
              name    "pipewire (${e.name})"
              filters "${e.name}"
              enabled  "${e.enabled}"
            }
          '') speeds
        );
      in
      ''
        auto_update "yes"
        audio_buffer_size "4096"

        ${filter_configs_string}
        ${audio_output_configs_string}
      '';
  };
  config.programs.rmpc = {
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
