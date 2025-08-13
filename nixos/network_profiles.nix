environmentFile:
# generated via:
# sudo su -c "cd /etc/NetworkManager/system-connections && nix --extra-experimental-features 'nix-command flakes' run github:shymega/nm2nix/refactor\/fix-json-tmpfile | nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixfmt-rfc-style"
{
  environmentFiles = [ environmentFile ];
  profiles = {
    wwan_1 = {
      connection = {
        id = "wwan_1";
        type = "gsm";
      };
      gsm = {
        apn = "internet";
        pin = "$wwan_1_pin";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
    };
    wwan_2 = {
      connection = {
        id = "wwan_2";
        type = "gsm";
      };
      gsm = {
        apn = "internet";
        pin = "$wwan_2_pin";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
    };
    home_wlan = {
      connection = {
        id = "home_wlan";
        type = "wifi";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "$home_wlan_ssid";
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = "$home_wlan_psk";
      };
    };
    eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
        permissions = "user:markus:;";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
      wifi = {
        ssid = "eduroam";
      };
      wifi-security = {
        group = "ccmp;tkip;";
        key-mgmt = "wpa-eap";
        pairwise = "ccmp;";
        proto = "rsn;";
      };
      "802-1x" = {
        anonymous-identity = "$eduroam_anonymous_user";
        ca-cert = "/home/markus/.config/cat_installer/ca.pem";
        eap = "peap;";
        identity = "$eduroam_user";
        password = "$fau_password";
        phase2-auth = "mschapv2";
      };
    };
  };
}
