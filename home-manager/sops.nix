{ config, hostname, inputs, ... }:
let
  secretspath = builtins.toString inputs.sops_secrets;
  # NOTE: normally this is /run/user/1000 but doing it this way keys.txt gets created from sshKeyPaths with the expected path ~/.config/sops/age/keys.txt
  # run_path = "${config.xdg.configHome}/sops/age";
in {
  sops = rec {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = true;

    # see: https://github.com/Mic92/sops-nix/issues/824
    environment = {
      SOPS_AGE_SSH_PRIVATE_KEY_FILE = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };

    age = {
      # currently unused since secrets are configured to use this directly and sops-nix converts this to age key and gives it to sops
      # (but sth has to be configured anyway)
      # sops uses the above env variable instead to find the required private key for decryption
      sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };

    secrets = {
      imap_password = { };
      wlan_password = { };
      taswarrior_encryption_secret = { };
      "keys/${hostname}/private" = { };
      vdirsyncer_htpasswd = {
        key = "radicale_htpasswd";
      };
    };

    templates = {
      taskwarrior_encryption_secret_taskrc = {
        content = ''
          sync.encryption_secret=${config.sops.placeholder.taswarrior_encryption_secret}
        '';
      };
    };
  };
}
