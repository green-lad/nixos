{
  config,
  pkgs,
  user,
  domain,
  ...
}:
{
  imports = [
  ];

  sops.secrets = {
    "cloudflare_api/email" = { };
    "cloudflare_api/key" = { };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "${domain}" = {
        domain = domain;
        extraDomainNames = [
          "calibre.${domain}"
          "fava.${domain}"
          "miniflux.${domain}"
          "binarycache.${domain}"
          "radicale.${domain}"
          "syncthing.${domain}"
          "immich.${domain}"
          "tandoor.${domain}"
        ];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        group = "nginx";
        credentialFiles = {
          "CF_API_EMAIL_FILE" = config.sops.secrets."cloudflare_api/email".path;
          "CF_API_KEY_FILE" = config.sops.secrets."cloudflare_api/key".path;
        };
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];

  nix.settings = {
    allowed-users = [ "nix-serve" ];
    trusted-users = [ "nix-serve" ];
  };
  sops.secrets = {
    "nix-serve/private" = {
      restartUnits = [ "nix-serve.service" ];
    };
    "nix-serve/public" = {
      restartUnits = [ "nix-serve.service" ];
    };
  };
  services.nix-serve = {
    enable = true;
    port = 5002;
    openFirewall = true;
    secretKeyFile = config.sops.secrets."nix-serve/private".path;
    extraParams = "--priority 99";
  };

  services.calibre-server = {
    enable = true;
    port = 5012;
    libraries = [
      "/var/lib/calibre-server/default"
    ];
  };

  services.pihole-ftl =
    let
      ipv4_network_part = "192.168.50";
    in
    {
      enable = true;
      # See <https://docs.pi-hole.net/ftldns/configfile/>
      settings = {
        dns = {
          listeningMode = "ALL";
          domain = "${domain}";
          domainNeeded = true;
          expandHosts = true;
          interface = "eth0";
          upstreams = [
            "1.1.1.1" # cloudflare
            "9.9.9.9" # quad9
          ];
          hosts = [
            "${ipv4_network_part}.1 fritz.box"
            "${ipv4_network_part}.1 router"
            "${ipv4_network_part}.79 nuc"
            "${ipv4_network_part}.79 miniflux"
            "${ipv4_network_part}.79 calibre"
            "${ipv4_network_part}.79 radicale"
            "${ipv4_network_part}.79 syncthing"
            "${ipv4_network_part}.79 immich"
            "${ipv4_network_part}.79 tandoor"
            "${ipv4_network_part}.79 fava"
            "${ipv4_network_part}.79 pihole"
            "${ipv4_network_part}.79 binarycache"
          ];
        };

        dhcp = {
          active = true;
          hosts = [
            "f4:4e:e3:de:5a:7b,${ipv4_network_part}.79,nuc"
            "82:88:91:D5:AE:5B,${ipv4_network_part}.80,Xperia-10-V"
            "10:F6:0A:DD:25:93,${ipv4_network_part}.81,x13"
            "60:67:20:2C:39:A8,${ipv4_network_part}.82,x230"
            "D8:43:AE:BF:4C:A1,${ipv4_network_part}.85,rad"
            "20:50:E7:C6:E4:C4,${ipv4_network_part}.87,remarkable"
            # "60:67:20:2C:39:A8,${ipv4_network_part}.83,pocketnc"
            # "60:67:20:2C:39:A8,${ipv4_network_part}.2,ruida_laser"
          ];
          ipv6 = false;
          leaseTime = "3650d";
          start = "${ipv4_network_part}.80";
          end = "${ipv4_network_part}.200";
          rapidCommit = true;
          resolver = {
            resolveIPv6 = false;
          };
          router = "${ipv4_network_part}.1";
        };
      };

      lists = [
        {
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          type = "block";
          enabled = true;
          description = "hagezi blocklist";
        }
      ];

      openFirewallDNS = true;
      openFirewallDHCP = true;
      openFirewallWebserver = true;
      queryLogDeleter.enable = true;
    };

  services.pihole-web = {
    enable = true;
    ports = [ "444s" ];
  };

  sops.secrets = {
    radicale_htpasswd = {
      restartUnits = [ "radicale.service" ];
      group = "radicale";
      mode = "440";
    };
  };
  # TODO: switch to xandikos
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [
        "localhost:5232"
        "0.0.0.0:5232"
        "[::]:5232"
      ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets.radicale_htpasswd.path;
        htpasswd_encryption = "plain";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
    # NOTE: rights seems to create the wrong format, eg for user:
    #   generated: "user=.*"
    #   expected: "user: .*"
    #   rights = {
    #     root = {
    #       user = ".+";
    #       collection = "";
    #       permissions = "rw";
    #     };
    #     principal = {
    #       user = ".+";
    #       collection = "{user}";
    #       permissions = "RW";
    #     };
    #     calendars = {
    #       user = ".+";
    #       collection = "{user}/[^/]+";
    #       permissions = "rw";
    #     };
    #   };
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      "acmechallenge.${domain}" = {
        # Catchall vhost, will redirect users to HTTPS for all vhosts
        serverAliases = [ "*.${domain}" ];
        locations."/.well-known/acme-challenge" = {
          root = "/var/lib/acme/.challenges";
        };
        locations."/" = {
          return = "301 https://$host$request_uri";
        };
      };
      "binarycache.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations."/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
      "fava.${domain}".locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:5000";
        };
      };
      "calibre.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:5012";
          };
        };
      };
      "miniflux.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8002";
          };
        };
      };
      "tandoor.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:5004";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Scheme https;
            '';
          };
        };
      };
      "syncthing.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8384";
            extraConfig = ''
              proxy_set_header Host localhost;
              auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
              proxy_set_header X-Preferred-Username $preferred_username;

              proxy_set_header        X-Real-IP $remote_addr;
              proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header        X-Forwarded-Proto $scheme;
              proxy_read_timeout      600s;
              proxy_send_timeout      600s;
            '';
          };
        };
      };
      "immich.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig = ''
              client_max_body_size 50000M;
              proxy_read_timeout   600s;
              proxy_send_timeout   600s;
              send_timeout         600s;
            '';
          };
        };
      };
      "radicale.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:5232";
            extraConfig = ''
              proxy_set_header  X-Script-Name /radicale;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header  X-Forwarded-Host $host;
              proxy_set_header  X-Forwarded-Port $server_port;
              proxy_set_header  X-Forwarded-Proto $scheme;
              proxy_set_header  Host $host;
              proxy_pass_header Authorization;
            '';
          };
        };
      };
      "pihole.${domain}".locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:443";
        };
      };
      "memos.${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:5230";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Scheme https;
            '';
          };
        };
      };
    };
  };

  # TODO: for miniflux use separte config file and OAUTH2 (see: https://github.com/felschr/nixos-config/blob/41307308527cdf7a352e87e2ff36d91546eb29a4/services/miniflux.nix#L12)
  users.groups.miniflux_secrets = { };
  sops.secrets = {
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
  };
  systemd.services.miniflux.serviceConfig.SupplementaryGroups = [ "miniflux_secrets" ];
  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = pkgs.writeTextFile {
      name = "miniflux.conf";
      text = ''
        ADMIN_USERNAME=${user}
        ADMIN_PASSWORD_FILE=${config.sops.secrets."miniflux/password".path}
      '';
    };
    config = {
      # BASE_URL = "https://${hostname}/";
      LISTEN_ADDR = "127.0.0.1:8002";
      # PORT = 8002;
      FETCH_YOUTUBE_WATCH_TIME = "true";
      # CERT_FILE = "${config.sops.secrets."miniflux/certificate".path}";
      # KEY_FILE = "${config.sops.secrets."miniflux/key".path}";
    };
  };

  environment.systemPackages = with pkgs; [ fava ];
  users.users.fava = {
    home = "/var/lib/fava";
    createHome = true;
    isSystemUser = true;
    group = "fava";
    # TODO: check on different PC if this works, on initial setup I set this manually
    homeMode = "770";
  };
  systemd.services.fava =
    let
      ledgerFile = "/var/lib/fava/ledger.bean";
    in
    {
      description = "Fava";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = ''/bin/sh -c '[ -f "${ledgerFile}" ] || ${pkgs.coreutils}/bin/install -m770 -o fava -g fava /dev/null "${ledgerFile}"' '';
        ExecStart = "${pkgs.fava}/bin/fava ${ledgerFile}";
        Type = "simple";
        User = "fava";
        Group = "fava";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        PrivateHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        ReadWriteDirectories = "/var/lib/fava";
      };
    };
  users.groups.fava = { };

  users.users."${user}".extraGroups = [
    "fava"
  ];

  services.tandoor-recipes = {
    enable = true;
    port = 5004;
    address = "127.0.0.1";
    # database.createLocally = true;
    extraConfig = {
      CSRF_TRUSTED_ORIGINS = "https://tandoor.greenlad.net";
      ALLOWED_HOSTS = [ "tandoor.greenlad.net" ];
    };
  };

  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    user = user;
    dataDir = "/home/${user}/syncthing";
    settings = {
      gui = {
        user = "markus";
        password = "daedalus";
      };
      devices = {
        "XQ-DC72" = {
          id = "V2U6ZI4-4UGUZ6C-AWCTGGX-OYHPOPF-42LDVV4-R6PS6AU-IPGZJ73-4ZCJJQ5";
        };
        "rad" = {
          id = "M777QYL-7JXYNXL-74SFF6A-QNLCIUA-KSOAPS7-2E3DOD6-YIAWPS7-HDD3QQV";
        };
      };
      folders = {
        "logseq" = {
          id = "uscr9-hyowx";
          path = "/home/${user}/logseq";
          devices = [ "XQ-DC72" "rad" ];
        };
        "songs" = {
          id = "uscr9-hyowz";
          path = "/home/${user}/music/songs";
          devices = [ "XQ-DC72" "rad" ];
        };
      };
    };
  };

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
  };
}
