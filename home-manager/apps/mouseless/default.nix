{ config, pkgs, ... }:
{
  config.home.packages = [ pkgs.mouseless ];
  config.systemd.user.services.mouseless = {
    # Enable = true;
    Unit = {
      Description = "Mouseless key remapping service";
    };
    Service = {
      ExecStartPre = "/bin/sleep 2";
      ExecStart = "sudo mouseless --config %h/.config/mouseless/config.yaml";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  config.home.file.".config/mouseless/config.yaml".text = ''
    # the default speed for mouse movement and scrolling
    baseMouseSpeed: 1000.0
    baseScrollSpeed: 20.0

    # the rest of the config defines the layers with their bindings
    layers:
      # the first layer is active at start
      - name: initial
        bindings:
          # when tab is held and another key pressed, activate mouse layer
          leftalt: tap-hold-next tab ; toggle-layer mouse ; 500
      - name: mouse
        # when true, keys that are not mapped keep their original meaning
        passThrough: false
        bindings:
          # quit mouse layer
          q: layer initial
          # keep the mouse layer active
          space: layer mouse
          l: move  1  0
          h: move -1  0
          j: move  0  1
          k: move  0 -1
          p: scroll up
          n: scroll down
          leftshift: speed 0.3
          f: button left
          d: button middle
          s: button right
  '';
}
