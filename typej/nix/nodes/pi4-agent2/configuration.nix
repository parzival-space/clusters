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

  networking.hostName = "pi4-agent2"; # Define your hostname.

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

