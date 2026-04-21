{ hostname, inputs, ... }:
let
  secretspath = builtins.toString inputs.sops_secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/keys.txt";
      generateKey = true;
    };

    secrets = {
      "nix-serve/private" = {
        restartUnits = [ "nix-serve.service" ];
      };
      "nix-serve/public" = {
        restartUnits = [ "nix-serve.service" ];
      };
      radicale_htpasswd = {
        restartUnits = [ "radicale.service" ];
        group = "radicale";
        mode = "440";
      };
      "cloudflare_api/email" = { };
      "cloudflare_api/key" = { };
      network_keys = { };
      # vikunja_env = { };
      "miniflux/password" = {
        restartUnits = [ "miniflux.service" ];
        group = "miniflux_secrets";
        mode = "440";
      };
      "miniflux/key" = {
        restartUnits = [ "miniflux.service" ];
        group = "miniflux_secrets";
        mode = "440";
      };
      "miniflux/certificate" = {
        restartUnits = [ "miniflux.service" ];
        group = "miniflux_secrets";
        mode = "440";
      };
      "keys/${hostname}/public" = { };
    };
  };
}
