{
  config,
  hostname,
  user,
  hosts,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks =
      let
        hostBlocks = builtins.mapAttrs (n: v: {
          host = n;
          user = user;
          identityFile = [ config.sops.secrets."keys/${hostname}/private".path ];
        }) hosts;
      in
      hostBlocks
      // {
        "github" = {
          host = "github";
          hostname = "github.com";
          user = "git";
          identitiesOnly = true;
          identityFile = [ config.sops.secrets."keys/${hostname}/private".path ];
        };
        "gitlab_fau" = {
          host = "gitlab_fau";
          hostname = "gitlab.cs.fau.de";
          user = "git";
          identitiesOnly = true;
          identityFile = [ config.sops.secrets."keys/${hostname}/private".path ];
        };
      };
  };
}
