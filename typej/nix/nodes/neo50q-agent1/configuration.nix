{ config, lib, pkgs, ... }:
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  networking.hostName = "neo50q-agent1"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  networking.enableIPv6 = true;

  # configure firewall
  # 6443 - Kubernetes API server
  # 80 - HTTP
  # 443 - HTTPS
  # 8472 - Flannel VXLAN networking
  networking.firewall.allowedTCPPorts = [ 6443 80 443 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  sops.secrets."k3s/token" = { };
  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets."k3s/token".path;
    serverAddr = "https://pi5-master1.typej:6443";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
