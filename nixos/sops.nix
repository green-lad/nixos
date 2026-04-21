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
      network_keys = { };
      # vikunja_env = { };
      "keys/${hostname}/public" = { };
    };
  };
}
