# NOTE: currenty not working
{ }:
{
  environment.systemPackages = with pkgs; [ teddycloud ];
  users.groups.teddycloud = { };
  users.users.teddycloud = {
    home = "/var/lib/teddycloud";
    createHome = true;
    group = "teddycloud";
    isSystemUser = true;
    description = "teddycloud service user";
  };

  # TODO: make this work
  # systemd.services.teddycloud = {
  #   description = "teddy cloud server";
  #   path = [ pkgs.ffmpeg-headless ];

  #   preStart = ''
  #     mkdir -p /var/lib/teddycloud/{certs,config,data}
  #     mkdir -p /var/lib/teddycloud/certs/{client,server}
  #     mkdir -p /var/lib/teddycloud/data/{content,library,firmware,cache}
  #   '';
  #   script = "${pkgs.teddycloud}/bin/teddycloud --base_path /var/lib/teddycloud";

  #   serviceConfig = {
  #     User = "teddycloud";
  #     Group = "teddycloud";
  #     Restart = "on-failure";

  #     ProtectHome = true;
  #     PrivateTmp = true;
  #     PrivateDevices = true;

  #     AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
  #     CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
  #   };

  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" ];
  #   wants = [ "network-online.target" ];
  # };

}
