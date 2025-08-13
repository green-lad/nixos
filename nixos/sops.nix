{ hostname, sops_secrets, ... }:
let secretspath = builtins.toString sops_secrets;
in {
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/keys.txt";
      generateKey = true;
    };

    secrets = {
      network_keys = { };
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
