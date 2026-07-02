{ config, hostname, user, inputs, ... }:
let
  secretspath = builtins.toString inputs.sops_secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = true;

    # see: https://github.com/Mic92/sops-nix/issues/824
    environment = {
      SOPS_AGE_SSH_PRIVATE_KEY_FILE = "${config.users.users.${user}.home}/.ssh/id_ed25519";
    };

    # age = {
    #   sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # };

    secrets = {
      network_keys = { };
      "keys/${hostname}/public" = { };
    };
  };
}
