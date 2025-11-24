{ pkgs, config, ... }:
{
  programs.taskwarrior = {
    package = pkgs.taskwarrior3;
    enable = true;
    config = {
    };
    extraConfig = ''
      include ${config.sops.templates.taskwarrior_encryption_secret_taskrc.path}
      sync.server.url=https:\/\/nuc:10222
      sync.server.client_id=0
    '';
  };
}
