{ config, lib, pkgs, ... }:
{
  sops.secrets."wireguard/privateKey" = { };
  networking.wg-quick.interfaces = {
    typej0 = {
      address = [ "172.20.0.2/32" ];
      privateKeyFile = config.sops.secrets."wireguard/privateKey".path;

      peers = [
        {
          publicKey = "eN2HaOfuECnmC07l9nS3TQyBKYP11H062W92EuspS1I=";
          allowedIPs = [ "172.20.0.1/24" ];
          endpoint = "g11s-ingress1.typej.parzival.space:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
