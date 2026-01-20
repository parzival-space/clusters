{ config, lib, pkgs, ... }:
{
  imports = [
    ../common.nix

    ./hardware-rpi4.nix
    ./hardware-configuration.nix
  ];

  # Enables the generation of /boot/extlinux/extlinux.conf (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  networking.hostName = "pi4-agent3"; # Define your hostname.

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

  boot.kernelParams = [
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

  sops.secrets."k3s/token" = { };
  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets."k3s/token".path;
    serverAddr = "https://pi5-master1.typej:6443";
  };

  # configure openscsi
  environment.systemPackages = [ pkgs.nfs-utils ];
  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

